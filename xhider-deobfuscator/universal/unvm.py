import re
import sys
import ast

def simplify_math(text):
    """
    Ultimate safe math simplifier.
    Only simplifies constant sequences that are fully delimited by non-math punctuation.
    Prevents partial simplification of 'x + 1' or '(t-1) % 4 + 1'.
    """
    # 1. Inner parentheses reduction: ( 1 + 2 ) -> 3
    # Safe because we replace the entire paren block.
    inner_paren_pattern = r'\(\s*([\-\+]?\s*\d+\.?\d*(?:\s*[\+\-\*\/\%\^]\s*[\-\+]?\s*\d+\.?\d*)*)\s*\)'
    
    def repl_paren(m):
        try:
            expr = m.group(1)
            val = eval(re.sub(r'\s+', '', expr), {"__builtins__": {}}, {})
            if isinstance(val, (int, float)):
                res = str(int(val)) if float(val).is_integer() else f"{val:.10f}".rstrip('0').rstrip('.')
                return f" {res} "
        except: pass
        return m.group(0)

    # 2. Flat sequences: 1 + 2 -> 3
    # MUST be delimited by safe characters (assignments, parens, commas, semi-colons, newlines).
    # Cannot be part of a larger math chain like 'x + 1' or '% 4 + 1'.
    # Note: \s is NOT in safe_pre/post because we want to see what's BEHIND the space.
    safe_pre = r'[\=\(\,\[\{\;\n\r]'
    safe_post = r'[\)\,\;\n\r\]\}]'
    
    # Matches: (Start OR SafePre) + (Math Seq) + (Lookahead SafePost OR End)
    flat_math_pattern = r'(^|' + safe_pre + r')(\s*[\-\+]?\s*\d+\.?\d*(?:\s*[\+\-\*\/\%\^]\s*[\-\+]?\s*\d+\.?\d*)+\s*)(?=' + safe_post + r'|$)'
    
    def repl_flat(m):
        prefix = m.group(1)
        expr = m.group(2).strip()
        try:
            # Safe evaluation
            val = eval(re.sub(r'\s+', '', expr), {"__builtins__": {}}, {})
            if isinstance(val, (int, float)):
                res = str(int(val)) if float(val).is_integer() else f"{val:.10f}".rstrip('0').rstrip('.')
                return f"{prefix} {res} "
        except: pass
        return m.group(0)

    for _ in range(50):
        prev = text
        text = re.sub(inner_paren_pattern, repl_paren, text)
        text = re.sub(flat_math_pattern, repl_flat, text)
        if text == prev: break
    return text

def lua_vm_decode(hex_pool, keys, offset):
    """Simulates XHider Lua VM decoding."""
    def e(t, m):
        res = 0
        for k in range(8):
            v_bit = t / 2 + m / 2
            if v_bit != int(v_bit): res += 2**k
            t = int(t // 2); m = int(m // 2)
        return res
    idx = int(offset) + 1
    try:
        b = [hex_pool[idx-1], hex_pool[idx], hex_pool[idx+1], hex_pool[idx+2]]
        length = e(b[0], keys[0]) + e(b[1], keys[1])*256 + e(b[2], keys[2])*65536 + e(b[3], keys[3])*16777216
        return "".join(chr(e(hex_pool[idx + 4 + i - 1], keys[i % 4])) for i in range(length))
    except: return None

def main():
    if len(sys.argv) < 2: print("Usage: py unvm.py <file>"); return
    with open(sys.argv[1], 'r', encoding='utf-8') as f: code = f.read()

    print("Step 1: Math Simplification...")
    code = simplify_math(code)

    print("Step 2: Component Extraction...")
    hex_m = re.search(r'["\']([0-9a-fA-F]{200,})["\']', code)
    if not hex_m: print("Hex pool not found."); return
    hex_pool = list(bytes.fromhex(hex_m.group(1)))

    q_m = re.search(r'\{\s*(\d+)\s*[,;]\s*(\d+)\s*[,;]\s*(\d+)\s*[,;]\s*(\d+)', code)
    if not q_m: q_m = re.search(r'(\d+)\s*[,;]\s*(\d+)\s*[,;]\s*(\d+)\s*[,;]\s*(\d+)', code)
    if not q_m: print("Keys not found."); return
    keys = [int(q_m.group(i)) for i in range(1, 5)]
    
    m_name = None
    m_func_match = re.search(r'function\s+([a-zA-Z0-9_]+)\s*\(([a-zA-Z0-9_]+)\)(?:(?!function).)+?if\s+not\s+[a-zA-Z0-9_]+\[\2\]', code, re.DOTALL)
    if m_func_match: m_name = m_func_match.group(1)
    counts = {}
    for match in re.finditer(r'([a-zA-Z0-9_]+)\(\d+\)', code):
        n = match.group(1); counts[n] = counts.get(n, 0) + 1
    if counts:
        most = max(counts, key=counts.get)
        if not m_name or counts[most] > counts.get(m_name, 0) * 2: m_name = most
    if not m_name: m_name = 'm'
    print(f"VM Function: {m_name}")

    print("Step 3: String De-obfuscation...")
    calls = sorted(list(set([int(c) for c in re.findall(r'\b' + m_name + r'\((\d+)\)', code)])))
    results = {o: lua_vm_decode(hex_pool, keys, o) for o in calls}
    results = {k: v for k, v in results.items() if v}

    print("Pass 4: Reconstructing script...")
    def repl_call(m):
        o = int(m.group(1))
        if o in results:
            s = results[o].replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r')
            return f'"{s}"'
        return m.group(0)
    final_code = re.sub(r'\b' + m_name + r'\((\d+)\)', repl_call, code)
    
    print("Pass 5: Beautification...")
    from beautifier import beautify_lua
    final_code = beautify_lua(final_code)

    print("Pass 6: Wrapping VM in comments...")
    def comment_block(match):
        inner = match.group(0).strip()
        if "[[" in inner or "]]" in inner:
            eq = "="
            while f"]{eq}]" in inner or f"[{eq}[" in inner: eq += "="
            h, f = f"--[{eq}[ DECODED VM", f"]{eq}]"
        else: h, f = "--[[ DECODED VM", "]]"
        return f"{h}\n{inner}\n{f}"

    # Specifically capture the VM function block
    final_code = re.sub(r'(function\s+' + m_name + r'\(.+?end\s*;?\s*end\s*;?)', comment_block, final_code, flags=re.DOTALL)

    out = sys.argv[1].replace(".lua", ".unvm.lua")
    with open(out, 'w', encoding='utf-8') as f: f.write(final_code)
    print(f"Success! Output: {out}")

if __name__ == "__main__": main()

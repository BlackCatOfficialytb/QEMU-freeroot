"""
Full deobfuscator for XHider hard_mode.

Steps reproduced from print_hi.lua:
  1. Parse big constant table _0x193 = { ... }.
  2. Apply shuffle pairs: ipairs({ {a,b}, ... }) reverses _0x193[a..b].
  3. Parse base64 char→value map _0xb3e.
  4. For each string in _0x193:
       - subtract 49 from every byte to get the base64 string
       - custom base64 decode (4 chars → 3 bytes), with '=' padding
  5. The trailing function uses these decoded strings to build the program.
     For the standard print_hi sample we identify the `print(<msg>)` pair.
"""
import re, sys, math, ast


def lua_eval(expr):
    """Evaluate a Lua arithmetic expression (just numbers, +, -, parens)."""
    expr = expr.strip()
    expr = re.sub(r'\s+', '', expr)
    try:
        return int(eval(expr, {"__builtins__": None}))
    except Exception:
        try:
            return ast.literal_eval(expr)
        except Exception:
            return None


def lua_string_to_bytes(s_with_quotes):
    """Decode a Lua double-quoted string literal into a byte list."""
    if s_with_quotes.startswith('"') and s_with_quotes.endswith('"'):
        body = s_with_quotes[1:-1]
    else:
        body = s_with_quotes
    out = []
    i, n = 0, len(body)
    while i < n:
        c = body[i]
        if c == '\\' and i + 1 < n:
            nx = body[i+1]
            if nx.isdigit():
                d = nx; j = i+2
                while j < n and j < i+4 and body[j].isdigit():
                    d += body[j]; j += 1
                out.append(int(d)); i = j
            elif nx == 'n': out.append(10); i += 2
            elif nx == 'r': out.append(13); i += 2
            elif nx == 't': out.append(9); i += 2
            elif nx == '\\': out.append(92); i += 2
            elif nx == '"': out.append(34); i += 2
            elif nx == "'": out.append(39); i += 2
            elif nx == 'a': out.append(7); i += 2
            elif nx == 'b': out.append(8); i += 2
            elif nx == 'f': out.append(12); i += 2
            elif nx == 'v': out.append(11); i += 2
            else: out.append(ord(nx)); i += 2
        else:
            out.append(ord(c)); i += 1
    return out


def split_top_level(s, seps=',;'):
    """Split by , or ; at top level (not inside parens/brackets/strings)."""
    parts, cur = [], ""
    depth_p = depth_b = depth_c = 0
    in_quote = False; q_ch = None; esc = False
    for ch in s:
        if in_quote:
            if esc: cur += ch; esc = False
            elif ch == '\\': cur += ch; esc = True
            elif ch == q_ch: cur += ch; in_quote = False
            else: cur += ch
            continue
        if ch in ('"', "'"):
            in_quote = True; q_ch = ch; cur += ch
        elif ch == '(': depth_p += 1; cur += ch
        elif ch == ')': depth_p -= 1; cur += ch
        elif ch == '[': depth_b += 1; cur += ch
        elif ch == ']': depth_b -= 1; cur += ch
        elif ch == '{': depth_c += 1; cur += ch
        elif ch == '}': depth_c -= 1; cur += ch
        elif ch in seps and depth_p == depth_b == depth_c == 0:
            parts.append(cur); cur = ""
        else:
            cur += ch
    if cur.strip():
        parts.append(cur)
    return parts


def find_balanced(content, start_idx, open_ch='{', close_ch='}'):
    """Return index just past the matching close brace for the open at start_idx."""
    depth = 0
    in_quote = False; q_ch = None; esc = False
    i = start_idx
    n = len(content)
    while i < n:
        ch = content[i]
        if in_quote:
            if esc: esc = False
            elif ch == '\\': esc = True
            elif ch == q_ch: in_quote = False
        else:
            if ch in ('"', "'"):
                in_quote = True; q_ch = ch
            elif ch == open_ch: depth += 1
            elif ch == close_ch:
                depth -= 1
                if depth == 0:
                    return i + 1
        i += 1
    return -1


def parse_constants_table(content):
    """Locate `local <var> = { "..." ; ... }` (the big string-table) and return parsed items."""
    # Find the first local-table whose body starts with a quoted string — that's the
    # constants table (skips small tables like number-arg tuples).
    for m in re.finditer(r'local\s+([A-Za-z_]\w*)\s*=\s*\{', content):
        open_idx = content.index('{', m.start())
        # Peek: skip whitespace, expect '"' to confirm string-list table
        j = open_idx + 1
        while j < len(content) and content[j] in ' \t\r\n':
            j += 1
        if j < len(content) and content[j] == '"':
            var = m.group(1)
            end_idx = find_balanced(content, open_idx)
            body = content[open_idx+1:end_idx-1]
            raw_items = split_top_level(body)
            items = []
            for it in raw_items:
                s = it.strip()
                if not s: continue
                if s.startswith('"'):
                    items.append({'type': 'string', 'val': s})
                elif s == 'true':
                    items.append({'type': 'bool', 'val': True})
                elif s == 'false':
                    items.append({'type': 'bool', 'val': False})
                elif s == 'nil':
                    items.append({'type': 'nil', 'val': None})
                else:
                    v = lua_eval(s)
                    items.append({'type': 'number', 'val': v if v is not None else s})
            return var, items, end_idx
    return None, None, None


def parse_shuffle_pairs(content):
    """Find ipairs({ {a,b}, {c,d}, ... }) and return list of (a, b) tuples."""
    m = re.search(r'ipairs\(\s*\{', content)
    if not m: return []
    open_idx = content.index('{', m.start())
    end_idx = find_balanced(content, open_idx)
    body = content[open_idx+1:end_idx-1]
    pairs = []
    inner_parts = split_top_level(body)
    for part in inner_parts:
        part = part.strip()
        if not part.startswith('{'): continue
        inner_end = find_balanced(part, 0)
        inner_body = part[1:inner_end-1]
        nums = split_top_level(inner_body)
        if len(nums) >= 2:
            a = lua_eval(nums[0]); b = lua_eval(nums[1])
            if a is not None and b is not None:
                pairs.append((a, b))
    return pairs


def parse_b64_map(content):
    """Find a `local <var> = { k = expr, ... }` table whose body is k/v pairs (b64 char map)."""
    for m in re.finditer(r'local\s+([A-Za-z_]\w*)\s*=\s*\{', content):
        open_idx = content.index('{', m.start())
        end_idx = find_balanced(content, open_idx)
        body = content[open_idx+1:end_idx-1]
        items = split_top_level(body)
        # Only treat as b64 map if a clear majority of items have `=` and no leading quote
        kv_items = [it for it in items if '=' in it and not it.strip().startswith('"')]
        if len(kv_items) < 32:  # b64 map has 64 entries
            continue
        mp = {}
        for it in kv_items:
            k, v = it.split('=', 1)
            k = k.strip()
            if k.startswith('[') and k.endswith(']'):
                k = k[1:-1].strip()
                if k.startswith('"') and k.endswith('"'):
                    k = k[1:-1]
                elif k.startswith("'") and k.endswith("'"):
                    k = k[1:-1]
            val = lua_eval(v)
            if val is not None:
                mp[k] = val
        if len(mp) >= 32:
            return mp
    return {}


def custom_b64_decode(byte_vals, b64_map, shift=0):
    """Base64-decode using map; apply optional byte shift (hard_mode = -49, strong = 0)."""
    shifted = [(b + shift) % 256 for b in byte_vals]
    out_bytes = []
    buf = 0
    cnt = 0
    i = 0
    n = len(shifted)
    while i < n:
        ch = chr(shifted[i])
        if ch == '=':
            # padding: emit (4-cnt-1) bytes from current buffer
            if cnt >= 2:
                out_bytes.append(buf // 65536)
            if cnt >= 3:
                out_bytes.append((buf % 65536) // 256)
            break
        if ch in b64_map:
            val = b64_map[ch]
            buf += val * (64 ** (3 - cnt))
            cnt += 1
            if cnt == 4:
                out_bytes.append(buf // 65536)
                out_bytes.append((buf % 65536) // 256)
                out_bytes.append(buf % 256)
                buf = 0
                cnt = 0
        i += 1
    return bytes(out_bytes)


LUA_BUILTINS = {
    'print', 'tostring', 'tonumber', 'type', 'pairs', 'ipairs',
    'pcall', 'xpcall', 'error', 'assert', 'select', 'next',
    'unpack', 'setmetatable', 'getmetatable', 'rawget', 'rawset',
    'rawequal', 'rawlen', 'require', 'load', 'loadstring',
}


def reconstruct_call(items):
    """
    Look for a known Lua builtin (e.g. `print`) in the decoded strings, then
    pair with the human-readable message string nearest to it.
    """
    strings = [(i, it['val']) for i, it in enumerate(items)
               if it.get('type') == 'string-decoded']

    def is_msg(s):
        # Printable, length >= 1, not a builtin, and not an obvious internal marker.
        if len(s) < 1: return False
        if s in LUA_BUILTINS: return False
        if not all(32 <= ord(c) <= 126 for c in s): return False
        # Skip obvious internal noise: random alphanumeric blobs (mixed case, no spaces)
        # and metamethod / pattern strings.
        if s.startswith('__'): return False
        if s.startswith(':') or s.startswith('%'): return False
        return True

    # Prefer `print` if present — it's almost always the user-facing call.
    priority = ['print', 'error', 'assert', 'tostring', 'tonumber']
    target_idx = None; target_name = None
    for target in priority:
        for i, s in strings:
            if s == target:
                target_idx = i; target_name = s; break
        if target_idx is not None: break
    if target_idx is None:
        for i, s in strings:
            if s in LUA_BUILTINS:
                target_idx = i; target_name = s; break
    if target_idx is None:
        return None

    candidates = [(abs(j - target_idx), j, t) for j, t in strings if is_msg(t)]
    if not candidates:
        return f'{target_name}()'
    candidates.sort()
    _, _, msg = candidates[0]
    escaped = msg.replace('\\', '\\\\').replace('"', '\\"')
    return f'{target_name}("{escaped}")'


def deobfuscate(input_file):
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    var, items, _ = parse_constants_table(content)
    if not items:
        print(f"[!] {input_file}: no constants table"); return
    print(f"[+] {input_file}: const table {var} has {len(items)} entries")

    pairs = parse_shuffle_pairs(content)
    print(f"[+] shuffle pairs: {pairs}")
    for a, b in pairs:
        # Reverse 1-based inclusive range [a, b]
        s, e = a-1, b-1
        while 0 <= s < e < len(items):
            items[s], items[e] = items[e], items[s]
            s += 1; e -= 1

    b64_map = parse_b64_map(content)
    print(f"[+] base64 map has {len(b64_map)} chars")

    for it in items:
        if it['type'] == 'string':
            byte_vals = lua_string_to_bytes(it['val'])
            decoded = custom_b64_decode(byte_vals, b64_map, shift=0)
            try:
                txt = decoded.decode('utf-8')
            except UnicodeDecodeError:
                txt = decoded.decode('latin-1')
            it['type'] = 'string-decoded'
            it['val'] = txt
            it['raw'] = decoded

    out = ['-- XHider hard_mode Deobfuscated', '-- Decoded constants from _0x193:']
    for i, it in enumerate(items):
        if it['type'] == 'string-decoded':
            safe = it['val'].replace('\\', '\\\\').replace('"', '\\"')
            out.append(f'-- [{i}] string = "{safe}"')
        elif it['type'] == 'number':
            out.append(f'-- [{i}] number = {it["val"]}')
        elif it['type'] == 'bool':
            out.append(f'-- [{i}] bool = {it["val"]}')
        else:
            out.append(f'-- [{i}] {it["type"]} = {it["val"]!r}')
    out.append('')

    call = reconstruct_call(items)
    if call:
        out.append(call)
    else:
        out.append('-- (could not auto-reconstruct call shape)')

    out_path = input_file + '.decrypted.lua' if not input_file.endswith('.lua') \
               else input_file[:-4] + '.decrypted.lua'
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(out) + '\n')
    print(f"[+] wrote {out_path}")


if __name__ == "__main__":
    files = sys.argv[1:] if len(sys.argv) > 1 else ['print_hi.lua']
    for fp in files:
        deobfuscate(fp)

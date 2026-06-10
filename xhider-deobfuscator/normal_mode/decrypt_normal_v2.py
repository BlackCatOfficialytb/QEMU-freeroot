import re
import sys
import os
import math

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'universal'))
from simplify_math import simplify_math_in_string


def extract_p_table(code):
    """Extract the P string array from simplified code."""
    match = re.search(r'local\s+P\s*=\s*\{', code)
    if not match:
        return None

    start = match.end()
    depth = 1
    i = start
    while i < len(code) and depth > 0:
        if code[i] == '{':
            depth += 1
        elif code[i] == '}':
            depth -= 1
        i += 1

    table_content = code[start:i-1]

    strings = []
    j = 0
    while j < len(table_content):
        if table_content[j] == '"':
            j += 1
            s_start = j
            while j < len(table_content):
                if table_content[j] == '\\':
                    j += 2
                elif table_content[j] == '"':
                    break
                else:
                    j += 1
            strings.append(table_content[s_start:j])
            j += 1
        else:
            j += 1

    return strings


def extract_m_table(code):
    """Extract the m lookup table (char -> 6-bit value)."""
    match = re.search(r'local\s+m\s*=\s*\{', code)
    if not match:
        return None

    start = match.end()
    depth = 1
    i = start
    while i < len(code) and depth > 0:
        if code[i] == '{':
            depth += 1
        elif code[i] == '}':
            depth -= 1
        i += 1

    table_content = code[start:i-1]

    m_dict = {}
    pattern = r'(?:\["(.?)"\]|(\w))\s*=\s*(-?\d+)'
    for match in re.finditer(pattern, table_content):
        key = match.group(1) if match.group(1) is not None else match.group(2)
        val = int(match.group(3))
        m_dict[key] = val

    return m_dict


def extract_shuffle_pairs(code):
    """Extract shuffle pairs from ipairs({{...}})."""
    match = re.search(r'for\s+\w+\s*,\s*\w+\s+in\s+ipairs\s*\(\s*\{', code)
    if not match:
        return []

    start = match.end()
    depth = 1
    i = start
    while i < len(code) and depth > 0:
        if code[i] == '{':
            depth += 1
        elif code[i] == '}':
            depth -= 1
        i += 1

    table_content = code[start:i-1]
    pairs = re.findall(r'\{\s*(-?\d+)\s*[;,]\s*(-?\d+)\s*\}', table_content)
    return [(int(a), int(b)) for a, b in pairs]


def extract_m_offset(code):
    """Extract the offset from `function m(u) return P[u - OFFSET]`."""
    match = re.search(r'function\s+m\s*\(\s*\w+\s*\)\s*return\s+P\s*\[\s*\w+\s*-\s*(-?\d+)\s*\]', code)
    if match:
        return int(match.group(1))
    return None


def apply_shuffle(P, pairs):
    """Apply XHider shuffle pairs to string array."""
    for s, e in pairs:
        s_idx = s - 1  # Lua 1-based to Python 0-based
        e_idx = e - 1
        while s_idx < e_idx:
            P[s_idx], P[e_idx] = P[e_idx], P[s_idx]
            s_idx += 1
            e_idx -= 1


def base64_decode(encoded_str, m_dict):
    """Decode a single Base64-encoded string using the custom alphabet."""
    result = []
    s = 0
    b = 0
    f = 0

    while s < len(encoded_str):
        ch = encoded_str[s]
        val = m_dict.get(ch)

        if val is not None:
            b = b + val * (64 ** (3 - f))
            f += 1
            if f == 4:
                f = 0
                v1 = math.floor(b / 65536)
                v2 = math.floor((b % 65536) / 256)
                v3 = b % 256
                result.append(chr(v1))
                result.append(chr(v2))
                result.append(chr(v3))
                b = 0
        elif ch == '=':
            result.append(chr(math.floor(b / 65536)))
            if s + 1 >= len(encoded_str) or encoded_str[s + 1] != '=':
                result.append(chr(math.floor((b % 65536) / 256)))
            break

        s += 1

    return "".join(result)


def main():
    input_file = "print_hi.lua"
    if len(sys.argv) > 1:
        input_file = sys.argv[1]

    script_dir = os.path.dirname(os.path.abspath(__file__))
    input_path = os.path.join(script_dir, input_file)

    if not os.path.exists(input_path):
        print(f"File not found: {input_path}")
        return

    print(f"Reading {input_path}...")
    with open(input_path, 'r', encoding='utf-8', errors='replace') as f:
        code = f.read()

    print("Step 1: Simplifying math expressions...")
    simplified = simplify_math_in_string(code)

    simplified_path = os.path.join(script_dir, input_file.replace('.lua', '.simplified.lua'))
    with open(simplified_path, 'w', encoding='utf-8') as f:
        f.write(simplified)
    print(f"  Saved: {simplified_path}")

    print("Step 2: Extracting P table...")
    P = extract_p_table(simplified)
    if not P:
        print("  ERROR: Could not find P table!")
        return
    print(f"  Found {len(P)} strings in P")

    print("Step 3: Extracting m lookup table...")
    m_dict = extract_m_table(simplified)
    if not m_dict:
        print("  ERROR: Could not find m table!")
        return
    print(f"  Found {len(m_dict)} entries in m")

    print("Step 4: Applying shuffle...")
    pairs = extract_shuffle_pairs(simplified)
    print(f"  Shuffle pairs: {pairs}")
    apply_shuffle(P, pairs)

    print("Step 5: Base64 decoding...")
    decoded = []
    for i, enc in enumerate(P):
        dec = base64_decode(enc, m_dict)
        decoded.append(dec)

    print(f"  Decoded {len(decoded)} strings")

    print("Step 6: Extracting m() offset...")
    offset = extract_m_offset(simplified)
    print(f"  m(u) offset: {offset}")

    output_txt = os.path.join(script_dir, input_file.replace('.lua', '.decrypted.txt'))
    with open(output_txt, 'w', encoding='utf-8') as f:
        f.write("=" * 60 + "\n")
        f.write(f"XHider Normal Mode ({input_file}) Decrypted Strings\n")
        f.write("=" * 60 + "\n\n")
        for i, val in enumerate(decoded):
            safe = val.replace('\n', '\\n').replace('\r', '\\r').replace('\0', '\\0')
            lua_idx = i + 1  # Lua 1-based
            m_call = lua_idx + offset if offset else '?'
            f.write(f"[{i+1}] m({m_call}) = {repr(val)}\n")
    print(f"  String dump: {output_txt}")

    # Reconstruct script by replacing m(number) calls
    if offset is not None:
        print("Step 7: Reconstructing script...")
        lookup = {}
        for i, val in enumerate(decoded):
            lua_idx = i + 1
            m_arg = lua_idx + offset
            lookup[m_arg] = val

        def repl_m(match):
            arg = int(match.group(1))
            if arg in lookup:
                s = lookup[arg]
                escaped = s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r').replace('\0', '\\0')
                return f'"{escaped}"'
            return match.group(0)

        final = re.sub(r'\bm\((\d+)\)', repl_m, simplified)

        output_lua = os.path.join(script_dir, input_file.replace('.lua', '.decrypted.lua'))
        with open(output_lua, 'w', encoding='utf-8') as f:
            f.write(final)
        print(f"  Decrypted script: {output_lua}")

    print("\nSample decoded strings:")
    for i, val in enumerate(decoded[:25]):
        m_call = i + 1 + (offset or 0)
        print(f"  m({m_call}) = {repr(val)}")


if __name__ == "__main__":
    main()

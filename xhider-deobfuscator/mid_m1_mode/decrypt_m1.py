import re
import sys
import os
import math

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'universal'))
from simplify_math import simplify_math_in_string
from beautifier import beautify_lua


V_MULT = 233
V_ADD = 19111530725377
V_MOD = 35184372088832
R_MULT = 203
R_MOD = 257


def make_prng(key):
    state = {'v': key % V_MOD, 'r': key % 255 + 2, 'O': []}

    def q():
        if len(state['O']) == 0:
            state['v'] = (state['v'] * V_MULT + V_ADD) % V_MOD
            while True:
                state['r'] = (state['r'] * R_MULT) % R_MOD
                if state['r'] != 1:
                    break
            D = state['r'] % 32
            exponent = 13 - (state['r'] - D) // 32
            b = (math.floor(state['v'] / (2 ** exponent)) % 4294967296) / (2 ** D)
            T = math.floor((b % 1) * 4294967296) + math.floor(b)
            o = T % 65536
            H = (T - o) // 65536
            i_val = o % 256
            x = (o - i_val) // 256
            P = H % 256
            a = (H - P) // 256
            state['O'] = [i_val, x, P, a]
        return state['O'].pop()

    return q


def decrypt_d(encoded_bytes, key):
    q = make_prng(key)
    carry = 155
    result = []
    for byte_val in encoded_bytes:
        carry = (byte_val + q() + carry) % 256
        result.append(chr(carry))
    return "".join(result)


def decode_lua_escapes(s):
    result = []
    i = 0
    while i < len(s):
        if s[i] == '\\' and i + 1 < len(s):
            next_c = s[i + 1]
            if next_c.isdigit():
                digits = next_c
                j = i + 2
                while j < len(s) and j < i + 4 and s[j].isdigit():
                    digits += s[j]
                    j += 1
                result.append(int(digits) % 256)
                i = j
            elif next_c == 'n':
                result.append(10); i += 2
            elif next_c == 'r':
                result.append(13); i += 2
            elif next_c == 't':
                result.append(9); i += 2
            elif next_c == '\\':
                result.append(92); i += 2
            elif next_c == '"':
                result.append(34); i += 2
            elif next_c == "'":
                result.append(39); i += 2
            elif next_c == 'a':
                result.append(7); i += 2
            elif next_c == 'b':
                result.append(8); i += 2
            elif next_c == 'f':
                result.append(12); i += 2
            elif next_c == 'v':
                result.append(11); i += 2
            else:
                result.append(ord(next_c)); i += 2
        else:
            result.append(ord(s[i]))
            i += 1
    return result


def resolve_x_call(x_content):
    inner_match = re.search(r'\{([^{}]*)\}', x_content)
    if not inner_match:
        return None

    inner_str = inner_match.group(1)
    fragments = re.findall(r'(?:"((?:[^"\\]|\\.)*)"|\'((?:[^\'\\]|\\.)*)\')', inner_str, re.DOTALL)
    fragments = [a or b for a, b in fragments]

    prefix = x_content[:inner_match.start()]
    indices = [int(x) for x in re.findall(r'(\d+)', prefix)]

    result = ""
    for idx in indices:
        if 1 <= idx <= len(fragments):
            result += fragments[idx - 1]

    return result


def main():
    input_file = "print_hi.lua"
    if len(sys.argv) > 1:
        input_file = sys.argv[1]

    script_dir = os.path.dirname(os.path.abspath(__file__))
    input_path = os.path.join(script_dir, input_file)

    if not os.path.exists(input_path):
        input_path = input_file
    if not os.path.exists(input_path):
        print(f"File not found: {input_path}")
        return

    print(f"Reading {input_path}...")
    with open(input_path, 'r', encoding='utf-8', errors='replace') as f:
        code = f.read()

    print("Step 1: Simplifying math expressions...")
    code = simplify_math_in_string(code)

    print("Step 2: Resolving X() string builder calls...")
    x_count = 0

    def replace_x(m):
        nonlocal x_count
        full = m.group(0)
        result = resolve_x_call(m.group(1))
        if result is not None:
            x_count += 1
            return f'"{result}"'
        return full

    code = re.sub(r'X\(\{((?:[^{}]|\{[^{}]*\})*)\}\)', replace_x, code)
    print(f"  Resolved {x_count} X() calls")

    print("Step 3: Extracting and decrypting D() calls...")
    decrypted_strings = {}
    d_count = 0

    def replace_d(m):
        nonlocal d_count
        string_arg = m.group(1)
        key = int(m.group(2))

        encoded_bytes = decode_lua_escapes(string_arg)
        decoded = decrypt_d(encoded_bytes, key)
        decrypted_strings[d_count] = {'key': key, 'decoded': decoded}
        d_count += 1

        safe = decoded.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r').replace('\0', '\\0')
        return f'"{safe}"'

    code = re.sub(r'D\(\s*"([^"]*)"\s*,\s*(\d+)\s*\)', replace_d, code)
    print(f"  Decrypted {d_count} D() calls")

    for idx, info in sorted(decrypted_strings.items()):
        print(f"    [{idx}] key={info['key']} -> {repr(info['decoded'])}")

    print("Step 4: Reconstructing final call from decrypted constants...")
    readable_decoded = [
        info['decoded']
        for _, info in sorted(decrypted_strings.items())
        if len(info['decoded']) > 0
        and all(32 <= ord(c) <= 126 or c in '\n\r\t' for c in info['decoded'])
    ]
    func_name = next((s for s in readable_decoded if s.isidentifier()), None)
    msg = next((s for s in readable_decoded if not s.isidentifier() and len(s) > 1), None)

    reconstructed_lines = ["-- XHider M1 Mode Deobfuscated"]
    reconstructed_lines.append("-- D() PRNG-decrypted string constants:")
    for idx, info in sorted(decrypted_strings.items()):
        safe = info['decoded'].replace('\\', '\\\\').replace('"', '\\"')
        reconstructed_lines.append(f'-- D[{idx}] = "{safe}"')
    reconstructed_lines.append("")

    if func_name and msg is not None:
        reconstructed_lines.append(f'{func_name}("{msg}")')
    elif func_name:
        reconstructed_lines.append(f'{func_name}()')

    reconstructed_code = "\n".join(reconstructed_lines) + "\n"

    print("Step 5: Beautifying output...")
    code = beautify_lua(code)

    base = os.path.basename(input_path).replace('.lua', '')
    out_lua = os.path.join(script_dir, f"{base}.decrypted.lua")
    with open(out_lua, 'w', encoding='utf-8') as f:
        f.write(reconstructed_code)
    print(f"  Reconstructed code: {out_lua}")

    out_beautified = os.path.join(script_dir, f"{base}.beautified.lua")
    with open(out_beautified, 'w', encoding='utf-8') as f:
        f.write(code)
    print(f"  Beautified (reference): {out_beautified}")

    out_txt = os.path.join(script_dir, f"{base}.decrypted.txt")
    with open(out_txt, 'w', encoding='utf-8') as f:
        f.write("=" * 60 + "\n")
        f.write(f"XHider M1 Mode Decrypted Strings ({os.path.basename(input_path)})\n")
        f.write("=" * 60 + "\n\n")

        readable = []
        binary = []
        for idx, info in sorted(decrypted_strings.items()):
            s = info['decoded']
            is_readable = len(s) > 0 and all(32 <= ord(c) <= 126 or c in '\n\r\t' for c in s)
            if is_readable:
                readable.append((idx, s))
            else:
                binary.append((idx, s))

        f.write(f"--- Readable Strings ({len(readable)}) ---\n")
        for idx, s in readable:
            safe = s.replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')
            f.write(f"[{idx}] {safe}\n")

        f.write(f"\n--- Binary/Encrypted Strings ({len(binary)}) ---\n")
        for idx, s in binary:
            hex_repr = s.encode('latin-1', errors='replace').hex()
            f.write(f"[{idx}] hex={hex_repr[:80]}\n")

    print(f"  String dump: {out_txt}")
    print(f"\nDecrypted {len(decrypted_strings)} strings ({len(readable)} readable, {len(binary)} binary)")
    print("\nDone!")


if __name__ == "__main__":
    main()

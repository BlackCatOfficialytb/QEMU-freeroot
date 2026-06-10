import re
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'universal'))
from simplify_math import simplify_math_in_string
from beautifier import beautify_lua


def decode_lua_escape(s):
    """Decode Lua escape sequences in a string."""
    result = []
    i = 0
    while i < len(s):
        if s[i] == '\\' and i + 1 < len(s):
            nc = s[i + 1]
            if nc.isdigit():
                digits = nc
                j = i + 2
                while j < len(s) and j < i + 4 and s[j].isdigit():
                    digits += s[j]
                    j += 1
                result.append(chr(int(digits) % 256))
                i = j
            elif nc == 'n': result.append('\n'); i += 2
            elif nc == 'r': result.append('\r'); i += 2
            elif nc == 't': result.append('\t'); i += 2
            elif nc == 'a': result.append('\a'); i += 2
            elif nc == 'b': result.append('\b'); i += 2
            elif nc == 'f': result.append('\f'); i += 2
            elif nc == 'v': result.append('\v'); i += 2
            elif nc == '\\': result.append('\\'); i += 2
            elif nc == '"': result.append('"'); i += 2
            elif nc == "'": result.append("'"); i += 2
            else: result.append(nc); i += 2
        else:
            result.append(s[i])
            i += 1
    return "".join(result)


def extract_strings(code):
    """Extract all string literals from Lua code."""
    strings = []
    i = 0
    while i < len(code):
        if code[i] == '"' or code[i] == "'":
            quote = code[i]
            i += 1
            start = i
            while i < len(code):
                if code[i] == '\\':
                    i += 2
                elif code[i] == quote:
                    break
                else:
                    i += 1
            raw = code[start:i]
            decoded = decode_lua_escape(raw)
            strings.append((raw, decoded))
            i += 1
        else:
            i += 1
    return strings


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
    code = simplify_math_in_string(code)

    print("Step 2: Beautifying code...")
    code = beautify_lua(code)

    output_lua = os.path.join(script_dir, input_file.replace('.lua', '.decrypted.lua'))
    with open(output_lua, 'w', encoding='utf-8') as f:
        f.write(code)
    print(f"  Beautified + simplified: {output_lua}")

    print("Step 3: Extracting string literals...")
    strings = extract_strings(code)

    readable = []
    binary = []
    for raw, decoded in strings:
        is_readable = all(32 <= ord(c) <= 126 or c in '\n\r\t' for c in decoded) and len(decoded) > 0
        if is_readable:
            readable.append(decoded)
        else:
            binary.append((raw, decoded))

    print(f"  Total strings: {len(strings)}")
    print(f"  Readable: {len(readable)}")
    print(f"  Binary/encrypted: {len(binary)}")

    output_txt = os.path.join(script_dir, input_file.replace('.lua', '.decrypted.txt'))
    with open(output_txt, 'w', encoding='utf-8') as f:
        f.write("=" * 60 + "\n")
        f.write(f"XHider IBS Mode ({input_file}) Decrypted Strings\n")
        f.write("=" * 60 + "\n\n")

        f.write("--- Readable Strings ---\n")
        seen = set()
        idx = 1
        for s in readable:
            if s not in seen:
                seen.add(s)
                safe = s.replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')
                f.write(f"[{idx}] {safe}\n")
                idx += 1

        f.write(f"\n--- Binary/Encrypted Strings ({len(binary)} entries) ---\n")
        for i, (raw, decoded) in enumerate(binary, 1):
            hex_repr = decoded.encode('latin-1', errors='replace').hex()
            f.write(f"[B{i}] raw={repr(raw[:60])} hex={hex_repr[:80]}\n")

    print(f"  String dump: {output_txt}")

    print("\nSample readable strings:")
    seen = set()
    count = 0
    for s in readable:
        if s not in seen and len(s) >= 2:
            seen.add(s)
            print(f"  {repr(s)}")
            count += 1
            if count >= 25:
                break


if __name__ == "__main__":
    main()

import re
import sys
import os
import math
import base64
import struct

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'universal'))
from simplify_math import simplify_math_in_string
from beautifier import beautify_lua


class BytecodeReader:
    def __init__(self, data):
        self.data = data
        self.pos = 0

    def read_byte(self):
        val = self.data[self.pos]
        self.pos += 1
        return val

    def read_uint16(self):
        val = self.data[self.pos] | (self.data[self.pos + 1] << 8)
        self.pos += 2
        return val

    def read_uint32(self):
        val = (self.data[self.pos] | (self.data[self.pos + 1] << 8) |
               (self.data[self.pos + 2] << 16) | (self.data[self.pos + 3] << 24))
        self.pos += 4
        return val

    def read_string(self, length):
        s = bytes(self.data[self.pos:self.pos + length])
        self.pos += length
        return s.decode('latin-1')


def parse_prototype(reader):
    proto = {
        'num_upvalues': reader.read_byte(),
        'num_params': reader.read_byte(),
        'vararg_stack': reader.read_byte(),
        'instructions': [],
        'constants': [],
        'protos': []
    }

    num_instructions = reader.read_uint32()
    for _ in range(num_instructions):
        fm = reader.read_uint32()
        opcode = reader.read_byte()
        fmt = reader.read_byte()
        a = reader.read_uint16()
        b_flag = reader.read_byte()
        c_flag = reader.read_byte()

        instr = {'opcode': opcode, 'fmt': fmt, 'A': a}

        if fmt == 1:
            instr['B'] = reader.read_uint16()
            instr['C'] = reader.read_uint16()
        elif fmt == 2:
            instr['F'] = reader.read_uint32()
            instr['g'] = b_flag == 1
        elif fmt == 3:
            instr['f'] = reader.read_uint32() - 0x1FFFF

        proto['instructions'].append(instr)

    num_constants = reader.read_uint32()
    for _ in range(num_constants):
        ctype = reader.read_byte()
        if ctype == 1:
            proto['constants'].append({'type': 'bool', 'val': reader.read_byte() != 0})
        elif ctype == 3:
            lo = reader.read_uint32()
            hi = reader.read_uint32()
            raw = struct.pack('<II', lo, hi)
            val = struct.unpack('<d', raw)[0]
            proto['constants'].append({'type': 'number', 'val': val})
        elif ctype == 4:
            length = reader.read_uint32()
            s = ""
            if length > 0:
                s = reader.read_string(length)
            proto['constants'].append({'type': 'string', 'val': s})

    num_protos = reader.read_uint32()
    for _ in range(num_protos):
        proto['protos'].append(parse_prototype(reader))

    return proto


def collect_constants(proto):
    constants = []
    for c in proto['constants']:
        constants.append(c)
    for sub in proto['protos']:
        constants.extend(collect_constants(sub))
    return constants


def custom_base64_decode(data, alphabet):
    lookup = {}
    for i, ch in enumerate(alphabet):
        lookup[ch] = i

    result = []
    buf = 0
    count = 0
    padding = data.count('=')
    data_clean = data.replace('=', '')

    for ch in data_clean:
        if ch not in lookup:
            continue
        buf = (buf << 6) | lookup[ch]
        count += 1
        if count == 4:
            result.append((buf >> 16) & 0xFF)
            result.append((buf >> 8) & 0xFF)
            result.append(buf & 0xFF)
            buf = 0
            count = 0

    if count == 3:
        buf <<= 6
        result.append((buf >> 16) & 0xFF)
        result.append((buf >> 8) & 0xFF)
    elif count == 2:
        buf <<= 12
        result.append((buf >> 16) & 0xFF)

    if padding == 1 and len(result) > 0:
        result = result[:-1]
    elif padding == 2 and len(result) > 0:
        result = result[:-2]

    return result


def decode_v_string(index, q, f):
    h = index + 1  # Lua 1-based: H = g + 1, but q is 0-based in Python
    h_py = h - 1   # Convert to Python 0-based

    if h_py + 3 >= len(q):
        return None

    length = (
        (q[h_py] ^ f[0]) +
        (q[h_py + 1] ^ f[1]) * 256 +
        (q[h_py + 2] ^ f[2]) * 65536 +
        (q[h_py + 3] ^ f[3]) * 16777216
    )

    h_py += 4

    chars = []
    for g in range(1, length + 1):
        key_idx = (g - 1) % 4
        byte_idx = h_py + g - 1
        if byte_idx >= len(q):
            break
        chars.append(chr(q[byte_idx] ^ f[key_idx]))

    return "".join(chars)


def extract_all_v_indices(code):
    indices = set()
    for m in re.finditer(r'\bv\s*\(\s*(-?[\d\s\+\-\*\/\(\)\.]+)\s*\)', code):
        expr = m.group(1).strip()
        try:
            expr_py = expr.replace('^', '**')
            val = eval(expr_py, {"__builtins__": {}, "math": math}, {})
            indices.add(int(val))
        except:
            pass
    return sorted(indices)


def safe_eval(expr):
    try:
        expr = expr.replace('^', '**')
        return eval(expr, {"__builtins__": {}, "math": math}, {})
    except:
        return None


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

    print("Step 2: Extracting custom base64 alphabet...")
    h_match = re.search(r'local\s+H\s*=\s*"([^"]{64})"', code)
    if not h_match:
        h_match = re.search(r'local\s+H\s*=\s*"([A-Za-z0-9+/]{60,70})"', code)
    if not h_match:
        print("  ERROR: Could not find custom base64 alphabet.")
        return
    alphabet = h_match.group(1)
    print(f"  Alphabet: {alphabet}")

    print("Step 3: Extracting XOR key table...")
    f_match = re.search(r'local\s+f\s*=\s*\{([^}]+)\}', code)
    if not f_match:
        print("  ERROR: Could not find XOR key table.")
        return

    f_entries = re.findall(r'(-?\d+(?:\.\d+)?)', f_match.group(1))
    f_keys = [int(float(x)) for x in f_entries]
    print(f"  XOR keys: {f_keys}")

    print("Step 4: Extracting data blob...")
    m_match = re.search(r'local\s+m\s*=\s*\(\s*\[=\[(.*?)\]=\]\s*\)', code, re.DOTALL)
    if not m_match:
        m_match = re.search(r'local\s+m\s*=\s*\(\[=\[(.*?)\]=\]\)', code, re.DOTALL)
    if not m_match:
        print("  ERROR: Could not find data blob.")
        return

    blob = m_match.group(1)
    if blob.startswith("XHD:"):
        blob = blob[4:]
    print(f"  Blob: {len(blob)} chars (after XHD: prefix removal)")

    print("Step 5: Custom base64 decoding blob...")
    q = custom_base64_decode(blob, alphabet)
    print(f"  Decoded {len(q)} bytes")

    print("Step 6: Extracting v() call indices...")
    indices = extract_all_v_indices(code)
    print(f"  Found {len(indices)} unique v() indices")

    print("Step 7: Decoding all v() strings...")
    v_strings = {}
    for idx in indices:
        decoded = decode_v_string(idx, q, f_keys)
        if decoded is not None:
            v_strings[idx] = decoded

    print(f"  Decoded {len(v_strings)} strings")

    readable_v = []
    binary_v = []
    for idx in sorted(v_strings.keys()):
        s = v_strings[idx]
        is_readable = len(s) > 0 and all(32 <= ord(c) <= 126 or c in '\n\r\t' for c in s)
        if is_readable:
            readable_v.append((idx, s))
            if len(readable_v) <= 20:
                print(f"    v({idx}) = {repr(s)}")
        else:
            binary_v.append((idx, s))

    if len(readable_v) > 20:
        print(f"    ... ({len(readable_v) - 20} more)")

    print("\nStep 8: Finding and decoding bytecode payload...")
    final_match = re.search(r'L\s*\(\s*A\s*\(\s*N\s*\[\s*v\s*\(\s*(-?[\d\s\+\-\*\/\(\)\.]+)\s*\)\s*\]', code)
    bytecode_constants = []

    if final_match:
        payload_expr = final_match.group(1).strip()
        payload_idx = safe_eval(payload_expr)
        if payload_idx is not None:
            payload_idx = int(payload_idx)
            print(f"  Final payload at v({payload_idx})")

            if payload_idx in v_strings:
                payload_b64 = v_strings[payload_idx]
                print(f"  Payload base64: {len(payload_b64)} chars")

                try:
                    raw_bytes = list(base64.b64decode(payload_b64))
                    print(f"  Decoded {len(raw_bytes)} bytecode bytes")

                    reader = BytecodeReader(raw_bytes)
                    proto = parse_prototype(reader)
                    bytecode_constants = collect_constants(proto)
                    print(f"  Bytecode constants: {len(bytecode_constants)}")

                    for i, c in enumerate(bytecode_constants):
                        if c['type'] == 'string':
                            print(f"    [{i}] {repr(c['val'])}")
                        elif c['type'] == 'number':
                            print(f"    [{i}] (number) {c['val']}")
                except Exception as e:
                    print(f"  ERROR parsing bytecode: {e}")
            else:
                print(f"  WARNING: v({payload_idx}) not in decoded strings")
    else:
        print("  No final payload pattern found")

    print("\nStep 9: Writing output files...")

    output_code = "-- XHider M3 Mode Deobfuscated\n"
    output_code += "-- String encryption layer decoded, bytecode constants extracted\n\n"
    output_code += "-- v() decoded strings:\n"
    for idx, s in readable_v:
        safe = s.replace('\\', '\\\\').replace('"', '\\"')
        output_code += f'-- v({idx}) = "{safe}"\n'

    if bytecode_constants:
        output_code += "\n-- Bytecode constants:\n"
        call_args = []
        for c in bytecode_constants:
            if c['type'] == 'string':
                safe = c['val'].replace('\\', '\\\\').replace('"', '\\"')
                output_code += f'-- const = "{safe}"\n'
                call_args.append(c['val'])

        if len(call_args) >= 2:
            output_code += f'\n{call_args[0]}("{call_args[1]}")\n'
        elif len(call_args) == 1:
            output_code += f'\n{call_args[0]}()\n'

    base = os.path.basename(input_path).replace('.lua', '')
    out_lua = os.path.join(script_dir, f"{base}.decrypted.lua")
    with open(out_lua, 'w', encoding='utf-8') as f:
        f.write(output_code)
    print(f"  Reconstructed code: {out_lua}")

    out_txt = os.path.join(script_dir, f"{base}.decrypted.txt")
    with open(out_txt, 'w', encoding='utf-8') as f:
        f.write("=" * 60 + "\n")
        f.write(f"XHider M3 Mode Decrypted Strings ({os.path.basename(input_path)})\n")
        f.write("=" * 60 + "\n\n")

        f.write(f"--- v() Decoded Strings ({len(readable_v)} readable) ---\n")
        for idx, s in readable_v:
            safe = s.replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')
            f.write(f"v({idx}) = {safe}\n")

        f.write(f"\n--- v() Binary Strings ({len(binary_v)}) ---\n")
        for idx, s in binary_v:
            hex_repr = s.encode('latin-1', errors='replace').hex()
            f.write(f"v({idx}) = hex={hex_repr[:80]}\n")

        if bytecode_constants:
            f.write(f"\n--- Bytecode Constants ({len(bytecode_constants)}) ---\n")
            for i, c in enumerate(bytecode_constants):
                if c['type'] == 'string':
                    safe = c['val'].replace('\n', '\\n').replace('\r', '\\r')
                    f.write(f"[{i}] {safe}\n")
                elif c['type'] == 'number':
                    f.write(f"[{i}] (number) {c['val']}\n")
                elif c['type'] == 'bool':
                    f.write(f"[{i}] (bool) {c['val']}\n")

    print(f"  String dump: {out_txt}")
    print(f"\nTotal: {len(readable_v)} v() strings + {len(bytecode_constants)} bytecode constants")
    print("Done!")


if __name__ == "__main__":
    main()

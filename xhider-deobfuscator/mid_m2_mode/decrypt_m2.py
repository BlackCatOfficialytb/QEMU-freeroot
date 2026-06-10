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

    def read_double(self):
        raw = self.data[self.pos:self.pos + 8]
        self.pos += 8
        return struct.unpack('<d', bytes(raw))[0]

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

        instr = {'fm': fm, 'opcode': opcode, 'fmt': fmt, 'A': a}

        if fmt == 1:
            instr['B'] = reader.read_uint16()
            instr['C'] = reader.read_uint16()
            instr['s'] = b_flag == 1 and instr['B'] > 0xFF
            instr['a'] = c_flag == 1 and instr['C'] > 0xFF
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


def reconstruct_code(proto):
    lines = []
    constants = proto['constants']

    for instr in proto['instructions']:
        op = instr['opcode']
        if op == 0x05:
            if instr.get('g') and instr['F'] < len(constants):
                c = constants[instr['F']]
                if c['type'] == 'string':
                    lines.append(f"-- GETGLOBAL R{instr['A']} = _G[\"{c['val']}\"]")
        elif op == 0x01:
            if instr.get('g') and instr['F'] < len(constants):
                c = constants[instr['F']]
                if c['type'] == 'string':
                    lines.append(f"-- LOADK R{instr['A']} = \"{c['val']}\"")
                elif c['type'] == 'number':
                    lines.append(f"-- LOADK R{instr['A']} = {c['val']}")
        elif op == 0x1C:
            lines.append(f"-- CALL R{instr['A']}")
        elif op == 0x1E:
            lines.append(f"-- RETURN R{instr['A']}")

    return "\n".join(lines)


def extract_base64_payload(code):
    match = re.search(r'(?:st|LM|ie)\s*\(\s*(?:st\s*\(\s*)?LM\s*\(\s*"([A-Za-z0-9+/=]+)"', code)
    if match:
        return match.group(1)

    match = re.search(r'LM\s*\(\s*"([A-Za-z0-9+/=]{20,})"', code)
    if match:
        return match.group(1)

    candidates = re.findall(r'"([A-Za-z0-9+/=]{20,})"', code)
    if candidates:
        return max(candidates, key=len)

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

    print("Step 2: Extracting base64 payload...")
    payload = extract_base64_payload(code)
    if not payload:
        print("  ERROR: Could not find base64 payload.")
        return
    print(f"  Found payload: {len(payload)} chars")

    print("Step 3: Base64 decoding...")
    raw_bytes = list(base64.b64decode(payload))
    print(f"  Decoded {len(raw_bytes)} bytes")

    print("Step 4: Parsing bytecode...")
    reader = BytecodeReader(raw_bytes)
    proto = parse_prototype(reader)
    print(f"  Instructions: {len(proto['instructions'])}, Constants: {len(proto['constants'])}, Sub-protos: {len(proto['protos'])}")

    print("Step 5: Collecting constants...")
    all_constants = collect_constants(proto)
    print(f"  Total constants (including nested): {len(all_constants)}")

    print("Step 6: Reconstructing code...")
    reconstructed = reconstruct_code(proto)
    for sub in proto['protos']:
        reconstructed += "\n" + reconstruct_code(sub)

    output_code = f"-- XHider M2 Mode Deobfuscated\n-- Bytecode constants and reconstructed logic\n\n{reconstructed}\n\n"

    call_args = []
    for instr in proto['instructions']:
        if instr['opcode'] == 0x01 and instr.get('g'):
            idx = instr['F']
            if idx < len(proto['constants']) and proto['constants'][idx]['type'] == 'string':
                call_args.append(proto['constants'][idx]['val'])

    if len(call_args) >= 2:
        output_code += f'{call_args[0]}("{call_args[1]}")\n'
    elif len(call_args) == 1:
        output_code += f'{call_args[0]}()\n'

    base = os.path.basename(input_path).replace('.lua', '')
    out_lua = os.path.join(script_dir, f"{base}.decrypted.lua")
    with open(out_lua, 'w', encoding='utf-8') as f:
        f.write(output_code)
    print(f"  Reconstructed code: {out_lua}")

    out_txt = os.path.join(script_dir, f"{base}.decrypted.txt")
    with open(out_txt, 'w', encoding='utf-8') as f:
        f.write("=" * 60 + "\n")
        f.write(f"XHider M2 Mode Decrypted Constants ({os.path.basename(input_path)})\n")
        f.write("=" * 60 + "\n\n")

        readable = []
        binary = []
        for i, c in enumerate(all_constants):
            if c['type'] == 'string':
                s = c['val']
                is_readable = len(s) > 0 and all(32 <= ord(ch) <= 126 or ch in '\n\r\t' for ch in s)
                if is_readable:
                    readable.append((i, s))
                else:
                    binary.append((i, s))
            elif c['type'] == 'number':
                readable.append((i, f"(number) {c['val']}"))
            elif c['type'] == 'bool':
                readable.append((i, f"(bool) {c['val']}"))

        f.write(f"--- Readable Strings ({len(readable)}) ---\n")
        for idx, s in readable:
            safe = s.replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')
            f.write(f"[{idx}] {safe}\n")

        f.write(f"\n--- Binary/Encrypted Strings ({len(binary)}) ---\n")
        for idx, s in binary:
            hex_repr = s.encode('latin-1', errors='replace').hex()
            f.write(f"[{idx}] hex={hex_repr[:80]}\n")

    print(f"  String dump: {out_txt}")

    print(f"\nDecrypted constants ({len(all_constants)} total):")
    shown = 0
    for i, c in enumerate(all_constants):
        if c['type'] == 'string' and len(c['val']) >= 1:
            print(f"  [{i}] {repr(c['val'])}")
            shown += 1
            if shown >= 30:
                print("  ... (truncated)")
                break
        elif c['type'] == 'number':
            print(f"  [{i}] (number) {c['val']}")
        elif c['type'] == 'bool':
            print(f"  [{i}] (bool) {c['val']}")

    print("\nDone!")


if __name__ == "__main__":
    main()

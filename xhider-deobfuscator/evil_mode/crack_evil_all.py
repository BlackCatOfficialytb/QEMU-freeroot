import re
import sys
import os
import math
import argparse

# Add universal to path for simplify_math
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'universal'))
try:
    from simplify_math import simplify_math_in_string
except ImportError:
    # Fallback if not found
    def simplify_math_in_string(code):
        return code

# --- Variant A (LCG Cipher) Logic ---
def parse_lua_string(s):
    result = []
    i = 0
    while i < len(s):
        if s[i] == '\\' and i + 1 < len(s):
            next_ch = s[i + 1]
            if next_ch == 'n': result.append(10); i += 2
            elif next_ch == 'r': result.append(13); i += 2
            elif next_ch == 't': result.append(9); i += 2
            elif next_ch == '\\': result.append(92); i += 2
            elif next_ch == '"': result.append(34); i += 2
            elif next_ch == "'": result.append(39); i += 2
            elif next_ch == 'a': result.append(7); i += 2
            elif next_ch == 'b': result.append(8); i += 2
            elif next_ch == 'f': result.append(12); i += 2
            elif next_ch == 'v': result.append(11); i += 2
            elif next_ch == '0':
                digits = '0'
                j = i + 2
                while j < len(s) and j < i + 4 and s[j].isdigit():
                    digits += s[j]
                    j += 1
                result.append(int(digits) % 256)
                i = j
            elif next_ch.isdigit():
                digits = next_ch
                j = i + 2
                while j < len(s) and j < i + 4 and s[j].isdigit():
                    digits += s[j]
                    j += 1
                result.append(int(digits) % 256)
                i = j
            else:
                result.append(ord(s[i]))
                i += 1
        else:
            result.append(ord(s[i]))
            i += 1
    return result

class LCGDecryptor:
    def __init__(self):
        self.l = {}
        for m in range(1, 257):
            self.l[m] = chr(m - 1)
        self.cache = {}

    def _prng_generate(self):
        self.U = (self.U * 89 + 34013992534017) % 35184372088832
        while True:
            self.g = (self.g * 163) % 257
            if self.g != 1: break
        D = self.g % 32
        shift = 13 - (self.g - D) // 32
        M_val = (math.floor(self.U / (2 ** shift)) % 4294967296) / (2 ** D)
        p = math.floor((M_val % 1) * 4294967296) + math.floor(M_val)
        p = int(p) & 0xFFFFFFFF
        n = p % 65536
        e = (p - n) // 65536
        Z = n % 256
        l_val = (n - Z) // 256
        W = e % 256
        Y = (e - W) // 256
        self.I = [Z, l_val, W, Y]

    def _A(self):
        if len(self.I) == 0:
            self._prng_generate()
        return self.I.pop()

    def decrypt(self, encoded_bytes, key):
        if key in self.cache: return self.cache[key]
        self.I = []
        self.U = key % 35184372088832
        self.g = key % 255 + 2
        e = 244
        result = ""
        for byte_val in encoded_bytes:
            e = (byte_val + self._A() + e) % 256
            result += self.l[e + 1]
        self.cache[key] = result
        return result

def extract_d_calls(code):
    calls = []
    i = 0
    while i < len(code):
        if i < len(code) - 2 and code[i] == 'D' and code[i+1] == '(':
            if i > 0 and (code[i-1].isalnum() or code[i-1] == '_'):
                i += 1
                continue
            start = i
            i += 2
            while i < len(code) and code[i] in ' \t\n\r': i += 1
            if i >= len(code) or code[i] != '"': continue
            i += 1
            str_start = i
            while i < len(code):
                if code[i] == '\\': i += 2
                elif code[i] == '"': break
                else: i += 1
            if i >= len(code): continue
            str_content = code[str_start:i]
            i += 1
            while i < len(code) and code[i] in ' \t\n\r,': i += 1
            key_start = i
            while i < len(code) and (code[i].isdigit() or code[i] == '-'): i += 1
            if i == key_start: continue
            key_str = code[key_start:i]
            while i < len(code) and code[i] in ' \t\n\r': i += 1
            if i < len(code) and code[i] == ')':
                i += 1
                try:
                    key = int(key_str)
                    calls.append((start, i, str_content, key))
                except ValueError: pass
            continue
        i += 1
    return calls

def decrypt_variant_a(code, out_path):
    print("Detected Variant A: LCG Cipher (D calls)")
    calls = extract_d_calls(code)
    if not calls:
        print("Error: Detected Variant A but no D() calls found.")
        return False
        
    decryptor = LCGDecryptor()
    decrypted = {}
    for start, end, str_content, key in calls:
        try:
            encoded_bytes = parse_lua_string(str_content)
            result = decryptor.decrypt(encoded_bytes, key)
            decrypted[(start, end)] = result
        except: pass

    parts = []
    prev_end = 0
    sorted_calls = sorted(decrypted.items(), key=lambda x: x[0][0])
    for (start, end), val in sorted_calls:
        parts.append(code[prev_end:start])
        escaped = val.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r').replace('\0', '\\0')
        prefix = code[max(0, start-2):start]
        if prefix.endswith('M['):
            suffix = code[end:end+1]
            if suffix == ']':
                parts[-1] = parts[-1][:-2]
                parts.append(f'"{escaped}"')
                prev_end = end + 1
                continue
        parts.append(f'"{escaped}"')
        prev_end = end

    parts.append(code[prev_end:])
    final_code = "".join(parts)

    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(final_code)
    print(f"Decrypted {len(decrypted)} strings. Saved to {out_path}")
    return True

# --- Variant B (Hex Pool) Logic ---
def xor_bits(a, b): return a ^ b

def decode_hex_pool(hex_str):
    return [int(hex_str[i:i+2], 16) for i in range(0, len(hex_str), 2)]

def find_k_calls(code):
    calls = {}
    for m in re.finditer(r'([a-zA-Z_]\w*)\[([a-zA-Z_]\w*)\((\-?\d+)\)\]', code):
        offset = int(m.group(3))
        calls[offset] = calls.get(offset, 0) + 1
    return calls

def decrypt_variant_b(code, out_path):
    print("Detected Variant B: Hex Pool + XOR")
    simplified = simplify_math_in_string(code)
    
    hex_str = None
    hex_match = re.search(r'\[=\[XHD:([0-9A-Fa-f]+)\]=\]', simplified)
    if hex_match:
        hex_str = hex_match.group(1)
    if not hex_str:
        hex_match = re.search(r'local [a-zA-Z_]\w*\s*=\s*"([0-9A-Fa-f]+)"', simplified)
        if hex_match: hex_str = hex_match.group(1)
    if not hex_str:
        hex_match = re.search(r'"([0-9A-Fa-f]{200,})"', simplified)
        if hex_match: hex_str = hex_match.group(1)

    if not hex_str:
        print("Error: Could not find hex pool string!")
        return False

    hex_pool = decode_hex_pool(hex_str)
    
    keys = []
    for keys_match in re.finditer(r'local [a-zA-Z_]\w*\s*=\s*\{([^}]+)\}', simplified):
        keys_str = keys_match.group(1).replace(';', ',')
        parts = [p.strip() for p in keys_str.split(',') if p.strip()]
        if len(parts) >= 4:
            temp_keys = []
            for p in parts[:4]:
                try: temp_keys.append(int(eval(p, {"__builtins__": {}}, {})))
                except:
                    key_values = re.findall(r'(-?\d+)', p)
                    if key_values: temp_keys.append(int(key_values[0]))
            if len(temp_keys) == 4:
                keys = temp_keys
                break

    if len(keys) < 4:
        print("Error: Could not extract 4 keys!")
        return False
        
    k_calls = find_k_calls(simplified)
    decoded = {}
    for offset in sorted(k_calls.keys()):
        idx = offset
        if idx < 0 or idx + 4 > len(hex_pool): continue
        length = (xor_bits(hex_pool[idx], keys[0])
                  + xor_bits(hex_pool[idx+1], keys[1]) * 256
                  + xor_bits(hex_pool[idx+2], keys[2]) * 65536
                  + xor_bits(hex_pool[idx+3], keys[3]) * 16777216)
        if length <= 0 or length > 10000: continue
        start = idx + 4
        if start + length > len(hex_pool): continue
        chars = []
        for r in range(length):
            key = keys[r % 4]
            byte_val = xor_bits(hex_pool[start + r], key)
            chars.append(chr(byte_val & 0xFF))
        decoded[offset] = "".join(chars)

    def repl_nk(m):
        offset = int(m.group(3))
        if offset in decoded:
            s = decoded[offset]
            escaped = s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r').replace('\0', '\\0')
            return f'"{escaped}"'
        return m.group(0)

    final_code = re.sub(r'([a-zA-Z_]\w*)\[([a-zA-Z_]\w*)\((\-?\d+)\)\]', repl_nk, simplified)

    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(final_code)
    print(f"Decrypted {len(decoded)} strings. Saved to {out_path}")
    return True

# --- Main Logic ---
def main():
    parser = argparse.ArgumentParser(description="Unified XHider Evil Mode Decryptor")
    parser.add_argument("-i", "--input", required=True, help="Input obfuscated Lua file")
    parser.add_argument("-o", "--output", help="Output decrypted Lua file")
    args = parser.parse_args()

    input_path = args.input
    if not os.path.exists(input_path):
        print(f"Error: File not found: {input_path}")
        return

    output_path = args.output if args.output else input_path.replace('.lua', '.decrypted.lua')

    with open(input_path, 'r', encoding='utf-8', errors='replace') as f:
        code = f.read()

    # Detect variant
    if 'D(' in code and re.search(r'D\(\s*"', code):
        decrypt_variant_a(code, output_path)
    elif 'XHD:' in code or re.search(r'"([0-9A-Fa-f]{200,})"', code) or 'N[K(' in code:
        decrypt_variant_b(code, output_path)
    else:
        print("Error: Could not identify evil_mode variant. Make sure it is an evil_mode obfuscated script.")

if __name__ == "__main__":
    main()

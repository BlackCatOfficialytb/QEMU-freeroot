import re
import sys
import math
import os

def parse_lua_string(s):
    """Parse a Lua string literal with escape sequences into bytes."""
    result = []
    i = 0
    while i < len(s):
        if s[i] == '\\' and i + 1 < len(s):
            next_ch = s[i + 1]
            if next_ch == 'n':
                result.append(10)
                i += 2
            elif next_ch == 'r':
                result.append(13)
                i += 2
            elif next_ch == 't':
                result.append(9)
                i += 2
            elif next_ch == '\\':
                result.append(92)
                i += 2
            elif next_ch == '"':
                result.append(34)
                i += 2
            elif next_ch == "'":
                result.append(39)
                i += 2
            elif next_ch == 'a':
                result.append(7)
                i += 2
            elif next_ch == 'b':
                result.append(8)
                i += 2
            elif next_ch == 'f':
                result.append(12)
                i += 2
            elif next_ch == 'v':
                result.append(11)
                i += 2
            elif next_ch == '0':
                # Could be \0, \0X, \0XX
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
    """Replicates the XHider evil mode stream cipher from one.lua."""

    def __init__(self):
        # l[M] = string.char(M - 1) for M = 1..256
        # Since every M from 1-256 is placed exactly once, l is deterministic
        self.l = {}
        for m in range(1, 257):
            self.l[m] = chr(m - 1)
        self.cache = {}

    def _prng_generate(self):
        """Advance LCG state and generate 4 bytes."""
        self.U = (self.U * 89 + 34013992534017) % 35184372088832

        while True:
            self.g = (self.g * 163) % 257
            if self.g != 1:
                break

        D = self.g % 32
        shift = 13 - (self.g - D) // 32
        M_val = (math.floor(self.U / (2 ** shift)) % 4294967296) / (2 ** D)
        p = math.floor((M_val % 1) * 4294967296) + math.floor(M_val)
        # Force integer
        p = int(p) & 0xFFFFFFFF
        n = p % 65536
        e = (p - n) // 65536
        Z = n % 256
        l_val = (n - Z) // 256
        W = e % 256
        Y = (e - W) // 256
        self.I = [Z, l_val, W, Y]

    def _A(self):
        """Get next PRNG byte (pops from end of buffer)."""
        if len(self.I) == 0:
            self._prng_generate()
        return self.I.pop()

    def decrypt(self, encoded_bytes, key):
        """Decrypt a single D(string, key) call."""
        if key in self.cache:
            return self.cache[key]

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
    """Extract all D("...", key) call patterns from the source."""
    calls = []
    # Match D("...", number) — the string may contain any escaped chars
    # We need a careful parser since regex can't handle all Lua escape sequences

    i = 0
    while i < len(code):
        # Look for D( pattern
        if i < len(code) - 2 and code[i] == 'D' and code[i+1] == '(':
            # Check it's not part of a longer identifier
            if i > 0 and (code[i-1].isalnum() or code[i-1] == '_'):
                i += 1
                continue

            start = i
            i += 2  # Skip 'D('

            # Skip whitespace
            while i < len(code) and code[i] in ' \t\n\r':
                i += 1

            if i >= len(code) or code[i] != '"':
                continue

            # Parse the string literal
            i += 1  # Skip opening quote
            str_start = i
            while i < len(code):
                if code[i] == '\\':
                    i += 2  # Skip escaped char
                elif code[i] == '"':
                    break
                else:
                    i += 1

            if i >= len(code):
                continue

            str_content = code[str_start:i]
            i += 1  # Skip closing quote

            # Skip whitespace and comma
            while i < len(code) and code[i] in ' \t\n\r,':
                i += 1

            # Parse key number
            key_start = i
            while i < len(code) and (code[i].isdigit() or code[i] == '-'):
                i += 1

            if i == key_start:
                continue

            key_str = code[key_start:i]

            # Skip whitespace and closing paren
            while i < len(code) and code[i] in ' \t\n\r':
                i += 1

            if i < len(code) and code[i] == ')':
                i += 1
                try:
                    key = int(key_str)
                    calls.append((start, i, str_content, key))
                except ValueError:
                    pass
            continue
        i += 1

    return calls


def main():
    input_file = "one.lua"
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

    print("Extracting D() calls...")
    calls = extract_d_calls(code)
    print(f"Found {len(calls)} D() calls")

    if not calls:
        print("No D() calls found!")
        return

    print("Decrypting strings...")
    decryptor = LCGDecryptor()
    decrypted = {}
    errors = 0

    for start, end, str_content, key in calls:
        try:
            encoded_bytes = parse_lua_string(str_content)
            result = decryptor.decrypt(encoded_bytes, key)
            decrypted[(start, end)] = result
        except Exception as e:
            errors += 1
            if errors <= 5:
                print(f"  Error decrypting key={key}: {e}")

    print(f"Decrypted {len(decrypted)} strings ({errors} errors)")

    # Dump decoded strings
    output_strings = os.path.join(script_dir, input_file.replace('.lua', '.decrypted.txt'))
    with open(output_strings, 'w', encoding='utf-8') as f:
        f.write("=" * 60 + "\n")
        f.write("XHider Evil Mode (one.lua) Decrypted Strings\n")
        f.write("=" * 60 + "\n\n")
        seen = {}
        for (start, end), val in sorted(decrypted.items()):
            if val not in seen:
                seen[val] = len(seen) + 1
            f.write(f"[{seen[val]}] {repr(val)}\n")
    print(f"String dump: {output_strings}")

    # Reconstruct script with decoded strings
    print("Reconstructing script...")
    parts = []
    prev_end = 0
    sorted_calls = sorted(decrypted.items(), key=lambda x: x[0][0])

    for (start, end), val in sorted_calls:
        parts.append(code[prev_end:start])
        escaped = val.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r').replace('\0', '\\0')
        # Replace M[D("...", key)] with just "decoded_string"
        # Check if preceded by M[
        prefix = code[max(0, start-2):start]
        if prefix.endswith('M['):
            # Check if followed by ]
            suffix = code[end:end+1]
            if suffix == ']':
                parts[-1] = parts[-1][:-2]  # Remove M[
                parts.append(f'"{escaped}"')
                prev_end = end + 1  # Skip ]
                continue
        parts.append(f'"{escaped}"')
        prev_end = end

    parts.append(code[prev_end:])
    final_code = "".join(parts)

    output_file = os.path.join(script_dir, input_file.replace('.lua', '.decrypted.lua'))
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(final_code)
    print(f"Decrypted script: {output_file}")

    # Print some sample strings
    unique = list(set(decrypted.values()))
    unique.sort()
    print(f"\nUnique strings: {len(unique)}")
    print("Sample decoded strings:")
    for s in unique[:20]:
        print(f"  {repr(s)}")


if __name__ == "__main__":
    main()

import re
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'universal'))
from simplify_math import simplify_math_in_string


def xor_bits(a, b):
    """Replicate v(K, N) — bitwise XOR via the Lua bit-counting method."""
    return a ^ b


def decode_hex_pool(hex_str):
    """Parse hex string into byte array (y() function)."""
    result = []
    for i in range(0, len(hex_str), 2):
        pair = hex_str[i:i+2]
        result.append(int(pair, 16))
    return result


def decrypt_strings(hex_pool, keys):
    """
    Replicate the K() function that decodes strings from the hex pool.

    K(r):
      idx = r + 1  (1-based)
      length = v(q[idx], i[1]) + v(q[idx+1], i[2])*256 + v(q[idx+2], i[3])*65536 + v(q[idx+3], i[4])*16777216
      idx += 4
      for r = 1, length:
        N = (r-1) % 5
        char = v(q[idx+r-1], i[N])  -- i[0] = nil = 0 in Lua XOR context
      return concat
    """
    strings = {}
    i = 0
    while i < len(hex_pool) - 4:
        offset = i  # This is the 0-based offset; K() is called with 0-based r values
        idx = offset  # q is 1-based in Lua, but 0-based in Python
        if idx + 4 > len(hex_pool):
            break

        length = (xor_bits(hex_pool[idx], keys[0])
                  + xor_bits(hex_pool[idx+1], keys[1]) * 256
                  + xor_bits(hex_pool[idx+2], keys[2]) * 65536
                  + xor_bits(hex_pool[idx+3], keys[3]) * 16777216)

        if length < 0 or length > 10000:
            i += 1
            continue

        start = idx + 4
        if start + length > len(hex_pool):
            i += 1
            continue

        chars = []
        valid = True
        for r in range(length):
            key = keys[r % 4]
            byte_val = xor_bits(hex_pool[start + r], key)
            if byte_val > 127:
                valid = False
                break
            chars.append(chr(byte_val))

        if valid and length > 0:
            strings[offset] = "".join(chars)

        i += 1

    return strings


def find_k_calls(code):
    """Find all N[K(number)] patterns in simplified code."""
    pattern = r'N\[K\((\-?\d+)\)\]'
    calls = {}
    for m in re.finditer(pattern, code):
        offset = int(m.group(1))
        calls[offset] = calls.get(offset, 0) + 1
    return calls


def main():
    input_file = "two.lua"
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

    simplified_path = input_path.replace('.lua', '.simplified.lua')
    with open(simplified_path, 'w', encoding='utf-8') as f:
        f.write(simplified)
    print(f"  Saved simplified: {simplified_path}")

    print("Step 2: Extracting hex pool...")
    hex_match = re.search(r'local b\s*=\s*"([0-9A-Fa-f]+)"', simplified)
    if not hex_match:
        hex_match = re.search(r'"([0-9A-Fa-f]{200,})"', simplified)
    if not hex_match:
        print("  ERROR: Could not find hex pool string!")
        return

    hex_str = hex_match.group(1)
    hex_pool = decode_hex_pool(hex_str)
    print(f"  Hex pool: {len(hex_str)} chars -> {len(hex_pool)} bytes")

    print("Step 3: Extracting XOR keys...")
    keys_match = re.search(r'local i\s*=\s*\{([^}]+)\}', simplified)
    if not keys_match:
        print("  ERROR: Could not find keys table!")
        return

    keys_str = keys_match.group(1).replace(';', ',')
    parts = [p.strip() for p in keys_str.split(',') if p.strip()]
    keys = []
    for p in parts[:4]:
        try:
            keys.append(int(eval(p, {"__builtins__": {}}, {})))
        except:
            key_values = re.findall(r'(-?\d+)', p)
            if key_values:
                keys.append(int(key_values[0]))
    if len(keys) < 4:
        print(f"  ERROR: Only found {len(keys)} keys!")
        return
    print(f"  XOR keys: {keys}")

    print("Step 4: Finding K() call offsets...")
    k_calls = find_k_calls(simplified)
    offsets = sorted(k_calls.keys())
    print(f"  Found {len(offsets)} unique K() offsets")

    print("Step 5: Decrypting strings at known offsets...")
    decoded = {}
    errors = 0

    for offset in offsets:
        idx = offset  # 0-based in Python
        if idx < 0 or idx + 4 > len(hex_pool):
            errors += 1
            continue

        length = (xor_bits(hex_pool[idx], keys[0])
                  + xor_bits(hex_pool[idx+1], keys[1]) * 256
                  + xor_bits(hex_pool[idx+2], keys[2]) * 65536
                  + xor_bits(hex_pool[idx+3], keys[3]) * 16777216)

        if length <= 0 or length > 10000:
            errors += 1
            continue

        start = idx + 4
        if start + length > len(hex_pool):
            errors += 1
            continue

        chars = []
        for r in range(length):
            key = keys[r % 4]
            byte_val = xor_bits(hex_pool[start + r], key)
            chars.append(chr(byte_val & 0xFF))

        decoded[offset] = "".join(chars)

    print(f"  Decoded {len(decoded)} strings ({errors} errors)")

    # Dump decoded strings
    output_strings = os.path.join(script_dir, input_file.replace('.lua', '.decrypted.txt'))
    with open(output_strings, 'w', encoding='utf-8') as f:
        f.write("=" * 60 + "\n")
        f.write(f"XHider Evil Mode ({input_file}) Decrypted Strings\n")
        f.write("=" * 60 + "\n\n")
        for i, (offset, val) in enumerate(sorted(decoded.items()), 1):
            f.write(f"[{i}] offset={offset}: {repr(val)}\n")
    print(f"  String dump: {output_strings}")

    # Reconstruct script
    print("Step 6: Reconstructing script...")

    def repl_nk(m):
        offset = int(m.group(1))
        if offset in decoded:
            s = decoded[offset]
            escaped = s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r').replace('\0', '\\0')
            return f'"{escaped}"'
        return m.group(0)

    final_code = re.sub(r'N\[K\((\-?\d+)\)\]', repl_nk, simplified)

    output_file = os.path.join(script_dir, input_file.replace('.lua', '.decrypted.lua'))
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(final_code)
    print(f"  Decrypted script: {output_file}")

    # Print samples
    print(f"\nUnique strings: {len(set(decoded.values()))}")
    print("Sample decoded strings:")
    for offset in sorted(decoded.keys())[:20]:
        print(f"  K({offset}) = {repr(decoded[offset])}")


if __name__ == "__main__":
    main()

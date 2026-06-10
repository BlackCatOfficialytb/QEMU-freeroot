"""
XHider Max Security Mode Deobfuscator
Decrypts max security mode obfuscated Lua scripts.

Max Security Pattern:
1. Strings are reconstructed using a[8] function with indices and fragments
2. String pool is shuffled using ipairs loop with swap pairs
3. Strings are encoded with ASCII85-like encoding

Usage: python decrypt_max_final.py [input_file] [output_file]
"""

import re
import math
import sys
import os

def lua_eval(expr):
    """Evaluate Lua math expressions in Python."""
    try:
        expr = str(expr).replace('\n', ' ').strip()
        if not expr:
            return 0
        return int(eval(expr, {"__builtins__": None, "math": math}))
    except:
        return 0

def unescape_lua(s):
    """Convert Lua escape sequences to Python strings."""
    result = []
    i = 0
    while i < len(s):
        if s[i] == '\\' and i + 1 < len(s):
            next_char = s[i + 1]
            if next_char.isdigit():
                num_str = next_char
                j = i + 2
                while j < len(s) and j < i + 4 and s[j].isdigit():
                    num_str += s[j]
                    j += 1
                try:
                    result.append(chr(int(num_str)))
                except:
                    result.append('?')
                i = j
            elif next_char == 'n':
                result.append('\n')
                i += 2
            elif next_char == 'r':
                result.append('\r')
                i += 2
            elif next_char == 't':
                result.append('\t')
                i += 2
            elif next_char == '\\':
                result.append('\\')
                i += 2
            elif next_char == '"':
                result.append('"')
                i += 2
            elif next_char == "'":
                result.append("'")
                i += 2
            else:
                result.append(next_char)
                i += 2
        else:
            result.append(s[i])
            i += 1
    return ''.join(result)

def reconstruct_a8(block):
    """
    Reconstruct string from a[8]({indices, {fragments}}) call.
    a[8] concatenates fragments based on 1-based indices.
    """
    # Find the last { which contains the fragments
    last_brace = block.rfind('{')
    if last_brace == -1:
        return ""

    indices_part = block[:last_brace]
    fragments_part = block[last_brace + 1:block.rfind('}')]

    # Extract fragments
    frag_pattern = re.compile(r'"((?:[^"\\]|\\.)*)"|\'((?:[^\'\\]|\\.)*)\'')
    fragments = []
    for m in frag_pattern.finditer(fragments_part):
        s = m.group(1) if m.group(1) is not None else m.group(2)
        fragments.append(unescape_lua(s))

    if not fragments:
        return ""

    # Extract indices
    indices = []
    current = ""
    balance = 0

    for c in indices_part:
        if c == '(':
            balance += 1
            current += c
        elif c == ')':
            balance -= 1
            current += c
        elif c == '{':
            balance += 1
            current += c
        elif c == '}':
            balance -= 1
            current += c
        elif (c == ',' or c == ';') and balance == 0:
            val = lua_eval(current.strip())
            if val != 0:
                indices.append(val)
            current = ""
        else:
            current += c

    if current.strip():
        val = lua_eval(current.strip())
        if val != 0:
            indices.append(val)

    # Reconstruct: concatenate fragments by indices (1-based)
    result = ""
    for idx in indices:
        py_idx = idx - 1
        if 0 <= py_idx < len(fragments):
            result += fragments[py_idx]

    return result

def extract_a8_strings(content):
    """Extract all strings from a[8]({...}) calls."""
    strings_pool = []
    pos = 0

    while True:
        # Find a[8]({ pattern
        start_marker = "a[8]({"
        idx = content.find(start_marker, pos)
        if idx == -1:
            break

        # Skip if it's part of a function definition
        if "function" in content[max(0, idx - 30):idx]:
            pos = idx + 1
            continue

        # Find matching closing braces
        p = idx + len(start_marker)
        balance = 1
        in_quote = False
        quote_char = None

        while p < len(content) and balance > 0:
            c = content[p]
            if in_quote:
                if c == '\\':
                    p += 1
                elif c == quote_char:
                    in_quote = False
            else:
                if c == '"' or c == "'":
                    in_quote = True
                    quote_char = c
                elif c == '{':
                    balance += 1
                elif c == '}':
                    balance -= 1
            p += 1

        if balance == 0:
            # Check for closing paren
            if p < len(content) and content[p] == ')':
                block_content = content[idx + 6:p - 1]
                decoded = reconstruct_a8(block_content)
                if decoded:
                    strings_pool.append(decoded)
                pos = p + 1
            else:
                pos = idx + 1
        else:
            pos = idx + 1

    return strings_pool

def extract_shuffle_pairs(content):
    """Extract shuffle pairs from ipairs loop."""
    pairs = []

    # Pattern: ipairs({{expr1, expr2}, ...})do
    ipairs_match = re.search(r'ipairs\(\{(.*?)\}\)do', content, re.DOTALL)
    if not ipairs_match:
        return pairs

    pairs_content = ipairs_match.group(1).replace('\n', '')

    # Split by }, {
    raw_pairs = re.split(r'\}\s*,\s*\{', pairs_content)

    for p_str in raw_pairs:
        p_str = p_str.replace('{', '').replace('}', '')
        parts = re.split(r'[;,]', p_str)
        if len(parts) >= 2:
            start = lua_eval(parts[0])
            end = lua_eval(parts[1])
            if start > 0 and end > 0:
                pairs.append((start, end))

    return pairs

def apply_shuffle(strings_pool, pairs):
    """Apply shuffle operations (reverse ranges)."""
    for start, end in pairs:
        s = start - 1
        e = end - 1

        if s < 0:
            s = 0
        if e >= len(strings_pool):
            e = len(strings_pool) - 1

        while s < e:
            strings_pool[s], strings_pool[e] = strings_pool[e], strings_pool[s]
            s += 1
            e -= 1

    return strings_pool

def decrypt_ascii85(s_in):
    """
    Decrypt ASCII85-like encoded string.
    XHider's ASCII85 variant:
    - 'z' represents 4 zero bytes
    - Skip whitespace
    - 5 chars encode to 4 bytes (standard ASCII85)
    """
    out = bytearray()
    i = 0

    while i < len(s_in):
        c = s_in[i]

        if c == 'z':
            out.extend([0, 0, 0, 0])
            i += 1
        elif c.isspace():
            i += 1
        else:
            # Accumulate up to 5 chars
            block = []
            while len(block) < 5 and i < len(s_in):
                char = s_in[i]
                if char == 'z' or char.isspace():
                    break
                block.append(char)
                i += 1

            if not block:
                continue

            count = len(block)
            # Pad with 'u' (ASCII 117) for incomplete blocks
            padded = block + ['u'] * (5 - count)

            # Calculate value: sum of (char - 33) * 85^(4-i)
            val = 0
            for char in padded:
                val = val * 85 + (ord(char) - 33)

            # Extract bytes from most significant to least
            # Standard ASCII85: 5 chars -> 4 bytes
            bytes_to_extract = count - 1 if count < 5 else 4

            for h in range(3, 3 - bytes_to_extract, -1):
                b = (val >> (h * 8)) & 0xFF
                out.append(b)

    return out

def decrypt_max(input_file, output_file=None):
    """Main decryption function for max security mode."""
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    print(f"File size: {len(content)} bytes")
    print("=" * 50)

    # Step 1: Extract strings from a[8] calls
    print("Step 1: Extracting strings from a[8] calls...")
    strings_pool = extract_a8_strings(content)
    print(f"  Found {len(strings_pool)} raw strings")

    # Step 2: Extract and apply shuffle
    print("Step 2: Extracting shuffle pairs...")
    shuffle_pairs = extract_shuffle_pairs(content)
    if shuffle_pairs:
        print(f"  Found {len(shuffle_pairs)} shuffle pairs")
        strings_pool = apply_shuffle(strings_pool, shuffle_pairs)
        print("  Applied shuffle operations")
    else:
        print("  No shuffle pairs found")

    # Step 3: Decrypt strings (ASCII85)
    print("Step 3: Decrypting strings (ASCII85)...")
    decrypted_pool = []
    for i, s in enumerate(strings_pool):
        try:
            dec_bytes = decrypt_ascii85(s)
            dec_str = dec_bytes.decode('utf-8', errors='replace')
            decrypted_pool.append(dec_str)
        except Exception as e:
            decrypted_pool.append(f"[DECRYPT_ERROR: {e}]")

    # Output results
    if output_file is None:
        output_file = input_file.replace('.lua', '.decrypted.txt')
        if output_file == input_file:
            output_file = input_file + '.decrypted.txt'

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("=" * 60 + "\n")
        f.write("XHider Max Security Mode Decrypted Strings\n")
        f.write(f"Source: {input_file}\n")
        f.write("=" * 60 + "\n\n")

        for i, s in enumerate(decrypted_pool):
            safe_s = s.replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')
            f.write(f"[{i + 1}] {safe_s}\n")

    print(f"\nOutput saved to: {output_file}")

    # Display results
    print("\n" + "=" * 50)
    print("Decrypted Strings:")
    print("=" * 50)

    for i, s in enumerate(decrypted_pool):
        safe_s = s.replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')
        if len(safe_s) > 80:
            safe_s = safe_s[:80] + "..."
        print(f"[{i + 1}] {safe_s}")

    # Search for interesting patterns
    print("\n" + "=" * 50)
    print("Interesting findings:")
    print("=" * 50)

    for i, s in enumerate(decrypted_pool):
        s_lower = s.lower()
        if 'http' in s_lower:
            print(f"URL [{i + 1}]: {s}")
        if 'print' in s_lower:
            print(f"Print [{i + 1}]: {s}")
        if 'loadstring' in s_lower:
            print(f"Loadstring [{i + 1}]: {s}")
        if 'you are lost' in s_lower:
            print(f"XHider marker [{i + 1}]: {s}")
        if s.strip() == 'Hi' or 'hi' in s_lower:
            print(f"Possible output [{i + 1}]: {s}")

    return decrypted_pool

if __name__ == "__main__":
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
    else:
        input_file = r"E:\dec bot2\max_security_mode\print_hi.beautified.lua"

    output_file = sys.argv[2] if len(sys.argv) > 2 else None
    decrypt_max(input_file, output_file)

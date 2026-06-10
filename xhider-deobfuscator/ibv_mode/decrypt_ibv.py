import re
import sys
import os
import math

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'universal'))
from simplify_math import simplify_math_in_string
from beautifier import beautify_lua


def parse_table_items(table_content):
    """Parse comma/semicolon-separated items from a Lua table, respecting strings."""
    items = []
    current = ""
    in_quote = False
    quote_char = None
    escape = False

    for ch in table_content:
        if in_quote:
            if escape:
                current += ch
                escape = False
            elif ch == '\\':
                current += ch
                escape = True
            elif ch == quote_char:
                current += ch
                in_quote = False
            else:
                current += ch
        else:
            if ch in ('"', "'"):
                in_quote = True
                quote_char = ch
                current += ch
            elif ch in (',', ';'):
                if current.strip():
                    items.append(current.strip())
                current = ""
            else:
                current += ch
    if current.strip():
        items.append(current.strip())
    return items


def safe_eval(expr):
    """Evaluate a constant math expression safely."""
    try:
        expr = expr.replace('^', '**')
        return eval(expr, {"__builtins__": {}, "math": math}, {})
    except:
        return None


def extract_hex_alphabet(code):
    """Extract the hex alphabet map (0-9, A-F -> values 0-15) from simplified code."""
    entry_pattern = re.compile(
        r'(?:\[(["\'])([0-9A-Fa-f])\1\]|([A-Fa-f]))\s*=\s*(-?[\d\s\+\-\*\/\(\)\.]+)'
    )

    best = {}
    for m in re.finditer(r'local\s+\w+\s*=\s*\{((?:[^{}]|\{[^{}]*\})*)\}', code):
        content = m.group(1)
        candidate = {}
        for entry in entry_pattern.finditer(content):
            key = entry.group(2) if entry.group(2) else entry.group(3)
            val = safe_eval(entry.group(4).strip())
            if val is not None and 0 <= val <= 15:
                candidate[key.upper()] = int(val)
        if len(candidate) > len(best):
            best = candidate

    return best


def extract_shuffle_pairs(code):
    """Extract the table shuffle pairs from ipairs({{...}}) blocks."""
    pairs = []
    match = re.search(r'ipairs\s*\(\s*\{(.*?)\}\s*\)\s*do', code, re.DOTALL)
    if not match:
        return pairs

    content = match.group(1)
    for m in re.finditer(r'\{\s*(-?\d+)\s*[,;]\s*(-?\d+)\s*\}', content):
        pairs.append((int(m.group(1)), int(m.group(2))))
    return pairs


def extract_main_table(code):
    """Extract the initial data table (first large table in the outer function)."""
    match = re.search(r'local\s+(\w+)\s*=\s*\{(.*?)\}\s*local\s+function', code, re.DOTALL)
    if not match:
        match = re.search(r'local\s+(\w+)\s*=\s*\{(.*?)\}', code, re.DOTALL)
    if not match:
        return None, []

    table_name = match.group(1)
    content = match.group(2)
    items = parse_table_items(content)

    parsed = []
    for item in items:
        item = item.strip()
        if (item.startswith('"') and item.endswith('"')) or (item.startswith("'") and item.endswith("'")):
            parsed.append({"type": "string", "val": item[1:-1]})
        elif item in ('true', 'false'):
            parsed.append({"type": "bool", "val": item == 'true'})
        elif item == 'nil':
            parsed.append({"type": "nil", "val": None})
        else:
            val = safe_eval(item)
            if val is not None:
                parsed.append({"type": "number", "val": val})
            else:
                parsed.append({"type": "raw", "val": item})

    return table_name, parsed


def shuffle_table(table, pairs):
    """Apply table shuffling (reversing ranges) - converts from Lua 1-based to Python 0-based."""
    for start, end in pairs:
        s = start - 1
        e = end - 1
        while s < e:
            table[s], table[e] = table[e], table[s]
            s += 1
            e -= 1
    return table


def decode_hex_strings(table, alphabet):
    """Decode hex-encoded string entries using the alphabet map."""
    decoded_count = 0
    for i, entry in enumerate(table):
        if entry["type"] != "string":
            continue
        hex_str = entry["val"]
        if not all(c.upper() in alphabet for c in hex_str):
            continue
        if len(hex_str) % 2 != 0:
            continue

        chars = []
        for j in range(0, len(hex_str), 2):
            high = alphabet.get(hex_str[j].upper())
            low = alphabet.get(hex_str[j + 1].upper())
            if high is None or low is None:
                break
            chars.append(chr(high * 16 + low))

        if chars:
            table[i] = {"type": "string", "val": "".join(chars)}
            decoded_count += 1

    return table, decoded_count


def extract_accessor_offset(code):
    """Extract the offset constant from the accessor function v_1(x) = v_0[x - offset]."""
    match = re.search(
        r'function\s+(\w+)\s*\(\s*\w+\s*\)\s*return\s+\w+\s*\[\s*\w+\s*-\s*\(?(-?[\d\s\+\-\*\/\(\)]+)\)?\s*\]',
        code
    )
    if match:
        name = match.group(1)
        val = safe_eval(match.group(2).strip())
        if val is not None:
            return name, int(val)
    return None, None


def resolve_accessor_calls(code, table, accessor_name, offset):
    """Replace accessor function calls with the actual table values."""
    def repl(m):
        arg = safe_eval(m.group(1))
        if arg is None:
            return m.group(0)
        idx = int(arg) - offset - 1
        if idx < 0 or idx >= len(table):
            return m.group(0)
        entry = table[idx]
        if entry["type"] == "string":
            s = entry["val"].replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r').replace('\0', '\\0')
            return f'"{s}"'
        elif entry["type"] == "number":
            v = entry["val"]
            return str(int(v)) if float(v).is_integer() else str(v)
        elif entry["type"] == "bool":
            return "true" if entry["val"] else "false"
        elif entry["type"] == "nil":
            return "nil"
        return m.group(0)

    pattern = r'\b' + re.escape(accessor_name) + r'\((-?[\d\s\+\-\*\/\(\)]+)\)'
    return re.sub(pattern, repl, code)


def main():
    input_file = "printhi.lua"
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

    print("Step 2: Extracting components...")
    table_name, table = extract_main_table(code)
    if not table:
        print("  ERROR: Could not extract main data table.")
        return
    print(f"  Table '{table_name}': {len(table)} entries")

    string_count = sum(1 for e in table if e["type"] == "string")
    number_count = sum(1 for e in table if e["type"] == "number")
    print(f"  Types: {string_count} strings, {number_count} numbers, {len(table) - string_count - number_count} other")

    print("Step 3: Extracting shuffle pairs...")
    pairs = extract_shuffle_pairs(code)
    if pairs:
        print(f"  Found {len(pairs)} shuffle ranges")
        table = shuffle_table(table, pairs)
        print("  Table shuffled.")
    else:
        print("  No shuffle pairs found (may not be needed).")

    print("Step 4: Extracting hex alphabet...")
    alphabet = extract_hex_alphabet(code)
    if alphabet:
        print(f"  Alphabet: {len(alphabet)} entries -> {dict(sorted(alphabet.items()))}")
    else:
        print("  WARNING: No hex alphabet found, using default 0-F.")
        alphabet = {c: i for i, c in enumerate("0123456789ABCDEF")}

    print("Step 5: Decoding hex-encoded strings...")
    table, decoded_count = decode_hex_strings(table, alphabet)
    print(f"  Decoded {decoded_count} strings")

    print("Step 6: Resolving accessor calls...")
    acc_name, acc_offset = extract_accessor_offset(code)
    if acc_name:
        print(f"  Accessor: {acc_name}(x) = table[x - {acc_offset}]")
        code = resolve_accessor_calls(code, table, acc_name, acc_offset)
    else:
        print("  No accessor function found, skipping.")

    print("Step 7: Beautifying output...")
    code = beautify_lua(code)

    base = os.path.basename(input_path).replace('.lua', '')
    out_lua = os.path.join(script_dir, f"{base}.decrypted.lua")
    with open(out_lua, 'w', encoding='utf-8') as f:
        f.write(code)
    print(f"  Beautified code: {out_lua}")

    out_txt = os.path.join(script_dir, f"{base}.decrypted.txt")
    with open(out_txt, 'w', encoding='utf-8') as f:
        f.write("=" * 60 + "\n")
        f.write(f"XHider IBV Mode Decrypted Strings ({os.path.basename(input_path)})\n")
        f.write("=" * 60 + "\n\n")

        readable = []
        binary = []
        for i, entry in enumerate(table):
            if entry["type"] == "string":
                s = entry["val"]
                is_readable = len(s) > 0 and all(32 <= ord(c) <= 126 or c in '\n\r\t' for c in s)
                if is_readable:
                    readable.append((i, s))
                else:
                    binary.append((i, s))

        f.write(f"--- Readable Strings ({len(readable)}) ---\n")
        for idx, s in readable:
            safe = s.replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')
            f.write(f"[{idx}] {safe}\n")

        f.write(f"\n--- Binary/Encrypted Strings ({len(binary)}) ---\n")
        for idx, s in binary:
            hex_repr = s.encode('latin-1', errors='replace').hex()
            f.write(f"[{idx}] hex={hex_repr[:80]}\n")

    print(f"  String dump: {out_txt}")

    print(f"\nDecrypted strings ({len(readable)} readable, {len(binary)} binary):")
    shown = 0
    for idx, s in readable:
        if len(s) >= 1:
            print(f"  [{idx}] {repr(s)}")
            shown += 1
            if shown >= 30:
                print("  ... (truncated)")
                break

    print("\nDone!")


if __name__ == "__main__":
    main()

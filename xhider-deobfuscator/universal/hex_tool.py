import re
import sys

def hex_to_bytes(hex_str):
    """Converts hex string to byte array."""
    hex_str = re.sub(r'[^0-9a-fA-F]', '', hex_str)
    try:
        return bytes.fromhex(hex_str)
    except Exception as e:
        return f"Error: {e}"

def bytes_to_hex(data):
    """Converts bytes to hex string."""
    return data.hex().upper()

def hex_reverse_search(text):
    """Finds hex segments in text and shows decoded strings."""
    # Matches strings of 10+ hex characters
    matches = re.finditer(r'["\']([0-9a-fA-F]{10,})["\']', text)
    results = []
    for m in matches:
        hex_val = m.group(1)
        data = hex_to_bytes(hex_val)
        try:
            decoded = data.decode('utf-8', errors='replace')
            # Only keep if it looks like real text (mostly printable)
            printable_ratio = sum(1 for c in decoded if c.isprintable()) / len(decoded)
            if printable_ratio > 0.5:
                results.append((m.start(), hex_val, decoded))
        except:
            pass
    return results

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python hex_tool.py decode <hex_file_or_string>")
        print("  python hex_tool.py encode <string>")
        print("  python hex_tool.py search <lua_file>")
        sys.exit(1)

    cmd = sys.argv[1].lower()
    val = sys.argv[2] if len(sys.argv) > 2 else ""

    if cmd == "decode":
        print(hex_to_bytes(val))
    elif cmd == "encode":
        print(bytes_to_hex(val.encode('utf-8')))
    elif cmd == "search":
        try:
            with open(val, 'r', encoding='utf-8') as f:
                content = f.read()
            found = hex_reverse_search(content)
            if not found:
                print("No clear hex-encoded ASCII strings found.")
            for pos, h, d in found:
                print(f"[{pos}] Hex: {h[:30]}...")
                print(f"      Dec: {d}")
                print("-" * 40)
        except Exception as e:
            print(f"Error reading file: {e}")

import sys

def decode_psu(encoded_str):
    if encoded_str.startswith("PSU|"):
        encoded_str = encoded_str[4:]
    
    # Character map
    # The Lua script initializes d and c with characters 0 to e-1
    # e = #wn + 185 = 73 + 185 = 258
    # But usually it's just chr(i)
    d = {i: chr(i) for i in range(258)}
    c = {chr(i): i for i in range(258)}
    
    next_index = 258
    
    pos = 0
    def get_next_val():
        nonlocal pos
        if pos >= len(encoded_str):
            return None
        # Read one char for length
        o_str = encoded_str[pos:pos+1]
        pos += 1
        o = int(o_str, 36)
        # Read o chars for value
        val_str = encoded_str[pos:pos+o]
        pos += o
        return int(val_str, 36)

    first_val = get_next_val()
    if first_val is None:
        return ""
    
    output = []
    o = d[first_val]
    output.append(o)
    
    while True:
        n = get_next_val()
        if n is None:
            break
        
        if n in d:
            t = d[n]
        else:
            t = o + o[0]
        
        output.append(t)
        d[next_index] = o + t[0]
        next_index += 1
        o = t
        
    return "".join(output)

if __name__ == "__main__":
    # Read the PSU string from the file
    # For now, I'll just paste the one from print_hi.lua.chunk_1.lua if I can
    # Or I can try to find it in the file
    with open(sys.argv[1], "r", encoding="utf-8") as f:
        content = f.read()
    
    import re
    # Look for "PSU|..."
    match = re.search(r'"PSU\|([^"]+)"', content)
    if not match:
        # Try single quotes
        match = re.search(r"'PSU\|([^']+)'", content)
    
    if match:
        psu_str = match.group(1)
        decoded = decode_psu("PSU|" + psu_str)
        # Use latin-1 to keep bytes as-is
        sys.stdout.buffer.write(decoded.encode('latin-1'))
    else:
        sys.stderr.write("PSU string not found\n")

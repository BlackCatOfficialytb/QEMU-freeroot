import re
import math
import sys

def decrypt_hard(input_file):
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    print("Parsing file...")

    # Helper to eval lua math
    def lua_eval(expr):
        try:
            # Replace lua syntax
            expr = expr.replace('\n', ' ')
            # simplistic
            return int(eval(expr, {"__builtins__": None}))
        except:
            return 0

    # 1. Extract _0 x193 table
    # It starts at `local _0 x193 = {` and ends at `}` (before the loop)
    # Regex to find the table content
    # Note: The table contains strings with escapes.
    
    # Regex to find the table content
    # Look for local _0 x193 = { ... } followed by `for`
    table_match = re.search(r'local\s+_0 x193\s*=\s*{(.*?)}\s*for', content, re.DOTALL)
    if not table_match:
        # Try finding the closing brace manually if regex fails
        start_marker = "local _0 x193 = {"
        start_idx = content.find(start_marker)
        if start_idx != -1:
            # find matching brace? 
            # Or just search for `for _0 x` which comes after
            end_idx = content.find("for _0 x", start_idx)
            if end_idx != -1:
                # Backtrack to }
                table_end = content.rfind("}", start_idx, end_idx)
                if table_end != -1:
                    table_content = content[start_idx + len(start_marker):table_end]
                    table_match = True 
        
        if not table_match:
            print("Could not find table _0 x193")
            return

    if isinstance(table_match, re.Match):
        table_content = table_match.group(1)
    
    # Parse the table items. Strings can contain commas, so we need a smarter split.
    # But wait, looking at the file:
    # "string", math, "string", math;
    # It uses ; and , as separators.
    
    items = []
    # Simple state machine to parse the list
    current_item = ""
    in_quote = False
    quote_char = None
    escape = False
    
    for char in table_content:
        if in_quote:
            if escape:
                current_item += char
                escape = False
            elif char == '\\':
                current_item += char
                escape = True
            elif char == quote_char:
                current_item += char
                in_quote = False
            else:
                current_item += char
        else:
            if char in ['"', "'"]:
                in_quote = True
                quote_char = char
                current_item += char
            elif char in [',', ';']:
                if current_item.strip():
                    items.append(current_item.strip())
                current_item = ""
            else:
                current_item += char
    if current_item.strip():
        items.append(current_item.strip())

    # Evaluate items
    parsed_table = []
    for item in items:
        item = item.strip()
        if (item.startswith('"') and item.endswith('"')) or (item.startswith("'") and item.endswith("'")):
            # It's a string, we need to resolve lua escapes if we want exact bytes
            # python's eval might work if we verify syntax
            # But let's just keep it as a python string for now, we might need to decode escapes
            # Custom decode
            parsed_table.append({"type": "string", "val": item})
        else:
            # It's an expression
            val = lua_eval(item)
            parsed_table.append({"type": "number", "val": val})

    print(f"Extracted {len(parsed_table)} items from table.")

    # 2. Extract Shuffling Pairs
    # ipairs({{ ... }, { ... }})
    # Regex for the ipairs content
    ipairs_match = re.search(r'ipairs\(\{(.*?)\}\)do', content, re.DOTALL)
    if ipairs_match:
        pairs_content = ipairs_match.group(1)
        # Split by }, {
        # This is rough, assumes no nested tables
        pair_strings = re.split(r'\}\s*,\s*\{', pairs_content)
        
        pairs = []
        for p_str in pair_strings:
            p_str = p_str.replace('{', '').replace('}', '')
            # Split by ; or ,
            parts = re.split(r'[,;]', p_str)
            if len(parts) >= 2:
                start = lua_eval(parts[0])
                end = lua_eval(parts[1])
                pairs.append((start, end))
        
        print(f"Found {len(pairs)} shuffle pairs: {pairs}")
        
        # Apply Sorting (Reverse sections)
        # Lua 1-based indexing
        for start, end in pairs:
            # Determine logic:
            # The loop is: while start < end do swap(start, end); start++; end--;
            # This reverses the range [start, end]
            
            # Python 0-based: start-1 to end (exclusive? no, slice includes end)
            # range is inclusive in Lua
            
            s = start - 1
            e = end - 1
            
            if s < 0: s = 0
            if e >= len(parsed_table): e = len(parsed_table) - 1
            
            if s < e:
                # Reverse slice
                # parsed_table[s:e+1] = reversed(parsed_table[s:e+1])
                # We can just swap in a loop to be safe
                while s < e:
                    parsed_table[s], parsed_table[e] = parsed_table[e], parsed_table[s]
                    s += 1
                    e -= 1

    # 3. Extract Key Table _0 xb3 e
    # It contains keys like `["8"] = ...`, `r = ...`
    keys_match = re.search(r'local\s+_0 xb3 e\s*=\s*{(.*?)}', content, re.DOTALL)
    key_map = {}
    if keys_match:
        keys_content = keys_match.group(1)
        # Parse items
        # format: key = expr; or ["key"] = expr;
        # Split by ; or , but match carefully
        k_items = re.split(r'[;,]', keys_content)
        for item in k_items:
            if '=' not in item: continue
            k, v = item.split('=', 1)
            k = k.strip()
            v = v.strip()
            
            if k.startswith('[') and k.endswith(']'):
                k = k[2:-2] # remove [" ... "]
            
            val = lua_eval(v)
            key_map[k] = val
            
    print(f"Extracted {len(key_map)} keys.")

    # 4. Decrypt Strings
    # Logic:
    # byte = byte - (-429525 + 429574)  => byte - 49
    # Then Base64-like decode
    
    # Reconstruct Base64 decode logic from lua:
    # Buffer `_0 x42 a` accumulates value: `curr + val * (64 ^ (3 - f))` (if we map math)
    # Actually checking lines 161:
    # _0 x42 a = _0 x42 a + _0 xf5 c * (( ... ) + 262390) ^ ((407455 + - 407452) - _0 xfeb)
    #  Base = (-964195 + 701869 + 262390) => 64
    #  Power = (3) - _0 xfeb
    #  _0 xfeb increments. 
    # This is classic Base64 logic: 4 chars -> 3 bytes using base 64.
    
    # Wait, Step 1: "byte - 49"
    # The script has TWO loops.
    # Loop 1 (148-151): iterates string bytes.
    # _0 x1 bc = byte - 49.
    # construct new string.
    
    # Loop 2 (157+):
    # uses this new string (which is base64 encoded?)
    # iterates and decodes using table.
    
    decrypted_strings = []
    
    for idx, entry in enumerate(parsed_table):
        if entry["type"] != "string": continue
        
        raw_lua_str = entry["val"]
        # Remove quotes
        s_content = raw_lua_str[1:-1]
        
        # Decode Lua escapes to bytes
        # Python's string escape decoding is tricky for Lua. 
        # Manual escape handler is safer.
        
        byte_vals = []
        i = 0
        while i < len(s_content):
            c = s_content[i]
            if c == '\\':
                if i+1 < len(s_content):
                    next_c = s_content[i+1]
                    if next_c.isdigit():
                        # \ddd
                        d = next_c
                        j = i + 2
                        while j < len(s_content) and j < i + 4 and s_content[j].isdigit():
                            d += s_content[j]
                            j += 1
                        byte_vals.append(int(d))
                        i = j
                    elif next_c == 'n': byte_vals.append(10); i+=2
                    elif next_c == 'r': byte_vals.append(13); i+=2
                    elif next_c == 't': byte_vals.append(9); i+=2
                    elif next_c == '\\': byte_vals.append(92); i+=2
                    elif next_c == '"': byte_vals.append(34); i+=2
                    elif next_c == "'": byte_vals.append(39); i+=2
                    else: byte_vals.append(ord(next_c)); i+=2 # literal escape?
                else:
                    byte_vals.append(92); i+=1
            else:
                byte_vals.append(ord(c))
                i += 1
                
        # Phase 1: Shift
        shifted_bytes = []
        for b in byte_vals:
            # _0 x1 bc = _0 x1 bc - 49
            nb = (b - 49) % 256 # Wrap mostly irrelevant if valid but good for safety
            shifted_bytes.append(chr(nb))
            
        base64_str = "".join(shifted_bytes)
        
        # Phase 2: Base64 Decode using map
        # map key -> val
        # If key is not in map, ignore (unless '=')
        
        decoded_bytes = []
        buffer = 0
        bits_collected = 0
        
        # Logic says: 
        # _0 xfeb counts 0 to 3.
        # buffer += val * (64 ** (3 - count))
        # if count == 3: decode 3 bytes
        
        count = 0 
        buffer = 0
        
        for char in base64_str:
            if char == '=':
                break 
                
            if char not in key_map:
                continue
                
            val = key_map[char]
            
            # buffer += val * (64 ** (3 - count))
            buffer += val * (64 ** (3 - count))
            count += 1
            
            if count == 4:
                # Decode 3 bytes
                # b1 = floor(buffer / 65536)
                # b2 = floor((buffer % 65536) / 256)
                # b3 = buffer % 256
                b1 = math.floor(buffer / 65536)
                b2 = math.floor((buffer % 65536) / 256)
                b3 = buffer % 256
                
                decoded_bytes.append(b1)
                decoded_bytes.append(b2)
                decoded_bytes.append(b3)
                
                buffer = 0
                count = 0
                
        # Handle padding if needed? script implies logic for padding but standard B64 usually suffices.
        # If count > 0 at end, we have partial bytes. 
        # But looking at logic, it seems standard.
        
        final_str = "".join(chr(b) for b in decoded_bytes if b > 0)
        decrypted_strings.append(final_str)
        print(f"[{idx}] {final_str}")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", required=True, help="Input obfuscated lua file")
    args = parser.parse_args()
    decrypt_hard(args.input)

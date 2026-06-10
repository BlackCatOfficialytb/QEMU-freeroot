import re
import math
import sys

def decrypt_strong(input_file):
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    print("Parsing file...")

    def lua_eval(expr):
        try:
            expr = expr.replace('\n', ' ')
            return int(eval(expr, {"__builtins__": None}))
        except:
            return 0

    # 1. Extract L table
    # local L = { ... }
    # Ends before `local function N` or just `local function`
    l_match = re.search(r'local\s+L\s*=\s*{(.*?)}\s*local\s+function', content, re.DOTALL)
    if not l_match:
        # Fallback
        l_match = re.search(r'local\s+L\s*=\s*{(.*?)};', content, re.DOTALL)
        
    if not l_match:
        print("Could not find table L")
        return

    table_content = l_match.group(1)
    
    # Parse L items (strings)
    items = []
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

    parsed_table = []
    for item in items:
        item = item.strip()
        if (item.startswith('"') and item.endswith('"')) or (item.startswith("'") and item.endswith("'")):
            parsed_table.append({"type": "string", "val": item})
        else:
            val = lua_eval(item)
            parsed_table.append({"type": "number", "val": val})

    print(f"Extracted {len(parsed_table)} items from table L.")

    # 2. Extract Shuffles
    # for N, M in ipairs({{...}, ...}) do
    ipairs_match = re.search(r'ipairs\(\{(.*?)\}\)do', content, re.DOTALL)
    if ipairs_match:
        pairs_content = ipairs_match.group(1)
        # Split by }, {
        pair_strings = re.split(r'\}\s*,\s*\{', pairs_content)
        
        # In Strong Mode, the pairs might be complex.
        # { - 1039867 - (871972 + - 1911840); 120882 - (478005 - 357193)}
        # They are pairs of numbers.
        
        # Verify loop logic at line 53: 
        # while M[1] < M[2] do ... swap ... end
        # So it sorts/reverses a range.
        
        for p_str in pair_strings:
            p_str = p_str.replace('{', '').replace('}', '')
            parts = re.split(r'[;,]', p_str) # can be ; or ,
            if len(parts) >= 2:
                # Need to handle math expressions in parts
                start = lua_eval(parts[0])
                end = lua_eval(parts[1])
                
                # Apply shuffle (Reverse range)
                s = start - 1
                e = end - 1
                
                if s < 0: s = 0
                if e >= len(parsed_table): e = len(parsed_table) - 1
                
                if s < e:
                    while s < e:
                        parsed_table[s], parsed_table[e] = parsed_table[e], parsed_table[s]
                        s += 1
                        e -= 1
        print("Applied shuffles.")

    # 3. Extract Key Map N
    # local N = { ... }
    # Search for `local N = {` AFTER the loop?
    # The loop ends with `end do` at line 56? No `end` then `do`? 
    # Ah line 56: `end do`. Wait, `for ... do ... end` loop.
    # Line 56: `end do` might be beautifier artifact or multiple loops.
    # Actually line 57: `local N = {`
    
    n_match = re.search(r'local\s+N\s*=\s*{(.*?)}', content, re.DOTALL)
    if not n_match:
         # Maybe it captured the function N?
         # The table N is defined later
         # Regex for `local N = {` matches the first one? 
         # Line 48 is `local function N`.
         # So `local N = {` should match the table.
         pass

    key_map = {}
    if n_match:
        keys_content = n_match.group(1)
        k_items = re.split(r'[;,]', keys_content)
        for item in k_items:
            if '=' not in item: continue
            k, v = item.split('=', 1)
            k = k.strip()
            v = v.strip()
            
            if k.startswith('[') and k.endswith(']'):
                k = k[2:-2] # remove [" ... "]
            elif k.startswith('"') or k.startswith("'"):
                 # key is string w/o brackets? rare in lua tables unless formatted
                 k = k[1:-1]
            
            val = lua_eval(v)
            key_map[k] = val
            
    print(f"Extracted {len(key_map)} keys from N.")

    # 4. Decrypt Strings
    # Loop over parsed_table
    decrypted_strings = []
    
    for idx, entry in enumerate(parsed_table):
        if entry["type"] != "string": continue
        
        raw_lua_str = entry["val"]
        s_content = raw_lua_str[1:-1]
        
        # Decode escapes
        byte_vals = []
        i = 0
        while i < len(s_content):
            c = s_content[i]
            if c == '\\':
                if i+1 < len(s_content):
                    next_c = s_content[i+1]
                    if next_c.isdigit():
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
                    else: byte_vals.append(ord(next_c)); i+=2
                else:
                    byte_vals.append(92); i+=1
            else:
                byte_vals.append(ord(c))
                i += 1
        
        # Strong Mode Logic:
        # Loop 102:
        # I = I + Y * (64) ^ ...
        # No initial shift ("-49") seen in the loop on lines 102-130.
        # It just takes `L` (char), finds `N[L]`, accumulates base64.
        # So it's pure Base64 decode using custom alphabet.
        
        # The string L[N] is the encoded string.
        # "2FwW8Cme3j==" etc.
        
        decoded_bytes = []
        buffer = 0
        count = 0 
        
        # Base64 chars
        chars = "".join(chr(b) for b in byte_vals)
        
        for char in chars:
            if char == '=':
                continue # Padding
            
            if char not in key_map:
                continue
                
            val = key_map[char]
            
            # Logic in lua:
            # I = I + Y * (64) ^ ((3) - H)
            # Standard Base64 accumulation
            
            buffer = (buffer << 6) | val
            count += 1
            
            if count == 4:
                b1 = (buffer >> 16) & 0xFF
                b2 = (buffer >> 8) & 0xFF
                b3 = buffer & 0xFF
                decoded_bytes.extend([b1, b2, b3])
                buffer = 0
                count = 0
        
        # Handle remaining (if any, though standard B64 implies 4-blocks)
        if count == 3:
             b1 = (buffer >> 10) & 0xFF # shifted by 2? 
             b2 = (buffer >> 2) & 0xFF
             decoded_bytes.extend([b1, b2])
        elif count == 2:
             b1 = (buffer >> 4) & 0xFF
             decoded_bytes.append(b1)
             
        final_str = "".join(chr(b) for b in decoded_bytes if b > 0) # filter nulls?
        # Actually standard b64 can have nulls, but for strings usually not
        
        print(f"[{idx}] {final_str}")
        decrypted_strings.append(final_str)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        decrypt_strong(sys.argv[1])
    else:
        decrypt_strong(r"d:\dec bot2\strong_mode\106225638336511.beautified.utf8.lua")

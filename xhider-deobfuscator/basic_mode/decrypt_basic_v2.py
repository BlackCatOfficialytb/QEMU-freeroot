import re
import sys

def decrypt_lua_basic(input_file):
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading file: {e}")
        return

    # Extracted from Lua source
    R_keys = [0xF5, 0xD1, 0xC6, 0xC5]
    
    # Extract the long obfuscated string 'U'
    u_match = re.search(r'local U="(.*?)"', content)
    if not u_match:
        # Try simplified spacing
        u_match = re.search(r'local\s+U\s*=\s*"(.*?)"', content)
        
    if not u_match:
        print("Could not find payload string U")
        return
    
    U_str = u_match.group(1)
    
    def decode_n(p):
        R = []
        n = 1
        U = len(p)
        while n <= U:
            if ord(p[n-1]) == 0x7A:
                for _ in range(4): R.append(0)
                n += 1
            else:
                a = 0
                X = 5
                if n + 4 > U:
                    X = (U - n) + 1
                    
                for j in range(1, X + 1):
                    val = ord(p[n + j - 1 - 1]) - 0x21
                    a = a * 0x55 + val
                
                for j in range(X + 1, 6):
                    a = a * 0x55 + 0x54
                
                M = (a // 0x1000000) % 0x100
                y = (a // 0x10000) % 0x100
                o = (a // 0x100) % 0x100
                v = a % 0x100
                
                R.append(M)
                R.append(y)
                R.append(o)
                R.append(v)
                
                n += (5 if X == 5 else X)
        return R

    X = decode_n(U_str)
    
    def decrypt_xor(p, B):
        a = 0
        for R in range(8):
            n = p/2 + B/2
            if n != int(n):
                 a = a + 2**R
            p = int(p/2)
            B = int(B/2)
        return a

    def decrypt_string(j_idx, X_arr):
        n = j_idx # Lua: n=j+1. X[n] access via X[n-1].
        # In Python X is 0-based.
        # Lua: X[n] -> Python X[n-1+1-1] = X[n]
        # Wait. Lua is 1-based.
        # Call S(0). j=0. n=1. X[1] (Lua) -> X[0] (Py).
        # So X index IS j_idx.
        
        if n + 3 >= len(X_arr): return None, 0
        
        b1 = decrypt_xor(X_arr[n], R_keys[0])
        b2 = decrypt_xor(X_arr[n+1], R_keys[1])
        b3 = decrypt_xor(X_arr[n+2], R_keys[2])
        b4 = decrypt_xor(X_arr[n+3], R_keys[3])
        
        length = b1 + b2*256 + b3*65536 + b4*16777216
        
        n_start = n + 4
        res = ""
        
        for j in range(1, length + 1):
            # Lua: B=(j-1)%4+1. Index into R (1-based).
            # Python R index: (j-1)%4
            
            # Lua: X[(n+j)-1]. 
            # n here is already incremented by 4 in Lua.
            # Python X index: (n_start + j - 1)
            
            key_idx = (j - 1) % 4
            val_idx = n_start + j - 1
            
            if val_idx >= len(X_arr): break
            
            char_code = decrypt_xor(X_arr[val_idx], R_keys[key_idx])
            res += chr(char_code)
            
        return res, length

    print("--- Decrypted Strings ---")
    curr = 0
    decrypted_map = {}
    
    while curr < len(X):
        s, length = decrypt_string(curr, X)
        if s is not None:
             # Look for known VM strings
             print(f"Offset {curr} ({hex(curr)}): {repr(s)}")
             decrypted_map[curr] = s
             curr += 4 + length
        else:
             break
             
    # Replace in content
    # Regex: e[S(0x...)] or _AOaUwkb~=e[S(0x0)]
    
    def replacer(match):
        hex_val = match.group(1)
        val = int(hex_val, 16)
        if val in decrypted_map:
            s = decrypted_map[val]
            s = s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r')
            return f'"{s}"'
        return match.group(0)

    new_content = re.sub(r'e\[S\((0x[0-9A-Fa-f]+)\)\]', replacer, content)
    new_content = re.sub(r'S\((0x[0-9A-Fa-f]+)\)', replacer, new_content)

    out_file = input_file + ".decrypted.lua"
    with open(out_file, "w", encoding='utf-8') as f:
        f.write(new_content)
    print(f"Saved to {out_file}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        decrypt_lua_basic(sys.argv[1])
    else:
        decrypt_lua_basic("d:\\dec bot2\\basic_mode\\1765094582044242.lua")

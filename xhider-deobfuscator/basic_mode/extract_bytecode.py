import re
import sys

def decrypt_lua_basic_v6(input_file):
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading file: {e}")
        return

    R_keys = [0xF5, 0xD1, 0xC6, 0xC5]
    
    u_match = re.search(r'local U="((?:[^"\\]|\\.)*)"', content)
    if not u_match:
        u_match = re.search(r'local\s+U\s*=\s*"((?:[^"\\]|\\.)*)"', content)
        
    if not u_match:
        print("Could not find payload U")
        return
    
    U_raw = u_match.group(1)

    def lua_unescape(s):
        res = []
        i = 0
        n = len(s)
        while i < n:
            c = s[i]
            if c == '\\':
                if i + 1 >= n:
                    res.append('\\')
                    break
                next_c = s[i+1]
                if next_c.isdigit():
                    d = next_c
                    j = i + 2
                    while j < n and j < i + 4 and s[j].isdigit():
                        d += s[j]
                        j += 1
                    res.append(chr(int(d)))
                    i = j
                elif next_c == 'a': res.append('\a'); i += 2
                elif next_c == 'b': res.append('\b'); i += 2
                elif next_c == 'f': res.append('\f'); i += 2
                elif next_c == 'n': res.append('\n'); i += 2
                elif next_c == 'r': res.append('\r'); i += 2
                elif next_c == 't': res.append('\t'); i += 2
                elif next_c == 'v': res.append('\v'); i += 2
                elif next_c == '\\': res.append('\\'); i += 2
                elif next_c == '"': res.append('"'); i += 2
                elif next_c == "'": res.append("'"); i += 2
                elif next_c == '\n': i += 2
                else: res.append(next_c); i += 2
            else:
                res.append(c)
                i += 1
        return "".join(res)

    U_str = lua_unescape(U_raw)
    
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
        n = j_idx 
        if n + 3 >= len(X_arr): return None, 0
        
        b1 = decrypt_xor(X_arr[n], R_keys[0])
        b2 = decrypt_xor(X_arr[n+1], R_keys[1])
        b3 = decrypt_xor(X_arr[n+2], R_keys[2])
        b4 = decrypt_xor(X_arr[n+3], R_keys[3])
        
        length = b1 + b2*256 + b3*65536 + b4*16777216
        
        if length > 10000: return None, 0
        
        n_start = n + 4
        res = bytearray()
        
        for j in range(1, length + 1):
            key_idx = (j - 1) % 4
            val_idx = n_start + j - 1
            if val_idx >= len(X_arr): break
            char_code = decrypt_xor(X_arr[val_idx], R_keys[key_idx])
            res.append(char_code)
            
        return res, length

    # Extract bytecode at 0x5E
    bytecode, b_len = decrypt_string(0x5E, X)
    if bytecode:
        print(f"Extracted Bytecode at 0x5E, length {len(bytecode)}")
        with open(input_file + ".luac", "wb") as f:
            f.write(bytecode)
            print(f"Saved bytecode to {input_file + '.luac'}")
            
    # Also save decrypted Strings
    print("Strings found:")
    for offset in [0x0, 0x32, 0x3B, 0x40, 0x44, 0x4C, 0x54, 0xAF]:
        s_bytes, l = decrypt_string(offset, X)
        if s_bytes:
             try:
                 print(f"Offset {hex(offset)}: {s_bytes.decode('latin1')}")
             except:
                 print(f"Offset {hex(offset)}: <binary>")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        decrypt_lua_basic_v6(sys.argv[1])
    else:
        decrypt_lua_basic_v6("d:\\dec bot2\\basic_mode\\1765094582044242.lua")

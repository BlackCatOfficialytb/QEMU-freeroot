import re

def decrypt_lua_basic(input_file):
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Extracted from Lua source
    R_keys = [0xF5, 0xD1, 0xC6, 0xC5]
    
    # Extract the long obfuscated string 'U'
    u_match = re.search(r'local U = "(.*?)"', content)
    if not u_match:
        print("Could not find payload string U")
        return
    
    U_str = u_match.group(1)
    
    # Lua logic reproduction:
    # function n(p, a) local R={} ... end
    # We need to implement this 'n' function logic in Python.
    
    def decode_n(p):
        R = []
        n = 1
        U = len(p)
        while n <= U:
            # Lua: if B(p,n)==0x7A then ...
            if ord(p[n-1]) == 0x7A:
                # for j=1,4 do R[#R+1]=0 end
                for _ in range(4): R.append(0)
                n += 1
            else:
                a = 0
                X = 5
                # if n+4 > U then X = (U-n)+1 end
                if n + 4 > U:
                    X = (U - n) + 1
                    
                # for j=1,X do a=a*0x55+(B(p,n+j-1)-0x21) end
                for j in range(1, X + 1):
                    val = ord(p[n + j - 1 - 1]) - 0x21
                    a = a * 0x55 + val
                
                # for j=X+1,5 do a=a*0x55+0x54 end
                for j in range(X + 1, 6):
                    a = a * 0x55 + 0x54
                
                # Big number splitting logic
                # M = floor(a/0x1000000)%0x100
                M = (a // 0x1000000) % 0x100
                y = (a // 0x10000) % 0x100
                o = (a // 0x100) % 0x100
                v = a % 0x100
                
                R.append(M)
                R.append(y)
                R.append(o)
                R.append(v)
                
                n += (5 if X == 5 else X)
                
        # for j=1,a do R[#R]=nil end -- 'a' here is the SECOND arg to n(p,a), which is 0x0 in call.
        # local X=n(U, 0x0). So we remove 0 elements? 
        # Wait, the Lua code says: local function n(p,a) ... for j=1,a,1 do R[#R]=nil end.
        # In the call `local X = n(U, 0x0)`, a is 0. So no removal.
        return R

    X = decode_n(U_str)
    
    # Decrypt strings using `S(j)` function logic
    # S(j) uses global X (decoded bytes) and R (keys)
    # logic:
    # n = j + 1
    # U = (a(X[n], R[1]) + ...) -> decrypted length
    # n = n + 4
    # M = {} for j=1,U do ... end
    
    def decrypt_xor(p, B):
        # function a(p, B) ... return a end
        # logic: for R=0,7 do n=p/2+B/2 if n~=floor(n) then a=a+2^R end p=floor(p/2) B=floor(B/2) end
        # This is essentially XOR.
        return p ^ B

    def decrypt_string(j_idx):
        # j_idx is 0-based index from Lua call e.g. S(0x0)
        # Lua arrays are 1-based. X[n] access using n=j+1.
        
        # Adjust for Python 0-based list X
        n = j_idx # X[n] in Lua is X[n-1] in Python? No, n=j+1. X[j].
        
        if n >= len(X): return None
        
        # Read length (4 bytes)
        # Lua: a(X[n], R[1]) ...
        # Python: X[n] ^ R[0]
        
        try:
            b1 = decrypt_xor(X[n], R_keys[0])
            b2 = decrypt_xor(X[n+1], R_keys[1])
            b3 = decrypt_xor(X[n+2], R_keys[2])
            b4 = decrypt_xor(X[n+3], R_keys[3])
            
            length = b1 + b2*256 + b3*65536 + b4*16777216
            
            n += 4
            res = ""
            for k in range(length):
                # Lua: (j-1)%4 + 1. j starts at 1.
                # k starts 0. Lua j = k+1.
                # key_idx: ((k+1)-1)%4 + 1 = k%4 + 1. Python index k%4.
                key_idx = k % 4
                
                # val: X[n+j-1] -> X[n+k]
                val = X[n + k]
                key = R_keys[key_idx]
                decoded_char = chr(decrypt_xor(val, key))
                res += decoded_char
                
            return res
        except Exception as e:
            print(f"Error decoding string at {j_idx}: {e}")
            return None

    # Find all S(0x...) calls and replace them
    def replacer(match):
        hex_val = match.group(1)
        val = int(hex_val, 16)
        decrypted = decrypt_string(val)
        if decrypted:
            # Escape for code
            decrypted = decrypted.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
            return f'"{decrypted}"'
        return match.group(0)

    # Regex for e[S(0x...)]
    # The beautified code has `e[S(0 x...)]` or `e[S(0x...)]`?
    # Original file had `e[S(0x0)]`. 
    # Let's target the hex pattern.
    
    # We should run this on the original file logic or beautified?
    # Beautified is easier to parse manually but might have broken spacing.
    # The logic above parses 'U' from content.
    
    new_content = re.sub(r'e\[S\((0x[0-9A-Fa-f]+)\)\]', replacer, content)
    
    # Also dump all strings?
    # We can walk the X array.
    # The offset `j` increments by length + 4.
    
    print("Dumping all strings:")
    curr = 0
    while curr < len(X):
        s = decrypt_string(curr)
        if s is not None:
            print(f"Offset {hex(curr)}: {s}")
            curr += 4 + len(s)
        else:
            break
            
    with open(input_file + ".decrypted.lua", "w", encoding='utf-8') as f:
        f.write(new_content)

if __name__ == "__main__":
    pass

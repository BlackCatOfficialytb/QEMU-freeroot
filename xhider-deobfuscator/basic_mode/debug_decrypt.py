import re
import sys

# DEBUG VERSION to print intermediate values
def debug_decrypt(input_file):
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    def lua_unescape(s):
        # ... (same as v4)
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

    U_match = re.search(r'local U="(.*?)"', content) or re.search(r'local\s+U\s*=\s*"(.*?)"', content)
    if not U_match:
        print("No U")
        return
        
    U_str = lua_unescape(U_match.group(1))
    print(f"DEBUG: U len = {len(U_str)}")
    print(f"DEBUG: U[:20] hex = {' '.join(hex(ord(c)) for c in U_str[:20])}")
    
    # Lua logic reproduction for 'n'
    def decode_n(p, a_arg):
        R = []
        n = 1
        U_len = len(p)
        while n <= U_len:
            byte_at_n = ord(p[n-1])
            if byte_at_n == 0x7A:
                for _ in range(4): R.append(0)
                n += 1
            else:
                a = 0
                X = 5
                if n + 4 > U_len:
                    X = (U_len - n) + 1
                    
                # Python loop 1..X
                for j in range(1, X + 1):
                    # Lua: B(p, (n+j)-1) - 0x21
                    # Python p index: (n+j-2) ?
                    # n is 1-based index in Lua. n-1 is python index.
                    # n+j-1 is python index.
                    # Lua: (n+j)-1 points to: if n=1,j=1 -> 1. X[1]
                    # Python: p[n-1 + j-1] ? No.
                    # Lua starts array at 1. p[1] is first char.
                    # B(p, (n+j)-1). n=1, j=1 -> B(p, 1). First char.
                    # Python p[0].
                    # So index is `(n + j) - 1 - 1` = `n + j - 2`.
                    
                    val = ord(p[n + j - 2]) - 0x21
                    a = a * 0x55 + val
                
                for j in range(X + 1, 6):
                    a = a * 0x55 + 0x54 # 0x54 is 'T'?
                
                # ... M, y, o, v logic ...
                M = (a // 0x1000000) % 0x100
                y = (a // 0x10000) % 0x100
                o = (a // 0x100) % 0x100
                v = a % 0x100
                
                R.append(M)
                R.append(y)
                R.append(o)
                R.append(v)
                
                n += (5 if X == 5 else X)
        
        # for j=1,a do R[#R]=nil end. a_arg passed is 0.
        return R

    X = decode_n(U_str, 0)
    print(f"DEBUG: X len = {len(X)}")
    print(f"DEBUG: X[:20] = {X[:20]}")
    
    # Check X content.
    # We expect decrypted bytecode or string data.
    
    # Try decrypt offset 0
    R_keys = [0xF5, 0xD1, 0xC6, 0xC5]
    def decrypt_xor(p, B):
        return p ^ B # Simplified XOR for sanity check

    def decrypt_string_simple(offset):
        if offset+4 >= len(X): return "OOB"
        b1 = X[offset] ^ R_keys[0]
        b2 = X[offset+1] ^ R_keys[1]
        b3 = X[offset+2] ^ R_keys[2]
        b4 = X[offset+3] ^ R_keys[3]
        length = b1 + b2*256 + b3*65536 + b4*16777216
        print(f"Offset {offset}: length {length}")
        return length

    decrypt_string_simple(0)
    decrypt_string_simple(0x32)
    decrypt_string_simple(0x3B)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        debug_decrypt(sys.argv[1])

"""Analyze basic_mode VM by extracting bytecode and constants."""
import re
import sys
import struct

def lua_unescape(s):
    res = []
    i = 0
    n = len(s)
    while i < n:
        c = s[i]
        if c == '\\':
            if i + 1 >= n:
                res.append('\\'); break
            nx = s[i+1]
            if nx.isdigit():
                d = nx; j = i+2
                while j < n and j < i+4 and s[j].isdigit():
                    d += s[j]; j += 1
                res.append(chr(int(d))); i = j
            elif nx == 'n': res.append('\n'); i += 2
            elif nx == 'r': res.append('\r'); i += 2
            elif nx == 't': res.append('\t'); i += 2
            elif nx == '\\': res.append('\\'); i += 2
            elif nx == '"': res.append('"'); i += 2
            elif nx == "'": res.append("'"); i += 2
            else: res.append(nx); i += 2
        else:
            res.append(c); i += 1
    return "".join(res)

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
            for j in range(1, X+1):
                a = a*0x55 + (ord(p[n+j-1-1]) - 0x21)
            for j in range(X+1, 6):
                a = a*0x55 + 0x54
            M = (a // 0x1000000) % 0x100
            y = (a // 0x10000) % 0x100
            o = (a // 0x100) % 0x100
            v = a % 0x100
            R.extend([M, y, o, v])
            n += (5 if X == 5 else X)
    return R

def decrypt_string(j_idx, X_arr, R_keys=[0xF5, 0xD1, 0xC6, 0xC5]):
    n = j_idx
    if n + 3 >= len(X_arr): return None
    b1 = X_arr[n]   ^ R_keys[0]
    b2 = X_arr[n+1] ^ R_keys[1]
    b3 = X_arr[n+2] ^ R_keys[2]
    b4 = X_arr[n+3] ^ R_keys[3]
    length = b1 + b2*256 + b3*65536 + b4*16777216
    if length > 100000: return None
    out = bytearray()
    for j in range(length):
        key = R_keys[j % 4]
        out.append(X_arr[n+4+j] ^ key)
    return bytes(out), length

def main(input_file):
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    m = re.search(r'local U="((?:[^"\\]|\\.)*)"', content)
    U_raw = m.group(1)
    U_str = lua_unescape(U_raw)
    X = decode_n(U_str)

    offsets = sorted(set(int(m.group(1), 16) for m in re.finditer(r'S\(\s*(0x[0-9A-Fa-f]+)\s*\)', content)))
    strings = {}
    for off in offsets:
        result = decrypt_string(off, X)
        if result is None: continue
        data, length = result
        try:
            decoded = data.decode('utf-8')
            strings[off] = decoded
        except UnicodeDecodeError:
            strings[off] = data

    bc_str = strings[0x5E]
    if isinstance(bc_str, str):
        bc_bytes = bc_str.encode('latin-1')
    else:
        bc_bytes = bc_str

    # Q is 1-based array of bytes. So Q[1..N]
    # M(j, p): read p bytes starting at 1-based index j, little-endian
    Q = bc_bytes  # 0-based python; for 1-based access do Q[idx-1]

    def M(j, p):
        v = 0
        mul = 1
        for k in range(p):
            v += Q[j + k - 1] * mul
            mul *= 0x100
        return v

    print(f"Bytecode len: {len(Q)}")
    print(f"First bytes: {Q[:32].hex()}")

    # g():
    N = 4
    X_count = M(1, 3)
    print(f"X (num G entries) = {X_count}")
    G = [None]
    for j in range(X_count):
        G.append(M(N + j*3, 3))
    print(f"G[1..]: {G[1:]}")
    N = N + X_count*3
    print(f"N after G: {N}")
    a = M(N, 3)
    print(f"a (num consts) = {a}")
    p_arr = [None]
    for j in range(a):
        p_arr.append(M((N+3) + j*4, 4))
    print(f"p[1..]: {p_arr[1:]}")
    N = (N + a*4) + 6
    print(f"N after p: {N}")
    l = M(N - 3, 3)
    print(f"l (code count) = {l}")
    n_const = N + l*4
    print(f"n (const base) = {n_const}")

    # Constant pool entries: each pointer p[j] is offset into Q from n
    print(f"\n=== Constants ===")
    consts = {}
    for idx in range(1, a+1):
        ptr = p_arr[idx]
        l_ptr = ptr + n_const  # 1-based start of this constant
        type_byte = Q[l_ptr - 1]
        if type_byte == 0:
            slen = M(l_ptr + 1, 4)
            sval = bytes(Q[l_ptr + 5 - 1 : l_ptr + 5 - 1 + slen])
            try:
                consts[idx] = ('string', sval.decode('utf-8'))
            except:
                consts[idx] = ('bytes', sval)
        elif type_byte == 1:
            consts[idx] = ('int', M(l_ptr + 1, 4))
        elif type_byte == 2:
            consts[idx] = ('-int', -M(l_ptr + 1, 4))
        else:
            consts[idx] = ('?', type_byte)
        print(f"  c[{idx}] = {consts[idx]}")

    # Code area: 4 bytes per instruction starting at N (1-based)
    print(f"\n=== Bytecode instructions ({l} total) ===")
    for i in range(l):
        ip = N + i*4   # 1-based
        opcode = Q[ip - 1]
        a1 = Q[ip]; a2 = Q[ip+1]; a3 = Q[ip+2]
        print(f"  [{i}] @{ip} op=0x{opcode:02X} args={a1:02X} {a2:02X} {a3:02X}")

if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else 'print_hi.lua')

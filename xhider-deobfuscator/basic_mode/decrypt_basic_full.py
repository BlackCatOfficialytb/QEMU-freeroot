"""
Full deobfuscator for XHider basic_mode.
Reconstructs real Lua source from string-table + custom-VM bytecode.

Pipeline:
  1. Parse `local U="..."` payload, decode-n into byte array X.
  2. Decrypt all S(off) strings (length+XOR with 4-key wheel).
  3. Locate the bytecode blob (always referenced as Q = e[S(0xXX)]).
  4. Parse the VM header: G[] (const indices), p[] (const offsets),
     code section (l 4-byte instructions), const pool.
  5. Symbolically execute the bytecode with a small state machine to
     recover the original `func(args)` shape.
"""
import re, sys, os

R_KEYS = [0xF5, 0xD1, 0xC6, 0xC5]


def lua_unescape(s):
    res, i, n = [], 0, len(s)
    while i < n:
        c = s[i]
        if c == '\\' and i + 1 < n:
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
    R, n, U = [], 1, len(p)
    while n <= U:
        if ord(p[n-1]) == 0x7A:
            R.extend([0]*4); n += 1
        else:
            a, X = 0, 5
            if n + 4 > U:
                X = (U - n) + 1
            for j in range(1, X+1):
                a = a*0x55 + (ord(p[n+j-2]) - 0x21)
            for j in range(X+1, 6):
                a = a*0x55 + 0x54
            R.extend([(a >> 24) & 0xFF, (a >> 16) & 0xFF,
                      (a >> 8) & 0xFF, a & 0xFF])
            n += (5 if X == 5 else X)
    return R


def decrypt_string(idx, X):
    if idx + 3 >= len(X): return None
    length = (X[idx]   ^ R_KEYS[0]) \
           | ((X[idx+1] ^ R_KEYS[1]) << 8) \
           | ((X[idx+2] ^ R_KEYS[2]) << 16) \
           | ((X[idx+3] ^ R_KEYS[3]) << 24)
    if length > 100000 or idx + 4 + length > len(X): return None
    out = bytes(X[idx+4+j] ^ R_KEYS[j % 4] for j in range(length))
    return out


def parse_bytecode(Q):
    """Parse XHider basic_mode bytecode header. 1-based pointers as in Lua."""
    def M(j, p):
        v = 0
        for k in range(p):
            v |= Q[j+k-1] << (8*k)
        return v

    N = 4
    n_G = M(1, 3)
    G = [None] + [M(N + j*3, 3) for j in range(n_G)]
    N += n_G * 3

    n_p = M(N, 3)
    p_arr = [None] + [M(N + 3 + j*4, 4) for j in range(n_p)]
    N = N + n_p*4 + 6

    l = M(N - 3, 3)
    n_const = N + l*4

    # Decode constant pool
    consts = {}
    for idx in range(1, n_p + 1):
        l_ptr = p_arr[idx] + n_const
        t = Q[l_ptr - 1]
        if t == 0:
            slen = M(l_ptr + 1, 4)
            sval = bytes(Q[l_ptr+4 : l_ptr+4+slen])
            try: consts[idx] = ('string', sval.decode('utf-8'))
            except: consts[idx] = ('string', sval.decode('latin-1'))
        elif t == 1:
            consts[idx] = ('int', M(l_ptr + 1, 4))
        elif t == 2:
            consts[idx] = ('int', -M(l_ptr + 1, 4))
        elif t == 3:
            # custom 8-byte float (rarely used for our targets)
            consts[idx] = ('float', None)
        else:
            consts[idx] = ('unknown', t)

    code = []
    for i in range(l):
        ip = N + i*4
        code.append((Q[ip-1], Q[ip], Q[ip+1], Q[ip+2]))
    return G, consts, code


def lua_lit(v):
    """Render a Lua literal."""
    kind, val = v
    if kind == 'string':
        s = val.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r')
        return f'"{s}"'
    if kind == 'int':
        return str(val)
    if kind == 'float':
        return '0.0  --[[ float (raw bits) ]]'
    return f'--[[?{val}]]'


def reconstruct(G, consts, code):
    """
    Symbolically execute the VM. The VM uses nested frames:
      o = { [0]=parent, [1..s] = locals_in_this_frame }
    with `s` being the top index. Frames map naturally to call expressions.

    Faithful op interpretation (from print_hi.lua VM):
      0xD3 idx     : s++; o[s] = consts[idx]
      0xA6         : o[s] = _G[o[s]]  (no stack change)
      0xC8         : o[s+1] = s; o = {[0]=o}; s = 0   (enter call-arg frame)
      0x86         : copy o[1] (varargs / a-table snapshot)
      0x33 idx     : pop value v; o = o[0]; s = o[idx]+1; o[s] = v
      0xBE         : s--; o[s] = o[s](unpack(o[s+1]))   (CALL)
      0xC2         : o = {[0]=o[0]}; s = 0   (clear current frame)
      0xB2         : return
      0xCF         : header / no-op for reconstruction
    """
    # Each frame: {'stack': [...], 'parent': frame_or_None}
    root = {'stack': [], 'parent': None}
    cur = root
    output_calls = []

    pc = 0
    while pc < len(code):
        op, a1, a2, a3 = code[pc]
        operand = a1 | (a2 << 8) | (a3 << 16)

        if op == 0xD3:    # LOADK
            c = consts.get(operand, ('unknown', operand))
            cur['stack'].append(('const', c))
        elif op == 0xA6:  # GETGLOBAL: top = _G[top]
            top = cur['stack'].pop()
            if top[0] == 'const' and top[1][0] == 'string':
                cur['stack'].append(('global', top[1][1]))
            else:
                cur['stack'].append(('value', f'_G[{render_value(top)}]'))
        elif op == 0xC8:  # ENTER frame
            cur = {'stack': [], 'parent': cur}
        elif op == 0xC2:  # CLEAR current frame
            cur['stack'] = []
        elif op == 0x86:  # snapshot — irrelevant for shape
            pass
        elif op == 0x33:  # MOVE top of cur to parent at slot operand
            v = cur['stack'].pop() if cur['stack'] else ('value', 'nil')
            parent = cur['parent']
            if parent is None:
                parent = root
            parent['stack'].append(v)
            cur = parent
        elif op == 0xBE:  # CALL: callee + args sit on cur stack
            args = cur['stack'].pop() if cur['stack'] else None
            callee = cur['stack'].pop() if cur['stack'] else ('value', '?')
            args_text = render_value(args) if args else ''
            if callee[0] == 'global':
                expr = f'{callee[1]}({args_text})'
            else:
                expr = f'{render_value(callee)}({args_text})'
            output_calls.append(expr)
            cur['stack'].append(('value', 'nil'))
        elif op == 0xB2:  # RETURN
            break
        elif op == 0xCF:  # header/no-op
            pass
        else:
            # unknown opcode — log it
            output_calls.append(f'-- unknown op 0x{op:02X} {a1:02X} {a2:02X} {a3:02X}')
        pc += 1
    return output_calls


def render_value(v):
    if v is None: return ''
    tag, payload = v
    if tag == 'const':
        return lua_lit(payload)
    if tag == 'global':
        return payload
    if tag == 'value':
        return str(payload)
    return repr(v)


def deobfuscate(input_file):
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Long obfuscated payload: any local <name>="<long-string>" referenced by S/string-decoder.
    # Heuristic: pick the longest string literal in a `local X="..."` declaration.
    candidates = re.findall(r'local\s+(\w+)\s*=\s*"((?:[^"\\]|\\.)*)"', content)
    if not candidates:
        print(f"[!] {input_file}: no payload string found"); return
    payload_var, payload = max(candidates, key=lambda c: len(c[1]))
    if len(payload) < 50:
        print(f"[!] {input_file}: payload too short"); return

    U_str = lua_unescape(payload)
    X = decode_n(U_str)

    # Find the string-decoder function name. It maps offsets via `<fn>(0xNN)`.
    # In print_hi the function is `S`. In fibo it might be different. Search for the
    # caller pattern `<name>(0xNN)` whose results are used as table keys.
    s_fn_match = re.search(r'function\s+(\w+)\(\w+\)\s*local\s+\w+\s*=\s*\w+\s+if\s+not\s+\w+\[', content)
    if s_fn_match:
        s_fn = s_fn_match.group(1)
    else:
        s_fn = 'S'
    offsets = sorted(set(int(om.group(1), 16)
                          for om in re.finditer(rf'{re.escape(s_fn)}\(\s*(0x[0-9A-Fa-f]+)\s*\)', content)))
    strings = {}
    for off in offsets:
        d = decrypt_string(off, X)
        if d is None: continue
        strings[off] = d

    # Bytecode is the longest binary string referenced
    bc_off, bc = None, b''
    for off, val in strings.items():
        try:
            val.decode('utf-8')
        except UnicodeDecodeError:
            if len(val) > len(bc):
                bc, bc_off = val, off
    if not bc:
        # Sometimes the bytecode happens to decode as utf-8 (rare). Pick longest.
        bc_off = max(strings, key=lambda o: len(strings[o]))
        bc = strings[bc_off]

    print(f"[+] {input_file}: bytecode at offset {hex(bc_off)} len {len(bc)}")

    G, consts, code = parse_bytecode(bc)
    print(f"    G entries: {len(G)-1}, consts: {len(consts)}, instructions: {len(code)}")
    for i, c in consts.items():
        print(f"    const[{i}] = {c}")

    calls = reconstruct(G, consts, code)
    out_lines = ['-- XHider basic_mode Deobfuscated', '-- Reconstructed Lua source from VM bytecode', '']
    out_lines.append('-- Decoded string constants:')
    for off, val in sorted(strings.items()):
        try:
            txt = val.decode('utf-8')
            out_lines.append(f'-- S({hex(off)}) = "{txt}"')
        except UnicodeDecodeError:
            out_lines.append(f'-- S({hex(off)}) = <bytecode {len(val)} bytes>')
    out_lines.append('')
    out_lines.append('-- Constants in VM:')
    for i, c in consts.items():
        out_lines.append(f'-- c[{i}] = {lua_lit(c)}')
    out_lines.append('')
    if calls:
        out_lines.extend(calls)
    else:
        out_lines.append('-- (no calls reconstructed)')

    out_path = os.path.splitext(input_file)[0] + '.decrypted.lua'
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(out_lines) + '\n')
    print(f"[+] wrote {out_path}")


if __name__ == "__main__":
    files = sys.argv[1:] if len(sys.argv) > 1 else ['print_hi.lua']
    for f in files:
        deobfuscate(f)


# Extend debug_val6.py to checking val 15 as well
import math
import re

# ... (Paste previous functions: decrypt_k4, LuaPRNG, decrypt_a5, unescape_lua, reconstruct_a8) ...
# I will just write the checking logic assuming the functions are there from memory 
# (simulated by re-writing them to be self-contained)

def decrypt_k4(s_in):
    out = bytearray()
    i = 0
    while i < len(s_in):
        c = s_in[i]
        if c == 'z':
            out.extend([0,0,0,0]); i += 1
        elif c.isspace():
            i += 1
        else:
            block = []
            while len(block) < 5 and i < len(s_in):
                char = s_in[i]
                if char in 'z \n\r\t': break
                block.append(char); i += 1
            count = len(block)
            if count == 0: break
            padded = block + ['u'] * (5 - count)
            val = 0
            for char in padded:
                val = val * 85 + (ord(char) - 33)
            # Lua: for H=3, 3-(K[3]-1), -1
            # count=5 => H=3..0 (4 bytes)
            for h in range(3, 4 - count, -1):
                out.append((val // (256**h)) % 256)
    return out

class LuaPRNG:
    def __init__(self, k3, k7):
        self.k3, self.k7, self.k12 = k3, k7, []
    def next(self):
        if not self.k12:
            self.k3 = (self.k3 * 237 + 15189139956072) % 35184372088832
            while True:
                self.k7 = (self.k7 * 203) % 257
                if self.k7 != 1: break
            h1 = self.k7 % 32
            h10 = (math.floor(self.k3 / (2**(13 - (self.k7-h1)//32))) % 4294967296) / (2**h1)
            h9 = math.floor((h10 % 1) * 4294717296) + math.floor(h10)
            h5 = h9 % 65536
            h6 = (h9 - h5) // 65536
            h8 = h5 % 256
            h7 = (h5 - h8) // 256
            h3 = h6 % 256
            h2 = (h6 - h3) // 256
            self.k12 = [h8, h7, h3, h2]
        return self.k12.pop()

def decrypt_a5(ciphertext, seed):
    k3_init = seed % 35184372088832
    k7_init = seed % 255 + 2
    prng_gen = LuaPRNG(k3_init, k7_init)
    curr_h1 = 72
    res = bytearray()
    for b in ciphertext:
        curr_h1 = (b + prng_gen.next() + curr_h1) % 256
        res.append(curr_h1)
    return res

content = open(r'd:\dec bot2\max_security_mode\print_hi.lua', 'r', encoding='utf-8', errors='ignore').read()

def unescape_lua(s):
    if s is None: return ""
    def dec_esc(m): return chr(int(m.group(1)))
    s = re.sub(r'\\([0-9]{3})', dec_esc, s)
    return s.replace('\\"', '"').replace("\\'", "'").replace('\\\\', '\\').replace('\\n', '\n')

def reconstruct_a8(block):
    lb = block.rfind('{')
    if lb == -1: return ""
    indices_p = block[:lb]
    strings_p = block[lb+1 : block.rfind('}')]
    s_l = [unescape_lua(m.group(1) or m.group(2)) for m in re.finditer(r'"((?:[^"\\]|\\.)*)"|\'((?:[^\'\\]|\\.)*)\'', strings_p)]
    def leval(p): return int(eval(p)) if p.strip() else 0
    indices = [leval(p) for p in re.split(r'[;,]', indices_p) if p.strip()]
    return "".join(s_l[i-1] for i in indices if 0 < i <= len(s_l))

print("Parsing a[1]...")
start_match = re.search(r'a\[1\]\s*=\s*\{', content)
p = start_match.end()
bal = 1; parts = []; curr_part = ""; in_q = False; qc = None
while p < len(content):
    c = content[p]
    if in_q:
        curr_part += c
        if c == '\\': p += 1; curr_part += content[p]
        elif c == qc: in_q = False
    else:
        if c in ('"', "'"): in_q = True; qc = c; curr_part += c
        elif c == '{': bal += 1; curr_part += c
        elif c == '}':
            bal -= 1
            if bal == 0: break
            curr_part += c
        elif (c == ',' or c == ';') and bal == 1:
            parts.append(curr_part.strip()); curr_part = ""
        else: curr_part += c
    p += 1
if curr_part.strip(): parts.append(curr_part.strip())

a1_raw = []
for p_str in parts:
    if p_str.startswith("a[8]"):
        m = re.search(r'a\[8\]\(\{(.*)\}\)', p_str, re.DOTALL)
        a1_raw.append(reconstruct_a8(m.group(1)) if m else "")
    elif p_str.startswith('"') or p_str.startswith("'"):
        a1_raw.append(unescape_lua(p_str[1:-1]))
    else: a1_raw.append("")

# Shuffle a[1]
def lua_eval(expr): return int(eval(expr.replace('math.floor','')))
ipairs_match = re.search(r'a\[2\]=function.*?for K,H in ipairs\(\{(.*?)\}\)do', content, re.DOTALL)
if ipairs_match:
    pairs_list = re.split(r'\}\s*,\s*\{', ipairs_match.group(1).replace('\n', ''))
    for p_str in pairs_list:
        parts_p = re.split(r'[;,]', p_str.replace('{', '').replace('}', ''))
        if len(parts_p) >= 2:
            s_idx, e_idx = lua_eval(parts_p[0]) - 1, lua_eval(parts_p[1]) - 1
            if s_idx < 0: s_idx = 0
            if e_idx >= len(a1_raw): e_idx = len(a1_raw) - 1
            while s_idx < e_idx:
                a1_raw[s_idx], a1_raw[e_idx] = a1_raw[e_idx], a1_raw[s_idx]
                s_idx += 1; e_idx -= 1

# Check index 170 (Value 6)
val_6_idx = 170
seed_6 = 30398273658468
print(f"\nChecking Value 6 (Idx {val_6_idx}):")
if val_6_idx < len(a1_raw):
    raw_str = a1_raw[val_6_idx]
    print(f"  Raw: '{raw_str}' ({len(raw_str)} chars)")
    decoded = decrypt_k4(raw_str)
    print(f"  Decoded: {list(decoded)}")
    dec = decrypt_a5(decoded, seed_6)
    print(f"  Result: {list(dec)}")
else:
    print(f"  Out of range!")

# Check index 240 (Value 15)
# a2(-19221) -> -19221 + 19462 - 1 = 240
val_15_idx = 240
seed_15 = 20027115420364
print(f"\nChecking Value 15 (Idx {val_15_idx}):")
if val_15_idx < len(a1_raw):
    raw_str = a1_raw[val_15_idx]
    print(f"  Raw: '{raw_str}' ({len(raw_str)} chars)")
    decoded = decrypt_k4(raw_str)
    print(f"  Decoded: {list(decoded)}")
    dec = decrypt_a5(decoded, seed_15)
    print(f"  Result: {list(dec)}")
else:
    print(f"  Out of range!")

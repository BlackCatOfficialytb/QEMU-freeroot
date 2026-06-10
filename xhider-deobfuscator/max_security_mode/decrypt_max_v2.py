import re
import math
import os
import collections
import logging

logging.basicConfig(level=logging.INFO, format='%(message)s')

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", required=True)
args = parser.parse_args()
input_file = args.input

with open(input_file, 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

def lua_eval(expr):
    try:
        expr = expr.replace("\n", " ").strip()
        if not expr: return 0
        # Basic math simplification for evaluation
        # Replace Lua-style math.floor with floor for eval if needed
        expr = expr.replace("math.floor", "math.floor") 
        return int(eval(expr, {"__builtins__": None, "math": math}))
    except:
        # Fallback for complex expressions
        try:
            # Try to simplify simple arithmetic
            expr = re.sub(r'([0-9]+)\.0', r'\1', expr)
            return int(eval(expr, {"__builtins__": None, "math": math}))
        except:
            return 0

def unescape_lua(s):
    def dec_esc(m): return chr(int(m.group(1)))
    s = re.sub(r'\\([0-9]{3})', dec_esc, s)
    s = s.replace('\\"', '"').replace("\\'", "'").replace('\\\\', '\\')\
         .replace('\\n', '\n').replace('\\r', '\r').replace('\\t', '\t')
    return s

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
            # Padding is always 'u' in the Lua for short blocks
            padded = block + ['u'] * (5 - count)
            val = 0
            for char in padded:
                val = val * 85 + (ord(char) - 33)
            # Lua: for H=3, 3-(K[3]-1), -1  where K[3]=count-1
            # count=5 => H=3..0 (4 bytes)
            # count=2 => H=3..3 (1 byte)
            for h in range(3, 4 - count, -1):
                out.append((val // (256**h)) % 256)
    return out

def reconstruct_a8(block):
    lb = block.rfind('{')
    if lb == -1: return ""
    indices_p = block[:lb]
    strings_p = block[lb+1 : block.rfind('}')]
    s_l = [unescape_lua(m.group(1) or m.group(2)) for m in re.finditer(r'"((?:[^"\\]|\\.)*)"|\'((?:[^\'\\]|\\.)*)\'', strings_p)]
    indices = []
    parts = re.split(r'[;,]', indices_p)
    for p in parts:
        if p.strip():
            indices.append(lua_eval(p))
    res = "".join(s_l[i-1] for i in indices if 0 < i <= len(s_l))
    return res

# 1. Reconstruct a[1] (Full)
print("Parsing full a[1] table...")
start_match = re.search(r'a\[1\]\s*=\s*\{', content)
if not start_match:
    print("Could not find a[1] start!")
    exit(1)

p = start_match.end()
bal = 1
parts = []
curr_part = ""
in_q, qc = False, None
while p < len(content):
    c = content[p]
    if in_q:
        curr_part += c
        if c == '\\':
            p += 1
            if p < len(content): curr_part += content[p]
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
        if m: a1_raw.append(reconstruct_a8(m.group(1)))
        else: a1_raw.append("")
    elif p_str.startswith('"') or p_str.startswith("'"):
        a1_raw.append(unescape_lua(p_str[1:-1]))
    else: a1_raw.append("")

# Shuffle a[1]
print("Shuffling a[1]...")
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

a1_decoded = []
for s in a1_raw:
    try: a1_decoded.append(decrypt_k4(s))
    except: a1_decoded.append(b"")

from collections import Counter
print(f"Decoded alphabet entry lengths: {Counter(len(x) for x in a1_decoded)}")
print(f"Sample a1 entries (40-70):")
for i in range(40, 70):
    if i < len(a1_raw):
        print(f"[{i+1}] Raw: {repr(a1_raw[i])}, Decoded: {list(a1_decoded[i])}")

class LuaPRNG:
    def __init__(self, k3, k7):
        self.k3, self.k7, self.k12 = k3, k7, []
    def next(self):
        if not self.k12:
            self.k3 = (self.k3 * 237 + 15189140112205) % 35184372088832
            while True:
                self.k7 = (self.k7 * 203) % 257
                if self.k7 != 1: break
            h1 = self.k7 % 32
            h10 = (math.floor(self.k3 / (2**(13 - (self.k7-h1)//32))) % 4294967296) / (2**h1)
            h9 = math.floor((h10 % 1) * 4294967296) + math.floor(h10)
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

def get_a2_val(k_expr):
    idx = lua_eval(k_expr) + 19462 - 1
    if 0 <= idx < len(a1_decoded): return a1_decoded[idx]
    return b""

# 2. Extract and Decrypt a[7] Entries (Layer 1)
print("Decrypting a[7] Layer 1...")
# Find the a[7] = { ... } block
a7_match = re.search(r'a\[7\]\s*=\s*\{(.*?)\}for', content, re.DOTALL)
if not a7_match:
    print("Could not find a[7] initialization!")
    exit(1)

a7_init_str = a7_match.group(1)
a7_entries_raw = re.findall(r'a\[12\]\[a\[5\]\(a\[2\]\((.*?)\),(.*?)\)\]', a7_init_str)
a7_layer1 = []
for idx_expr, seed_expr in a7_entries_raw:
    ciphertext = get_a2_val(idx_expr)
    seed = lua_eval(seed_expr)
    decrypted = decrypt_a5(ciphertext, seed)
    a7_layer1.append(decrypted)

# Shuffle a[7]
print("Shuffling a[7]...")
# for K,H in ipairs({{(250854-820864)-(-570011);-709353+709635},{714398+-714397;-449227-(-449321)};{111310+-111215;-947470+947752}})do
ipairs_a7 = re.search(r'a\[7\]=\{.*?\}for K,H in ipairs\(\{(.*?)\}\)do', content, re.DOTALL)
if ipairs_a7:
    pairs_list = re.split(r'\}\s*,\s*\{', ipairs_a7.group(1).replace('\n', ''))
    for p_str in pairs_list:
        parts_p = re.split(r'[;,]', p_str.replace('{', '').replace('}', ''))
        if len(parts_p) >= 2:
            s_idx, e_idx = lua_eval(parts_p[0]) - 1, lua_eval(parts_p[1]) - 1
            if s_idx < 0: s_idx = 0
            if e_idx >= len(a7_layer1): e_idx = len(a7_layer1) - 1
            while s_idx < e_idx:
                a7_layer1[s_idx], a7_layer1[e_idx] = a7_layer1[e_idx], a7_layer1[s_idx]
                s_idx += 1; e_idx -= 1

# 3. Layer 2: Custom Hex Decoding
print("Extracting K[5] custom hex mapping (Layer 2)...")
k5_match = re.search(r'K\[5\]\s*=\s*\{(.*?)\}for', content, re.DOTALL)
hex_map = {}
if k5_match:
    k5_inner = k5_match.group(1)
    # Sophisticated split for K[5] entries
    # Each entry is [a[12][a[5](a[2](...), ...)]] = ...
    # We want to find the pairs of (a[2]_expr, seed_expr) and the value.
    
    p = 0
    while p < len(k5_inner):
        start = k5_inner.find('[a[12][a[5](a[2](', p)
        if start == -1: break
        
        # Parse first arg of a5 (the a2 call)
        # a[5](a[2](  <-- we are after this
        p1 = start + len('[a[12][a[5](a[2](')
        bal = 1
        a2_expr = ""
        while p1 < len(k5_inner) and bal > 0:
            c = k5_inner[p1]
            if c == '(': bal += 1
            elif c == ')': bal -= 1
            if bal > 0: a2_expr += c
            p1 += 1
        
        # Now we are after a[2](...)
        # Next comes the comma
        comma_idx = k5_inner.find(',', p1)
        if comma_idx == -1: break
        
        # Parse second arg of a5 (the seed)
        p2 = comma_idx + 1
        bal = 1 # We are inside a[5](
        seed_expr = ""
        while p2 < len(k5_inner) and bal > 0:
            c = k5_inner[p2]
            if c == '(': bal += 1
            elif c == ')': bal -= 1
            if bal > 0: seed_expr += c
            p2 += 1
        
        # Now we are after a[5](...)
        # Next follows ]]] = 
        eq_idx = k5_inner.find('=', p2)
        if eq_idx == -1: break
        
        p_val = eq_idx + 1
        val_str = ""
        while p_val < len(k5_inner):
            c = k5_inner[p_val]
            if c in (',', ';', '}'): break
            val_str += c
            p_val += 1
        
        ciphertext = get_a2_val(a2_expr)
        seed = lua_eval(seed_expr)
        digit_bytes = bytes(decrypt_a5(ciphertext, seed))
        val = lua_eval(val_str)
        hex_map[digit_bytes] = val
        
        p = p_val + 1

print(f"Custom Hex Map (Bytes): {hex_map}")
found_vals = sorted(hex_map.values())
missing = [i for i in range(16) if i not in found_vals]
print(f"Values found: {found_vals}")
if missing:
    print(f"WARNING: Missing values from hex map: {missing}")

def custom_hex_decode(data_bytes):
    res = bytearray()
    for i in range(0, len(data_bytes), 2):
        if i + 1 < len(data_bytes):
            c1 = bytes([data_bytes[i]])
            c2 = bytes([data_bytes[i+1]])
            if c1 in hex_map and c2 in hex_map:
                val = hex_map[c1] * 16 + hex_map[c2]
                res.append(val)
            else:
                # Fallback: if not all bytes match, it might not be hex-encoded
                # or the entry is incomplete. 
                # For Max Security, we expect most a7 to be hex.
                return data_bytes 
    return res

# ===== Layer 2: First hex decode of a[7] =====
print("Decoding a[7] Layer 2 (first hex decode)...")
a7_hex1 = []
for entry in a7_layer1:
    decoded = custom_hex_decode(entry)
    a7_hex1.append(decoded)

# ===== Layer 2b: Second in-place hex decode of a[7] =====
# The Lua code builds a SECOND K[5] hex map using a[12][a[5](a[2](idx), seed)]
# Each entry maps a single-byte key to a value 0-15
# Keys are from a[5] decryption = single-byte strings (since K[2][N] = char(N-1))
print("Building second K[5] hex map for Layer 2b...")

# These are the 16 entries extracted from the Lua code
# Format: (a[2] index, seed, value)
k5b_entries_raw = [
    (-19314, 28299492315572, 0),
    (-19294, 20335914651640, 1),
    (-19248, 28232296451569, 2),
    (-19162, 5859349809672, 3),
    (-19151, 20855021724430, 4),
    (-19206, 23762823634053, 5),
    (-19291, 30398273658468, 6),
    (-19257, 22873711031877, 7),
    (-19243, 25294775306026, 8),
    (-19268, 7548167475487, 9),
    (-19166, 4728052555727, 10),
    (-19295, 34089849104075, 11),
    (-19352, 28054333411203, 12),
    (-19421, 20437502796033, 13),
    (-19359, 13866351594604, 14),
    (-19221, 20027115420364, 15),
]

k5b_map = {}  # Maps byte value -> hex digit (0-15)
offset = 19462
for a2_idx, seed, value in k5b_entries_raw:
    real_idx = a2_idx + offset - 1
    if 0 <= real_idx < len(a1_decoded):
        ciphertext = a1_decoded[real_idx]
        decrypted = decrypt_a5(ciphertext, seed)
        # The decrypted result should be a single byte (after K[2] identity mapping)
        if len(decrypted) > 0:
            # Each byte of decrypted is the accumulated value
            # In Lua, K[2][H[1]+1] = char(H[1]), so decrypted byte = H[1]
            # The key in K[5] is string.byte(char) = the byte value itself
            for b in decrypted:
                k5b_map[b] = value

print(f"Second K[5] map: {len(k5b_map)} entries")
for k, v in sorted(k5b_map.items()):
    print(f"  byte {k} (0x{k:02x}) -> {v}")

# Apply second hex decode to a[7]
print("Applying Layer 2b (second hex decode) to a[7]...")
a7_final = []
for entry in a7_hex1:
    if isinstance(entry, (bytearray, bytes)) and len(entry) >= 2:
        res = bytearray()
        valid = True
        for i in range(0, len(entry) - 1, 2):
            b1 = entry[i]
            b2 = entry[i+1]
            if b1 in k5b_map and b2 in k5b_map:
                res.append(k5b_map[b1] * 16 + k5b_map[b2])
            else:
                valid = False
                break
        if valid:
            a7_final.append(res)
        else:
            a7_final.append(entry)  # Keep as-is if not valid hex
    else:
        a7_final.append(entry)

print(f"a[7] final: {len(a7_final)} entries")

# ===== Populate a[3] from a[7] =====
print("Reconstructing a[3] table...")

def get_a7_val(idx_expr):
    idx = lua_eval(idx_expr)
    real_idx = idx - (143733 - 126130) - 1
    if 0 <= real_idx < len(a7_final):
        return a7_final[real_idx]
    return bytearray()

a3_match = re.search(r'a\[3\]=\{(.*?)\}a\[11\]', content, re.DOTALL)
a3 = []
if a3_match:
    ptr = 0
    inner = a3_match.group(1)
    while ptr < len(inner):
        if inner[ptr:ptr+5] == 'a[4](':
            start = ptr + 5
            bal = 1; p1 = start
            while p1 < len(inner) and bal > 0:
                if inner[p1] == '(': bal += 1
                elif inner[p1] == ')': bal -= 1
                p1 += 1
            expr = inner[start:p1-1]
            a3.append(get_a7_val(expr))
            ptr = p1
        elif inner[ptr] in ',; ':
            ptr += 1
        else:
            next_d = len(inner)
            for d in ',;':
                idx = inner.find(d, ptr)
                if idx != -1 and idx < next_d: next_d = idx
            val_str = inner[ptr:next_d].strip()
            if val_str:
                val = lua_eval(val_str)
                if isinstance(val, str):
                    a3.append(bytearray(val.encode('utf-8')))
                else:
                    a3.append(val)
            ptr = next_d + 1

print(f"a[3] has {len(a3)} entries")

# a[3] Swaps
a3_swaps_data = [[1, 312], [1, 42], [43, 312]]
for start_idx, end_idx in a3_swaps_data:
    p1, p2 = start_idx, end_idx
    while p1 < p2:
        if p1-1 < len(a3) and p2-1 < len(a3):
            a3[p1-1], a3[p2-1] = a3[p2-1], a3[p1-1]
        p1 += 1; p2 -= 1

# Debug a[3] lengths
from collections import Counter
a3_lens = [len(x) if isinstance(x, (bytes, bytearray)) else 0 for x in a3]
print(f"a[3] entry string lengths: {Counter(a3_lens)}")

# Dump a[3] for debug
with open("a3_dump.txt", "w", encoding="utf-8") as f:
    for i, entry in enumerate(a3):
        if isinstance(entry, (bytes, bytearray)):
            hex_s = " ".join(f"{b:02x}" for b in entry)
            txt = entry.decode('latin-1', errors='replace')
            f.write(f"[{i+1}] len={len(entry)} hex={hex_s} txt={txt}\n")
        else:
            f.write(f"[{i+1}] {entry}\n")



# Helper class for args
class Args:
    output = r"d:\dec bot2\max_security_mode\a7_v4_decrypted.bin"
args = Args()

# ===== Apply K[5] hex decode to multi-byte a7_final entries =====
# The Lua code runs a loop that transforms hex-encoded entries in K[3] (=a[7])
# using K[5] before K[2] is built. Entries with even length > 1 get decoded:
# for each pair of chars, look up each in K[5] to get nibbles, combine into byte.
print("Applying K[5] in-place decode to a7_final entries...")
decoded_count = 0
for i in range(len(a7_final)):
    entry = a7_final[i]
    if isinstance(entry, (bytes, bytearray)) and len(entry) > 1 and len(entry) % 2 == 0:
        # Check if all bytes are valid K[5] keys (0-9, A-F range after decode)
        all_valid = True
        for b in entry:
            if b not in k5b_map:
                all_valid = False
                break
        if all_valid:
            # Hex decode using K[5]
            result = bytearray()
            for j in range(0, len(entry), 2):
                hi = k5b_map[entry[j]]
                lo = k5b_map[entry[j+1]]
                result.append(hi * 16 + lo)
            a7_final[i] = result
            decoded_count += 1

print(f"  Decoded {decoded_count} multi-byte a7_final entries")

# ===== K[2] Base64 Map Extraction =====
print("Extracting K[2] Base64 Map...")

k2_block = ""
source_content = ""
if os.path.exists("k5_dump.txt"):
    try:
        with open("k5_dump.txt", "r", encoding="utf-8") as f:
            source_content = f.read()
            print("  Using k5_dump.txt as source")
    except: pass

if not source_content:
    source_content = content
    print("  Using main content as source")

k2_pos = source_content.find('K[2]={')
if k2_pos != -1:
    print(f"  Found K[2] start at index {k2_pos}")
    # Try specific anchor for k5_dump.txt: }K[1]=
    k2_end_anchor = source_content.find('}K[1]=', k2_pos)
    
    if k2_end_anchor != -1:
        print(f"  Found }}K[1]= anchor at index {k2_end_anchor}")
        # Include the closing brace
        k2_block = source_content[k2_pos : k2_end_anchor + 1]
    else:
        # Fallback to a[3]={ as anchor (for print_hi.lua)
        a3_pos = source_content.find('a[3]={', k2_pos)
        if a3_pos != -1:
            print(f"  Found a[3] start at index {a3_pos}")
            k2_block = source_content[k2_pos : a3_pos]
        else:
            print("  Could not find anchor (}K[1]= or a[3]={) after K[2]")
            pass
else:
    print("  Could not find K[2]={")

k2_map = {}
if k2_block:
    print(f"  Block start: {k2_block[:100]}...")
    
    def parse_k2_entries(block):
        """Parse K[2] entries using paren-counting for [a[4](...)]= patterns."""
        entries_found = 0
        idx = 0
        while idx < len(block):
            # Find next [a[4]( pattern
            pos = block.find('[a[4](', idx)
            if pos == -1:
                break
            
            # Balance parens to find end of expression
            start = pos + 6  # after [a[4](
            depth = 1
            p = start
            while p < len(block) and depth > 0:
                if block[p] == '(': depth += 1
                elif block[p] == ')': depth -= 1
                p += 1
            # p is now after closing ), expr is block[start:p-1]
            key_expr = block[start:p-1]
            
            # Expect ]= after )
            if p < len(block) and block[p] == ']':
                p += 1  # skip ]
                # Skip =
                while p < len(block) and block[p] in ' \t=': p += 1
                
                # Value expression: until , or ; or end
                v_start = p
                while p < len(block) and block[p] not in ',;':
                    p += 1
                val_expr = block[v_start:p].strip()
                
                try:
                    idx_val = lua_eval(key_expr)
                    real_idx = idx_val - (143733 - 126130) - 1
                    
                    if 0 <= real_idx < len(a7_final):
                        key_bytes = a7_final[real_idx]
                        if len(key_bytes) == 1:
                            key_char = key_bytes[0]
                            val_num = lua_eval(val_expr)
                            k2_map[key_char] = val_num
                            entries_found += 1
                            if entries_found <= 3:
                                print(f"    [{entries_found}] Mapped byte {key_char} ('{chr(key_char) if 32<=key_char<127 else hex(key_char)}') -> {val_num}")
                        else:
                            print(f"    SKIP: a7[{real_idx}] has {len(key_bytes)} bytes, not 1")
                    else:
                        print(f"    OUT OF RANGE: idx_val={idx_val} -> real_idx={real_idx}")
                except Exception as e:
                    print(f"    Error: {e} | key={key_expr[:40]} val={val_expr[:40]}")
            
            idx = p + 1
        
        print(f"  Total entries parsed: {entries_found}")
    
    parse_k2_entries(k2_block)
else:
    print("  FAILED to extract K[2] block!")

# === Fix: Apply K[5] hex-decode to multi-byte a7 keys for K[2] ===
# The Lua code hex-decodes multi-byte a[7] entries in-place via K[5] BEFORE
# K[2] uses them as keys. Entries with even-length byte sequences where all
# bytes are valid K[5] keys get decoded to single-byte results.
print("Fixing K[2]: applying K[5] hex-decode to multi-byte a7 keys...")
k2_multibyte_fixed = 0

# Re-parse K[2] block, this time handling multi-byte keys
if k2_block:
    idx = 0
    while idx < len(k2_block):
        pos = k2_block.find('[a[4](', idx)
        if pos == -1:
            break
        start = pos + 6  # after [a[4](
        depth = 1
        p = start
        while p < len(k2_block) and depth > 0:
            if k2_block[p] == '(': depth += 1
            elif k2_block[p] == ')': depth -= 1
            p += 1
        key_expr = k2_block[start:p-1]
        if p < len(k2_block) and k2_block[p] == ']':
            p += 1
            while p < len(k2_block) and k2_block[p] in ' \t=': p += 1
            v_start = p
            while p < len(k2_block) and k2_block[p] not in ',;':
                p += 1
            val_expr = k2_block[v_start:p].strip()
            try:
                idx_val = lua_eval(key_expr)
                real_idx = idx_val - (143733 - 126130) - 1
                if 0 <= real_idx < len(a7_final):
                    key_bytes = a7_final[real_idx]
                    val_num = lua_eval(val_expr)
                    if len(key_bytes) == 1:
                        # Already in k2_map from first pass
                        pass
                    elif len(key_bytes) > 1 and len(key_bytes) % 2 == 0:
                        # Apply K[5] hex-decode: pair up bytes, look up in k5b_map
                        all_valid = all(b in k5b_map for b in key_bytes)
                        if all_valid:
                            decoded = bytearray()
                            for j in range(0, len(key_bytes), 2):
                                hi = k5b_map[key_bytes[j]]
                                lo = k5b_map[key_bytes[j+1]]
                                decoded.append(hi * 16 + lo)
                            if len(decoded) == 1:
                                k2_map[decoded[0]] = val_num
                                k2_multibyte_fixed += 1
                            else:
                                # Multi-round decode may be needed
                                # Try decoding again
                                while len(decoded) > 1 and len(decoded) % 2 == 0:
                                    all_v = all(b in k5b_map for b in decoded)
                                    if not all_v:
                                        break
                                    new_decoded = bytearray()
                                    for j in range(0, len(decoded), 2):
                                        hi = k5b_map[decoded[j]]
                                        lo = k5b_map[decoded[j+1]]
                                        new_decoded.append(hi * 16 + lo)
                                    decoded = new_decoded
                                if len(decoded) == 1:
                                    k2_map[decoded[0]] = val_num
                                    k2_multibyte_fixed += 1
                                else:
                                    print(f"    K[2] fix: a7[{real_idx}] decoded to {len(decoded)} bytes, still not 1")
                        else:
                            print(f"    K[2] fix: a7[{real_idx}] has bytes not in k5b_map")
            except Exception as e:
                pass
        idx = p + 1

print(f"  Fixed {k2_multibyte_fixed} multi-byte K[2] entries via K[5] hex-decode")
print(f"K[2] map has {len(k2_map)} entries")

# ===== Build K[10] map and merge with K[2] for full Base64 =====
# K[10] entries from the a[6] decode context map a[11](idx) -> base64 value
# a[11](idx) = a[3][idx - (301403 - 258337)]
def get_a11_val_direct(idx):
    real_idx = idx - (301403 - 258337) - 1
    if 0 <= real_idx < len(a3):
        return a3[real_idx]
    return bytearray()

k10_entries_raw = [
    (43141, 0), (43091, 1), (43194, 2), (43263, 3), (43172, 4), (43243, 5),
    (43271, 6), (43102, 7), (43074, 8), (43067, 9), (43177, 10), (43205, 11),
    (43135, 12), (43235, 13), (43174, 14), (43162, 15), (43088, 16), (43092, 17),
    (43143, 18), (43104, 19), (43253, 20), (43079, 21), (43112, 22), (43220, 23),
    (43093, 24), (43159, 25), (43264, 26), (43257, 27), (43184, 28), (43146, 29),
    (43085, 30), (43219, 31), (43100, 32), (43265, 33), (43123, 34), (43111, 35),
    (43237, 36), (43270, 37), (43171, 38), (43189, 39), (43187, 40), (43152, 41),
    (43203, 42), (43246, 43), (43148, 44), (43169, 45), (43076, 46), (43168, 47),
    (43247, 48), (43166, 49), (43262, 50), (43197, 51), (43214, 52), (43238, 53),
    (43084, 54), (43232, 55), (43272, 56), (43082, 57), (43109, 58), (43215, 59),
    (43204, 60), (43099, 61), (43137, 62), (43110, 63),
]

k10_map = {}
for a11_idx, value in k10_entries_raw:
    entry = get_a11_val_direct(a11_idx)
    if isinstance(entry, (bytearray, bytes)) and len(entry) == 1:
        k10_map[entry[0]] = value

print(f"K[10] map has {len(k10_map)} entries")

# Merge K[10] into K[2] to get full Base64 map
full_b64_map = dict(k2_map)  # Start with K[2]'s 36 entries
for k, v in k10_map.items():
    if k not in full_b64_map:
        full_b64_map[k] = v

print(f"Merged Base64 map has {len(full_b64_map)} entries")
# Check coverage
covered = sorted(full_b64_map.values())
missing = sorted(set(range(64)) - set(covered))
if missing:
    print(f"  WARNING: Missing values: {missing}")
else:
    print(f"  Full coverage of values 0-63!")

# ===== Main Payload Decoding (a[3]) =====
print("Decoding a[3] payload (Shift -40 + Base64 w/ merged map)...")

def base64_decode_custom(data_bytes, map_k2):
    # 1. Shift by -40
    # 2. Map -> 6-bit
    # 3. Pack 4 -> 3 bytes
    
    valid_vals = []
    for b in data_bytes:
        shifted = (b - 40) % 256
        if shifted in map_k2:
            valid_vals.append(map_k2[shifted])
            
    res = bytearray()
    for i in range(0, len(valid_vals), 4):
        chunk = valid_vals[i:i+4]
        if chunk: # Check chunk validity
            VAL = 0
            for x in chunk: VAL = (VAL << 6) | x
            
            nbits = len(chunk) * 6
            nbytes = nbits // 8
            
            for b_i in range(nbytes):
                shift = nbits - 8 * (b_i + 1)
                res.append((VAL >> shift) & 0xFF)
    return res

final_bytecode = bytearray()
a3_decoded_list = []

for entry in a3:
    if isinstance(entry, (bytes, bytearray)):
        dec = base64_decode_custom(entry, full_b64_map)
        a3_decoded_list.append(dec)
    else:
        a3_decoded_list.append(b"")

largest_chunk = b""
for d in a3_decoded_list:
    if len(d) > len(largest_chunk):
        largest_chunk = d

print(f"Largest decoded chunk size: {len(largest_chunk)} bytes")

if len(largest_chunk) > 4 and largest_chunk[:4] == b'\x1bLua':
    print("SUCCESS: Found Lua Bytecode signature in decrypted payload!")
    # Just save the largest chunk as the final result
    with open(args.output, "wb") as f:
        f.write(largest_chunk)
    print(f"Saved payload to {args.output}")
else:
    print("WARNING: Lua Bytecode signature not found in largest chunk.")
    # Save anyway
    with open(args.output, "wb") as f:
        f.write(largest_chunk)

# Dump for verification
with open("decrypted_strings.txt", "w", encoding="utf-8", errors="ignore") as f:
    for i, d in enumerate(a3_decoded_list):
        f.write(f"[{i+1}] {repr(d)}\n")


# ===== Build K[10] base64 map from a[11] lookups =====
print("Building K[10] base64 map...")

# Restore missing helper functions
def get_a11_val_direct(idx):
    # Map raw index to a[3] index
    real_idx = idx - (301403 - 258337) - 1
    if 0 <= real_idx < len(a3):
        return a3[real_idx]
    return bytearray()

def get_a11_val(idx_expr):
    idx = lua_eval(idx_expr)
    return get_a11_val_direct(idx)

# Restore missing helper function
def get_a11_val_direct(idx):
    # Map raw index to a[3] index
    # Based on a[11] logic: return a[3][H[1]-(301403-258337)]
    real_idx = idx - (301403 - 258337) - 1
    if 0 <= real_idx < len(a3):
        return a3[real_idx]
    return bytearray()

# These entries map a[11](idx) -> value (0-63, plus 65 for padding '=')
k10_entries_raw = [
    (43141, 0), (43091, 1), (43194, 2), (43263, 3), (43172, 4), (43243, 5),
    (43271, 6), (43102, 7), (43074, 8), (43067, 9), (43177, 10), (43205, 11),
    (43135, 12), (43235, 13), (43174, 14), (43162, 15), (43088, 16), (43092, 17),
    (43143, 18), (43104, 19), (43253, 20), (43079, 21), (43112, 22), (43220, 23),
    (43093, 24), (43159, 25), (43264, 26), (43257, 27), (43184, 28), (43146, 29),
    (43085, 30), (43219, 31), (43100, 32), (43265, 33), (43123, 34), (43111, 35),
    (43237, 36), (43270, 37), (43171, 38), (43189, 39), (43187, 40), (43152, 41),
    (43203, 42), (43246, 43), (43148, 44), (43169, 45), (43076, 46), (43168, 47),
    (43247, 48), (43166, 49), (43262, 50), (43197, 51), (43214, 52), (43238, 53),
    (43084, 54), (43232, 55), (43272, 56), (43082, 57), (43109, 58), (43215, 59),
    (43204, 60), (43099, 61), (43137, 62), (43110, 63),
]

# Build K[10] map: maps single-byte strings → base64 value
k10_map = {}  # byte -> value
k10_padding_byte = None
for a11_idx, value in k10_entries_raw:
    entry = get_a11_val_direct(a11_idx)
    if isinstance(entry, (bytearray, bytes)):
        if len(entry) == 1:
            k10_map[entry[0]] = value
        elif len(entry) > 0:
            # Multi-byte - use first byte
            k10_map[entry[0]] = value

# Padding entry: a[11](0) -> value=65, but we need to find the actual padding char
# From Lua code: the padding check uses a[4](952247+...) which evaluates to "="
# Actually a[11](0) probably gives us the padding character entry
padding_entry = get_a11_val_direct(0)
if isinstance(padding_entry, (bytearray, bytes)) and len(padding_entry) > 0:
    k10_padding_byte = padding_entry[0]

print(f"K[10] map: {len(k10_map)} entries")
# Print readable form
for b, v in sorted(k10_map.items(), key=lambda x: x[1]):
    try:
        c = chr(b) if 32 <= b < 127 else f'0x{b:02x}'
    except:
        c = f'0x{b:02x}'
    print(f"  '{c}' (byte {b}) -> {v}")
if k10_padding_byte is not None:
    print(f"  Padding byte: {k10_padding_byte} ('{chr(k10_padding_byte) if 32 <= k10_padding_byte < 127 else hex(k10_padding_byte)}')")

# ===== Populate a[6] =====
print("Reconstructing a[6] table...")
a6_match = re.search(r'a\[6\]=\{(.*?)\}for\s*K,H\s*in\s*ipairs\(\{\{\(\-182754', content, re.DOTALL)
a6 = []
if a6_match:
    inner = a6_match.group(1)
    ptr = 0
    while ptr < len(inner):
        if inner[ptr:ptr+6] == 'a[11](':
            start = ptr + 6
            bal = 1; p1 = start
            while p1 < len(inner) and bal > 0:
                if inner[p1] == '(': bal += 1
                elif inner[p1] == ')': bal -= 1
                p1 += 1
            expr = inner[start:p1-1]
            a6.append(get_a11_val(expr))
            ptr = p1
        elif inner[ptr] in ',; ':
            ptr += 1
        else:
            next_d = len(inner)
            for d in ',;':
                idx = inner.find(d, ptr)
                if idx != -1 and idx < next_d: next_d = idx
            val_str = inner[ptr:next_d].strip()
            if val_str:
                val = lua_eval(val_str)
                if isinstance(val, str):
                    a6.append(bytearray(val.encode('utf-8')))
                else:
                    a6.append(val)
            ptr = next_d + 1

print(f"a[6] has {len(a6)} entries")

# a[6] Swaps
a6_swaps_data = [[1, 138], [1, 53], [54, 138]]
for start_idx, end_idx in a6_swaps_data:
    p1, p2 = start_idx, end_idx
    while p1 < p2:
        if p1-1 < len(a6) and p2-1 < len(a6):
            a6[p1-1], a6[p2-1] = a6[p2-1], a6[p1-1]
        p1 += 1; p2 -= 1

# ===== Layer 3: Two-phase decode on a[6] =====
# Phase 1: For each string in a[6], apply byte-40 shift and K[10] char lookup
# Phase 2: Base64-like decode using K[2] (which is identity: byte N -> char(N-1))
# From Lua:
#   e[4] = byte(char) - 40
#   K[4](H[1], K[10](e[4]))  -- K[10] maps value to string.char
#   Then base64 decode of the resulting string using K[2] char->value map

# Actually, re-reading the Lua code more carefully:
# Phase 1 transforms bytes: shift -40, then look up in a SEPARATE K[10] table 
#   that maps VALUES to CHARACTERS (not the K[10] base64 map!)
# Wait - re-checking: K[10] in the a[3] context is different from K[10] in a[6] context
# Let me re-examine...

# From the a[6] decrypt loop:
# K[4]=string.byte (from a[4]())
# K[9]=string.len (from a[11]())  
# K[3]=math.floor (from a[11]())
# K[10]={...} is the base64 map (values 0-63)
# K[6]=string.sub
# K[2]=K[2] from the shuffle (identity map)
# K[7]=type
# K[1]=math.floor

# Phase 1: for each char in string:
#   e[4] = e[1]:byte() - 40 (byte shift)
#   K[4](H[1], K[10](e[4]))  --> wait, K[10] is a table here, not a function
#   Actually K[10] is used as K[10](e[4]) which for a table is indexing: K[10][e[4]] 
#   No wait, K[10] is also string.char somewhere...
#   Let me re-check the Lua code

# From extract_maps.py output:
# K[4]=string[a[11](-963425+1006698)] -> string.byte? or string.char?
# K[9]=string[a[11](783403+-740242)] -> string.len/sub? 
# K[3]=math[a[11](-721689+764762)] -> math.floor
# K[10]={...} -> base64 map table

# The Phase 1 loop does:
#   e[4] = e[1]:byte() - 40
#   K[4](H[1], K[10](e[4]))
# K[4] is table.insert (from table[a[4](...)])
# K[10](e[4]) is string.char(e[4])? No, K[10] is a table...
# Wait: K[10] in THIS context IS string.char!
# Looking more carefully: in the outer a[3] context, K[10] is the base64 TABLE
# But in the a[6] context: there's a DIFFERENT K[10]!

# Let me re-read:
# "K[10]={[a[11](...)]=value,...}" - this is the base64 MAP from the a[6] decrypt region
# But then it also uses K[10](V[1],V[2],V[3]) as a FUNCTION call - string.char!
# So K[10] must be OVERWRITTEN. Let me look again...

# From the output at pos 91500:
#   K[1]=math[a[4](...)] -> math.floor
#   K[4]=table[a[4](...)] -> table.insert
#   K[8]=a[3] (the a[3] table itself)
#   K[3]=table[a[4](...)] -> table.concat
#   K[7]=type
#   K[9]=string.len  
#   K[6]=string.sub

# Then the a[3] in-place decode loop transforms a[3] entries using a DIFFERENT K[10]
# And THEN the a[6] context has its own K[...] variables

# OK I think the confusion is scope. Let me just do it empirically:
# Phase 1: byte - 40, then look up in the K[10] map to get a character
# Phase 2: base64 decode the resulting characters

# Actually wait - K[10] maps bytes to VALUES (0-63), not to characters
# And K[10] is called as K[10](V[1],V[2],V[3]) which is string.char
# So there must be TWO K[10]s in different scopes. Let me look at the exact Lua...

# From pos 92118: 
# K[4](H[1],K[10](e[4]))  -- here K[10] is string.char, e[4] is byte-40
# So Phase 1 just does string.char(byte-40) = identity with shift

# Then later: K[2][z[1]] where z[1]=K[6](V[3],H[2],H[2]) = string.sub(V[3],H[2],H[2])
# K[2] maps character to base64 value
# And K[10](V[1],V[2],V[3]) = string.char(floor(acc/65536), floor(acc%65536/256), acc%256)

# So the K[10] used as function = string.char
# And the K[10] used as table = base64 mapping
# These must be in DIFFERENT do...end scopes!

# Let me just implement it:
# Phase 1: for each byte b in entry: output char(b - 40)
# Phase 2: base64 decode using K[2] (identity map: char -> byte value)

print("Applying Layer 3 decode to a[6]...")

# Build the K[2] reverse map: char -> base64 value (0-63)
# From the K[10] entries, each entry maps a[11](idx) which resolves to a single byte from a[3]
# The VALUE is the base64 index (0-63)
# So we need: byte_of_a3_entry -> base64_value

# Build K[2] map from K[10] entries:
k2_b64_map = {}  # byte -> base64 value
for a11_idx, value in k10_entries_raw:
    entry = get_a11_val_direct(a11_idx)
    if isinstance(entry, (bytearray, bytes)) and len(entry) == 1:
        k2_b64_map[entry[0]] = value

# Find the padding character
padding_char = None
# a[4](952247+...) = the index for '='
# Let's check a few likely candidates
# Actually from the padding entry a[11](0):
pad_entry = get_a11_val_direct(0)
if isinstance(pad_entry, (bytearray, bytes)) and len(pad_entry) == 1:
    padding_char = pad_entry[0]

print(f"K[2] base64 map: {len(k2_b64_map)} entries, padding={padding_char}")

# a[6] two-phase decode
a6_decoded = []
for i, entry in enumerate(a6):
    if not isinstance(entry, (bytearray, bytes)):
        a6_decoded.append(entry)
        continue
    
    # Phase 1: byte shift -40
    phase1 = bytearray()
    for b in entry:
        phase1.append((b - 40) % 256)
    
    # Phase 2: base64 decode
    # Accumulate 4 base64 values (6 bits each) = 24 bits = 3 bytes
    result = bytearray()
    acc = 0
    count = 0
    for b in phase1:
        if b in k2_b64_map:
            acc = acc + k2_b64_map[b] * (64 ** (3 - count))
            count += 1
            if count == 4:
                result.append((acc >> 16) & 0xFF)
                result.append((acc >> 8) & 0xFF)
                result.append(acc & 0xFF)
                acc = 0
                count = 0
        elif padding_char is not None and b == padding_char:
            # Handle padding
            if count == 2:
                result.append((acc >> 16) & 0xFF)
            elif count == 3:
                result.append((acc >> 16) & 0xFF)
                result.append((acc >> 8) & 0xFF)
            break
    
    a6_decoded.append(result)

# ===== Output =====
print(f"\na[6] decoded: {len(a6_decoded)} entries")
with open(r'd:\dec bot2\max_security_mode\a6_final.txt', 'w', encoding='utf-8', errors='replace') as f:
    for i, entry in enumerate(a6_decoded):
        if isinstance(entry, (bytearray, bytes)):
            s = entry.decode('utf-8', errors='replace')
            f.write(f"[{i+1}] (string) {s}\n")
        else:
            f.write(f"[{i+1}] (number) {entry}\n")
print("a[6] decoded strings saved to a6_final.txt")

# Check for common Lua keywords
lua_keywords = ['print', 'local', 'function', 'return', 'end', 'if', 'then', 'else',
                'for', 'while', 'do', 'table', 'string', 'math', 'game', 'pcall',
                'loadstring', 'spawn', 'wait', 'GetService', 'Players', 'HttpGet']
found_kw = {}
for entry in a6_decoded:
    if isinstance(entry, (bytearray, bytes)):
        s = entry.decode('utf-8', errors='replace')
        for kw in lua_keywords:
            if kw in s:
                found_kw[kw] = found_kw.get(kw, 0) + 1
if found_kw:
    print("\nLua keywords found in a[6]:")
    for kw, count in sorted(found_kw.items()):
        print(f"  '{kw}': {count}")
else:
    print("\nNo Lua keywords found in a[6] — may need further investigation")

# Save a[7] final
output_file = input_file + ".decrypted.bin"
with open(output_file, "wb") as f:
    for i, data in enumerate(a7_final):
        f.write(f"\n--- ENTRY {i+1} ---\n".encode('ascii'))
        if isinstance(data, (bytearray, bytes)):
            f.write(data)

txt_output = input_file + ".decrypted.txt"
with open(txt_output, "w", encoding="utf-8", errors="replace") as f:
    for i, data in enumerate(a7_final):
        if isinstance(data, (bytearray, bytes)):
            f.write(f"[{i+1}] {data.decode('utf-8', errors='replace')}\n")
        else:
            f.write(f"[{i+1}] {data}\n")

print(f"Fully decrypted data saved to {output_file} and {txt_output}")

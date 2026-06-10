import re

content = open(r'd:\dec bot2\max_security_mode\print_hi.lua', 'r', encoding='utf-8', errors='ignore').read()
a1_raw = []
# Find all strings in the file - a[1] is usually built from these
# But wait, a[1] has 256 entries in Layer 1.
# In the deeper layers, it can have thousands.
# Let's extract the a[8] reconstructions.

def unescape_lua(s):
    def dec_esc(m): return chr(int(m.group(1)))
    s = re.sub(r'\\([0-9]{3})', dec_esc, s)
    s = s.replace('\\"', '"').replace("\\\'", "\'").replace('\\\\', '\\')
    return s

def reconstruct_a8(block):
    lb = block.rfind('{')
    if lb == -1: return ""
    indices_p = block[:lb]
    strings_p = block[lb+1 : block.rfind('}')]
    s_l = [unescape_lua(m.group(1) or m.group(2)) for m in re.finditer(r'\"((?:[^\"\\\\]|\\\\.)*)\"|\'((?:[^\'\\\\]|\\\\.)*)\'', strings_p)]
    indices = []
    parts = re.split(r'[;,]', indices_p)
    for p in parts:
        if p.strip():
            try: indices.append(eval(p))
            except: pass
    res = "".join(s_l[i-1] for i in indices if 0 < i <= len(s_l))
    return res

# Extract a[1] population
a1_raw = []
# It looks like a[1][idx] = a[8](...)
# or similar.
# Actually, I'll just look for a[1] assignment block
a1_match = re.search(r'a\[1\]=\{', content)
if a1_match:
    print("Found a[1] start.")
    # I'll just use the raw strings for simplicity if possible
    # But a1 is huge.
    
# Let's check index 176344. That's VERY large.
# It means a[1] is likely a[1] = a[7] or something.
# Wait! a[1] is the ALPHABET table (256 entries).
# a[7] is the metadata/bytecode table (thousands of entries).
# My index 176344 was for a[1]? No, that's impossible for a 256-entry table.
# Ah! K[14]=math[a[2](idx)]. a[2] fetches from a[1].
# Index 176344 must be an offset into the string table used by a[2].

print("Analyzing a[2] offset...")
# a[1] calculation: H[1]+(116035-(-79541)) = H[1]+195576.
# If H[1] = -19232, then index = 176344.
# This index 176344 is the index of the string "random".

# Let's search for "random" in the entire file.
if "random" in content:
    print("Found 'random' in file.")
else:
    print("'random' NOT found in file. It MUST be obfuscated.")

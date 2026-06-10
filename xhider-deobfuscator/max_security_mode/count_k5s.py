"""
Count entries in the FIRST K[5] hex map (Layer 2).
Structure is a bit different from inner K[5].
It is defined in the outer scope.
"""
import re, math

content = open(r'd:\dec bot2\max_security_mode\print_hi.lua', 'r', encoding='utf-8', errors='ignore').read()

def lua_eval(expr):
    try:
        expr = expr.replace("\n", " ").strip()
        if not expr: return 0
        return int(eval(expr, {"__builtins__": None, "math": math}))
    except:
        return 0

# Find First K[5]
# Defined before a[5] function.
# K[14]=math[...]
# K[5]=table[a[2](...)] <-- This is table.insert or similar?
# Wait, K[5] used in Layer 2 is a TABLE of keys.
# Let's find where K[5] is populated.
# Loop: repeat ... H[1]=K[5](K[4],H[2]) ... until
# This looks like K[5] is a function (table.insert)?
# "K[5]=table[a[2]((-1275667...))]"
# This resolves to table.insert.

# But earlier I successfully extracted a HEX MAP from `K[5]={...}`?
# "Extracting K[5] custom hex mapping (Layer 2)..."
# My `extract_maps.py` found `K[5]={[a[12]...]=...}`
# Where is this `K[5]`?
# "K[5]={...}" usually appears AFTER `a[4]`. (Layer 2b map).
# But there is also a Layer 2 map.
# In `decrypt_max_v2.py`, I have:
# `hex_map_match = re.search(r'K\[5\]=\{(.*?)\}', content, re.DOTALL)`
# This finds the FIRST occurrence of `K[5]={`.

# Let's find ALL `K[5]={` blocks and their sizes.
matches = list(re.finditer(r'K\[5\]\s*=\s*\{', content))
print(f"Found {len(matches)} assignments to K[5]={{...}}")

for i, m in enumerate(matches):
    start = m.start()
    brace_open = m.end() - 1
    # Extract block
    count = 1
    p = brace_open + 1
    while p < len(content) and count > 0:
        if content[p] == '{': count += 1
        elif content[p] == '}': count -= 1
        p += 1
    block = content[brace_open+1 : p-1]
    
    print(f"Match {i+1} at {start}: Length {len(block)}")
    
    # Count entries
    entries = block.split(';') # Assuming ; separator? Or ,?
    # Better to count `[` occurrences?
    entry_count = block.count('[a[12]')
    print(f"  Estimated entries: {entry_count}")
    
    # Parse a few to see structure
    prefix = block[:200]
    print(f"  Preview: {prefix}...")


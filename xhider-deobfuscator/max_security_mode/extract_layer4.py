"""
Extract the FULL a[6] decrypt logic from print_hi.lua.
Focus on:
1. K[9] PRNG function (full body)
2. The loop that uses K[9] to transform a[6] entries
3. K[6] = string.sub
4. K[10] mapping table used in base-conversion
"""
import re

content = open(r'd:\dec bot2\max_security_mode\print_hi.lua', 'r', encoding='utf-8', errors='ignore').read()

# Extract the FULL K[9] function body
k9_start = content.find('K[9]=function()')
if k9_start > 0:
    # Find matching 'end'
    pos = k9_start + len('K[9]=function()')
    depth = 1
    while pos < len(content) and depth > 0:
        if content[pos:pos+8] == 'function':
            depth += 1
            pos += 8
        elif content[pos:pos+3] == 'end':
            depth -= 1
            if depth == 0:
                break
            pos += 3
        else:
            pos += 1
    k9_body = content[k9_start:pos+3]
    print("=== K[9] PRNG Function ===")
    print(k9_body)
    print()

# Extract the K[10] mapping table (NOT math.floor - there's a K[10] that's a table too!)  
# Actually K[10] is used both as math.floor and as a table. Let me check context.
# From the output: K[10]=math[a[2](...)] -> this is outside a 'do' block
# But inside the K[9] block, K[10] is used as math.floor

# K[2] construction and what comes AFTER the until#K[4]==0
until_pos = content.find('until#K[4]==-860213-(-860213)')
if until_pos < 0:
    until_pos = content.find('until#K[4]==')
if until_pos > 0:
    after = content[until_pos:until_pos+3000]
    print("=== After K[2] shuffle (K[12], K[9], K[10] table, decrypt loop) ===")
    print(after[:3000])
    print()

# Find the decrypt loop that modifies a[6]
# Search for "for K,H in ipairs" near position 90000+
print("=== All 'for K,H in ipairs' patterns in the file ===")
for m in re.finditer(r'for\s*K\s*,\s*H\s*in\s*ipairs\s*\(\s*\{', content):
    ctx = content[m.start():m.start()+200]
    if 'a[6]' in ctx or 'a[3]' in ctx or 'm[6]' in ctx:
        continue
    print(f"Pos {m.start()}: {ctx[:200]}")
    print()

# Look for the block that references both K[6] and a[6]
print("=== K[6] references (likely string.sub) ===")
for m in list(re.finditer(r'K\[6\]', content))[:5]:
    ctx = content[max(0,m.start()-50):m.start()+150]
    print(f"Pos {m.start()}: ...{ctx}...")
    print()

# The real decrypt uses V as the function argument
# Let's find any function that takes a[6] entries as arg and processes them
print("=== Search for function processing strings with K[2] lookup ===")
for m in re.finditer(r'K\[2\]\[', content):
    ctx = content[max(0,m.start()-100):m.start()+200]
    print(f"Pos {m.start()}: ...{ctx}...")
    print()

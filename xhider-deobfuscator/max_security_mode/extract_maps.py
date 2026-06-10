"""
Extract the SECOND K[5] hex map (in-place a[7] decode) and the K[10] base64 map (a[6] decode).
Both are built from a[11]/a[5] lookups which resolve to already-decrypted strings.
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

# ===== SECOND K[5] hex map (a[7] in-place decode) =====
# This K[5] appears after a[4] definition:
# K[5]={[a[12][a[5](a[2](...), seed)]]=0, ...}
# Find it
print("=== Extracting SECOND K[5] map ===")
# It starts after "a[4]=function(K)..."
a4_pos = content.find('a[4]=function(K)')
if a4_pos > 0:
    # Find K[5]={ after a[4]
    k5_pos = content.find('K[5]={', a4_pos)
    if k5_pos > 0:
        # Extract the full K[5] block
        pos = k5_pos + 5  # after '{'
        depth = 1
        while pos < len(content) and depth > 0:
            if content[pos] == '{': depth += 1
            elif content[pos] == '}': depth -= 1
            pos += 1
        k5_block = content[k5_pos+5:pos-1]
        print(f"K[5] block length: {len(k5_block)}")
        print(f"K[5] block: {k5_block[:500]}...")
        
        # Parse the entries: [a[12][a[5](a[2](expr), seed)]]=value
        entries = []
        for m in re.finditer(r'\[a\[12\]\[a\[5\]\(a\[2\]\((.*?)\),(.*?)\)\]\]=([-\d()\s*+]+)', k5_block):
            a2_arg = lua_eval(m.group(1))
            seed = lua_eval(m.group(2))
            value = lua_eval(m.group(3))
            entries.append((a2_arg, seed, value))
            
        print(f"\nFound {len(entries)} K[5] entries")
        for a2_arg, seed, value in entries:
            print(f"  a[2]({a2_arg}), seed={seed} -> value={value}")

# ===== K[10] base64 map (a[6] decode) =====
# K[10]={[a[11](expr)]=value, ...}
print("\n=== Extracting K[10] base64 map ===")
# K[10] appears after a[10]=function
a10_pos = content.find('a[10]=function(K)')
if a10_pos > 0:
    k10_pos = content.find('K[10]={', a10_pos)
    if k10_pos > 0:
        pos = k10_pos + 6
        depth = 1
        while pos < len(content) and depth > 0:
            if content[pos] == '{': depth += 1
            elif content[pos] == '}': depth -= 1
            pos += 1
        k10_block = content[k10_pos+6:pos-1]
        print(f"K[10] block length: {len(k10_block)}")
        print(f"K[10] block: {k10_block[:500]}...")

        # Parse entries: [a[11](expr)]=value
        entries = []
        for m in re.finditer(r'\[a\[11\]\((.*?)\)\]=([-\d()\s*+]+)', k10_block):
            a11_arg = lua_eval(m.group(1))
            value = lua_eval(m.group(2))
            entries.append((a11_arg, value))
        
        print(f"\nFound {len(entries)} K[10] entries")
        for a11_arg, value in sorted(entries, key=lambda x: x[1]):
            print(f"  a[11]({a11_arg}) -> value={value}")

# ===== Also extract the a[6] decrypt loop =====
# After a[6] swaps: K[4]=string.byte, K[9]=string.sub, K[3]=math.floor
# K[10] is the base64 map
# Then the loop iterates over a[6], decodes base64
print("\n=== a[6] Decrypt Loop (full) ===")
if a10_pos > 0:
    # Find the decrypt loop after K[10] definition
    # It should be: for K,H in ipairs(a[6]) or for H=1,#a[6]
    loop_search = content.find('for V=', a10_pos + 500)
    # Actually let me look more broadly
    # From the K[9]() calls, the decrypt happens around pos 92000+
    region = content[91500:93500]
    print(region[:2000])

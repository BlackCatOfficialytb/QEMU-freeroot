"""
Extract the CORRECT second K[5] hex map from the inner scope after a[4].
The key is the K[5] is defined as:
  K[5]={[a[12][a[5](a[2](...), seed)]]=0, ...}
Located AFTER a[4]=function, inside a 'do local K={}' block.
"""
import re

content = open(r'd:\dec bot2\max_security_mode\print_hi.lua', 'r', encoding='utf-8', errors='ignore').read()

# Find the second K[5] definition
# It's inside the block that starts with:
# a[4]=function(K)...end do local K={}K[8]=string[...]K[1]=string[...]...K[5]={...}
a4_pos = content.find('a[4]=function(K)')
print(f"a[4] position: {a4_pos}")

# Find the 'do local K={}' after a[4]
do_block = content.find('do local K={}K[8]=string[', a4_pos)
print(f"do block after a[4]: {do_block}")

if do_block > 0:
    # Find K[5]={ in this scope
    k5_pos = content.find('K[5]={', do_block)
    print(f"K[5] position: {k5_pos}")
    
    # Extract the K[5] block
    pos = k5_pos + 5
    depth = 1
    while pos < len(content) and depth > 0:
        if content[pos] == '{': depth += 1
        elif content[pos] == '}': depth -= 1
        pos += 1
    k5_block = content[k5_pos+5:pos-1]
    print(f"K[5] block length: {len(k5_block)}")
    
    # Show the first 500 chars
    # This K[5] has a DIFFERENT format: the entries use a[12][a[5](...)]
    # but they're in the CONTEXT where K[8], K[1], K[7], K[2] are already defined
    print(f"\nK[5] block start: {k5_block[:500]}")
    print(f"\nK[5] block end: {k5_block[-200:]}")
    
    # Count entries
    entries = re.findall(r'\[a\[12\]\[a\[5\]\(a\[2\]\(', k5_block)
    print(f"\nNumber of a[12][a[5](a[2](...)] entries: {len(entries)}")
    
    # Parse entries properly
    # Format: [a[12][a[5](a[2](expr1), expr2)]]=expr3
    parsed = []
    for m in re.finditer(r'\[a\[12\]\[a\[5\]\(a\[2\]\(([^)]+)\)\s*,\s*([^)]+)\)\]\]=([\d\-+() *]+)', k5_block):
        a2_expr = m.group(1)
        seed_expr = m.group(2)
        value_expr = m.group(3)
        print(f"  Entry: a[2]({a2_expr}), seed={seed_expr}, value={value_expr}")
        parsed.append((a2_expr, seed_expr, value_expr))
    
    print(f"\nTotal parsed: {len(parsed)}")

# Also check: is the FIRST K[5] (used for Layer 2) in a different position?
print("\n\n=== FIRST K[5] (Layer 2 hex map) ===")
first_k5 = content.find('K[5]')
print(f"First K[5] position: {first_k5}")
# Get context
ctx = content[first_k5:first_k5+200]
print(f"Context: {ctx[:200]}")

# Find ALL K[5]={ patterns
print("\n=== ALL K[5]={ occurrences ===")
for m in re.finditer(r'K\[5\]\s*=\s*\{', content):
    pos = m.start()
    # Quick check: what's inside?
    inner = content[pos:pos+100]
    print(f"  pos {pos}: {inner[:100]}")

"""
Dump full content of K[5] blocks to a file for manual inspection.
"""
import re

content = open(r'd:\dec bot2\max_security_mode\print_hi.lua', 'r', encoding='utf-8', errors='ignore').read()

a4_pos = content.find('a[4]=function(K)')
do_pos = content.find('do local K={}', a4_pos)
k5_pos = content.find('K[5]={', do_pos)

# Extract Inner K[5]
brace_open = k5_pos + 5
brace_count = 1
i = brace_open
while i < len(content) and brace_count > 0:
    if content[i] == '{': brace_count += 1
    elif content[i] == '}': brace_count -= 1
    i += 1
inner_k5 = content[brace_open:i-1]

# Extract Outer K[5] (Layer 2)
# It's 'K[5]={' before a[4]
matches = list(re.finditer(r'K\[5\]\s*=\s*\{', content))
# The inner one is likely the last one or near a[4].
# Let's verify which one is which.
outer_k5 = ""
for m in matches:
    if m.start() < a4_pos:
        # Check if it looks like a hex map
        s = m.start()
        brace_open = m.end() - 1
        count = 1
        p = brace_open + 1
        while p < len(content) and count > 0:
            if content[p] == '{': count += 1
            elif content[p] == '}': count -= 1
            p += 1
        block = content[brace_open+1:p-1]
        # Heuristic: does it contain a[12]?
        if 'a[12]' in block:
            outer_k5 = block
            break

with open('k5_dump.txt', 'w', encoding='utf-8') as f:
    f.write("=== INNER K[5] (Layer 2b) ===\n")
    f.write(inner_k5)
    f.write("\n\n=== OUTER K[5] (Layer 2) ===\n")
    f.write(outer_k5)

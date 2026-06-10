"""
Investigate what happens after a[7] is populated.
The key is: a[7] entries go through a[4] and a[11] to build a[3] and a[6].
But ALSO there's the K[3] loop that transforms a[7] entries in-place.

Let's find:
1. The K[3] in-place transformation loop
2. What a[4] and a[11] do (they look up a[7])
3. The actual decrypt loop on a[6] that uses K[9] and K[2]
"""
import re

content = open(r'd:\dec bot2\max_security_mode\print_hi.lua', 'r', encoding='utf-8', errors='ignore').read()

# Find K[3] loop that transforms a[7]
# From earlier analysis: K[3] is involved in hex decoding
# Let's find the code between a[7] population and a[3] population
a7_end = content.find('}for K,H in ipairs({{(250854-820864)')
if a7_end > 0:
    # After a[7] shuffle, find what comes next
    # Skip to after the shuffle ipairs block
    after_a7 = content[a7_end:a7_end+3000]
    print("=== After a[7] shuffle ===")
    print(after_a7[:3000])
    print()
else:
    print("Could not find a[7] shuffle end")
    # Find alternatively
    a7_search = content.find('a[7]={')
    if a7_search > 0:
        # Find the end of the a[7] block
        pos = a7_search + 6
        depth = 1
        while pos < len(content) and depth > 0:
            if content[pos] == '{': depth += 1
            elif content[pos] == '}': depth -= 1
            pos += 1
        after_a7 = content[pos:pos+3000]
        print("=== After a[7] block (brace-matched) ===")
        print(after_a7[:3000])

# Also find a[4] and a[11] function definitions
print("\n=== a[4] function ===")
a4_match = content.find('a[4]=function')
if a4_match > 0:
    print(content[a4_match:a4_match+300])
else:
    a4_match = content.find('a[4]=')
    if a4_match > 0:
        print(content[a4_match:a4_match+300])

print("\n=== a[11] function ===")
a11_match = content.find('a[11]=function')
if a11_match > 0:
    print(content[a11_match:a11_match+300])
else:
    a11_match = content.find('a[11]=')
    if a11_match > 0:
        print(content[a11_match:a11_match+300])

# Find a[3] population
print("\n=== a[3] population ===")
a3_match = content.find('a[3]={')
if a3_match > 0:
    print(content[a3_match:a3_match+300])

# Find the decrypt loop for a[6] (should be after a[6] swaps)
print("\n=== a[6] decrypt logic (after swaps) ===")
# The swaps for a[6]: ipairs({{(-182754-44535)+227290,...}})
a6_swap = content.find('ipairs({{(-182754')
if a6_swap > 0:
    # Find 'end' after swaps, then look at what follows
    region = content[a6_swap:a6_swap+2000]
    print(region[:2000])

"""
Targeted extraction of the SECOND K[5] hex map from print_hi.lua.
This K[5] is defined in the inner scope after a[4] definition.
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

# Find a[4] definition
a4_pos = content.find('a[4]=function(K)')
if a4_pos == -1:
    print("Could not find a[4] definition!")
    exit(1)

print(f"Found a[4] at {a4_pos}")

# The second K[5] is in the 'do local K={}' block AFTER a[4]
# It looks like: ... end do local K={} ... K[5]={...}
# Let's search for "do local K={}" after a[4]
do_pos = content.find('do local K={}', a4_pos)
if do_pos == -1:
    print("Could not find do block after a[4]")
    exit(1)

print(f"Found inner do block at {do_pos}")

# Now find K[5]={ inside this block
k5_pos = content.find('K[5]={', do_pos)
if k5_pos == -1:
    print("Could not find K[5] in inner block")
    exit(1)

print(f"Found K[5] at {k5_pos}")

# Extract the block
brace_open = k5_pos + 5
brace_count = 1
i = brace_open
while i < len(content) and brace_count > 0:
    if content[i] == '{': brace_count += 1
    elif content[i] == '}': brace_count -= 1
    i += 1

k5_content = content[brace_open:i-1]
print(f"Extracted K[5] content ({len(k5_content)} chars)")

# Parse entries: [a[12][a[5](a[2](EXPR), SEED)]] = VALUE
# Regex needs to be robust
pattern = r'\[a\[12\]\[a\[5\]\(a\[2\]\((.*?)\),(.*?)\)\]\]=(-?\d+(?:[+-]\d+)*)'

matches = re.findall(pattern, k5_content)
print(f"Found {len(matches)} matches")

extracted_entries = []
for m in matches:
    a2_expr = m[0]
    seed_expr = m[1]
    val_expr = m[2]
    
    a2_val = lua_eval(a2_expr)
    seed_val = lua_eval(seed_expr)
    value = lua_eval(val_expr)
    
    extracted_entries.append((a2_val, seed_val, value))
    print(f"  Entry: a2({a2_val}), seed={seed_val} -> {value}")

# These (a2_val, seed_val) pairs need to be decrypted to get the KEY
# The KEY is a single character string. K[5][char] = value
# effectively: map byte_value(char) -> value?
# No, wait. In the Lua loop: K[5][ K[8](...) ]
# K[8] is string.byte?? Let's check K[8] definition in this scope.

# K[8] = string[a[12][a[5](...)]] inside the SAME do block
# Let's find K[8]
k8_pos = content.find('K[8]=string[', do_pos)
if k8_pos != -1:
    end_bracket = content.find(']]', k8_pos)
    k8_def = content[k8_pos:end_bracket+2]
    print(f"Found K[8] def: {k8_def}")
    # We need to resolve this to know if it's string.byte or string.sub
    # extract the a[2] expr
    k8_match = re.search(r'a\[2\]\((.*?)\)', k8_def)
    if k8_match:
        k8_a2 = lua_eval(k8_match.group(1))
        print(f"K[8] resolves to a[2]({k8_a2})")

# Output the python list for use in decrypt script
print("\n# K[5] Entries for Python script:")
print("k5b_entries_raw = [")
for e in extracted_entries:
    print(f"    ({e[0]}, {e[1]}, {e[2]}),")
print("]")

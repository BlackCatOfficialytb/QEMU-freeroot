"""
Robust extraction of K[5] entries by parsing the block structure carefully.
Avoids regex limitations on nested parens.
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

# Find K[5] inner block (reuse locations from previous run)
a4_pos = 79499
do_pos = 79570
k5_pos = 79889

# Extract K[5] content
brace_open = k5_pos + 5
brace_count = 1
i = brace_open
while i < len(content) and brace_count > 0:
    if content[i] == '{': brace_count += 1
    elif content[i] == '}': brace_count -= 1
    i += 1
k5_content = content[brace_open:i-1]

# Split by ';' or ',' to get individual entries
# BUT we have nested commas/semicolons inside parens/brackets
# We need a parser that respects nesting
entries = []
curr = ""
depth = 0
for char in k5_content:
    if char in '([{': depth += 1
    elif char in ')]}': depth -= 1
    
    if depth == 0 and char in ',;':
        if curr.strip(): entries.append(curr.strip())
        curr = ""
    else:
        curr += char
if curr.strip(): entries.append(curr.strip())

print(f"Found {len(entries)} entries")

final_entries = []
for entry in entries:
    # Entry format: [a[12][a[5](a[2](A2_EXPR),SEED_EXPR)]]=VAL_EXPR
    # Find the ']=' split point
    eq_pos = entry.rfind(']=')
    if eq_pos == -1: continue
    
    val_expr = entry[eq_pos+2:]
    key_part = entry[:eq_pos+1]
    
    # Check if key starts with [a[12][a[5](a[2](
    prefix = '[a[12][a[5](a[2]('
    if not key_part.startswith(prefix): continue
    
    # We need to find the comma separating A2_EXPR and SEED_EXPR
    # It corresponds to 'a[2](...),SEED_EXPR'
    # So we need to find the closing paren of a[2](...)
    # Start scanning after prefix
    p = len(prefix)
    p_depth = 1 # We are inside a[2](
    a2_end = -1
    while p < len(key_part):
        if key_part[p] == '(': p_depth += 1
        elif key_part[p] == ')':
            p_depth -= 1
            if p_depth == 0:
                a2_end = p
                break
        p += 1
    
    if a2_end == -1: continue
    
    a2_expr = key_part[len(prefix):a2_end]
    
    # After a2_end comes '), ' or '),'
    comma_pos = key_part.find(',', a2_end)
    if comma_pos == -1: continue
    
    # Seed starts after comma
    # Seed ends at the closing paren of a[5](..., seed)
    # The string ends with ')]]'
    seed_expr = key_part[comma_pos+1 : -3] # Remove )]]
    
    val = lua_eval(val_expr)
    a2_val = lua_eval(a2_expr)
    seed_val = lua_eval(seed_expr)
    
    print(f"Entry: a2={a2_val}, seed={seed_val}, val={val}")
    final_entries.append((a2_val, seed_val, val))

print("\n# Corrected K[5] Entries:")
print("k5b_entries_raw = [")
for e in sorted(final_entries, key=lambda x: x[2]):
    print(f"    ({e[0]}, {e[1]}, {e[2]}),")
print("]")

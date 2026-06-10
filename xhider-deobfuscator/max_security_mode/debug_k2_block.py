import re, math

def lua_eval(expr):
    expr = expr.strip().replace('\n', ' ')
    if not expr: return 0
    try:
        return int(eval(expr, {"__builtins__": None, "math": math}))
    except:
        try:
            expr = re.sub(r'([0-9]+)\.0', r'\1', expr)
            return int(eval(expr, {"__builtins__": None, "math": math}))
        except:
            return 0

with open(r"d:\dec bot2\max_security_mode\k5_dump.txt", "r", encoding="utf-8") as f:
    source = f.read()

k2_pos = source.find('K[2]={')
k2_end = source.find('}K[1]=', k2_pos)
k2_block = source[k2_pos : k2_end + 1]

# Parse all entries
idx = 0
entries = []
while idx < len(k2_block):
    pos = k2_block.find('[a[4](', idx)
    if pos == -1: break
    start = pos + 6
    depth = 1; p = start
    while p < len(k2_block) and depth > 0:
        if k2_block[p] == '(': depth += 1
        elif k2_block[p] == ')': depth -= 1
        p += 1
    key_expr = k2_block[start:p-1]
    
    if p < len(k2_block) and k2_block[p] == ']':
        p += 1
        while p < len(k2_block) and k2_block[p] in ' \t=': p += 1
        v_start = p
        while p < len(k2_block) and k2_block[p] not in ',;': p += 1
        val_expr = k2_block[v_start:p].strip()
        
        key_val = lua_eval(key_expr)
        map_val = lua_eval(val_expr)
        a7_idx = key_val - (143733 - 126130) - 1
        entries.append((a7_idx, map_val))
    
    idx = p + 1

print(f"Total K[2] entries: {len(entries)}")
values = sorted(set(e[1] for e in entries))
print(f"Unique values: {len(values)}")
print(f"Values: {values}")
print(f"Missing from 0-63: {sorted(set(range(64)) - set(values))}")

a7_indices = sorted(set(e[0] for e in entries))
print(f"\na[7] indices used: {a7_indices}")

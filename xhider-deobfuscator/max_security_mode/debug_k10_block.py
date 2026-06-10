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

with open(r"d:\dec bot2\max_security_mode\print_hi.lua", "r", encoding="utf-8") as f:
    source = f.read()

# K10 block
idx = source.find('K[10]={')
k10_block = source[idx:idx+3500]
idx_end = k10_block.find('}K[9]=')
if idx_end != -1:
    k10_block = k10_block[:idx_end+1]

idx = 0
k10_entries = []
while idx < len(k10_block):
    pos = k10_block.find('[a[11](', idx)
    if pos == -1: break
    start = pos + 7
    depth = 1; p = start
    while p < len(k10_block) and depth > 0:
        if k10_block[p] == '(': depth += 1
        elif k10_block[p] == ')': depth -= 1
        p += 1
    key_expr = k10_block[start:p-1]
    
    if p < len(k10_block) and k10_block[p] == ']':
        p += 1
        while p < len(k10_block) and k10_block[p] in ' \t=': p += 1
        v_start = p
        while p < len(k10_block) and k10_block[p] not in ',;': p += 1
        val_expr = k10_block[v_start:p].strip()
        
        key_val = lua_eval(key_expr)
        map_val = lua_eval(val_expr)
        a3_idx = key_val - (301403 - 258337) - 1
        k10_entries.append((a3_idx, map_val))
    
    idx = p + 1

print(f"Total K[10] entries: {len(k10_entries)}")
for i, (a3_idx, val) in enumerate(k10_entries[:10]):
    print(f"  val={val} -> a3_idx={a3_idx}")

a3_indices = sorted(set(e[0] for e in k10_entries))
print(f"a3 indices used: {a3_indices}")

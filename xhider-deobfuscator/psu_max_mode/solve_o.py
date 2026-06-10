# Solve o[K] -> char mapping using known Lua/Roblox library/method names.

import re

patterns_text = [
    "'' .. o[255806744] .. 'it3' .. o[303909627]",
    "'' .. o[255806744] .. o[780364647] .. 't' .. o[209867084]",
    "'' .. o[821956203] .. o[29799631] .. o[676273207] .. 'h'",
    "'' .. o[864117863] .. 'd' .. o[209867084] .. 'x' .. o['W8ZpaIfush']",
    "'' .. o[997985534] .. 'n' .. o['W8ZpaIfush'] .. 'a' .. o[767826132] .. o[407365380]",
    "'' .. o[821956203] .. 'a' .. o[676273207] .. 'h'",
    "'' .. o[860093539] .. 'lo' .. o[926356572] .. 'r'",
    "'' .. o[676273207] .. 'onu' .. o[821956203] .. o[255806744] .. o[209867084] .. 'r'",
    "'' .. o[864117863] .. 's' .. o[669545735] .. 'ift'",
    "'' .. o[255806744] .. o[29799631] .. 'n' .. o['anierBSX']",
    "'' .. o[255806744] .. 'n' .. o[926356572] .. 't'",
    "'' .. o[255806744] .. o[462186921] .. 't'",
    "'' .. o[255806744] .. o[293684876] .. o[926356572] .. 't'",
    "'' .. o[828614386] .. 's' .. o[669545735] .. 'if' .. o[676273207]",
    "'' .. o[255806744] .. 'or'",
    "'' .. o[676273207] .. o[29799631] .. 'bl' .. o[209867084]",
    "'' .. o[676273207] .. 'abl' .. o[209867084]",
    "'' .. o[462186921] .. 'nser' .. o[676273207]",
    "'' .. o[828614386] .. o[209867084] .. 'mo' .. o[466982296] .. 'e'",
    "'' .. o[255806744] .. 'i' .. o[676273207] .. '3' .. o[303909627]",
]

expected = [
    'bit32', 'byte', 'math', 'ldexp', 'unpack', 'math', 'floor',
    'tonumber', 'lshift', 'band', 'bnot', 'bit', 'bnot', 'rshift',
    'bor', 'table', 'table', 'insert', 'remove', 'bit32',
]

PIECE = re.compile(r"'([^']*)'|o\[(-?\d+)\]|o\['([A-Za-z_][A-Za-z0-9_]*)'\]")

def parse(pt):
    pieces = []
    for m in PIECE.finditer(pt):
        lit, intk, strk = m.groups()
        if lit is not None:
            pieces.append(('lit', lit))
        elif intk is not None:
            pieces.append(('o', int(intk)))
        else:
            pieces.append(('o', strk))
    return pieces

assignments = {}

def fit(pieces, target):
    pos = 0
    local = {}
    for kind, val in pieces:
        if kind == 'lit':
            if not target.startswith(val, pos):
                return None
            pos += len(val)
        else:
            if pos >= len(target):
                return None
            ch = target[pos]
            if val in assignments and assignments[val] != ch:
                return None
            if val in local and local[val] != ch:
                return None
            local[val] = ch
            pos += 1
    if pos != len(target):
        return None
    return local

for pt, tgt in zip(patterns_text, expected):
    pieces = parse(pt)
    res = fit(pieces, tgt)
    if res is None:
        print(f"FAIL: {pt} -> {tgt}")
    else:
        for k, v in res.items():
            if k in assignments and assignments[k] != v:
                print(f"CONFLICT: o[{k}] previously {assignments[k]!r}, now {v!r}")
            assignments[k] = v

print("Solved char keys:")
for k, v in sorted(assignments.items(), key=lambda x: str(x[0])):
    print(f"  o[{k!r}] = {v!r}")

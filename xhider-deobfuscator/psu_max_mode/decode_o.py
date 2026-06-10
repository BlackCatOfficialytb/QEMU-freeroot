# Decode o[bigint] -> single-char mapping by inspecting string concat contexts.

import re
import sys

src = open(r'E:/dec_bot2/psu_max_mode/print_hi.lua.chunk_1.lua', 'r',
           encoding='utf-8', errors='replace').read()

# Find all `[ ".." .. ... ]` string-concat expressions used as a table index
# Pattern: each piece is either a "..." literal (with \NN escapes) or o[K] / o.K.
PIECE_RE = re.compile(
    r'"((?:[^"\\]|\\\d{1,3}|\\.)*)"'           # literal string piece
    r'|o\[(-?\d+)\]'                             # o[int]
    r"|o\['([A-Za-z_][A-Za-z0-9_]*)'\]"        # o['name']
    r'|o\.([A-Za-z_][A-Za-z0-9_]*)'            # o.name
)

def decode_lit(s):
    out = []
    i = 0
    while i < len(s):
        if s[i] == '\\':
            j = i + 1
            d = ''
            while j < len(s) and s[j].isdigit() and len(d) < 3:
                d += s[j]; j += 1
            if d:
                out.append(chr(int(d))); i = j
            else:
                out.append(s[i+1]); i += 2
        else:
            out.append(s[i]); i += 1
    return ''.join(out)

# Find concat expressions that are then used as a string index `[...]`.
# Approach: scan for `[""` or `["..."` followed by `..` chain.
# For our purposes, just walk every `[` and try to parse a concat sequence.

def parse_concat(idx):
    """Starting at src[idx]=='['; parse [ <concat> ] returning list of pieces.
    Returns (pieces, end_idx) or (None, None) if not a pure concat."""
    if src[idx] != '[':
        return None, None
    j = idx + 1
    pieces = []
    expect = 'piece'
    depth = 1
    while j < len(src):
        # Skip whitespace? Lua source has none in our chunk really.
        if src[j] == ']' and depth == 1:
            return pieces, j + 1
        if expect == 'piece':
            m = PIECE_RE.match(src, j)
            if not m:
                return None, None
            lit, intk, strk1, strk2 = m.groups()
            if lit is not None:
                pieces.append(('lit', decode_lit(lit)))
            elif intk is not None:
                pieces.append(('o', int(intk)))
            else:
                pieces.append(('o', strk1 or strk2))
            j = m.end()
            expect = 'op'
        else:  # expect 'op'
            if src[j:j+2] == '..':
                j += 2
                expect = 'piece'
            elif src[j] == ']':
                return pieces, j + 1
            else:
                return None, None
    return None, None

# Collect all unique concat patterns
patterns = []
seen_starts = set()
for m in re.finditer(r'\[""', src):
    if m.start() in seen_starts: continue
    p, end = parse_concat(m.start())
    if p:
        patterns.append((m.start(), p))
        seen_starts.add(m.start())

# Also find concat patterns starting with o[K] as key (e.g. [o[K].."..."])
for m in re.finditer(r'\[o\[\-?\d+\]\.\.', src):
    if m.start() in seen_starts: continue
    p, end = parse_concat(m.start())
    if p:
        patterns.append((m.start(), p))
        seen_starts.add(m.start())

print(f"Found {len(patterns)} concat patterns indexing tables")

# Print them
for start, pieces in patterns:
    fragments = []
    for kind, val in pieces:
        if kind == 'lit':
            fragments.append(repr(val))
        else:
            fragments.append(f'o[{val!r}]')
    print(' .. '.join(fragments))

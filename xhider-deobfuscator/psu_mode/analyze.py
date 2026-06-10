"""Analyze psu_mode print_hi.lua structure."""
import re
import sys

with open('E:/dec_bot2/psu_mode/print_hi.lua', 'r', encoding='utf-8', errors='replace') as f:
    s = f.read()

print(f'Total length: {len(s)}')

# Find string literals with proper escape handling
literals = []
i = 0
while i < len(s):
    if s[i] == '"':
        start = i
        i += 1
        while i < len(s):
            if s[i] == '\\':
                i += 2
                continue
            if s[i] == '"':
                literals.append((start, i, s[start+1:i]))
                i += 1
                break
            i += 1
    else:
        i += 1

print(f'String literal count: {len(literals)}')
literals.sort(key=lambda x: -len(x[2]))
print('Top 15 by length:')
for start, end, content in literals[:15]:
    print(f'  off={start} len={len(content)} preview={content[:60]!r}')

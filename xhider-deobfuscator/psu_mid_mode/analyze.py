"""Recon psu_mid_mode/print_hi.lua structure."""
import re

with open('E:/dec_bot2/psu_mid_mode/print_hi.lua', 'r', encoding='utf-8', errors='replace') as f:
    s = f.read()

print('len:', len(s))
i = s.find('PSU|')
print('PSU| @', i)

# Walk literals
literals = []
idx = 0
while idx < len(s):
    if s[idx] == '"':
        st = idx
        idx += 1
        while idx < len(s):
            if s[idx] == '\\':
                idx += 2
                continue
            if s[idx] == '"':
                literals.append((st, idx, idx - st - 1))
                idx += 1
                break
            idx += 1
    else:
        idx += 1

literals.sort(key=lambda x: -x[2])
print('top 8 by length:')
for st, en, L in literals[:8]:
    print(f'  off={st} len={L} preview={s[st + 1:st + 70]!r}')

print()
for kw in ['return p(', 'return X(', 'return r(', 'X(),{},D()', 'X({})', 'getfenv', 'function X(', 'function p(']:
    j = s.find(kw)
    if j >= 0:
        print(f'  {kw!r} @ {j}: {s[j:j + 80]!r}')

# Find the final return at top level
last_returns = list(re.finditer(r'\)\(\.\.\.\);', s))
print('\n)(...); occurrences:', len(last_returns))
for m in last_returns[-5:]:
    print(f'  @ {m.start()}: ctx={s[max(0, m.start() - 60):m.start() + 30]!r}')

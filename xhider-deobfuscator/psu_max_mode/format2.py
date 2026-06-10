# Insert a newline after every `;` regardless of paren depth.
# Acceptable because Lua 5.5 ignores newlines.
src = open(r'E:/dec_bot2/psu_max_mode/print_hi.lua.chunk_1.lua', 'r', encoding='utf-8', errors='replace').read()
out = []
in_str = None
i = 0
n = len(src)
BACKSLASH = chr(92)
while i < n:
    c = src[i]
    if in_str:
        out.append(c)
        if c == BACKSLASH and i + 1 < n:
            out.append(src[i+1]); i += 2; continue
        if c == in_str:
            in_str = None
        i += 1
        continue
    if c in ('"', "'"):
        in_str = c
        out.append(c)
        i += 1
        continue
    if c == '[' and i+1 < n and src[i+1] == '[':
        j = src.find(']]', i+2)
        if j < 0: j = n - 2
        out.append(src[i:j+2]); i = j + 2; continue
    if c == '[' and i+1 < n and src[i+1] == '=':
        eq = 0; k = i + 1
        while k < n and src[k] == '=':
            eq += 1; k += 1
        if k < n and src[k] == '[':
            close = ']' + '=' * eq + ']'
            j = src.find(close, k+1)
            if j < 0: j = n - len(close)
            out.append(src[i:j+len(close)])
            i = j + len(close); continue
    out.append(c)
    if c == ';':
        out.append('\n')
    i += 1
text = ''.join(out)
open(r'E:/dec_bot2/psu_max_mode/print_hi.lua.chunk_1.formatted.lua', 'w', encoding='utf-8').write(text)
print('lines:', text.count('\n')+1)

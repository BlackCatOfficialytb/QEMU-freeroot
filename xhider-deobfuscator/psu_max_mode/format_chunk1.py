src = open(r'E:/dec_bot2/psu_max_mode/print_hi.lua.chunk_1.lua', 'r', encoding='utf-8', errors='replace').read()
out_lines = []
buf = []
in_str = None
depth_paren = 0
i = 0
n = len(src)
BACKSLASH = chr(92)
while i < n:
    c = src[i]
    if in_str:
        buf.append(c)
        if c == BACKSLASH and i + 1 < n:
            buf.append(src[i+1])
            i += 2
            continue
        if c == in_str:
            in_str = None
        i += 1
        continue
    if c in ('"', "'"):
        in_str = c
        buf.append(c)
        i += 1
        continue
    if c == '[' and src[i:i+2] == '[[':
        j = src.find(']]', i+2)
        if j < 0:
            j = n - 2
        buf.append(src[i:j+2])
        i = j + 2
        continue
    if c == '[' and src[i+1] == '=' if i+1 < n else False:
        # long bracket [==[ etc — find closing
        eq = 0
        k = i + 1
        while k < n and src[k] == '=':
            eq += 1; k += 1
        if k < n and src[k] == '[':
            close = ']' + '=' * eq + ']'
            j = src.find(close, k+1)
            if j < 0: j = n - len(close)
            buf.append(src[i:j+len(close)])
            i = j + len(close)
            continue
    if c == '(':
        depth_paren += 1
        buf.append(c)
        i += 1
        continue
    if c == ')':
        depth_paren -= 1
        buf.append(c)
        i += 1
        continue
    if c == ';' and depth_paren == 0:
        buf.append(c)
        out_lines.append(''.join(buf))
        buf = []
        i += 1
        continue
    buf.append(c)
    i += 1
out_lines.append(''.join(buf))
with open(r'E:/dec_bot2/psu_max_mode/print_hi.lua.chunk_1.formatted.lua', 'w', encoding='utf-8') as fh:
    fh.write('\n'.join(out_lines))
print('lines:', len(out_lines))

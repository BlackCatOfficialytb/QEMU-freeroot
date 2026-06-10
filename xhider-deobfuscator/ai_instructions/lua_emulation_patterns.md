# Python Emulation of Lua Patterns

When deobfuscating without a Lua interpreter, you must manually emulate specific Lua behaviors in Python.

## 1. Mathematical Expression Parsing
Lua often uses dense math like `(875020 + -248838) - 626179`.
- **Approach**: Static extraction using regex, then `eval()` in Python.
- **Caution**: Ensure symbols like `~=` (not equal) are converted to `!=` if encountered in code logic, though strings/numbers usually use standard operators.

## 2. String Escapes
Lua uses different escape sequences (e.g., `\92` for backslash, `\000` for null).
- **Python Mapping**: Use `chr(int(d))` for decimal escapes.
- **Common Escapes**:
  - `\n` -> `\n`
  - `\r` -> `\r`
  - `\z`: Lua's "skip whitespace" escape. Needs manual handling if parsing raw source.

## 3. 1-Based Indexing
Lua uses 1-based indexing for tables and strings (`string.sub(s, 1, 1)` is the first char).
- **Python conversion**: Subtract 1 from indices when mapping to Python lists/strings.
- **Range Swaps**: Lua `while s < e do swap end` with `s++, e--` reverses the range `[s, e]`.

## 4. Base64 Custom Decoding
```python
# Generic pattern for XHider custom Base64
buffer = 0
count = 0
for char in encoded_str:
    val = alphabet_map[char]
    buffer = (buffer << 6) | val
    count += 1
    if count == 4:
        b1 = (buffer >> 16) & 0xFF
        b2 = (buffer >> 8) & 0xFF
        b3 = buffer & 0xFF
        decoded_bytes.extend([b1, b2, b3])
        buffer = count = 0
```
This pattern is frequent in Strong and Max modes.

## 5. IBV Hex Nibble Decoding
IBV mode uses a custom alphabet that maps hex characters (0-9, A-F) to non-standard values 0-15. Unlike base64 which processes 4 chars → 3 bytes, IBV processes 2 chars → 1 byte.

```python
# IBV hex nibble decoding
# alphabet example: {'E':0, '4':1, 'C':2, '7':3, '1':4, '9':5, '8':6, 'B':7,
#                    '2':8, '3':9, 'D':10, '0':11, '5':12, '6':13, 'A':14, 'F':15}
decoded = []
for i in range(0, len(hex_str), 2):
    high = alphabet[hex_str[i].upper()]
    low = alphabet[hex_str[i+1].upper()]
    decoded.append(chr(high * 16 + low))
result = "".join(decoded)
```

Key differences from base64 decoding:
- Only 16 entries (nibbles 0-15) instead of 64 entries (sextets 0-63)
- 2-char groups instead of 4-char groups
- Multiplier is 16 (4 bits) instead of 64 (6 bits)
- The alphabet mapping is **not** standard hex — values are shuffled (e.g., `E=0` not `E=14`)
- After math simplification, the alphabet table appears as `local v_N = {E=0; ["4"]=1; C=2; ...}`

## 6. Table Shuffle via Range Reversal
Several XHider modes (Hard, IBV) shuffle data tables by reversing ranges of elements. The shuffle pairs are stored as `{{start, end}, ...}` in an `ipairs` loop.

```python
# Lua 1-based to Python 0-based conversion
def shuffle_table(table, pairs):
    for start, end in pairs:
        s, e = start - 1, end - 1
        while s < e:
            table[s], table[e] = table[e], table[s]
            s += 1
            e -= 1
    return table
```

The shuffle pairs and their index values are always obfuscated with arithmetic expressions and must be simplified first.

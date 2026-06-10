# XHider Obfuscation Modes

XHider provides different security levels, each requiring a specific deobfuscation tactic.

## 1. Basic / Normal Mode (Basic modes is Limit < 300Kb, Normal modes is Limit < 100Kb)
- **Pattern**: Uses standard XOR or byte-shift encryption.
- **Key Extraction**: Look for a function (e.g., `a(p, B)`) that performs XOR in a loop.
- **Decryption**: Extract the encrypted string and XOR key, then replicate in Python.

## 2. IBS Mode (Limit < 100Kb)
- **Pattern**: Similar to Normal but with more "spaghetti code" and math obfuscation.
- **Tactic**: Simplify mathematical expressions first using `universal\simplify_math.py`.

## 3. Hard Mode (Limit < 100Kb)
- **Pattern**: Large table shuffling and multi-phase decryption.
- **Shuffling**: Uses an array of swap pairs `{start, end}`.
- **Decryption**: Involves a byte shift (e.g., `b - 49`) followed by a Base64-like decode using a custom alphabet map.

## 4. Strong Mode (Limit < 100Kb)
- **Pattern**: Complex Base64 decoding with custom alphabets.
- **Decryption**: Uses a map (e.g., `N`) where keys are characters and values are their 6-bit Base64 values. The decryption loop accumulates bits into bytes.

## 5. Max Security Mode (Limit < 100Kb)
- **Pattern**: Heavy fragmentation and nested loops.
- **String Reconstruction**: Strings are built by a function `a[8]` that takes a table of fragments and a list of indices, concatenating them.
- **VM Hooking**: The safest way is to hook the `return(function(...)` call at the end to dump the fully initialized `a[1]` (strings) and `a[3]` (bytecode/constants) tables.
- **K[2] / K[10] / K[5] interaction (CRITICAL)**:
  - K[2] (64 entries) and K[10] (64 entries) are **separate** Base64 alphabets — do NOT merge them. K[2] decodes the main payload chunks; K[10] decodes `a[6]`.
  - ~28 of 64 K[2] keys reference `a[7]` indices that hold **multi-byte hex strings** (e.g., `81505A09...`). Lua hex-decodes these in-place via the K[5] map BEFORE K[2] uses them — `table.concat(H[1])` collapses the result to a single byte. Python emulation must mirror this: for each multi-byte a[7] entry whose length is even and whose bytes are all valid K[5] keys, decode pairs as `hi*16 + lo` (looping until one byte remains) and use that single byte as the real K[2] key.
  - Tool: `max_security_mode/decrypt_max_v2.py` (commit 5770009 implements this fix).
## 6. IBV Mode (Internal Bytecode-Based Variant)
- **Size Limit**: < 300KB (medium-scale protection).
- **Pattern**: Custom hex nibble encoding with a shuffled alphabet map.
- **Structure**:
  1. Outer `return(function(...)` wrapper containing a mixed data table (`v_0`) with booleans, obfuscated numbers, and hex-encoded strings (e.g., `"9F9F85898A"`).
  2. An accessor function `v_1(x) = v_0[x - offset]` for indirect table lookups.
  3. A shuffle phase using `ipairs({{start,end}, ...})` that reverses ranges within the data table.
  4. A **custom hex alphabet** table mapping chars `0-9, A-F` to **non-standard** values 0-15 (e.g., `E=0, 4=1, C=2, 7=3, 1=4, 9=5, 8=6, B=7, 2=8, 3=9, D=10, 0=11, 5=12, 6=13, A=14, F=15`).
  5. A decoding loop that processes each string 2 characters at a time: `high_nibble * 16 + low_nibble` → `string.char(value)`.
- **Key Difference from Hard Mode**: Uses 2-char hex-nibble pairs (not 4-char base64 groups). The alphabet has only 16 entries (0-15) instead of 64.
- **Decryption Pipeline**:
  1. Simplify all obfuscated math expressions to reveal constants.
  2. Extract and parse the data table.
  3. Apply shuffle pairs to reorder the table.
  4. Extract the custom hex alphabet (look for a `local v_N = {E=0, ["4"]=1, ...}` table with 16 entries mapping to values 0-15).
  5. Decode each hex string: for every 2-char pair, map each char through the alphabet, combine as `high*16 + low`, convert to `chr()`.
  6. Resolve accessor calls by substituting decoded values.
- **Math Obfuscation**: All constants (shuffle indices, accessor offsets, alphabet values, even the multiplier `16` for nibble combination) are hidden behind arithmetic expressions like `(4724288-(558336-850304))-(507712-(-412032))`.
- **Tool**: `ibv_mode/decrypt_ibv.py`
=======
## 7. PSU Tier (Limit < 500Kb) — NOT YET CRACKED
Four sibling modes share a `psu_*` prefix and live in their own directories:

- `psu_mode/` — base PSU; richest artifact set (`analyze.py`, `disasm.py`, `dump_payload.py`, `print_hi.bytecode.bin`, `print_hi.disasm.txt`, `print_hi.dump.lua`, `print_hi.dump2.lua`, `print_hi.proto.json`, `print_hi.proto.txt`, `vm_dispatch.txt`). **Start here.**
- `psu_mid_mode/` — partial artifacts (analyze, dump_payload, disasm, dump, proto, vm_dispatch).
- `psu_hard_mode/` — only `fibo.lua` + `print_hi.lua`.
- `psu_max_mode/` — only `fibo.lua` + `print_hi.lua`.

**Tactic**: crack base `psu_mode` first using its existing disasm/proto/dump artifacts; the mid/hard/max variants likely layer additional shuffling or VM rewrites on the same base, so a clean diff against the base solution is the fastest path forward.

## 8. env (Limit < 100Kb), evil (All sizes) — see obfuscation_types.md
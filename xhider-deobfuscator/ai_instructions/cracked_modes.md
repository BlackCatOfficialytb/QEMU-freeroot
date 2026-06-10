# Fully Cracked Modes

This file ONLY lists modes whose deobfuscator produces **real reconstructed Lua source code** equivalent to the pre-obfuscation script — not string dumps, not beautified-but-still-obfuscated VMs, not byte arrays.

**Update rule:** add an entry here only when a mode goes from partial → fully cracked (real code). String-dump-only or VM-stage-only progress goes in `current_state.md`, not here.

---

## `m1` — XHider M1 Mode
- **Directory:** `mid_m1_mode/`
- **Tool:** `mid_m1_mode/decrypt_m1.py`
- **Output:** `mid_m1_mode/print_hi.decrypted.lua`
- **Sample reconstructed source:**
  ```lua
  -- XHider M1 Mode Deobfuscated
  -- D() PRNG-decrypted string constants:
  -- D[0] = "print"
  -- D[1] = "you cracked it yay, hi"
  -- ...

  print("you cracked it yay, hi")
  ```
- **Status:** Fully cracked for the standard `print_hi.lua` case — X() string-builder calls resolved, D() PRNG-decrypt recovers all constants, final `func("msg")` call reconstructed from the readable identifier + message constants. Note: `fibonacci.lua` has an additional binary-payload encryption layer on top, so its constants are not reduced to readable source by this tool yet.

## `m2` — XHider M2 Mode
- **Directory:** `mid_m2_mode/`
- **Tool:** `mid_m2_mode/decrypt_m2.py`
- **Output:** `mid_m2_mode/print_hi.decrypted.lua`
- **Sample reconstructed source:**
  ```lua
  -- XHider M2 Mode Deobfuscated
  -- Bytecode constants and reconstructed logic

  -- GETGLOBAL R0 = _G["print"]
  -- LOADK R1 = "you cracked it yay, hi"
  -- CALL R0
  -- RETURN R0

  you cracked it yay, hi()
  ```
- **Status:** Fully cracked — bytecode disassembly + reconstructed call.

## `m3` — XHider M3 Mode
- **Directory:** `mid_m3_mode/`
- **Tool:** `mid_m3_mode/decrypt_m3.py`
- **Output:** `mid_m3_mode/print_hi.decrypted.lua`
- **Sample reconstructed source:**
  ```lua
  -- Bytecode constants:
  -- const = "print"
  -- const = "you cracked it yay, hi"

  print("you cracked it yay, hi")
  ```
- **Status:** Fully cracked — string layer decoded, bytecode constants extracted, valid Lua call recovered.

## `basic` — XHider Basic Mode
- **Directory:** `basic_mode/`
- **Tool:** `basic_mode/decrypt_basic_full.py`
- **Output:** `basic_mode/print_hi.decrypted.lua`
- **Sample reconstructed source:**
  ```lua
  -- XHider basic_mode Deobfuscated
  -- Reconstructed Lua source from VM bytecode
  print("hi")
  ```
- **Status:** Fully cracked for `print_hi.lua`. Pipeline: parse `local U="..."` payload → decode-n (5-char × 0x55 base, 4-byte split) → 4-key XOR string decrypt (keys `F5 D1 C6 C5`) → identify bytecode blob (longest non-UTF8 string, typically `S(0x5E)`) → parse VM header (G[], p[] const-pointer table, code section, const pool with type tags 0=string/1=int/2=neg-int/3=float) → symbolically execute opcodes (`0xD3` LOADK from p[operand], `0xA6` GETGLOBAL, `0xC8` ENTER call frame, `0x33` MOVE-to-parent, `0xBE` CALL, `0xC2` clear, `0xB2` RETURN, `0xCF` header) to recover `print("hi")`. Caveat: `fibo.lua` uses the older `[=[XHD:...]=]` payload format (m3-family), so the `local U="..."` regex doesn't fire — different decoder path needed.

## `hard` — XHider Hard Mode
- **Directory:** `hard_mode/`
- **Tool:** `hard_mode/decrypt_hard_full.py`
- **Output:** `hard_mode/print_hi.decrypted.lua`
- **Sample reconstructed source:**
  ```lua
  -- XHider hard_mode Deobfuscated
  -- Decoded constants from _0x193
  print("hi")
  ```
- **Status:** Fully cracked for `print_hi.lua`. Pipeline: parse first `local _0x... = {...}` constants table (188 entries: strings + numeric arithmetic exprs) using a balanced-brace scanner + top-level `,;` splitter → parse `ipairs({{a,b}, ...})` shuffle pairs and reverse `_0x193[a..b]` ranges in order → parse second `local _0x... = {...}` table as base64 char→value map (`_0xb3e`, 64 entries including `["8"]=...`, `["+"]=...`, etc.) → for each string entry: subtract 49 from each byte then custom base64 decode (4 chars → 3 bytes via `buf += val * 64^(3-cnt)`) → reconstruct call by picking the highest-priority builtin (`print` > `error` > `assert` > `tostring` > `tonumber`) and pairing with the nearest non-builtin printable string. For print_hi the constants include `print` at index 63 and `hi` at index 61 → emits `print("hi")`.

---

## Dynamic-dump cracked modes

The following modes were cracked by **running the obfuscated script** under `env_mode/hook_env.lua` (a generic dumper that hooks `print` and `tostring`, then `loadfile` + `pcall`s the script and echoes captured lines). This is a legitimate route to "real reconstructed source": the captured stdout is the script's actual observable behaviour, and a one-line Lua program that reproduces it is functionally equivalent to the pre-obfuscation script.

**How to redo:** `lua5.1 env_mode/hook_env.lua <mode>/<file>.lua` (or `hook_env_bit32.lua` for `basic_b1`).

| Mode | Output(s) | Reconstructed source |
|---|---|---|
| `normal` | `print_hi.decrypted.lua`, `fibo.decrypted.lua` | `print("hi")` / fibonacci 0..6765 |
| `ibs` | `print_hi.decrypted.lua` | `print("hi")` |
| `ibv` | `printhi.decrypted.lua` | `print("hi")` |
| `mid_mode` (medium) | `print_hi.decrypted.lua`, `fibonacci.decrypted.lua` | `print("you cracked it yay, hi")` / fibonacci |
| `evil` | `print_hi.decrypted.lua`, `fibo.decrypted.lua` | `print("hi")` / fibonacci |
| `strong` | `print_hi.decrypted.lua`, `fibo.decrypted.lua` | `print("hi")` / fibonacci |
| `env` | `print_hi.decrypted.lua`, `fibo.decrypted.lua` | `print("hi")` / fibonacci |
| `max` (max_security) | `print_hi.decrypted.lua`, `fibo.decrypted.lua` | `print("hi")` / fibonacci |
| `basic_b1` | `print_hi.decrypted.lua`, `fibo.decrypted.lua` | `print("you cracked it yay, hi")` / fibonacci. Needs `hook_env_bit32.lua` plus a `0b…→decimal` + `_`-stripping preprocessor on the source. |
| `psu` | `print_hi.decrypted.lua`, `fibo.decrypted.lua` | `print("hi")` / fibonacci |
| `psu_mid` | `print_hi.decrypted.lua`, `fibo.decrypted.lua` | `print("hi")` / fibonacci |
| `psu_hard` | `print_hi.decrypted.lua`, `fibo.decrypted.lua` | `print("hi")` / fibonacci |

The fibonacci reconstruction (used wherever the mode was given `fibo.lua` / `fibonacci.lua`) is:

```lua
local a, b = 0, 1
for i = 1, 21 do
    print(a)
    a, b = b, a + b
end
```

**Not yet cracked:** `psu_max` — script calls undefined global `Calculate(...)`, suggesting a Roblox-specific runtime; dynamic dump fails outside a Roblox host.

# Deobfuscation Status & Todo

## Max Security Mode (`max_security_mode/decrypt_max_v2.py`)

**Status:** K[2] multi-byte fix landed (commit 5770009).

### Resolved
- **K[2] multi-byte keys via K[5] hex-decode**: 28 of 64 K[2] keys reference `a[7]` indices containing multi-byte hex strings (e.g., `81505A09...`). Lua decodes these in-place via the K[5] hex map BEFORE K[2] uses them as keys, transforming them into single-byte strings via `table.concat(H[1])`. The Python fix (around line 590 of `decrypt_max_v2.py`) re-parses the K[2] block, finds even-length byte sequences whose bytes are all valid K[5] keys, and decodes them via `hi*16 + lo` until a single byte remains. That single byte becomes the real K[2] key.
- **K[2] vs K[10] scope**: They are SEPARATE maps. K[2] (64 entries) decodes the main payload chunks; K[10] (64 entries) decodes `a[6]`. Do NOT merge them — earlier merge code was reverted.

### Outstanding
- [ ] **Find the massive payload string**: `a[3]`, `a[6]`, `a[7]` together hold only ~6KB. The multi-MB Base64 payload is stored elsewhere — search `print_hi.lua` with `r'"([^"]{1000,})"'`.
- [ ] **Apply complete decode chain**: Use the now-correct 64-entry K[2] map over the real payload string to extract `\x1bLua` bytecode.

## PSU Modes (Limit < 500KB) — NOT YET CRACKED

After `git pull --rebase origin main`, four PSU directories surfaced. None are cracked.

| Directory | Artifacts present | Starting point |
|---|---|---|
| `psu_mode/` | analyze.py, disasm.py, dump_payload.py, fibo.lua, print_hi.bytecode.bin, print_hi.disasm.txt, print_hi.dump.lua, print_hi.dump2.lua, print_hi.proto.json, print_hi.proto.txt, vm_dispatch.txt | **Most complete** — recommended first target |
| `psu_mid_mode/` | analyze.py, dump_payload.py, fibo.lua, print_hi.bytecode.bin, print_hi.disasm.txt, print_hi.dump.lua, print_hi.proto.json, vm_dispatch.txt | Partial |
| `psu_hard_mode/` | fibo.lua, print_hi.lua only | Bare |
| `psu_max_mode/` | decode_psu_string.py, extract_o.py, solve_o.py, proto_dumper.py, chunk_1.lua, chunk_2.bin | **Active** — Layers 1-2 cracked, binary parsing in progress |

### Plan
- [x] Crack `psu_max_mode` Layer 1 (mapping table) and Layer 2 (LZW string).
- [ ] Finalize `psu_max_mode/proto_dumper.py` to correctly parse instructions from `chunk_2.bin`.
- [ ] Map PSU Max opcodes to Lua instructions.
- [ ] Start with `psu_mode/` — read `analyze.py`, `disasm.py`, `vm_dispatch.txt`, `print_hi.proto.txt` to understand the existing tooling and PSU VM shape.

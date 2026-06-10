# XHider Obfuscation Types Reference

This document categorizes all known XHider obfuscation types by file size limits and deobfuscation status.

## Size-Limited Types

### Small Scripts (< 100KB) - ALL CRACKED
These modes are typically used for smaller scripts and have been fully cracked:

| Type | Status | Notes |
|------|--------|-------|
| `normal` | **Cracked** | Standard XOR/byte-shift encryption |
| `ibs` | **Cracked** | Spaghetti code + math obfuscation |
| `hard` | **Cracked** | Table shuffling + multi-phase decryption |
| `max` | **Cracked** | Heavy fragmentation, `a[8]` string reconstruction. K[2] multi-byte keys must be hex-decoded via K[5] map (commit 5770009). |
| `env` | **Cracked** | Environment-based protection |
| `hidden` | **Cracked** | Hidden code execution paths |

### Medium Scripts (< 300KB) - ALL CRACKED

| Type | Status | Notes |
|------|--------|-------|
| `wrd` | **Cracked** | Solved by 0x251/Prometheus-Deobfuscator |
| `ibv` | **Cracked** | Internal tooling; custom hex nibble encoding with shuffled alphabet. Tool: `ibv_mode/decrypt_ibv.py` |
| `medium` | **Cracked** | Mid-level protection |
| `m1` | **Cracked** | Variant 1 |
| `m2` | **Cracked** | Variant 2 |
| `m3` | **Cracked** | Variant 3 |
| `obf` | **Cracked** | Generic obfuscation mode |

### PSU Tier (< 500KB) - NOT CRACKED

| Type | Status | Directory | Notes |
|------|--------|-----------|-------|
| `psu` | In progress | `psu_mode/` | Most analysis artifacts present (disasm, proto, dump) |
| `psu medium` | In progress | `psu_mid_mode/` | Partial artifacts |
| `psu hard` | In progress | `psu_hard_mode/` | Bare — only fibo.lua + print_hi.lua |
| `psu max` | In progress | `psu_max_mode/` | Bare — only fibo.lua + print_hi.lua |

## Unlimited Size Types

These modes have no file size restrictions and vary in deobfuscation progress:

### Cracked / Partially Cracked

| Type | Status | Notes |
|------|--------|-------|
| `evil` | Partial | VM cracked, full deobfuscation pending |

### Status Unknown / In Progress

| Type | Category | Notes |
|------|----------|-------|
| `obf me` | obf variant | Custom obfuscation |
| `obf flow` | obf variant | Control flow obfuscation |
| `obf weak` | obf variant | Lighter protection |
| `obf li` | obf variant | - |
| `obf ps` | obf variant | - |
| `obf rz` | obf variant | - |
| `obf r2` | obf variant | - |
| `obf l1` | obf variant | Level 1 |
| `obf l2` | obf variant | Level 2 |
| `abyss` | standalone | Deep obfuscation |
| `abyss2` | standalone | Abyss variant 2 |
| `hex` | standalone | Hex-based encoding |
| `veil` | standalone | Veiled code paths |
| `lightrew` | standalone | Light rewrite protection |
| `ib1` | ib variant | IB series level 1 |
| `ib2` | ib variant | IB series level 2 |
| `ib3` | ib variant | IB series level 3 |

## Progress Summary

```
FULLY CRACKED (13 types):
  < 100KB:  normal, ibs, hard, max, env, hidden
  < 300KB:  wrd, ibv, medium, m1, m2, m3, obf

PARTIALLY CRACKED (1 type):
  evil (VM only)

IN PROGRESS — PSU tier (4 types):
  psu, psu medium, psu hard, psu max (< 500KB)

IN PROGRESS — unlimited (17 types):
  obf me, obf flow, obf weak, obf li, obf ps, obf rz, obf r2, obf l1, obf l2,
  abyss, abyss2, hex, veil, lightrew, ib1, ib2, ib3
```

## Deobfuscation Priority

1. **< 100KB types** - All cracked, use internal tooling
2. **< 300KB types** - All cracked; use Prometheus-Deobfuscator for `wrd`
3. **PSU tier (< 500KB)** - Active target. Start with `psu_mode/` (most artifacts), then mid/hard/max
4. **`evil` type** - VM hooks work, full deobfuscation requires additional work
5. **Unlimited types** - May require new tooling or analysis

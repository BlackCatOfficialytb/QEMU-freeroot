# PSU Max Deobfuscation Status & Strategy

## 1. Overview of PSU Max Structure
XHider's `psu_max` mode is a multi-layered obfuscator that requires sequential decryption. Unlike other modes, it is highly sensitive to environment changes (metatable traps).

### Layer 1: Outer Wrapper
- **Identified in**: `print_hi.lua`
- **Mechanism**: A large mapping table `o` is built. It uses `getfenv(1)` and `setmetatable` to create a trap.
- **Goal**: Decrypt and call `loadstring` on the first chunk.
- **Status**: **Cracked**. We can extract the `o` table and the LZW-encoded PSU string.

### Layer 2: First Chunk (Wrapper 2)
- **Identified in**: `print_hi.lua.chunk_1.lua`
- **Mechanism**: Similar to Layer 1 but contains more aggressive junk code and a complex deserializer (`J`).
- **Goal**: Decode the second PSU string into a binary instruction set.
- **Status**: **Partially Cracked**. We have the LZW decoding logic (`decode_psu_string.py`) and have extracted the binary data (`print_hi.chunk_2.bin`).

### Layer 3: Binary Instruction Set (The VM Core)
- **Identified in**: `print_hi.chunk_2.bin`
- **Mechanism**: A custom bytecode format parsed by the deserializer `J`. It uses a **delta-XOR** running key for every byte.
- **Goal**: Parse instructions, constants, and sub-functions to reconstruct the original Lua script.
- **Status**: **Researching**. We have identified the delta-XOR logic but the instruction format is non-standard (linked-list style instead of array-based).

## 2. Key Decoding Logic

### LZW String Decoding (PSU|...)
The PSU string uses a base-36 LZW variant. Each entry consists of:
1. A 1-character length `L` (base-36).
2. `L` characters representing the index (base-36).

### Delta-XOR Binary Stream
Every byte `b` in the binary stream is XORed with a running key `k`:
```python
val = (b ^ k) & 0xFF
k = val
```
*Note: The initial key `k` is 102.*

## 3. Next Steps
1. **Fix Parser**: The `proto_dumper.py` currently hits a recursion error due to misreading the `num_subprotos` field. This suggests either a mis-synced XOR key or an incorrect field order in the deserializer.
2. **Map Opcodes**: Once the binary is parsed into a `proto.json`, we must map the custom opcodes to standard Lua/PSU operations using `psu_disasm.py`.
3. **Environment Shim**: To run the VM dynamically for verification, a robust `Calculate` (bit32.band) shim must be provided that bypasses the metatable identity checks.

## 4. Tooling Reference
- `psu_max_mode/decode_psu_string.py`: Decodes LZW strings.
- `psu_max_mode/proto_dumper.py`: (WIP) Parses binary instruction sets.
- `psu_max_mode/solve_o.py`: Resolves character mappings for the obfuscated VM.
- `universal/psu_disasm.py`: Universal disassembler for PSU-family VMs.

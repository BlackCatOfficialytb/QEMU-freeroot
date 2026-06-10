# XHider Deobfuscation Strategy

This guide outlines the systematic approach to deobfuscating Lua scripts protected by XHider (MoonSec-like) obfuscation.

## Core Pipeline

### 1. Beautification
Most XHider scripts are compressed into single lines or dense blocks. 
- **Tool**: `universal\beautifier.py`
- **Action**: Use the beautifier to restore indentation and spacing. This reveals the structure (VM, tables, loops).
- **Tip**: UTF-8 conversion (`Set-Content -Encoding UTF8`) is often necessary after beautification to avoid character corruption in strings.

### 2. Structural Analysis
Identify the "Entry Point" and "Bootstrapping Code".
- **VM Setup**: Look for large tables (e.g., `L`, `_0x193`) and initialization loops.
- **Entry Point**: Usually a `return(function(...) ... end)(...)` block at the very end of the script.
- **Booting**: The code before the entry function often prepares the string constants and bytecode.

### 3. Payload Extraction
XHider usually stores strings in a table that is decrypted or shuffled at runtime.
- **Basic/Normal**: Strings are XORed or transformed via simple loops.
- **Hard/Strong/Max**: Constant strings are reconstructed from fragments and indices using a dedicated function (often `a[8]`).
- **IBV**: Strings are hex-encoded using a custom 16-entry nibble alphabet (0-9, A-F → shuffled values 0-15). Decoded 2 chars at a time: `alphabet[high] * 16 + alphabet[low]` → byte value. The alphabet is stored in a dedicated table with entries like `E=0, ["4"]=1, C=2, ...`.

### 4. Decryption/De-shuffling
- **Static Analysis**: Replicate the shuffling logic (ranges, swaps) in Python.
- **Dynamic Hooking**: If Lua is available, inject `print` statements before the VM execution to dump the fully prepared string table.

## Common Indicators
- `You Are Lost!`: A common decoy or debug message found in XHider scripts.
- `bit32` / `math.floor`: Indicators of bitwise arithmetic used in XOR or decryption logic.
- `pcall`, `setmetatable`, `getfenv`: Used for VM isolation and environment setup.
- **IBV-specific**: A 16-entry table mapping single hex characters to values 0-15 (custom alphabet). Strings in the data table are all uppercase hex chars (e.g., `"9F9F85898A"`). An accessor function `v_N(x) = table[x - constant]` for indirect lookups. Shuffle pairs via `ipairs({{start,end},...})`.

# How It Works: Lua De-obfuscation Toolchain

This document details the technical architecture and logic of all components in the XHider de-obfuscation suite.

---

## 🛠️ Component Breakdown

### 1. `unvm.py` (The Orchestrator)

This is the main entry point that coordinate the 6-pass de-obfuscation process.

* **Pass 1: Math Simplification**: Uses a built-in reduction engine to evaluate obfuscated numeric constants.
* **Pass 2: Component Extraction**: Scans for the **Hex Pool** (encrypted payload) and the **Q-Table** (4-byte decryption keys).
* **Pass 3: String Decoding**: Replicates the Virtual Machine's bitwise logic in Python to decrypt the payload.
* **Pass 4: Script Reconstruction**: Replaces all VM function calls (e.g., `m(123)`) with their decrypted literal strings.
* **Pass 5: Beautification**: Calls `beautifier.py` to restore readability to minified code.
* **Pass 6: VM Archiving**: Digitally "seals" the original VM logic inside a safe long-bracket comment.

---

### 2. `beautifier.py` (The Formatter)

A robust Lua beautification engine designed specifically for obfuscated/minified code.

* **Token Protection**: Uses a custom tokenizer to identify Lua strings (`"..."`, `'...'`) and long-bracket comments/strings (`[[...]]`). These are treated as atomic units and protected from formatting changes.
* **Keyword Expansion**: The `expand_fused` function fixes minification artifacts like `localU` or `functionm(t)`. It intelligently separates keywords from identifiers while protecting built-ins like `math.floor`.
* **Operator Spacing**: Normalizes spacing around all Lua operators (`+`, `-`, `==`, `..`, etc.) using a placeholder system to protect multi-character operators like `...` or `~=`.
* **Control-Flow Indentation**: Monitors keywords like `if`, `do`, `function`, and `end` to manage a dynamic indentation level (default 4 spaces).

---

### 3. `simplify_math.py` (Arithmetic Engine)

While `unvm` has a built-in simplifier, this standalone module provides the core logic for reducing arithmetic obfuscation.

* **Iterative Reduction**: Performs up to 50 passes, reducing expressions from the inside out (innermost parentheses first).
* **Boundary Safety**: The current implementation uses a "Strict Boundary" logic. It only simplifies expressions bounded by non-math punctuation (like `=`, `,`, or `;`). This prevents it from accidentally "eating" part of a complex identifier or breaking Lua syntax.
* **Safe Evaluation**: Uses Python's `eval()` within a sandboxed environment (`{"__builtins__": {}}`) to safely calculate the results.

---

### 4. `hex_tool.py` (Discovery Utility)

A utility script used for manual analysis of obfuscated files.

* **Hex Decoding**: Converts raw hex strings back into bytes.
* **Discovery Search**: Scans a `.lua` file for sequences of 10+ hex characters, decodes them, and calculates a **Printable Ratio**. If a decoded sequence is mostly readable text, it flags it as a likely string pool.
* **Encoding**: Quickly generates hex equivalents for strings to test VM response or key offsets.

---

## 📈 Technical Flow

1. **Input**: Raw obfuscated Lua file.
2. **Cleaning**: `unvm.py` runs Pass 1 & 2 to find the VM bones and simplify the math.
3. **Extraction**: Python decrypts the data using the discovered Q-Table keys.
4. **Transformation**: All opaque calls are converted to readable strings.
5. **Polishing**: `beautifier.py` expands the code into a clean, human-readable structure.
6. **Final Output**: A `.unvm.lua` file containing de-obfuscated strings and formatted logic.

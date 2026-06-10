# Lua VM De-obfuscator (XHider Edition)

A powerful, standalone Python toolchain designed to de-obfuscate and beautify Lua scripts protected by **XHider** (MoonSec-style) Virtual Machines.

## Discord Server

Join our Discord Server to get updates and support: [Discord Server](https://dsc.gg/blackcatofficial)

## ❓ Where is it?

You can find it in [This Discord Server](https://discord.gg/E2N7w35zkt), go to #〔⚫〕ᴏʙғᴜsᴄᴀᴛᴏʀ-ʟᴜᴀ , select Bot2, then use it.  (.help first)

## 🚀 Key Features

* **Advanced String De-obfuscation**: Automatically detects VM entry points, extracts encryption keys (Hex Pool/Q-Table), and decrypts embedded strings across various security levels.
* **Intelligent Math Simplification**: Features a multi-pass reduction engine to resolve complex constant expressions (e.g., `1+2*3` → `7`) while preserving Lua's syntactic integrity.
* **Smart Beautification**: Transforms minified, fused code into clean, indented, and readable Lua scripts.
* **VM Isolation**: Safely wraps the original obfuscated VM logic in long-bracket comments (`--[[ ... ]]`), preserving the original bytecode while exposing the de-obfuscated logic.
* **Safety First**: Built-in protection ensures that existing strings and comments are never corrupted during the transformation process.

## ️ Supported Obfuscation Modes

This tool is optimized to handle various XHider security levels:

| Mode | Description |
| :--- | :--- |
| **Basic / Normal** | Handles standard XOR and byte-shift encryption. |
| **IBS** | Targeted simplification for "spaghetti code" and heavy math obfuscation. |
| **Hard** | Resolves large table shuffling and multi-phase decryption logic. |
| **Strong** | Decodes complex custom Base64 implementations. |
| **Max Security** | Reconstructs fragmented strings and handles nested loop structures. |

## 🛠️ Installation

1. **Prerequisites**: Ensure **Python 3.x** is installed.
2. **Setup**:
   * Clone or download this repository.
   * Place your obfuscated `.lua` files in the root directory.

## 📖 Usage

Run the main de-obfuscation script via your terminal or command prompt:

```powershell
py unvm.py your_script.lua
```

The tool will process the file through 6 passes:

1. **Math Simplification**: Evaluating obfuscated numeric constants.
2. **Component Extraction**: Pulling the hex pool and Q-table keys.
3. **String Decoding**: Decrypting the VM-managed strings.
4. **Script Reconstruction**: Replacing VM calls with real strings.
5. **Beautification**: Re-formatting the entire script for readability.
6. **VM Commenting**: Safely archiving the VM logic within the file.

### Output

The de-obfuscated script will be saved as `<filename>.unvm.lua`.

## 📁 Project Structure

* **unvm.py**: The main entry point and de-obfuscation engine.
* **beautifier.py**: A robust Lua formatting module used for final output cleaning.
* **how_it_works.md**: Technical documentation of the de-obfuscation process.

## ⚠️ Notes

* This tool is specifically optimized for XHider obfuscation. Other obfuscators may require pattern adjustments in `unvm.py`.
* Always review the `.unvm.lua` output to ensure the VM function detection was 100% accurate for your specific file version.

---

*Created for advanced Lua reverse engineering.*

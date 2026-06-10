"""
XHider ENV Mode Deobfuscator
Decrypts env mode obfuscated Lua scripts.

This mode uses complex metatable operations to reconstruct strings.
Pattern: g[9]^key function calls with indices and string fragments.
Structure: (g[9] ^ key)({index1, index2, ..., {"frag1", "frag2", ...}})

The strings are assembled by selecting fragments based on evaluated indices.
"""

import re
import math
import sys
import subprocess
import os

def lua_eval(expr):
    """Evaluate Lua math expressions in Python."""
    try:
        expr = str(expr).replace('\n', ' ').strip()
        if not expr:
            return 0
        # Handle Lua operators - but NOT ^ as that's power in both
        return int(eval(expr, {"__builtins__": None, "math": math}))
    except:
        return 0

def unescape_lua(s):
    """Convert Lua escape sequences to Python strings."""
    result = []
    i = 0
    while i < len(s):
        if s[i] == '\\' and i + 1 < len(s):
            next_char = s[i + 1]
            if next_char.isdigit():
                # \ddd decimal escape
                num_str = next_char
                j = i + 2
                while j < len(s) and j < i + 4 and s[j].isdigit():
                    num_str += s[j]
                    j += 1
                result.append(chr(int(num_str)))
                i = j
            elif next_char == 'n':
                result.append('\n')
                i += 2
            elif next_char == 'r':
                result.append('\r')
                i += 2
            elif next_char == 't':
                result.append('\t')
                i += 2
            elif next_char == '\\':
                result.append('\\')
                i += 2
            elif next_char == '"':
                result.append('"')
                i += 2
            elif next_char == "'":
                result.append("'")
                i += 2
            else:
                result.append(next_char)
                i += 2
        else:
            result.append(s[i])
            i += 1
    return ''.join(result)

def reconstruct_string(indices, fragments):
    """
    Reconstruct string from indices and fragments.
    indices: list of 1-based indices
    fragments: list of string fragments
    """
    result = ""
    for idx in indices:
        # Convert from 1-based to 0-based
        py_idx = idx - 1
        if 0 <= py_idx < len(fragments):
            result += fragments[py_idx]
    return result

def parse_g9_call(call_content):
    """
    Parse a g[9]^key({...}) call and extract indices and fragments.
    Returns the reconstructed string.
    """
    # Find the last { which starts the fragments array
    last_brace = call_content.rfind('{')
    if last_brace == -1:
        return ""

    # Split into indices part and fragments part
    indices_part = call_content[:last_brace]
    fragments_part = call_content[last_brace + 1:]

    # Remove trailing }
    if fragments_part.endswith('}'):
        fragments_part = fragments_part[:-1]

    # Extract fragments (strings in quotes)
    frag_pattern = re.compile(r'"((?:[^"\\]|\\.)*)"|\'((?:[^\'\\]|\\.)*)\'')
    fragments = []
    for m in frag_pattern.finditer(fragments_part):
        s = m.group(1) if m.group(1) is not None else m.group(2)
        fragments.append(unescape_lua(s))

    if not fragments:
        return ""

    # Extract indices (numbers or math expressions)
    indices = []
    current = ""
    balance = 0

    for c in indices_part:
        if c == '(':
            balance += 1
            current += c
        elif c == ')':
            balance -= 1
            current += c
        elif c == '{':
            balance += 1
            current += c
        elif c == '}':
            balance -= 1
            current += c
        elif (c == ',' or c == ';') and balance == 0:
            val = lua_eval(current.strip())
            if val != 0:
                indices.append(val)
            current = ""
        else:
            current += c

    # Handle last item
    if current.strip():
        val = lua_eval(current.strip())
        if val != 0:
            indices.append(val)

    return reconstruct_string(indices, fragments)

def extract_all_strings(content):
    """Extract all string literals from content."""
    strings = []
    # Match both plain strings and reconstructed ones
    pattern = re.compile(r'"((?:[^"\\]|\\.)*)"')
    for m in pattern.finditer(content):
        s = unescape_lua(m.group(1))
        if s and len(s) <= 10:  # Fragment strings are typically short
            strings.append(s)
    return strings

def extract_ox_table_strings(content):
    """
    Extract all strings from the Ox table which contains the string pool.
    This includes both plain strings and g[9] reconstructed strings.
    """
    strings = []

    # Find g[12] = g[10]({Ox = { ... pattern which contains the string table
    ox_match = re.search(r'Ox\s*=\s*\{', content)
    if not ox_match:
        print("Could not find Ox table")
        return strings

    start = ox_match.end()

    # Track brace depth to find end of Ox table
    depth = 1
    i = start
    in_string = False
    string_char = None

    while i < len(content) and depth > 0:
        c = content[i]
        if in_string:
            if c == '\\':
                i += 1
            elif c == string_char:
                in_string = False
        else:
            if c in ('"', "'"):
                in_string = True
                string_char = c
            elif c == '{':
                depth += 1
            elif c == '}':
                depth -= 1
        i += 1

    ox_content = content[start:i-1]

    # Now parse the Ox table content
    # Items are separated by commas, can be:
    # 1. Plain strings: "abc"
    # 2. g[9] calls: (g[9] ^ key)({indices, {fragments}})

    pos = 0
    while pos < len(ox_content):
        # Skip whitespace
        while pos < len(ox_content) and ox_content[pos] in ' \t\n\r,;':
            pos += 1

        if pos >= len(ox_content):
            break

        # Check for g[9] call
        g9_match = re.match(r'\(g\[9\]\s*\^\s*-?\s*\d+\)\s*\(\{', ox_content[pos:])
        if g9_match:
            # Find matching end
            call_start = pos + g9_match.end()
            depth = 1
            j = call_start
            in_str = False
            str_ch = None

            while j < len(ox_content) and depth > 0:
                c = ox_content[j]
                if in_str:
                    if c == '\\':
                        j += 1
                    elif c == str_ch:
                        in_str = False
                else:
                    if c in ('"', "'"):
                        in_str = True
                        str_ch = c
                    elif c == '{':
                        depth += 1
                    elif c == '}':
                        depth -= 1
                j += 1

            # Skip the closing )
            if j < len(ox_content) and ox_content[j] == ')':
                j += 1

            call_content = ox_content[call_start:j-2]  # -2 for })
            decoded = parse_g9_call(call_content)
            if decoded:
                strings.append(decoded)
            pos = j

        # Check for plain string
        elif ox_content[pos] == '"':
            # Parse string
            j = pos + 1
            while j < len(ox_content):
                if ox_content[j] == '\\':
                    j += 2
                elif ox_content[j] == '"':
                    break
                else:
                    j += 1
            if j < len(ox_content):
                s = unescape_lua(ox_content[pos+1:j])
                strings.append(s)
                pos = j + 1
            else:
                pos += 1
        else:
            pos += 1

    return strings

def create_lua_dumper(input_file, output_dir):
    """Create a Lua script that dumps the string table at runtime."""
    dumper_file = os.path.join(output_dir, "env_dumper.lua")

    dumper_code = '''
-- XHider ENV Mode String Dumper
-- Wraps the original script to dump strings before VM execution

local original_print = print
local collected_strings = {}

-- Hook to collect strings
local function collect_string(s)
    if type(s) == "string" and #s > 0 then
        table.insert(collected_strings, s)
    end
end

-- Load and wrap the original file
local f = io.open([[''' + input_file + ''']], "r")
if not f then
    print("Could not open file")
    return
end
local content = f:read("*a")
f:close()

-- Find the return(function pattern and inject before it
local inject_point = content:find("return%(function")
if not inject_point then
    print("Could not find entry point")
    return
end

-- Dump collected strings
print("=== ENV MODE STRING DUMP ===")
local chunk, err = load(content)
if chunk then
    -- Try to intercept the Ox table
    local ok, result = pcall(chunk)
    if ok and type(result) == "table" then
        for k, v in pairs(result) do
            if type(v) == "string" then
                print("STR: " .. v)
            end
        end
    end
end
print("=== END DUMP ===")
'''

    with open(dumper_file, 'w', encoding='utf-8') as f:
        f.write(dumper_code)

    return dumper_file

def extract_shuffle_pairs(content):
    """Extract shuffle pairs from ipairs loop."""
    pairs = []

    # Pattern: ipairs({{expr1, expr2}, {expr3, expr4}, ...})
    ipairs_match = re.search(r'ipairs\(\{\{(.*?)\}\}\)do', content, re.DOTALL)
    if not ipairs_match:
        return pairs

    pairs_content = ipairs_match.group(1)

    # Split by }, {
    pair_strings = re.split(r'\}\s*,\s*\{', pairs_content)

    for p_str in pair_strings:
        p_str = p_str.replace('{', '').replace('}', '')
        # Split by ; or ,
        parts = re.split(r'[,;]', p_str)
        if len(parts) >= 2:
            start = lua_eval(parts[0])
            end = lua_eval(parts[1])
            if start > 0 and end > 0:
                pairs.append((start, end))

    return pairs

def apply_shuffle(strings_pool, pairs):
    """Apply shuffle operations to string pool (reverse ranges)."""
    for start, end in pairs:
        # Convert 1-based to 0-based
        s = start - 1
        e = end - 1

        if s < 0:
            s = 0
        if e >= len(strings_pool):
            e = len(strings_pool) - 1

        # Reverse the range [s, e]
        while s < e:
            strings_pool[s], strings_pool[e] = strings_pool[e], strings_pool[s]
            s += 1
            e -= 1

    return strings_pool

def decrypt_env(input_file, output_file=None):
    """Main decryption function for env mode."""
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    print(f"File size: {len(content)} bytes")
    print("Extracting strings from Ox table...\n")

    # Extract strings from Ox table
    strings_pool = extract_ox_table_strings(content)

    print(f"Extracted {len(strings_pool)} strings from Ox table")

    # Extract and apply shuffle
    shuffle_pairs = extract_shuffle_pairs(content)
    if shuffle_pairs:
        print(f"Found {len(shuffle_pairs)} shuffle pairs: {shuffle_pairs}")
        strings_pool = apply_shuffle(strings_pool, shuffle_pairs)
        print("Applied shuffle operations")

    # Output results
    if output_file is None:
        output_file = input_file.replace('.lua', '.decrypted.txt')
        if output_file == input_file:
            output_file = input_file + '.decrypted.txt'

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("=" * 60 + "\n")
        f.write("XHider ENV Mode Decrypted Strings\n")
        f.write("=" * 60 + "\n\n")

        for i, s in enumerate(strings_pool):
            # Clean for display
            safe_s = s.replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')
            f.write(f"[{i + 1}] {safe_s}\n")

    print(f"\nOutput saved to: {output_file}")

    # Print all strings
    print("\n" + "=" * 50)
    print("Extracted Strings:")
    print("=" * 50)
    for i, s in enumerate(strings_pool):
        safe_s = s.replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')
        if len(safe_s) > 80:
            safe_s = safe_s[:80] + "..."
        print(f"[{i + 1}] {safe_s}")

    # Search for interesting patterns
    print("\n" + "=" * 50)
    print("Interesting findings:")
    print("=" * 50)

    for i, s in enumerate(strings_pool):
        s_lower = s.lower()
        if 'http' in s_lower:
            print(f"URL [{i + 1}]: {s}")
        if 'print' in s_lower:
            print(f"Print call [{i + 1}]: {s}")
        if 'loadstring' in s_lower:
            print(f"Loadstring [{i + 1}]: {s}")
        if 'you are lost' in s_lower:
            print(f"XHider marker [{i + 1}]: {s}")

    return strings_pool

if __name__ == "__main__":
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
    else:
        input_file = r"E:\dec bot2\env_mode\print_hi.beautified.lua"

    output_file = sys.argv[2] if len(sys.argv) > 2 else None
    decrypt_env(input_file, output_file)

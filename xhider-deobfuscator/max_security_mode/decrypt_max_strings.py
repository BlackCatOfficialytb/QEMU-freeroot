import re
import sys

input_file = r"d:\dec bot2\max_security_mode\987415550020054.beautified.utf8.lua"

with open(input_file, 'r', encoding='utf-8') as f:
    content = f.read()

print("Extracting a[8] calls...")

# We need to find `a[8]({ ... })`. 
# Since it can be recursive or nested (though a[1] = { a[8]..., a[8]... }), we scan for strict `a[8]({` start.
# And match balanced braces?
# Actually, the structure seen is `a[8]({ numbers; {strings} })`.
# It ends with `})`.
# Be careful of nested `{}` inside strings? No, strings are quoted.

def lua_eval(expr):
    # Safe eval of math
    try:
        # replace lua operators if any special ones (like //?)
        # standard +, -, *, / working in python mostly. 
        # Lua `-` unary?
        processed = expr.replace("\n", " ").strip()
        if not processed: return 0
        return int(eval(processed, {"__builtins__": None}))
    except Exception as e:
        # print(f"Eval error: {e} for {expr}")
        return 0

decrypted_pool = []

# Regex approach might be fragile if `a[8]` isn't regular.
# But looking at file, it seems regular: `a[8]({ ... })`.
# Let's try to parse manually.

idx = 0
while True:
    idx = content.find("a[8]({", idx)
    if idx == -1: break
    
    # Check if this `a[8]` is part of `local a = {}a[8] = function` definition
    # The definition is `a[8] = function...`. 
    # Use calls only.
    if "function" in content[idx-20:idx]: # heuristic
        idx += 1
        continue
        
    start_content = idx + 6 # len("a[8]({")
    
    # Find matching `})`
    # We need to count balanced `{}` and `()` inside?
    # Actually just balanced `(` and `)`? No, it opened with `({`.
    # So we need balanced `{}`?
    # The content is `{ ... }`. So we are inside `{`. We need to find closing `}` that matches this one.
    
    balance = 1
    end_content = -1
    curr = start_content
    in_quote = False
    quote_char = None
    
    while curr < len(content):
        c = content[curr]
        if in_quote:
            if c == '\\':
                curr += 1
            elif c == quote_char:
                in_quote = False
        else:
            if c == '"' or c == "'":
                in_quote = True
                quote_char = c
            elif c == '{':
                balance += 1
            elif c == '}':
                balance -= 1
                if balance == 0:
                    end_content = curr
                    break
        curr += 1
        
    if end_content != -1:
        block = content[start_content:end_content] # Content inside `a[8]({ ... ` -> `...`
        
        # Split block by `;` or `,`.
        # The structure is `expr, expr; expr; {strings}`.
        # But wait, the viewer showed `...; ...; { ... }`.
        # The last element is the string table.
        
        # We need to split by delimiters but respect nested `{}` (the string table).
        # We can find the last `{`?
        last_brace_open = block.rfind('{')
        if last_brace_open != -1:
            # The strings part
            strings_part = block[last_brace_open+1 : block.rfind('}')]
            indices_part = block[:last_brace_open]
            
            # Parse strings
            # Simple regex for strings?
            # They are comma separated strings.
            # "str", "str", ...
            # Handle escapes?
            
            # extract string literals.
            # Use regex for "..." or '...'
            string_list = []
            # We can use ast.literal_eval if format matches python, but Lua strings might differ ('\z' etc).
            # Let's simple parse.
            
            s_pattern = re.compile(r'"((?:[^"\\]|\\.)*)"|\'((?:[^\'\\]|\\.)*)\'')
            for sm in s_pattern.finditer(strings_part):
                s = sm.group(1) if sm.group(1) is not None else sm.group(2)
                # Unescape lua escapes
                # Simple unescape
                s = s.replace('\\"', '"').replace("\\'", "'").replace('\\\\', '\\')\
                     .replace('\\n', '\n').replace('\\r', '\r').replace('\\t', '\t')
                string_list.append(s)
            
            # Parse indices
            # Split by `,` or `;`.
            # Must respect nested parens `( ... )`.
            
            indices = []
            curr_expr = ""
            p_bal = 0
            for char in indices_part:
                if char == '(': p_bal += 1
                elif char == ')': p_bal -= 1
                
                if (char == ',' or char == ';') and p_bal == 0:
                    val = lua_eval(curr_expr)
                    indices.append(val)
                    curr_expr = ""
                else:
                    curr_expr += char
            
            if curr_expr.strip():
                indices.append(lua_eval(curr_expr))
            
            # Reconstruct
            # Logic: `H[1] = H[1] .. H[2][H[4][V[2]]]`
            # H[4] is indices (1-based). H[2] is string_list (1-based).
            # Python is 0-based.
            
            final_str = ""
            for i in indices:
                # i is index into string_list (1-based)
                # Map to 0-based
                idx_0 = i - 1
                if 0 <= idx_0 < len(string_list):
                    final_str += string_list[idx_0]
                else:
                    final_str += "[UNK]"
            
            decrypted_pool.append(final_str)
            # print(f"Decrypted: {final_str[:50]}...")
            
    idx = curr

print(f"Total decrypted strings: {len(decrypted_pool)}")
for i, s in enumerate(decrypted_pool):
    print(f"[{i}] {s}")

with open(r"d:\dec bot2\max_security_mode\decrypted_strings.txt", "w", encoding="utf-8") as f:
    for s in decrypted_pool:
        f.write(f"{s}\n")

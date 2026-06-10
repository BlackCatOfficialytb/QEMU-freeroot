import re
import sys

def extract_o_from_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Pattern for o[key] = value
    # Example: [(((828614460)-#("...")))]=("\114")
    # Also handle simpler ones if they exist.
    
    # This regex looks for: [ (expression) ] = (value)
    # The expression can be complex like (num)-#(str)
    # The value is usually a string like ("\114") or just "\114" or a number.
    
    pattern = r'\[\s*\(([^\]]+)\)\s*\]\s*=\s*\(([^)]+)\)'
    matches = re.finditer(pattern, content)
    
    o_map = {}
    
    def eval_expr(expr):
        # Handle cases like (((828614460)-#("psu ...")))
        # We need to replace #("...") with the length of the string.
        expr = expr.strip()
        
        # Replace #("...") with length
        def replace_len(m):
            s = m.group(1)
            return str(len(s))
        
        expr = re.sub(r'#\("([^"]*)"\)', replace_len, expr)
        expr = re.sub(r'#\(\'([^\']*)\'\)', replace_len, expr)
        
        # Clean up parentheses
        expr = expr.replace('(', ' ').replace(')', ' ')
        
        # Now it should be a simple math expression
        try:
            return eval(expr)
        except:
            return None

    def eval_val(val):
        val = val.strip()
        # Handle "\114" etc.
        if val.startswith('"') and val.endswith('"'):
            # It's a string literal
            # Python's string_escape or similar might work, but Lua uses \ddd for decimals.
            s = val[1:-1]
            def replace_lua_esc(m):
                return chr(int(m.group(1)))
            s = re.sub(r'\\(\d{1,3})', replace_lua_esc, s)
            return s
        return val

    for m in matches:
        key_expr = m.group(1)
        val_expr = m.group(2)
        
        key = eval_expr(key_expr)
        val = eval_val(val_expr)
        
        if key is not None:
            o_map[key] = val
            
    return o_map

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python extract_o.py <lua_file>")
        sys.exit(1)
    
    o_map = extract_o_from_file(sys.argv[1])
    for k in sorted(o_map.keys()):
        print(f"o[{k}] = {repr(o_map[k])}")

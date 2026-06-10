import re
import math
import sys
import traceback

def simplify_math_in_string(text):
    """
    Finds mathematical expressions in a string and replaces them with their evaluated results.
    Uses markers to protect strings and comments from being modified.
    """
    
    # 1. Identify definition aliases for math.floor, math.ceil, etc.
    # Pattern: local <alias> = math.floor
    floor_defs = {}
    for m in re.finditer(r'local\s+(\w+)\s*=\s*(math\.(floor|ceil|abs|sqrt))', text):
        alias = m.group(1)
        real_func = m.group(2)
        floor_defs[alias] = real_func
    
    protected = []
    def protect_callback(match):
        protected.append(match.group(0))
        return f"___PROTECTED_MARKER_{len(protected)-1}___"
    
    # Protect Lua strings and comments
    # Order: block comments, block strings, line comments, normal strings
    # We use [^\n]* for line comments to stay on one line even with DOTALL
    protect_pattern = r'(--\[\[.*?\]\])|(--[^\n]*)|("(?:\\.|[^"])*")|(\'(?:\\.|[^\'])*\')|(\[\[.*?\]\])'
    working_text = re.sub(protect_pattern, protect_callback, text, flags=re.DOTALL)

    def evaluate_math(expr):
        """Evaluates a mathematical expression string using Python's eval."""
        python_expr = expr.replace('^', '**')
        
        # Replace identified aliases with Python math functions
        for alias, real in floor_defs.items():
            python_expr = re.sub(r'\b' + re.escape(alias) + r'\(', f'{real}(', python_expr)

        try:
            # Safety check: allow digits, hex, ops, spaces, and whitelisted math functions
            check_expr = python_expr
            for f in ["math.floor", "math.ceil", "math.abs", "math.sqrt"]:
                check_expr = check_expr.replace(f, '')
            
            # Remove hex numbers
            check_expr = re.sub(r'0x[0-9a-fA-F]+', '', check_expr)
            
            # If any letters remain, it might be a variable or unsafe code
            if re.search(r'[a-zA-Z_]', check_expr):
                return None
            
            # Restricted eval environment
            res = eval(python_expr, {"__builtins__": {}, "math": math}, {})
            
            if isinstance(res, (int, float)):
                if isinstance(res, float) and res.is_integer():
                    return str(int(res))
                elif isinstance(res, float):
                    if abs(res) < 1e12 and abs(res) > 1e-8:
                        return f"{res:.15f}".rstrip('0').rstrip('.')
                    return f"{res:.8g}"
                return str(res)
        except:
            pass
        return None

    # Iterative simplification
    current = working_text
    changed = True
    iteration = 0
    
    num_part = r'(?:0x[0-9a-fA-F]+|\d+(?:\.\d*)?)'
    op_part = r'(?:\s*[\+\-\*\/\%\^]\s*)'
    # Binary op pattern: optional leading sign, num, then (op, optional sign, num)+
    bin_op_pattern = r'(?<![a-zA-Z0-9_])[+-]?\s*' + num_part + r'(?:' + op_part + r'[+-]?\s*' + num_part + r')+(?![0-9a-fA-Fx\.])'
    
    while changed and iteration < 150:
        old = current
        
        # 1. Simplify innermost parentheses ( ... )
        # Pattern ensures we find content with no nested parentheses or markers
        inner_paren_pattern = r'\(\s*([0-9a-fA-Fx\.\s\+\-\*\/\%\^]+)\s*\)'
        
        def paren_repl(m):
            content = m.group(1)
            res = evaluate_math(content)
            if res is not None:
                # Check if it was a function call: identifier immediately preceding '('
                prefix = current[:m.start()].rstrip()
                if prefix and re.search(r'[a-zA-Z_0-9$]$', prefix):
                    return "(" + res + ")"
                return " " + res + " "
            return m.group(0)

        current = re.sub(inner_paren_pattern, paren_repl, current)
        
        # 2. Simplify math function calls with constant arguments
        all_funcs = ["math.floor", "math.ceil", "math.abs", "math.sqrt"] + list(floor_defs.keys())
        for f_name in all_funcs:
            alias_esc = re.escape(f_name)
            # Pattern: func_name( constant_math )
            fp = r'\b' + alias_esc + r'\s*\(\s*([0-9a-fA-Fx\.\s\+\-\*\/\%\^]+)\s*\)'
            def func_repl(m):
                res = evaluate_math(m.group(0))
                return " " + res + " " if res is not None else m.group(0)
            current = re.sub(fp, func_repl, current)

        # 3. Simplify contiguous binary operations
        def binop_repl(m):
            res = evaluate_math(m.group(0))
            return " " + res + " " if res is not None else m.group(0)
        
        current = re.sub(bin_op_pattern, binop_repl, current)
        
        if current == old:
            changed = False
        iteration += 1

    # 4. Restore protected markers
    def restore_callback(match):
        idx = int(match.group(1))
        return protected[idx]
    
    final_text = re.sub(r'___PROTECTED_MARKER_(\d+)___', restore_callback, current)
    
    # 5. Result Cleanup
    # Reduce multiple spaces to single spaces, but preserve newlines
    lines = final_text.splitlines()
    cleaned_lines = [re.sub(r' +', ' ', l).strip() for l in lines]
    return "\n".join(cleaned_lines)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: py simplify_math.py <input_file> [output_file]")
        sys.exit(1)
        
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else input_file.replace(".lua", ".simplified.lua")
    
    if output_file == input_file:
        output_file += ".final.lua"
    
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        result = simplify_math_in_string(content)
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(result)
        
        print(f"Successfully processed {input_file} -> {output_file}")
    except Exception as e:
        print(f"Error: {e}")
        traceback.print_exc()

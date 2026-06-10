import re

def expand_fused(text):
    """Aggressive but selective fused-word expansion for code chunks."""
    kw_all = ['local', 'function', 'if', 'while', 'for', 'repeat', 'do', 'then', 'else', 'elseif', 'end', 'until', 'return', 'not', 'and', 'or', 'nil', 'true', 'false', 'in']
    safe_kws = ['local', 'function', 'return', 'not', 'nil', 'true', 'false']
    structurals = ['if', 'for', 'while', 'repeat', 'and', 'or', 'do', 'then', 'end', 'until', 'else', 'elseif', 'in']
    
    # 0. Digit-Letter Split
    text = re.sub(r'([0-9])([a-zA-Z_])', r'\1 \2', text)
    
    # 1. Keyword-Keyword Split
    for _ in range(2):
        for kw1 in kw_all:
            for kw2 in kw_all:
                if kw1 + kw2 in text:
                    text = re.sub(r'\b(' + kw1 + r')(' + kw2 + r')\b', r'\1 \2', text)
            
        # 2. Safe-Keyword-Identifier Split
        for kw in safe_kws:
            text = re.sub(r'\b(' + kw + r')([a-zA-Z_])', r'\1 \2', text)
            text = re.sub(r'([a-zA-Z_])(' + kw + r')\b', r'\1 \2', text)

        # 3. Structural Split
        for kw in structurals:
            text = re.sub(r'\b(' + kw + r')([a-zA-Z_])\b', r'\1 \2', text)
        
    # 4. Keyword stuck to digits
    for kw in kw_all:
        text = re.sub(r'\b(' + kw + r')([0-9])', r'\1 \2', text)

    return text

def beautify_lua(code):
    """
    Robust Lua beautifier with minified code support and string protection.
    """
    # 1. Tokenize to protect strings and comments
    tokens = []
    i = 0
    while i < len(code):
        # Long brackets --[[ or [[
        lb_match = re.match(r'(--)?\[(=*)\[', code[i:])
        if lb_match:
            is_comment = lb_match.group(1) is not None
            equals = lb_match.group(2)
            end_marker = f']{equals}]'
            start_pos = i
            i += lb_match.end()
            end_pos = code.find(end_marker, i)
            if end_pos != -1:
                content = code[start_pos : end_pos + len(end_marker)]
                tokens.append({'type': 'comment' if is_comment else 'string', 'content': content})
                i = end_pos + len(end_marker)
                continue
        
        # Single line comment
        if code[i:i+2] == '--':
            start_pos = i
            i = code.find('\n', i)
            if i == -1: i = len(code)
            tokens.append({'type': 'comment', 'content': code[start_pos:i]})
            continue
            
        # Standard String
        if code[i] in ('"', "'"):
            marker = code[i]
            start_pos = i
            i += 1
            while i < len(code):
                if code[i] == marker and code[i-1] != '\\':
                    break
                i += 1
            tokens.append({'type': 'string', 'content': code[start_pos:i+1]})
            i += 1
            continue
            
        # Code chunk
        start_pos = i
        while i < len(code) and code[i] not in ('"', "'") and code[i:i+2] != '--' and not (code[i] == '[' and (i+1 < len(code) and (code[i+1] == '[' or code[i+1] == '='))):
             i += 1
        if start_pos < i:
            tokens.append({'type': 'code', 'content': code[start_pos:i]})
            
    # 2. Process code tokens
    processed_tokens = []
    kw_all = ['local', 'function', 'if', 'while', 'for', 'repeat', 'do', 'then', 'else', 'elseif', 'end', 'until', 'return', 'not', 'and', 'or', 'nil', 'true', 'false', 'in']
    
    for tok in tokens:
        if tok['type'] == 'code':
            content = tok['content']
            # Operator spacing
            content = content.replace('...', ' ___DOT3___ ')
            content = content.replace('==', ' ___EQ___ ')
            content = content.replace('~=', ' ___NE___ ')
            content = content.replace('<=', ' ___LE___ ')
            content = content.replace('>=', ' ___GE___ ')
            content = content.replace('..', ' ___DOT2___ ')
            for op in "=+-*/%^#<>":
                content = content.replace(op, f" {op} ")
            content = content.replace(' ___DOT3___ ', ' ... ')
            content = content.replace(' ___DOT2___ ', ' .. ')
            content = content.replace(' ___EQ___ ', ' == ')
            content = content.replace(' ___NE___ ', ' ~= ')
            content = content.replace(' ___LE___ ', ' <= ')
            content = content.replace(' ___GE___ ', ' >= ')
            
            # Decimal and field normalization
            content = re.sub(r'([a-zA-Z0-9_])\s*\.\s*([a-zA-Z_])', r'\1.\2', content)
            content = re.sub(r'(\d)\s*\.\s*(\d)', r'\1.\2', content)
            content = content.replace(',', ', ')
            
            # Fused expansion
            content = expand_fused(content)
            
            # Minified split directives
            split_starts = ['local', 'if', 'while', 'for', 'repeat', 'return', 'function', 'end', 'until']
            for kw in split_starts:
                content = re.sub(r'\s*\b(' + kw + r')\b', r'\n\1', content)
            
            split_middles = ['then', 'do', 'else', 'elseif']
            for kw in split_middles:
                content = re.sub(r'\b(' + kw + r')\b\s*', r'\1\n', content)
                
            content = content.replace('local\nfunction', 'local function')
            content = content.replace(';', ';\n')
            
            # Clean spaces
            content = re.sub(r' +', ' ', content)
            processed_tokens.append(content)
        else:
            processed_tokens.append(tok['content'])
            
    # 3. Assemble and Indent
    full_text = "".join(processed_tokens)
    lines = full_text.splitlines()
    
    indented = []
    level = 0
    step = "    "
    
    for line in lines:
        clean = line.strip()
        if not clean: continue
        
        # De-indenting keywords
        if any(clean.startswith(kw) for kw in ['end', 'until', 'else', 'elseif', '}', 'do', 'then']):
             if not (clean.startswith('do') and any(x in clean for x in ['while', 'for'])):
                level = max(0, level - 1)
        
        indented.append(step * level + clean)
        
        # Indent increasing keywords
        if any(clean.endswith(kw) for kw in ['do', 'then', 'else', 'elseif', '{']):
             level += 1
        elif clean.startswith('function') and not clean.endswith('end'):
             level += 1

    return "\n".join(indented)

if __name__ == "__main__":
    import sys
    import argparse

    parser = argparse.ArgumentParser(description="Universal Lua Beautifier")
    parser.add_argument("-i", "--input", help="Input Lua file path", required=True)
    parser.add_argument("-o", "--output", help="Output Lua file path (prints to stdout if omitted)")

    args = parser.parse_args()

    try:
        with open(args.input, 'r', encoding='utf-8') as f:
            code = f.read()
        
        beautified = beautify_lua(code)

        if args.output:
            with open(args.output, 'w', encoding='utf-8') as f:
                f.write(beautified)
            print(f"Beautified code saved to {args.output}")
        else:
            print(beautified)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

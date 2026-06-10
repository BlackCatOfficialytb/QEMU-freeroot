import re
import sys
import math

def decrypt_normal(input_file):
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Extract 'm' table
    # Pattern: finds the local m = { ... } block
    # This is rough, we assume it starts at 'local m = {' and ends at '}' 
    # But looking at the file, it spans many lines.
    
    # Let's extract key-value pairs from the 'm' block.
    # The 'm' block seems to be lines 51-86 based on previous view.
    
    # We will search for 'local m = {' and then parse until '}'
    m_match = re.search(r'local\s+m\s*=\s*{(.*?)}(?=\s*local\s+Q)', content, re.DOTALL)
    if not m_match:
        # Try looser match
        m_match = re.search(r'local\s+m\s*=\s*{(.*?)}', content, re.DOTALL)
    
    if not m_match:
        print("Could not find table 'm'")
        return

    m_content_str = m_match.group(1)
    
    # Parse m keys
    # Keys can be `x` or `["9"]`
    # Values are expressions like `- 734053 - ( - 734081)`
    
    m_dict = {}
    
    # Split by commas or semicolons
    m_items = re.split(r'[,;]', m_content_str)
    
    for item in m_items:
        item = item.strip()
        if not item: continue
        
        if '=' not in item: continue
        
        # Split into key, value
        key_part, val_part = item.split('=', 1)
        key_part = key_part.strip()
        val_part = val_part.strip()
        
        # Clean key
        if key_part.startswith('[') and key_part.endswith(']'):
            key = key_part[2:-2] # Remove [" and "]
        else:
            key = key_part
            
        # Clean val for python eval
        # Lua ^ is ** in Python
        val_expr = val_part.replace('^', '**')
        # Lua uses -- for comments (shouldn't be here)
        # Lua newlines should be spaces
        val_expr = val_expr.replace('\n', ' ')
        
        try:
            val = eval(val_expr, {"__builtins__": None, "math": math})
            m_dict[key] = val
        except Exception as e:
            print(f"Error evaluating m['{key}']: {e} (Expr: {val_expr})")

    print(f"Extracted {len(m_dict)} keys from m table.")
    
    # 2. Extract P table
    # local P = { ... }
    p_match = re.search(r'local\s+P\s*=\s*{(.*?)}', content, re.DOTALL)
    if not p_match:
        print("Could not find table 'P'")
        return
        
    p_content_str = p_match.group(1)
    
    # Extract strings from P
    # Strings are in quotes ""
    # We can use regex to find all matches of "value"
    # Note: Escaped quotes \" might exist
    
    P_list = []
    # This regex captures "..." or '...'
    # It accounts for escaped quotes
    str_matches = re.findall(r'["\']((?:[^"\\]|\\.)*)["\']', p_content_str)
    
    for s in str_matches:
        P_list.append(s)
        
    print(f"Extracted {len(P_list)} strings from P table.")
    
    # 3. Decrypt Strings
    # Replicate Logic:
    # for P = 686966 + (773035 + - 1460000), # Q, - 832211 + 832212 do
    #     local F = Q[P]
    #     if G(F) == "string" then
    #         string decoding loop...
    
    # Constants for the loop (extracted from lines 94)
    # 686966 + (773035 + - 1460000) = 1
    # - 832211 + 832212 = 1
    # So it iterates 1 to #Q with step 1.
    
    decrypted_strings = []
    
    for idx, F_enc in enumerate(P_list):
        # Python string
        F = F_enc
        G = len(F)
        E = [] # result chars
        
        # s = 882827 - 882826 = 1
        s = 1
        # b = - 987317 - ( - 1099267 - ( - 111950)) 
        #   = -987317 - (-1211217) = 223900? Let's eval.
        b_expr = "- 987317 - ( - 1099267 - ( - 111950))"
        try:
            b = eval(b_expr.replace('^', '**'))
        except:
             b = 0
             
        # f = 733865 - 733865 = 0
        f = 0
        
        # Loop while s <= G
        # Lua 1-based index vs Python 0-based
        
        # Correctly implement the while loop
        s_idx = s - 1 # Python index
        
        while s_idx < G:
            P_char = F[s_idx]
            
            # Q = m[P]
            if P_char not in m_dict:
                # If char not in m, maybe it's not encoded or break?
                # The code says: if Q then ...
                s_idx += 1 # Only if we don't process it?
                # But wait: "if Q then ... end"
                # If !Q, it just loops. But where does s increment?
                # Line 118: "end s = s + ..." is OUTSIDE the "if Q then" block?
                # No, look at indentation.
                # line 105: if Q then
                # line 106: ...
                # line 119: Q[P] = v(E) (Wait, this is wrong in my read)
                # Let's re-read indentation carefully.
                
                # if Q then
                #   calc b, f
                #   if f == 4 then
                #      ... Y(E, u(...)) ...
                #   else
                #      if P == "=" then ... break end
                #      s = s + ... (Logic update)
                #   end
                # end
                
                # Wait, if Q is nil, the code does NOTHING and loop hangs? 
                # Impossible. s must increment.
                # Ah, indentation in beautified file might be misleading.
                pass
            
            Q = m_dict.get(P_char)
            if Q is not None:
                # b = b + Q * (64) ^ (3 - f)  (Simplified constants based on typical Base64)
                # 262481 + - 262417 = 64
                # 326546 + - 326543 = 3
                
                # f = f + 1
                # 886463 - ( - 649150 + 1535612) = 886463 - 886462 = 1
                
                b = b + Q * (64 ** (3 - f))
                f = f + 1
                
                if f == 4:
                    f = 0 # ( - 671540 - ( - 623776)) + 47764 = 0
                    
                    # Decrypt 3 chars
                    # P_val = math.floor(b / 65536)
                    val1 = math.floor(b / 65536)
                    # m_val = math.floor((b % 65536) / 256)
                    val2 = math.floor((b % 65536) / 256)
                    # Q_val = b % 256
                    val3 = b % 256
                    
                    E.append(chr(val1))
                    E.append(chr(val2))
                    E.append(chr(val3))
                    
                    b = 0 # - 1045667 + 1045667
                    
                s_idx += 1
            else:
                # If char not in m (e.g. "=" padding)
                if P_char == "=":
                     # Handle padding
                     # Y(E, u(g(b / 65536)))
                     val1 = math.floor(b / 65536)
                     E.append(chr(val1))
                     
                     # Check next char for "="
                     if s_idx + 1 >= G or F[s_idx+1] == "=":
                         # Y(E, u(g((b % 65536) / 256)))
                         pass # Actually logic says if next is not =, assume single padding?
                         # Line 115: if ... ~= "=" then Y(...) end
                         # Let's simplify: Padding logic in Base64
                         
                     # Base64 padding handling usually depends on f value
                     if f == 2:
                         # 1 eq char -> 2 bytes? No.
                         pass
                     elif f == 3:
                         # 2 bytes decoded
                         val2 = math.floor((b % 65536) / 256)
                         E.append(chr(val2))
                     
                     break # break loop
                
                # If unknown char, ignore?
                s_idx += 1

        decrypted_val = "".join(E)
        decrypted_strings.append(decrypted_val)
        P_list[idx] = decrypted_val # Update in place
        
        # Clean for printing
        safe_s = decrypted_val.replace('\n', '\\n').replace('\r', '\\r')
        if len(safe_s) > 50: safe_s = safe_s[:50] + "..."
        print(f"P[{idx}] = {safe_s}")

    return decrypted_strings

if __name__ == "__main__":
    if len(sys.argv) > 1:
        decrypt_normal(sys.argv[1])
    else:
        decrypt_normal("d:\\dec bot2\\normal_mode\\3093638569183289.beautified.utf8.lua")

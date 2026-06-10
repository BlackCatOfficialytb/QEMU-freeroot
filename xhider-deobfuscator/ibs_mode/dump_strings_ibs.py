import re
import sys

def dump_strings_ibs(input_file):
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Regex for double quoted strings (Lua can use ' or " or [[ ]])
    # The beautified file seems to use " for strings.
    
    # Capture "..." handling escapes
    matches = re.findall(r'"((?:[^"\\]|\\.)*)"', content)
    
    print(f"Found {len(matches)} string literals.")
    
    for i, s in enumerate(matches):
        # Decode lua escapes like \211 sent as bytes
        # simplified decode
        try:
            # We want to see what the string IS.
            # If it's \ddd, convert to char.
            decoded = ""
            idx = 0
            is_binary = False
            while idx < len(s):
                c = s[idx]
                if c == '\\':
                    # Check next
                    if idx + 1 < len(s):
                        nc = s[idx+1]
                        if nc.isdigit():
                            # \ddd
                            num_str = nc
                            j = idx + 2
                            while j < len(s) and j < idx + 4 and s[j].isdigit():
                                num_str += s[j]
                                j += 1
                            val = int(num_str)
                            decoded += chr(val)
                            if val > 127 or val < 32: is_binary = True
                            idx = j
                        elif nc == 'a': decoded += '\a'; idx += 2
                        elif nc == 'b': decoded += '\b'; idx += 2
                        elif nc == 'f': decoded += '\f'; idx += 2
                        elif nc == 'n': decoded += '\n'; idx += 2
                        elif nc == 'r': decoded += '\r'; idx += 2
                        elif nc == 't': decoded += '\t'; idx += 2
                        elif nc == 'v': decoded += '\v'; idx += 2
                        elif nc == '\\': decoded += '\\'; idx += 2
                        elif nc == '"': decoded += '"'; idx += 2
                        elif nc == "'": decoded += "'"; idx += 2
                        else: decoded += nc; idx += 2 # literal backslash?
                    else:
                        decoded += '\\'; idx += 1
                else:
                    decoded += c
                    idx += 1
            
            # Print readable strings
            safe_s = decoded.replace('\n', '\\n').replace('\r', '\\r')
            if len(safe_s) > 100: safe_s = safe_s[:100] + "..."
            
            # Filter pure junk/binary if needed, but for now print all
            print(f"[{i}] {safe_s}")
            
        except Exception as e:
            print(f"[{i}] Error decoding: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        dump_strings_ibs(sys.argv[1])
    else:
        dump_strings_ibs("d:\\dec bot2\\ibs_mode\\1943246169875400.beautified.utf8.lua")

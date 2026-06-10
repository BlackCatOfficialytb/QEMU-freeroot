import re
import os
import subprocess

input_file = r"d:\dec bot2\max_security_mode\987415550020054.beautified.utf8.lua"
output_file = r"d:\dec bot2\max_security_mode\987415550020054.injected.lua"

with open(input_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Find last return(function
target = "return(function"
last_idx = content.rfind(target)

if last_idx == -1:
    print("Could not find target string")
    exit(1)

print(f"Injecting at index {last_idx}")

dumper = r'''
-- INJECTED DUMPER
print("--- DUMP START ---")

-- Helper to print strings safely
local function print_str(prefix, s)
    s = tostring(s)
    local safe = ""
    for i = 1, #s do
        local b = string.byte(s, i)
        if b >= 32 and b <= 126 then
            safe = safe .. string.char(b)
        else
            safe = safe .. string.format("\\%03d", b)
        end
    end
    print(prefix .. safe)
end

if a then
    print("Found table a type: " .. type(a))
    if a[1] then
        print("Dumping a[1] (Strings):")
        for k, v in pairs(a[1]) do
            print_str("STR ["..k.."]: ", v)
        end
    end
    
    if a[3] then
        print("Dumping a[3]:")
        for k, v in pairs(a[3]) do
             print_str("A3 ["..k.."]: ", v)
        end
    end
end

if K and type(K) == "table" then
    print("Found table K")
    if K[2] then
        print("Dumping K[2] (Map):")
        for k, v in pairs(K[2]) do
            -- check if k or v is string
            local kstr = tostring(k)
            local vstr = tostring(v)
            if type(k) == "string" then kstr = k end
            print_str("KEY: " .. kstr .. " VAL: " .. vstr, "")
        end
    end
end

print("--- DUMP END ---")
os.exit(0)
'''

new_content = content[:last_idx] + dumper + content[last_idx:]

with open(output_file, 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Created injected file. Running lua...")

try:
    result = subprocess.run(["lua", output_file], capture_output=True, text=True, encoding='utf-8', errors='replace')
    print("STDOUT:", result.stdout[:2000]) # Print first 2000 chars
    print("STDERR:", result.stderr)
    
    # Save full output
    with open(r"d:\dec bot2\max_security_mode\dump_output.txt", "w", encoding="utf-8") as f:
        f.write(result.stdout)
        
except Exception as e:
    print(f"Error running lua: {e}")

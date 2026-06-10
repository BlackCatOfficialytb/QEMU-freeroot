import re

with open('psu_max_mode/print_hi.lua.chunk_1.lua', 'r') as f:
    content = f.read()

# Look for where Calculate is assigned
pattern = r'(\w+)\s*=\s*.*Calculate'
match = re.search(pattern, content)
if match:
    print(f"Potential assignment to Calculate at {match.start()}: ... {content[match.start()-100:match.end()+100]} ...")

# Look for the definition of the global Calculate
# In PSU, it's often _G["Calculate"] or similar
pattern = r'_G\[[^\]]+\]\s*=\s*function'
for match in re.finditer(pattern, content):
    print(f"Potential global assignment at {match.start()}: ... {content[match.start()-100:match.end()+100]} ...")

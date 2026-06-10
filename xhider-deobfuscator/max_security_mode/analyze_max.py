import re

filepath = r"d:\dec bot2\max_security_mode\987415550020054.beautified.utf8.lua"

with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

print(f"File size: {len(content)} bytes")
print(f"File lines: {content.count('\\n') + 1}")

# Find pattern `return(function` or `return function`
matches = list(re.finditer(r'return\s*\(\s*function', content))
print(f"Found {len(matches)} occurrences of 'return(function'.")

for m in matches:
    start = m.start()
    end = m.end()
    # Get line number
    line_num = content[:start].count('\n') + 1
    print(f"Match at line {line_num}, index {start}")
    print(f"Context: {content[start:start+100]}...")

# Check for just `return function`
matches2 = list(re.finditer(r'return\s+function', content))
print(f"Found {len(matches2)} occurrences of 'return function'.")
for m in matches2:
    start = m.start()
    line_num = content[:start].count('\n') + 1
    print(f"Match at line {line_num}, index {start}")
    print(f"Context: {content[start:start+100]}...")

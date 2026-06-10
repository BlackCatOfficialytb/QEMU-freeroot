import re

with open(r'd:\dec bot2\max_security_mode\print_hi.lua', 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

# Look for a[4]=function(K)...
match = re.search(r'a\[4\]=function\(K\)(.*?)end', content, re.DOTALL)
if match:
    body = match.group(1)
    print(f"Found a[4] body: {body}")
    # Extract numbers
    nums = re.findall(r'\d+', body)
    print(f"Numbers in body: {nums}")
else:
    print("Could not find a[4] definition")

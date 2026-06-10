import re

with open('psu_max_mode/print_hi.lua.chunk_1.lua', 'r') as f:
    content = f.read()

# Find all occurrences of Calculate and show 50 characters before and after
for match in re.finditer(r'Calculate', content):
    start = max(0, match.start() - 100)
    end = min(len(content), match.end() + 100)
    print(f"Match at {match.start()}: ... {content[start:end]} ...")

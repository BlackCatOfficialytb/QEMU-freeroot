import re

with open('psu_max_mode/print_hi.lua', 'r') as f:
    content = f.read()

# Keys for "calculate" (lowercase)
keys = [767826132, 29799631, 864117863, 767826132, 997985534, 864117863, 29799631, 676273207, 209867084]

# Search for patterns like o[key1]..o[key2]..
pattern = r'o\[' + r'\]\.\.o\['.join([str(k) for k in keys]) + r'\]'
match = re.search(pattern, content)
if match:
    print(f"Found 'calculate' pattern at {match.start()}")
    print(content[match.start()-50:match.end()+50])
else:
    # Try searching for individual keys close to each other
    first_key = str(keys[0])
    for match in re.finditer(first_key, content):
        start = max(0, match.start() - 100)
        end = min(len(content), match.end() + 500)
        print(f"Found first key {first_key} at {match.start()}: ... {content[start:end]} ...")

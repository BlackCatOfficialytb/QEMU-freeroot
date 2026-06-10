import collections

with open("a3_dump.txt", "r", encoding="utf-8") as f:
    for line in f:
        # Print a few lines that have length > 1
        if "len=" in line:
            parts = line.split()
            l = int(parts[1].split('=')[1])
            if l > 1 and l % 2 == 0:
                print(line.strip())

from decrypt_psu_max import *

def tobit32(x):
    return int(x) & 0xFFFFFFFF

def t(a, b):
    return tobit32(int(a)) ^ tobit32(int(b))

def band(a, b):
    return tobit32(int(a)) & tobit32(int(b))

o = O_TABLE

# Thresholds from lazy evaluations in Lua dispatch
l_62727361 = t(2660673, 28811554)
l_509744483 = t(t(t(1635498-337822-76057, 243699)-201583, 917648)
l_794859907 = t(t(t(991843-554000, 646430)-807866, 883132))
l_424202806 = (2343340-405909)-845813-418709-672897
l_350699343 = t(155448444, 155228450)
l_134990531 = t(t(t(1583139, 720463)-277419)-620213)-336896
l_919797218 = t(t(t(986559, 186452)-797780, 108954)
l_556970481 = t(t(t(897315-402713, 475721), 52819)

ct1 = band(t(919068738, 28811554), t(156229931, 155228450))
ct2 = band(t(592051204, 660029073), t(903245772, 905968982))
ct3 = band(t(284364705, 905968982), 1210963)
ct4 = band(t(42974262, 905968982), 1013789)
l_155228455 = t(155228455, 155228450)

print("Thresholds:")
print(f"  l[62727361] = {l_62727361}")
print(f"  l[509744483] = {l_509744483}")
print(f"  l[155228455] = {l_155228455}")
print(f"  148864")
print(f"  Calc t1 = {ct1}")
print(f"  l[794859907] = {l_794859907}")
print(f"  l[424202806] = {l_424202806}")
print(f"  l_350699343 = {l_350699343}")
print(f"  Calc t2 = {ct2}")
print(f"  l_134990531 = {l_134990531}")
print(f"  l[919797218 = {l_919797218}")
print(f"  Calc t3 = {ct3}")
print(f"  l[556970481 = {l_556970481}")
print(f"  Calc t4 = {ct4}")

# Map opcodes
names = {}
for e in range(256):
    if e <= l_62727361:
        if e == 246784:
            names[e] = "TAILCALL"
        elif e <= l_509744483:
            names[e] = "SET"
        else:
            names[e] = "JMP"
    elif e <= ct1:
        if e == 4:
            names[e] = "RETURN"
        elif e <= l_155228455:
            names[e] = "GETTABLE_UPVAL"
        elif e <= 148864:
            names[e] = "GETTABLE_IDX"
        elif e == 7:
            names[e] = "CALL1"
        elif e <= l_794859907:
            names[e] = "CONCAT"
        else:
            names[e] = "?branch2"
    elif e <= l_424202806:
        if e == 2296386:
            names[e] = "FORLOOP"
        elif e > 9:
            names[e] = "GETTABLE_IDX"
        elif e < l_350699343:
            names[e] = "SETTABLE_RANGED"
        elif e > ct2:
            names[e] = "LEN"
        elif e < l_134990531:
            names[e] = "CALL_N"
        else:
            names[e] = "GETTABLE_KEY"
    elif e <= l_919797218:
        names[e] = "SELF_CALL"
    elif e <= ct3:
        names[e] = "FORPREP"
    elif e == l_556970481:
        names[e] = "MOVE"
    elif e <= ct4:
        names[e] = "GETUPVAL"
    else:
        names[e] = "GETCONST"

print("\nOpcode map 0-17:")
for e in range(18):
    print(f"  {e:3d} = {names[e]}")

# Show used opcodes
test_ops = [3,17,10,16,1,17,10,1,12,11,14,13,1,8,3,15,3,1,5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,6,1,0,16,2,3,7,4]
from collections import Counter
c = Counter(test_ops)
print(f"\nUsed opcodes:")
for op, cnt in c.most_common():
    print(f"  {op:3d} ({names.get(op,'?'):20s}): {cnt}")

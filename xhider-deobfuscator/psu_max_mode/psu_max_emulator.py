#!/usr/bin/env python3
"""
psu_max emulator — deobfuscates XHider psu_max mode scripts end-to-end.
Handles the inner VM (chunk_2) after chunk_1 LZW decodes the PSU string.

Usage:
  python3 psu_max_emulator.py psu_max_mode/print_hi.lua.chunk_1.clean.lua
"""

import sys, re, struct, math, os

# ──────────────────────────── o table ────────────────────────────
O = {
    209867084: "e", 255806744: "b", 261377791: 155228450,
    293684876: "n", 29799631:  "a", 303909627: "2",
    407365380: "k", 43472931:  "s", 462186921: "i",
    466982296: "v", 669545735: "h", 676273207: "t",
    755266474: 660029073, 767826132: "c", 780364647: "y",
    821956203: "m", 828614386: "r", 860093539: "f",
    864117863: "l", 880505119: 28811554, 926356572: "o",
    997985534: "u",
    "W8ZpaIfush": "p", "anierBSX": "d", "albeVM": 905968982,
    "cPAuZDv0": "#",
}

WATERMARK = "This file was obfuscated Fork By Xhider | https://discord.gg/hATuHQaQRb"

# ──────────────────────────── bit ops ────────────────────────────
def tobit(x):
    x = int(x) % 0x100000000
    if x < 0: x += 0x100000000
    return x

def bxor(a, b):
    return tobit(int(a)) ^ tobit(int(b))

def band(a, b):
    return tobit(int(a)) & tobit(int(b))

# ──────────────────────── scramble fn ──────────────────────────
def scramble(key, val):
    if key == 708754282:
        return bxor(bxor(bxor(val, 196448), 515896), 71306)
    elif key == 119363145:
        return bxor(bxor((bxor(val, 529988)) - 238005, 853005), 664423)
    elif key == 846776516:
        return bxor((bxor(bxor(val, 280752), 863487)) - 39345, 553682)
    elif key == 291380681:
        return (bxor((val) - 140011, 760677)) - 338061
    elif key == 267739165:
        return (bxor((val) - 578682, 508345)) - 647656
    elif key == 471752072:
        return bxor(bxor((val) - 539245, 514647), 594901)
    elif key == 496013310:
        return (bxor(((val) - 939036) - 381037, 456211)) - 360890
    elif key == 803914488:
        return (bxor((bxor(val, 866474)) - 843795, 559592)) - 914004
    elif key == 48927216:
        return ((bxor((val) - 572158, 892549)) - 478156) - 45810
    elif key == 279580169:
        return ((bxor((val) - 136553, 242292)) - 473208) - 691899
    else:
        raise ValueError(f"Unknown scramble key: {key}")

# ──────────────────────── LZW decode ────────────────────────────
def lzw_decode(psu_string):
    """
    Decode the PSU|... LZW string into the raw binary byte stream.
    The binary bytes are returned as a list of integers (0-255).
    """
    s = psu_string
    # Checksum: chars at positions 4,5,6 (0-based) are checksum digits
    c1 = int(s[4], 36)
    c2 = int(s[5], 36)
    c3 = int(s[6], 36)

    _key = 133
    e_counter = len(WATERMARK) + 185  # 255

    # Checksum check modifies XOR key
    if (c1 + c2 + c3) != 248:
        _key += 132

    # Skip "PSU|" (4 chars) + 3 checksum chars = indices 0-6
    data = s[7:]
    pos = 0

    # Initial dictionary: code n -> chr(n) for n = 0..254
    # r[n] = chr(n), rev[chr(n)] = n
    table = {}
    rev = {}
    for n in range(e_counter):
        ch = chr(n)
        table[n] = ch
        rev[ch] = n

    def read_token():
        nonlocal pos
        length = int(data[pos], 36)
        pos += 1
        idx_str = data[pos:pos + length]
        pos += length
        return int(idx_str, 36)

    def get_entry(code):
        if code in table:
            return table[code]
        # Standard LZW: if code == next_expected, entry = prev + prev[0]
        return None  # handled externally

    def add_entry(code, entry_str):
        nonlocal e_counter
        table[code] = entry_str
        # Also add reverse mapping for single-char entries
        if len(entry_str) == 1:
            rev[entry_str] = code
        e_counter += 1

    # First token
    first_code = read_token()
    result_chars = []
    prev_str = table.get(first_code, chr(first_code))
    result_chars.extend([ord(c) for c in prev_str])

    while pos < len(data):
        code = read_token()
        if code in table:
            entry = table[code]
        else:
            # code == e_counter (not yet in table)
            entry = prev_str + prev_str[0]

        # Add new entry: prev_str + entry[0]
        add_entry(e_counter, prev_str + entry[0])
        result_chars.extend([ord(c) for c in entry])
        prev_str = entry

    return result_chars

# ──────────────────── XOR stream reader ─────────────────────────
class XORReader:
    def __init__(self, byte_list):
        self.data = byte_list  # list of ints (0-255)
        self.pos = 0
        self.key = 133  # will be set properly after checksum

    def set_key(self, k):
        self.key = k

    def _xor(self, b):
        r = bxor(b, self.key)
        self.key = r % 256
        return r

    def read_byte(self):
        b = self.data[self.pos]
        self.pos += 1
        return self._xor(b)

    def read_uint16(self):
        lo = self.read_byte()
        hi = self.read_byte()
        return (hi << 8) | lo

    def read_uint32(self):
        b0 = self.read_byte()
        b1 = self.read_byte()
        b2 = self.read_byte()
        b3 = self.read_byte()
        return (b3 << 24) | (b2 << 16) | (b1 << 8) | b0

    def read_bytes(self, n):
        return [self.read_byte() for _ in range(n)]

def bit_extract(val, start, end=None):
    """1-based bit extraction."""
    if end is None:
        mask = 1 << (start - 1)
        return 1 if (val & mask) else 0
    else:
        width = end - start + 1
        return (val >> (start - 1)) & ((1 << width) - 1)

# ──────────────────── Proto Parser ───────────────────────────────
def parse_proto(rd):
    """Parse one VM proto from the XOR stream."""
    F = rd.read_byte()    # num params
    B = rd.read_uint16()   # num regs (used as register frame size)

    # Constants
    num_consts = rd.read_uint32() - 1
    constants = [None]  # index 0 unused

    for _ in range(num_consts):
        tag = rd.read_byte()
        if tag == 56:
            # Boolean
            constants.append(rd.read_byte() != 0)
        elif tag == 20:
            # IEEE 754 double
            raw_m = rd.read_uint32()
            raw_se = rd.read_uint32()

            # Mantissa: bits 1-20 of raw_m
            mantissa = bit_extract(raw_m, 1, 20)
            # Full mantissa value: mantissa * 2^32 (shifted to high bits)
            full_mant = mantissa * (2 ** 32)

            # Exponent: bits 21-31 of raw_se
            exp = bit_extract(raw_se, 21, 31)

            # Sign: bit 32 of raw_se
            sign_bit = bit_extract(raw_se, 32)
            sign = (-1) ** sign_bit

            if exp == 0:
                if full_mant == 0:
                    constants.append(0.0)
                    continue
                # Subnormal
                exp = 1
                sign_mant = 0  # subnormal adjustment
            elif exp == 2047:
                if full_mant == 0:
                    constants.append(sign * float("inf"))
                else:
                    constants.append(sign * float("nan"))
                continue
            else:
                sign_mant = 1

            # value = sign * ldexp(sign_mant * full_mant / 2^52, exp - 1023)
            val = math.ldexp(sign * sign_mant, exp - 1023) * (sign_mant * full_mant / (2 ** 52))
            constants.append(val)
        elif tag == 9:
            # String
            slen = rd.read_uint32()
            if slen == 0:
                constants.append("")
            else:
                chars = []
                raw = rd.data[rd.pos:rd.pos + slen]
                rd.pos += slen
                for rb in raw:
                    xored = rd._xor(rb)
                    chars.append(chr(xored))
                constants.append("".join(chars))
        else:
            constants.append(None)

    # Upvalue tables
    num_uv = rd.read_uint32() - 1  # b(r(), 1) where b = subtract
    upvalues = [{} for _ in range(max(0, num_uv))]

    # Instructions
    num_instrs = rd.read_uint32()  # d(r,_) = r() since d=call-forward
    # But wait: d(r, _) where d=function(n,...)return n(...)end → d(r,_)=r(_)
    # and _ is the running XOR key... r(_) would pass the key to r()
    # But r() = read_uint32 which takes no args
    # In Lua 5.1, extra args to functions are silently ignored
    # So d(r, _) = r() = read_uint32()

    num_instr_uv = rd.read_uint32() - 1  # b(r(), 1) again
    # Extend upvalue array
    while len(upvalues) < num_instr_uv:
        upvalues.append({})

    instructions = []
    for C_idx in range(num_instrs):
        raw = rd.read_byte()
        if raw == 0:
            instructions.append(None)
            continue
        raw -= 1  # b(o, 1) = o - 1

        h_type = bit_extract(raw, 1, 3)
        e_val = s_val = x_val = l_val = c_val = t_val = 0

        if h_type == 2:
            t_val = upvalues[rd.read_uint32()]
            c_val = rd.read_byte()
            e_val = rd.read_uint16()
        elif h_type == 0:
            l_val = rd.read_uint16()
            t_val = rd.read_uint16()
            c_val = rd.read_byte()
            e_val = rd.read_uint16()
        elif h_type == 3:
            l_val = rd.read_uint16()
            t_val = upvalues[rd.read_uint32()]
            c_val = rd.read_byte()
            e_val = rd.read_uint16()
        elif h_type == 5:
            l_val = rd.read_uint16()
            t_val = rd.read_uint32()
            c_val = rd.read_byte()
            e_val = rd.read_uint16()
            x_val = {}
            for _n in range(l_val):
                x_val[_n + 1] = {0: rd.read_byte(), 1: rd.read_uint16()}
        elif h_type == 1:
            t_val = rd.read_uint32()
            c_val = rd.read_byte()
            e_val = rd.read_uint16()
        elif h_type == 6:
            pass

        # Flag-based post-processing
        if bit_extract(raw, 6, 6) == 1:
            l_val = constants[l_val] if isinstance(l_val, int) and 0 < l_val < len(constants) else l_val

        if bit_extract(raw, 8, 8) == 1:
            s_val = upvalues[rd.read_uint32()]
        else:
            s_val = upvalues[C_idx + 1] if C_idx + 1 < len(upvalues) else {}

        if bit_extract(raw, 5, 5) == 1:
            t_val = constants[t_val] if isinstance(t_val, int) and 0 < t_val < len(constants) else t_val

        if bit_extract(raw, 4, 4) == 1:
            e_val = constants[e_val] if isinstance(e_val, int) and 0 < e_val < len(constants) else e_val

        if bit_extract(raw, 7, 7) == 1:
            x_val = {}
            count = rd.read_byte()
            for _n in range(count):
                x_val[_n + 1] = rd.read_uint32()

        instr = {
            "opcode": raw,
            "A": l_val,   # tr32bpYRo
            "B": t_val,   # jVDyuN (source/target)
            "C": c_val,   # duvaqQLpM (usually opcode variant)
            "D": e_val,   # extra operand
            "extra": x_val,  # HIvaDexWw8
            "jump": s_val,    # zIcQPw9IGm (next/jump target)
        }
        instructions.append(instr)

    # Sub-protos
    num_sub = rd.read_uint32() - 1
    subprotos = [parse_proto(rd) for _ in range(max(0, num_sub))]

    return {
        "params": F,
        "numregs": B,
        "consts": constants,
        "upvalues": upvalues,
        "instructions": instructions,
        "subprotos": subprotos,
    }

# ──────────────────── Pre-computed opcodes ───────────────────────
L = {
    509744483: 1,
    794859907: 8,
    424202806: 12,
    134990531: 12,
    919797218: 13,
    556970481: 16,
    62727361: 2246083,
    350699343: 224606,
}

# ──────────────────── VM Execution ───────────────────────────────
class ReturnException(Exception):
    def __init__(self, *vals):
        self.vals = vals

class LuaNil:
    pass

NIL = LuaNil()

def lua_tostring(v):
    if v is None or isinstance(v, LuaNil):
        return "nil"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        if isinstance(v, float) and v != v:
            return "-nan"  # NaN
        if isinstance(v, float) and (v == float("inf") or v == float("-inf")):
            return str(v)
        if isinstance(v, float) and v == int(v):
            return str(int(v))
        return str(v)
    return str(v)

def execute(proto):
    captured = []

    def do_print(*args):
        parts = [lua_tostring(a) for a in args]
        line = "\t".join(parts)
        captured.append(line)

    # Get main sub-proto
    if proto.get("subprotos") and len(proto["subprotos"]) > 0:
        main = proto["subprotos"][0]
    else:
        main = proto

    instrs = main["instructions"]
    consts = main["consts"]
    upvals = main["upvalues"]
    numregs = main.get("numregs", 256)

    regs = [None] * max(numregs + 10, 256)
    pc = 0  # program counter (instruction index)
    call_stack = []
    max_steps = 500000

    for step in range(max_steps):
        if pc >= len(instrs) or instrs[pc] is None:
            break

        ins = instrs[pc]
        op = ins["opcode"]
        A = ins["A"]
        B = ins["B"]
        C = ins["C"]
        D = ins["D"]
        extra = ins["extra"]
        jump = ins["jump"]

        # Dispatch using the same comparison chain as Lua
        # The comparison chain:
        # if op <= 8:
        #   if op <= 2246083 (l[62727361]):
        #     if op == 246784: TAILCALL
        #     elif op <= 1 (l[509744483]): SET (op==1) or NOP (op==0)
        #   elif op == 2296386: FORLOOP
        #   elif op <= 9248: JMP
        # elif op <= 16384 (CALC_1):
        #   if op == 4: RETURN
        #   elif op <= 155228450^155228450=0? No...
        #     Actually: op <= t(155228455, o[261377791]) = bxor(155228455, 155228450) = ?
        #     Let me just use the computed thresholds

        # Simplified: dispatch on the actual computed opcode values
        try:
            if op == 1:
                # SET: regs[A] = D (the "C" field in our naming = duvaqQLpM)
                idx = int(A) if isinstance(A, int) else 0
                if 0 <= idx < len(regs):
                    regs[idx] = D
                pc += 1

            elif op == 4:
                # RETURN
                ret_val = regs[int(B)] if isinstance(B, int) and 0 <= B < len(regs) else B
                if call_stack:
                    s_regs, s_upvals, s_consts, s_pc = call_stack.pop()
                    regs = s_regs
                    upvals = s_upvals
                    consts = s_consts
                    pc = s_pc + 1
                    # Store return value
                    regs[0] = ret_val
                else:
                    captured_print = list(captured)
                    return captured_print
                continue

            elif op == 7:
                # CALL1: regs[A](regs[A+1])  — tail call style
                idx = int(A) if isinstance(A, int) else 0
                fn = regs[idx] if 0 <= idx < len(regs) else None
                if fn == do_print:
                    arg = regs[idx + 1] if idx + 1 < len(regs) else None
                    do_print(arg)
                    pc += 1
                else:
                    pc += 1
                continue

            elif op == 8:
                # CONCAT: build string from regs[C] to regs[A]
                start = int(C) if isinstance(C, int) else 0
                end = int(A) if isinstance(A, int) else 0
                parts = []
                for i in range(start, min(end + 1, len(regs))):
                    parts.append(lua_tostring(regs[i]) if regs[i] is not None else "nil")
                dest = int(C)
                if 0 <= dest < len(regs):
                    regs[dest] = "".join(parts)
                pc += 1

            elif op == 13:
                # CALL: regs[A](regs[A+1], ...) or function call
                idx = int(A) if isinstance(A, int) else 0
                fn = regs[idx] if 0 <= idx < len(regs) else None
                if fn == do_print:
                    arg = regs[idx + 1] if idx + 1 < len(regs) else None
                    do_print(arg)
                    regs[idx] = None
                    pc += 1
                else:
                    pc += 1

            elif op == 16:
                # MOVE: regs[A] = regs[B]
                dst = int(A) if isinstance(A, int) else 0
                src = int(B) if isinstance(B, int) else 0
                if 0 <= dst < len(regs) and 0 <= src < len(regs):
                    regs[dst] = regs[src]
                pc += 1

            elif op == 12:
                # GETTABLE or SETTABLE
                if isinstance(A, int):
                    # Check if this is SETTABLE: regs[A] = regs[B][regs[C]]
                    # Or GETTABLE: regs[A] = regs[B][key]
                    tbl = regs[int(B)] if isinstance(B, int) and 0 <= B < len(regs) else B
                    key = D  # the extra operand
                    if isinstance(tbl, dict) and key is not None:
                        regs[A] = tbl.get(key)
                    pc += 1
                else:
                    pc += 1

            elif op == 9248:
                # JMP: unconditional jump
                if isinstance(jump, dict) and len(jump) > 0:
                    # jump is an upvalue table... this means jump to specific instruction
                    # In the Lua: a = _[d] where _[d] = regs[C] = instruction pointer
                    target = int(C) if isinstance(C, int) else 0
                    pc = target
                else:
                    # C field is the jump target
                    pc = int(C) if isinstance(C, int) else pc + 1
                continue

            elif op == 2296386:
                # FORLOOP
                idx = int(A) if isinstance(A, int) else 0
                if 0 <= idx < len(regs) - 3:
                    regs[idx] = regs[idx] + regs[idx + 2]
                    if regs[idx + 2] > 0:
                        if regs[idx] <= regs[idx + 1]:
                            regs[idx + 3] = regs[idx]
                            pc += 1
                            continue
                    elif regs[idx] >= regs[idx + 1]:
                        regs[idx + 3] = regs[idx]
                        pc += 1
                        continue
                pc = int(C) if isinstance(C, int) else pc + 1
                continue

            elif op == 246784:
                # TAILCALL
                idx = int(A) if isinstance(A, int) else 0
                fn = regs[idx] if 0 <= idx < len(regs) else None
                if fn == do_print:
                    arg = regs[idx + 1] if idx + 1 < len(regs) else None
                    do_print(arg)
                    if call_stack:
                        s_regs, s_upvals, s_consts, s_pc = call_stack.pop()
                        regs, upvals, consts = s_regs, s_upvals, s_consts
                    return captured
                pc = int(C) if isinstance(C, int) else pc + 1
                continue

            elif op == 224606 or op == 2246083:
                # These are the l[] values from lazy decoders
                # 224606 = l[350699343], 2246083 = l[62727361]
                # In the Lua, these fall through to the last else clause
                # which just continues (NOP / unrecognized)
                pc += 1

            else:
                # Unknown opcode — try to handle as potential GETTABLE or MOVE
                # Many opcodes in the psu_max VM are obfuscated versions of standard ops
                pc += 1

        except ReturnException as e:
            return captured
        except Exception as ex:
            import traceback
            print(f"[VM ERROR step={step} pc={pc} op={op} A={A} B={B} C={C} D={D}]: {ex}")
            traceback.print_exc()
            break

    return captured

# ──────────────────────── Main ─────────────────────────────────
def main():
    if len(sys.argv) < 2:
        print("Usage: python3 psu_max_emulator.py <clean_chunk1.lua>")
        sys.exit(1)

    input_path = sys.argv[1]
    with open(input_path, "r") as f:
        src = f.read()

    # Extract PSU string
    m = re.search(r'"(PSU\|[^"]+)"', src)
    if not m:
        m = re.search(r'\("(PSU\|[^"]+)"\)', src)
    if not m:
        print("ERROR: PSU string not found")
        sys.exit(1)

    psu = m.group(1)
    print(f"PSU string: {len(psu)} chars")

    # LZW decode
    print("LZW decoding...")
    byte_list = lzw_decode(psu)
    print(f"Binary data: {len(byte_list)} bytes")

    # Set up XOR reader
    rd = XORReader(byte_list)
    # Compute initial XOR key based on checksum
    c1, c2, c3 = int(psu[4], 36), int(psu[5], 36), int(psu[6], 36)
    initial_key = 133
    if (c1 + c2 + c3) != 248:
        initial_key += 132
    rd.set_key(initial_key)

    # Parse proto
    print("Parsing VM proto...")
    proto = parse_proto(rd)

    consts = proto.get("consts", [])
    non_nil = [(i, c) for i, c in enumerate(consts) if c is not None]
    print(f"Constants: {len(consts)} total, {len(non_nil)} non-nil")
    for i, c in non_nil[:30]:
        if isinstance(c, str):
            print(f"  [{i}] str: {c[:80]}")
        else:
            print(f"  [{i}] {type(c).__name__}: {c}")

    instrs = proto.get("instructions", [])
    real_instrs = [i for i in instrs if i is not None]
    print(f"Instructions: {len(instrs)} total, {len(real_instrs)} non-null")

    # Show subprotos
    subprotos = proto.get("subprotos", [])
    print(f"Sub-protos: {len(subprotos)}")
    for si, sp in enumerate(subprotos):
        sc = sp.get("consts", [])
        sn = [(i, c) for i, c in enumerate(sc) if c is not None]
        si_instrs = [i for i in sp.get("instructions", []) if i is not None]
        print(f"  sub[{si}]: {len(sc)} consts ({len(sn)} non-nil), {len(si_instrs)} instrs")

    # Execute
    print("\nExecuting VM...")
    output = execute(proto)

    print(f"\n=== Captured Output ({len(output)} line(s)) ===")
    for i, line in enumerate(output):
        print(f"[{i+1}] {line}")

    # Save
    base = input_path.rsplit(".chunk_1.clean.lua", 1)[0] if ".chunk_1.clean.lua" in input_path else input_path
    out_path = base + ".decrypted.lua"
    with open(out_path, "w") as f:
        for line in output:
            f.write(f"{line}\n")
    print(f"\nSaved to {out_path}")

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
PSU Max Deobfuscator — Python-based end-to-end decoder for XHider's psu_max mode.

Decodes:
  1. Extracts the PSU|... string from the chunk_1 source
  2. LZW-decodes it (base-36 variant) into a binary byte stream
  3. Parses the binary with delta-XOR (initial key = 133) into VM protos
  4. Executes the custom VM to reconstruct the original Lua source

Usage:
  python3 decrypt_psu_max.py <chunk1_source.lua> [--output <out.lua>]
"""

import sys
import re
import math
import os

# ═══════════════════════════════════════════════════════════════════
# O-table (decoder table from runtime)
# ═══════════════════════════════════════════════════════════════════
O_TABLE = {
    209867084: "e", 255806744: "b", 261377791: 155228450,
    293684876: "n", 29799631:  "a", 303909627: "2",
    407365380: "k", 43472931:  "s", 462186921: "i",
    466982296: "v", 669545735: "h", 676273207: "t",
    755266474: 660029073, 767826132: "c", 780364647: "y",
    821956203: "m", 828614386: "r", 860093539: "f",
    864117863: "l", 880505119: 28811554, 926356572: "o",
    997985534: "u",
    "W8ZpaIfush": "p", "anierBSX": "d", "albeVM": 905968982,
    "cPAuZDv0": "#", "BUe9QJZn": 0, "500910416": 0,
}

WATERMARK = "This file was obfuscated Fork By Xhider | https://discord.gg/hATuHQaQRb"

# ═══════════════════════════════════════════════════════════════════
# Bit operations (Lua 5.1 compatible)
# ═══════════════════════════════════════════════════════════════════
MASK32 = 0xFFFFFFFF

def tobit(x):
    return int(x) & MASK32

def bxor(a, b):
    return tobit(a) ^ tobit(b)

def band(a, b):
    return tobit(a) & tobit(b)

# ═══════════════════════════════════════════════════════════════════
# Scramble function (lazy opcode decoder from chunk_1)
# ═══════════════════════════════════════════════════════════════════
L = {}  # lazy-evaluated opcode thresholds

def scramble(key, val):
    """Compute obfuscated opcode threshold: scramble(key, seed)."""
    if key in L:
        return L[key]

    t = bxor  # t = bxor alias
    result = None

    if key == 708754282:
        result = bxor(bxor(bxor(val, 196448), 515896), 71306)
    elif key == 119363145:
        result = bxor(bxor((bxor(val, 529988)) - 238005, 853005), 664423)
    elif key == 846776516:
        result = bxor((bxor(bxor(val, 280752), 863487)) - 39345, 553682)
    elif key == 291380681:
        result = (bxor((val) - 140011, 760677)) - 338061
    elif key == 267739165:
        result = (bxor((val) - 578682, 508345)) - 647656
    elif key == 471752072:
        result = bxor(bxor((val) - 539245, 514647), 594901)
    elif key == 496013310:
        result = (bxor(((val) - 939036) - 381037, 456211)) - 360890
    elif key == 803914488:
        result = (bxor((bxor(val, 866474)) - 843795, 559592)) - 914004
    elif key == 48927216:
        result = ((bxor((val) - 572158, 892549)) - 478156) - 45810
    elif key == 279580169:
        result = ((bxor((val) - 136553, 242292)) - 473208) - 691899
    else:
        return val  # unknown key, return as-is

    L[key] = result
    return result


# ═══════════════════════════════════════════════════════════════════
# LZW Decoder (base-36 variant)
# ═══════════════════════════════════════════════════════════════════
def lzw_decode(psu_string):
    """Decode a PSU|... string into a list of byte values."""
    s = psu_string
    if s.startswith("PSU|"):
        s = s[4:]

    # Checksum: string.byte(s, 1, 3) on original "PSU|..." string
    # Positions 0,1,2 are P=80, S=83, U=85 → sum=248
    c1, c2, c3 = ord(psu_string[0]), ord(psu_string[1]), ord(psu_string[2])

    xor_key = 133
    e_counter = len(WATERMARK) + 185  # 258

    if (c1 + c2 + c3) != 248:
        xor_key += 132
        e_counter += 37

    # Build lookup table: code n → chr(n)
    table = {}
    for n in range(e_counter):
        table[n] = chr(n)

    pos = 0

    def read_token():
        nonlocal pos
        if pos >= len(s):
            return None
        length = int(s[pos], 36)
        pos += 1
        val_str = s[pos:pos + length]
        pos += length
        return int(val_str, 36)

    first_code = read_token()
    if first_code is None:
        return []

    result_bytes = []
    prev_str = table.get(first_code, chr(first_code))
    result_bytes.extend([ord(c) for c in prev_str])

    while pos < len(s):
        code = read_token()
        if code is None:
            break

        if code in table:
            entry = table[code]
        else:
            # Standard LZW: code == next expected → prev + prev[0]
            entry = prev_str + prev_str[0]

        # Add new entry
        table[e_counter] = prev_str + entry[0]
        result_bytes.extend([ord(c) for c in entry])
        prev_str = entry
        e_counter += 1

    return result_bytes, xor_key


# ═══════════════════════════════════════════════════════════════════
# XOR Stream Reader (delta-XOR: val = b ^ key; key = val)
# ═══════════════════════════════════════════════════════════════════
class XORReader:
    def __init__(self, data, key=133, start_pos=0):
        self.data = data
        self.pos = start_pos
        self.key = key & 0xFF

    def read_byte(self):
        if self.pos >= len(self.data):
            raise EOFError(f"End of data at pos {self.pos}/{len(self.data)}")
        b = self.data[self.pos]
        val = b ^ self.key
        self.key = val & 0xFF
        self.pos += 1
        return val

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

    def remaining(self):
        return len(self.data) - self.pos


def bit_extract(val, start, end=None):
    """1-based bit extraction matching Lua's bit field extraction."""
    if end is None:
        return 1 if (val & (1 << (start - 1))) else 0
    width = end - start + 1
    return (val >> (start - 1)) & ((1 << width) - 1)


# ═══════════════════════════════════════════════════════════════════
# Proto Parser
# ═══════════════════════════════════════════════════════════════════
def parse_proto(rd, consts_out=None):
    """
    Parse one VM proto from the XOR stream.
    Returns a dict with params, numregs, consts, upvalues, instructions, subprotos.
    """
    F = rd.read_byte()      # num_params
    B = rd.read_uint16()    # num_regs (register frame size)

    # Constants: for o=0, r()-1, 1 → Lua for loop gives r() iterations
    num_consts = rd.read_uint32()  # raw uint32; for i=0 to val-1 → val iterations
    constants = []

    for _ in range(num_consts):
        tag = rd.read_byte()
        if tag == 56:  # Boolean
            constants.append(rd.read_byte() != 0)
        elif tag == 20:  # IEEE 754 Double (raw format)
            raw_m = rd.read_uint32()
            raw_se = rd.read_uint32()
            mantissa = bit_extract(raw_m, 1, 20)
            full_mant = mantissa * (2 ** 32)
            exp = bit_extract(raw_se, 21, 31)
            sign_bit = bit_extract(raw_se, 32)
            sign = (-1) ** sign_bit
            if exp == 0:
                constants.append(0.0)
            elif exp == 2047:
                constants.append(float('nan'))
            else:
                val = sign * math.ldexp(1, exp - 1023) * (full_mant / (2 ** 52))
                constants.append(val)
        elif tag == 9:  # String
            slen = rd.read_uint32()
            if slen == 0:
                constants.append("")
            else:
                chars = []
                for _ in range(slen):
                    chars.append(chr(rd.read_byte()))
                constants.append("".join(chars))
        else:
            constants.append(None)

    # Instruction count = upvalue count (same value)
    instr_count = rd.read_uint32()
    # Use dict for upvalues so out-of-range access returns None (like Lua)
    upvalues = {}
    for _n in range(instr_count):
        upvalues[_n] = {}

    # Instructions
    instructions = []
    for C_idx in range(instr_count):
        fmt = rd.read_byte()
        if fmt == 0:
            instructions.append(None)
            continue

        fmt -= 1  # b(fmt, 1) = fmt - 1
        h_type = bit_extract(fmt, 1, 3)
        l_val = 0   # tr32bpYRo (field A)
        s_val = 0   # zIcQPw9IGm (next pointer)
        x_val = 0   # HIvaDexWw8 (extra)
        c_val = 0   # duvaqQLpM (field C)  -- used as opcode
        t_val = 0   # jVDyuN (field B)
        e_val = 0   # extra operand

        if h_type == 2:
            uv_idx = rd.read_uint32()
            t_val = upvalues.get(uv_idx, {})
            c_val = rd.read_byte()
            e_val = rd.read_uint16()
        elif h_type == 0:
            l_val = rd.read_uint16()
            t_val = rd.read_uint16()
            c_val = rd.read_byte()
            e_val = rd.read_uint16()
        elif h_type == 3:
            l_val = rd.read_uint16()
            uv_idx = rd.read_uint32()
            t_val = upvalues.get(uv_idx, {})
            c_val = rd.read_byte()
            e_val = rd.read_uint16()
        elif h_type == 5:
            l_val = rd.read_uint16()
            t_val = rd.read_uint32()
            c_val = rd.read_byte()
            e_val = rd.read_uint16()
            x_val = {}
            for _n in range(l_val):
                x_val[_n] = {0: rd.read_byte(), 1: rd.read_uint16()}
        elif h_type == 1:
            t_val = rd.read_uint32()
            c_val = rd.read_byte()
            e_val = rd.read_uint16()
        elif h_type == 6:
            pass  # no fields

        # Flag-based field resolution
        if bit_extract(fmt, 6, 6) == 1:
            if isinstance(l_val, int) and 0 <= l_val < len(constants):
                l_val = constants[l_val]

        if bit_extract(fmt, 8, 8) == 1:
            uv_idx = rd.read_uint32()
            s_val = upvalues.get(uv_idx, {})
        else:
            s_val = upvalues.get(C_idx + 1, {})

        if bit_extract(fmt, 5, 5) == 1:
            if isinstance(t_val, int) and 0 <= t_val < len(constants):
                t_val = constants[t_val]

        if bit_extract(fmt, 4, 4) == 1:
            if isinstance(e_val, int) and 0 <= e_val < len(constants):
                e_val = constants[e_val]

        if bit_extract(fmt, 7, 7) == 1:
            x_val = {}
            count = rd.read_byte()
            for _n in range(count):
                x_val[_n + 1] = rd.read_uint32()

        instr = {
            "opcode": c_val,
            "next": s_val,
            "A": l_val,
            "B": t_val,
            "C": e_val,
            "extra": x_val,
        }
        instructions.append(instr)

    # Sub-protos: for n=0, b(r(),1), 1 → r() iterations
    num_subprotos = rd.read_uint32()
    subprotos = []
    for _ in range(num_subprotos):
        subprotos.append(parse_proto(rd, consts_out))

    proto = {
        "params": F,
        "numregs": B,
        "consts": constants,
        "upvalues": upvalues,
        "instructions": instructions,
        "subprotos": subprotos,
    }

    return proto


# ═══════════════════════════════════════════════════════════════════
# VM Executor
# ═══════════════════════════════════════════════════════════════════

# Opcode constants (from the dispatch tree in the VM executor)
# These are the values of the 'c' field (stored as instruction[-953553])
# that trigger specific operations.
# The dispatch uses lazy-evaluated thresholds via scramble()

class ReturnSignal(Exception):
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
    if isinstance(v, float):
        if v != v:
            return "-nan"
        if v == float("inf"):
            return "inf"
        if v == float("-inf"):
            return "-inf"
        if v == int(v):
            return str(int(v))
        return str(v)
    if isinstance(v, int):
        return str(v)
    return str(v)


def compute_opcode_thresholds():
    """Pre-compute all lazy opcode thresholds."""
    # From the VM dispatch tree, these are the thresholds used in
    # if/elseif comparisons to route opcodes.
    thresholds = {
        62727361: scramble(62727361, 0),
        509744483: scramble(509744483, 0),
        794859907: scramble(794859907, 0),
        424202806: scramble(424202806, 0),
        350699343: scramble(350699343, 0),
        134990531: scramble(134990531, 0),
        919797218: scramble(919797218, 0),
        556970481: scramble(556970481, 0),
    }

    # Also compute the Calculate() thresholds
    # Calculate = bxor of two values from O_TABLE
    calc_1 = bxor(26600673, O_TABLE[880505119])  # bxor(26600673, 28811554)
    calc_2 = bxor(919068738, O_TABLE[880505119])  # bxor(919068738, 28811554)
    calc_3 = bxor(155228455, O_TABLE[261377791])   # bxor(155228455, 155228450)
    calc_4 = bxor(bxor(592051204, O_TABLE[755266474]), bxor(903245772, O_TABLE["albeVM"]))
    calc_5 = bxor(bxor(284364705, O_TABLE["albeVM"]), 1210963)
    calc_6 = bxor(bxor(42974262, O_TABLE["albeVM"]), 1013789)

    thresholds["calc_1"] = calc_1  # for first Calculate call
    thresholds["calc_2"] = calc_2
    thresholds["calc_3"] = calc_3
    thresholds["calc_4"] = calc_4
    thresholds["calc_5"] = calc_5
    thresholds["calc_6"] = calc_6

    return thresholds


def get_opcode_value(name):
    """Get a specific opcode constant value."""
    # Pre-compute from the scramble function with specific seeds
    known = {
        "TAILCALL": 246784,
        "SET": 1,
        "JMP": 9248,
        "RETURN": 4,
        "GETTABLE_UPVAL": scramble(155228455, O_TABLE[261377791]),
        "FORLOOP": 2296386,
        "CALL1": 7,
        "CONCAT": scramble(991843, 0),  # l[794859907]
        "GETTABLE_IDX": 10,  # > 9
        "SETTABLE_RANGED": scramble(155448444, O_TABLE[261377791]),
        "LEN": scramble(592051204, O_TABLE[755266474]),  # from > calc_4
        "CALL_TAILCALL": scramble(155448444, O_TABLE[261377791]),  # l[350699343]
        "GETTABLE_KEY": scramble(1583139, 0),  # l[134990531]
        "SELF_CALL": scramble(986559, 0),  # l[919797218]
        "FORPREP": scramble(284364705, O_TABLE["albeVM"]),  # from calc_5 branch
        "MOVE": scramble(897315, 0),  # l[556970481]
        "GETUPVAL": scramble(bxor(42974262, O_TABLE["albeVM"]), 1013789),  # from calc_6 branch
        "GETCONST": None,  # from the last else branch
    }
    return known.get(name)


def resolve_int(val):
    """Resolve a value to an integer for register indexing."""
    if isinstance(val, dict):
        return 0
    if isinstance(val, bool):
        return 1 if val else 0
    if isinstance(val, float):
        return int(val)
    if val is None:
        return 0
    return int(val)


class VM:
    def __init__(self, proto, env=None):
        self.proto = proto
        self.env = env or {}

        # Pre-compute thresholds
        self.thresh = compute_opcode_thresholds()

        # Known opcode mappings (resolved at init)
        self.OP_SET = 1
        self.OP_TAILCALL = 246784
        self.OP_JMP = 9248
        self.OP_RETURN = 4
        self.OP_CALL1 = 7
        self.OP_FORLOOP = 2296386
        self.OP_CONCAT = self.thresh.get(794859907, 0)
        self.OP_MOVE = self.thresh.get(556970481, 0)
        self.OP_SELF_CALL = self.thresh.get(919797218, 0)
        self.OP_GETTABLE_KEY = self.thresh.get(134990531, 0)
        self.OP_GETTABLE_IDX = 10
        self.OP_FORPREP = self.thresh.get(424202806, 0)
        self.OP_LEN = self.thresh.get(134990531, 0)
        self.OP_SETRANGED = self.thresh.get(350699343, 0)

    def _get_main_proto(self):
        """Get the main executable sub-proto."""
        p = self.proto
        # The root proto is the wrapper; find the main sub-proto
        if p.get("subprotos") and len(p["subprotos"]) > 0:
            # Usually the first sub-proto is the entry point
            return p["subprotos"][0]
        return p

    def execute(self, *args):
        """Execute the VM and return captured print output."""
        output = []

        def do_print(*print_args):
            parts = [lua_tostring(a) for a in print_args]
            output.append("\t".join(parts))

        main = self._get_main_proto()
        result = self._exec_proto(main, [None] + list(args), self.env, do_print, output)
        return output

    def _exec_proto(self, proto, args, env, print_fn, output, max_steps=500000):
        """Execute a single proto."""
        instrs = proto["instructions"]
        consts = proto["consts"]
        numregs = proto.get("numregs", 256)
        f = numregs  # frame size (used to nil-out registers after calls)

        regs = [None] * max(numregs + 20, 256)

        # Place args in registers
        num_params = proto.get("params", 0)
        c = len(args) - 1  # p("#",...)-1

        for idx in range(min(c, len(regs) - 1)):
            if idx >= num_params:
                regs[idx] = args[idx + 1]
            else:
                regs[idx] = args[idx + 1]

        pc = 0  # instruction index

        for step in range(max_steps):
            if pc >= len(instrs) or instrs[pc] is None:
                break

            ins = instrs[pc]
            op = ins["opcode"]
            A = ins["A"]   # tr32bpYRo field
            B = ins["B"]   # jVDyuN field
            C = ins["C"]   # duvaqQLpM field (jump target or extra)
            extra = ins["extra"]

            # Dispatch
            try:
                result = self._dispatch(op, A, B, C, extra, regs, consts, f, numregs,
                                        print_fn, env, instrs)
                if result == "RETURN":
                    return
                elif isinstance(result, int):
                    pc = result
                else:
                    pc += 1
            except ReturnSignal as e:
                return
            except Exception as ex:
                # Try to continue
                pc += 1

        return

    def _dispatch(self, op, A, B, C, extra, regs, consts, f, numregs,
                  print_fn, env, instrs):
        """Dispatch a single instruction. Returns new PC or None."""

        a_idx = resolve_int(A)
        b_idx = resolve_int(B)
        c_idx = resolve_int(C)

        if op == self.OP_SET:
            # SET: regs[A] = C
            if 0 <= a_idx < len(regs):
                regs[a_idx] = C
            return None

        elif op == self.OP_RETURN:
            return "RETURN"

        elif op == self.OP_TAILCALL:
            # TAILCALL: regs[A](unpack(regs, A+1, C))
            fn = regs[a_idx] if 0 <= a_idx < len(regs) else None
            if fn == print_fn:
                args = []
                c_limit = resolve_int(C) if C is not None else a_idx + 1
                for i in range(a_idx + 1, min(c_limit + 1, len(regs))):
                    args.append(regs[i])
                print_fn(*args)
            return "RETURN"

        elif op == self.OP_CALL1:
            # CALL with 1 arg: regs[A](regs[A+1])
            fn = regs[a_idx] if 0 <= a_idx < len(regs) else None
            if fn == print_fn:
                arg = regs[a_idx + 1] if a_idx + 1 < len(regs) else None
                print_fn(arg)
                regs[a_idx] = None
            elif callable(fn):
                arg = regs[a_idx + 1] if a_idx + 1 < len(regs) else None
                try:
                    result = fn(arg)
                    regs[a_idx] = result
                except:
                    pass
            for i in range(a_idx, f):
                if i < len(regs):
                    regs[i] = None
            return None

        elif op == self.OP_JMP:
            # JMP: unconditional jump to C (next instruction)
            target = resolve_int(C)
            return target

        elif op == self.OP_FORLOOP:
            # FORLOOP
            if 0 <= a_idx < len(regs) - 3:
                step_val = regs[a_idx + 2] if regs[a_idx + 2] is not None else 1
                regs[a_idx] = (regs[a_idx] or 0) + step_val
                limit = regs[a_idx + 1]
                if step_val > 0:
                    if regs[a_idx] <= limit:
                        regs[a_idx + 3] = regs[a_idx]
                        return resolve_int(C)  # jump
                    else:
                        return None
                else:
                    if regs[a_idx] >= limit:
                        regs[a_idx + 3] = regs[a_idx]
                        return resolve_int(C)  # jump
                    else:
                        return None
            return None

        elif op == self.OP_CONCAT:
            # CONCAT: build string from regs[B] to regs[A]
            start = b_idx if b_idx is not None else 0
            end = a_idx if a_idx is not None else 0
            parts = []
            for i in range(min(start, len(regs)), min(end + 1, len(regs))):
                parts.append(lua_tostring(regs[i]))
            if 0 <= a_idx < len(regs):
                regs[a_idx] = "".join(parts)
            return None

        elif op == self.OP_MOVE:
            # MOVE: regs[A] = regs[B]
            if 0 <= a_idx < len(regs) and 0 <= b_idx < len(regs):
                regs[a_idx] = regs[b_idx]
            return None

        elif op == self.OP_GETTABLE_IDX:
            # GETTABLE index: regs[A] = regs[B][C]
            tbl = regs[b_idx] if 0 <= b_idx < len(regs) else None
            if isinstance(tbl, dict) and C is not None:
                regs[a_idx] = tbl.get(C) if isinstance(C, (int, str)) else None
            elif tbl is not None and C is not None:
                try:
                    regs[a_idx] = tbl[C]
                except (KeyError, TypeError, IndexError):
                    regs[a_idx] = None
            return None

        elif op == self.OP_GETTABLE_KEY:
            # GETTABLE with key field: regs[A] = regs[B][A's original value]
            # This is the "elseif(e>9)" branch: n[_[r]]=n[_[d]][_[i]]
            tbl = regs[b_idx] if 0 <= b_idx < len(regs) else None
            key = A  # the 'i' field (tr32bpYRo)
            if isinstance(tbl, dict) and key is not None:
                regs[a_idx] = tbl.get(key) if isinstance(key, (int, str)) else None
            elif tbl is not None and key is not None:
                try:
                    regs[a_idx] = tbl[key]
                except (KeyError, TypeError, IndexError):
                    regs[a_idx] = None
            return None

        elif op == self.OP_SELF_CALL:
            # Self-call: regs[A] = regs[A](regs[A+1]) (return value kept)
            fn = regs[a_idx] if 0 <= a_idx < len(regs) else None
            if fn == print_fn:
                arg = regs[a_idx + 1] if a_idx + 1 < len(regs) else None
                print_fn(arg)
                regs[a_idx] = None
            return None

        elif op == self.OP_LEN:
            # LEN: regs[A] = #regs[B]
            tbl = regs[b_idx] if 0 <= b_idx < len(regs) else None
            if tbl is None:
                regs[a_idx] = 0
            elif isinstance(tbl, (list, str, dict)):
                regs[a_idx] = len(tbl)
            elif isinstance(tbl, table):
                regs[a_idx] = len(tbl)
            else:
                regs[a_idx] = 0
            return None

        elif op == self.OP_SETRANGED:
            # SETTABLE ranged: set table field with range
            # n[_[r]] = n[_[d]]  (just a simple set)
            src_idx = b_idx
            if 0 <= src_idx < len(regs):
                regs[a_idx] = regs[src_idx]
            return None

        else:
            # Unknown opcode - could be a set/get operation
            # Try as SET: regs[A] = C
            if C is not None and 0 <= a_idx < len(regs):
                regs[a_idx] = C
            return None


# ═══════════════════════════════════════════════════════════════════
# High-level deobfuscation
# ═══════════════════════════════════════════════════════════════════
def extract_psu_string(source):
    """Extract the PSU|... string from Lua source code."""
    # Try double quotes
    m = re.search(r'"(PSU\|[^"]+)"', source)
    if m:
        return m.group(1)
    # Try single quotes
    m = re.search(r"'(PSU\|[^']+)'", source)
    if m:
        return m.group(1)
    # Try with )( prefix (from clean chunk_1 format)
    m = re.search(r'\("(PSU\|[^"]+)"\)', source)
    if m:
        return m.group(1)
    return None


def deobfuscate(source_path, output_path=None):
    """Main deobfuscation pipeline."""
    with open(source_path, "r", encoding="utf-8", errors="replace") as f:
        source = f.read()

    # 1. Extract PSU string
    psu_str = extract_psu_string(source)
    if psu_str is None:
        print("ERROR: PSU string not found in source")
        return False

    print(f"[1/4] PSU string extracted: {len(psu_str)} chars")

    # 2. LZW decode
    byte_list, xor_key = lzw_decode(psu_str)
    print(f"[2/4] LZW decoded: {len(byte_list)} bytes (XOR key={xor_key})")

    # 3. Parse binary into VM protos
    rd = XORReader(byte_list, xor_key, start_pos=0)
    try:
        proto = parse_proto(rd)
    except Exception as ex:
        print(f"ERROR during proto parsing: {ex}")
        import traceback
        traceback.print_exc()
        return False

    # Report proto structure
    main_proto = proto
    num_nonnull = sum(1 for i in main_proto["instructions"] if i is not None)
    print(f"[3/4] Proto parsed: {len(main_proto['consts'])} consts, "
          f"{len(main_proto['instructions'])} instructions ({num_nonnull} non-null), "
          f"{len(main_proto['subprotos'])} subprotos")

    # Report subprotos
    for si, sp in enumerate(main_proto["subprotos"][:5]):
        nc = sum(1 for c in sp["consts"] if c is not None)
        ni = sum(1 for i in sp["instructions"] if i is not None)
        print(f"      sub[{si}]: {len(sp['consts'])} consts ({nc} non-nil), "
              f"{len(sp['instructions'])} instrs ({ni} non-null)")
    if len(main_proto["subprotos"]) > 5:
        print(f"      ... and {len(main_proto['subprotos']) - 5} more subprotos")

    # 4. Execute VM
    print("[4/4] Executing VM...")
    vm = VM(proto)

    # Build a minimal environment for the VM
    env = {"print": lambda *args: None}  # placeholder, overridden in execute

    captured = vm.execute()

    if not captured:
        print("  VM produced no output (captured nothing from print)")
        return False

    # Build output
    result_lines = captured

    # Determine output path
    if output_path is None:
        base = source_path.rsplit(".chunk_1.clean.lua", 1)[0] \
            if ".chunk_1.clean.lua" in source_path \
            else source_path.rsplit(".lua", 1)[0]
        output_path = base + ".decrypted.lua"

    with open(output_path, "w") as f:
        for line in result_lines:
            f.write(line + "\n")

    print(f"\n=== Deobfuscated Output ({len(result_lines)} line(s)) ===")
    for i, line in enumerate(result_lines):
        print(f"  [{i}] {line}")
    print(f"\nSaved to: {output_path}")
    return True


# ═══════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <chunk1_source.lua> [--output out.lua]")
        sys.exit(1)

    input_path = sys.argv[1]
    out_path = None
    if "--output" in sys.argv:
        idx = sys.argv.index("--output")
        out_path = sys.argv[idx + 1]

    success = deobfuscate(input_path, out_path)
    sys.exit(0 if success else 1)

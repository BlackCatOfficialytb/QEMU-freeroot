"""Disassemble psu_mode print_hi.proto.json into a human-readable listing.

Field alias map (derived from wrapper):
  -844411 = opcode
  36910   = operand A
  69653   = operand B (also called r/C-index in some ops)
  -471351 = operand C
  HdV88T  = dest register / slot (operand "n" in dispatch)
  V760m   = next-instruction pointer

Opcodes (basic, decoded from dispatch loop):
  0  CALL_VOID    l[A](l[A+1 .. B])  ; no return value
  1  RETURN       return l[A .. top]
  2  LOADK        l[A] = K
  3  CALL_KEEP    l[A] = l[A](l[A+1 .. B])
  4  FUSED_16     16 sub-ops in sequence (MOVE, LOADK, GETGLOBAL, GETTABLE, ...)
  5  RETURN_VOID  return
  6  CLOSURE      l[A] = closure(sub_proto[B])
  7  FORPREP-num  numeric for loop init/check at l[A..A+3], jump to NEXT on done
  8  NEWTABLE_256 l[A] = {} (preallocated)
  9  VARARG       copy varargs into l[A..]
  10 FUSED_49a    49 LOADK in a row
  11 FUSED_49b    49 LOADK in a row
  12 FORLOOP      numeric for loop step
  13 TAILRET      return l[A..top]
  14 CALL1        l[A] = l[A](l[A+1])
  15 NEWTABLE     l[A] = {} (size from B)
  16 FUSED_NT     NEWTABLE then 49 LOADKs
  17 CONCAT       l[A] = l[B] .. l[B+1] .. l[C]
  18 FUSED_7      7-op sequence (mixed)
  19 JMP          i = NEXT
  20 CALL_VOID1   l[A](l[A+1])
  21 LEN          l[A] = #l[B]
  22 MOVE         l[A] = l[B]
  23 GETTABLE_K   l[A] = l[B][C]   (C is constant)
  24 GETGLOBAL    l[A] = _ENV[B]
  25 GETTABLE_R   l[A] = l[B][l[C]]
  26 NOP
  27 FUSED_49c    49 LOADK in a row
  28 SETLIST      l[A][stride*(C-1)+i] = l[A+i] for i=1..B-A
"""
import json
import pathlib
import sys

ROOT = pathlib.Path(r'E:/dec_bot2/psu_mode')
PROTO = ROOT / 'print_hi.proto.json'
OUT = ROOT / 'print_hi.disasm.txt'

OP_NAMES = {
    0: 'CALL_VOID', 1: 'RETURN', 2: 'LOADK', 3: 'CALL', 4: 'FUSED_16', 5: 'RETURN_VOID',
    6: 'CLOSURE', 7: 'FORPREP', 8: 'NEWTABLE_256', 9: 'VARARG', 10: 'FUSED_49a',
    11: 'FUSED_49b', 12: 'FORLOOP', 13: 'TAILRET', 14: 'CALL1', 15: 'NEWTABLE',
    16: 'FUSED_NT', 17: 'CONCAT', 18: 'FUSED_7', 19: 'JMP', 20: 'CALL_VOID1',
    21: 'LEN', 22: 'MOVE', 23: 'GETTABLE_K', 24: 'GETGLOBAL', 25: 'GETTABLE_R',
    26: 'NOP', 27: 'FUSED_49c', 28: 'SETLIST',
}


def load_graph(p):
    with open(p, 'r', encoding='utf-8') as f:
        d = json.load(f)
    return d['nodes'], d['root']


def deref(node, key, nodes):
    v = node.get(key)
    if isinstance(v, dict) and '$ref' in v:
        return nodes[str(v['$ref'])]
    return v


def get_value(v, nodes):
    if isinstance(v, dict) and '$ref' in v:
        return ('table', nodes[str(v['$ref'])])
    return ('val', v)


def fmt_operand(v, nodes, ref_to_id=None):
    if isinstance(v, dict) and '$ref' in v:
        rid = v['$ref']
        if ref_to_id is not None and rid in ref_to_id:
            return f'->[{ref_to_id[rid]}]'
        return f'<table#{rid}>'
    if isinstance(v, str):
        return repr(v)
    return str(v)


def disasm_proto(proto, nodes, depth=0, name='main'):
    indent = '  ' * depth
    out = []
    instr_arr = deref(proto, '356210', nodes)
    subprotos = deref(proto, 'ifn4Bj0', nodes)
    numreg = proto.get('g1pgau', '?')
    numparams = proto.get('477217', '?')
    out.append(f'{indent}== proto {name} (regs={numreg}, params={numparams}) ==')
    if not isinstance(instr_arr, dict):
        out.append(f'{indent}  (no instruction array)')
        return out

    # Build map: instruction-table-ref -> array index, for resolving JMP/FOR targets.
    keys = sorted((k for k in instr_arr.keys() if k.lstrip('-').isdigit()), key=int)
    ref_to_id = {}
    for k in keys:
        v = instr_arr.get(k)
        if isinstance(v, dict) and '$ref' in v:
            ref_to_id[v['$ref']] = k

    for k in keys:
        ins = deref(instr_arr, k, nodes)
        if not isinstance(ins, dict):
            continue
        op = ins.get('-844411', '?')
        A = ins.get('36910')
        B = ins.get('69653')
        C = ins.get('-471351')
        slot = ins.get('HdV88T')
        nxt = ins.get('V760m')
        if isinstance(nxt, dict) and '$ref' in nxt:
            nxt_id = ref_to_id.get(nxt['$ref'], f'#{nxt["$ref"]}')
        else:
            nxt_id = None
        opname = OP_NAMES.get(op, f'OP{op}')
        a_repr = fmt_operand(A, nodes, ref_to_id)
        b_repr = fmt_operand(B, nodes, ref_to_id)
        c_repr = fmt_operand(C, nodes, ref_to_id)
        next_repr = f' next=[{nxt_id}]' if nxt_id is not None else ''
        out.append(
            f'{indent}  [{k:>3}] (R{slot}) {opname:<13} A={a_repr:<35} B={b_repr:<15} C={c_repr}{next_repr}'
        )

    if isinstance(subprotos, dict):
        sub_keys = sorted(
            (k for k in subprotos.keys() if k.lstrip('-').isdigit()), key=int
        )
        for k in sub_keys:
            sp = deref(subprotos, k, nodes)
            if isinstance(sp, dict):
                out.extend(disasm_proto(sp, nodes, depth + 1, f'{name}.sub[{k}]'))
    return out


def main():
    nodes, root_id = load_graph(PROTO)
    root = nodes[str(root_id)]
    lines = disasm_proto(root, nodes)
    OUT.write_text('\n'.join(lines), encoding='utf-8')
    print(f'wrote {OUT} ({len(lines)} lines)')
    print('\n'.join(lines[:60]))


if __name__ == '__main__':
    main()

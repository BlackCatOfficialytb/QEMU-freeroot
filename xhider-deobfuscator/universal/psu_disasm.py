"""Universal disassembler for XHider PSU mode family (psu_mode, psu_mid_mode, ...).

Each PSU variant uses different table-key names but the same VM topology. We auto-detect
the field-role mapping by parsing the *VM closure* in the original .lua source, then
disassemble the dumped proto.json.

VM closure fingerprint (pattern, with K standing for any unique key literal):
    function E(e,o,f,...)
      local m = e[K_subprotos]
      local r = e[K_instructions]
      local o = e[K_???]               -- some scalar
      local n = 0
      local a = e[K_constants]
      local c = e[K_???]               -- some scalar
      return(function(...)
        ...
        local d = o[n]                 -- first instruction (o is instructions in this scope!)
        ...
        local l = K_op_or_slot         -- numeric/string literal — operand-A field key
        local w = K_opcode             -- operand-OPCODE field key
        local t = K_next               -- next-instruction field key
        local n = K_B                  -- operand-B field key
        local i = K_C                  -- operand-C field key
        ...
        while(true) do
          local e = d
          local c = e[w]               -- read opcode
          d = e[t]                     -- advance
          ...                         -- dispatch on c
        end
      end)
    end
"""
import json
import re
import pathlib
import sys


# Default OP table for psu_mode (the one we fully decoded). Other variants override.
OP_NAMES_PSU = {
    0: 'CALL_VOID', 1: 'RETURN', 2: 'LOADK', 3: 'CALL', 4: 'FUSED_16', 5: 'RETURN_VOID',
    6: 'CLOSURE', 7: 'FORPREP', 8: 'NEWTABLE_256', 9: 'VARARG', 10: 'FUSED_49a',
    11: 'FUSED_49b', 12: 'FORLOOP', 13: 'TAILRET', 14: 'CALL1', 15: 'NEWTABLE',
    16: 'FUSED_NT', 17: 'CONCAT', 18: 'FUSED_7', 19: 'JMP', 20: 'CALL_VOID1',
    21: 'LEN', 22: 'MOVE', 23: 'GETTABLE_K', 24: 'GETGLOBAL', 25: 'GETTABLE_R',
    26: 'NOP', 27: 'FUSED_49c', 28: 'SETLIST',
}

OP_NAMES_PSU_MID = {
    0: 'FUSED_49a', 1: 'LOADK', 2: 'CLOSURE', 3: 'NEWTABLE', 4: 'GETTABLE_K',
    5: 'FORPREP', 6: 'CALL_VOID', 7: 'CALL', 8: 'FUSED_14', 9: 'SETLIST',
    10: 'RETURN', 11: 'GETGLOBAL', 12: 'FUSED_7', 13: 'CALL1', 14: 'FUSED_49b',
    15: 'JMP', 16: 'GETTABLE_R', 17: 'FUSED_49c', 18: 'CALL_VOID1', 19: 'MOVE',
    20: 'FORLOOP', 21: 'NEWTABLE_256', 22: 'CONCAT', 23: 'VARARG', 24: 'NOP',
    25: 'LEN', 26: 'RETURN_VOID', 27: 'FUSED_49d',
}

OP_TABLES = {
    'psu_mode': OP_NAMES_PSU,
    'psu_mid_mode': OP_NAMES_PSU_MID,
}


def lit(s, var):
    """Return a regex fragment that captures the LITERAL passed to `local <var>=<LITERAL>;`.

    The literal can be a number, an identifier-quoted string in [], a single-/double-quoted
    string, or `e[..]` (we don't unwrap those — we just take the source literal).
    """
    return rf'local {re.escape(var)}=([^;]+?);'


def resolve_e_lookup(expr, e_map):
    """If expr is `e[KEY]` or `e.KEY`, return the literal key value (we want the
    table-key, NOT the dereferenced value). Otherwise return expr unchanged."""
    expr = expr.strip()
    # e[(NUMBER)]
    m = re.match(r'e\[\(?(-?\d+)\)?\]$', expr)
    if m:
        return int(m.group(1))
    m = re.match(r'e\["([^"]+)"\]$', expr)
    if m:
        return m.group(1)
    m = re.match(r"e\['([^']+)'\]$", expr)
    if m:
        return m.group(1)
    m = re.match(r'e\.(\w+)$', expr)
    if m:
        return m.group(1)
    # numeric literal (possibly parenthesised)
    m = re.match(r'\(?(-?\d+(?:\.\d+)?)\)?$', expr)
    if m:
        try:
            return float(m.group(1)) if '.' in m.group(1) else int(m.group(1))
        except ValueError:
            return expr
    # string literal
    m = re.match(r'"([^"]*)"$', expr)
    if m:
        return m.group(1)
    m = re.match(r"'([^']*)'$", expr)
    if m:
        return m.group(1)
    # Negation of e[lookup]: -<E_LOOKUP>
    m = re.match(r'-(.+)$', expr)
    if m:
        inner = resolve_e_lookup(m.group(1), e_map)
        if isinstance(inner, (int, float)):
            return -inner
    return expr


def extract_field_keys(lua_src):
    """Find the inner function E (or named differently) -> return(function(...)) closure
    and read its key locals."""
    # The closure starts with `local function NAME(e,o,f,...)`
    m = re.search(r'local function (\w+)\(e,o,f,\.\.\.\)', lua_src)
    if not m:
        # try variant with different first-arg names
        m = re.search(r'local function (\w+)\(\w,\w,\w,\.\.\.\)return\(function', lua_src)
    assert m, 'cannot locate VM closure'
    fn_name = m.group(1)

    # Find the inner `return(function(...)` that follows
    fn_start = m.end()
    inner_m = re.search(r'return\(function\(\.\.\.\)', lua_src[fn_start:])
    assert inner_m, 'cannot find inner return(function(...))'
    inner_start = fn_start + inner_m.end()

    # In the next ~3500 chars, find local definitions of single-letter names l, w, t, n, i
    # via lit() patterns. Take the last definition of each (in case of redefinitions).
    body = lua_src[inner_start:inner_start + 4000]
    keys = {}
    # Order matters: we want the LAST `local <name>=<literal>;` before `while(true)do`
    while_pos = body.find('while(true)do')
    if while_pos == -1:
        while_pos = len(body)
    region = body[:while_pos]
    for var in ['l', 'w', 't', 'n', 'i']:
        last = None
        for mm in re.finditer(r'local\s+' + var + r'\s*=([^;]+);', region):
            last = mm.group(1).strip()
        if last is None:
            continue
        keys[var] = resolve_e_lookup(last, None)
    return fn_name, keys


def extract_proto_keys(lua_src):
    """Identify the proto-builder return-table keys for instructions/subprotos/constants
    by analyzing the *runner's* inner closure usage patterns.

    The runner closure looks like:
        local function FN(e, ARG2, ARG3, ...)
          local <V_subprotos> = e[K_subprotos]
          local <V_regs>      = e[K_regs]      -- a number
          local <V_instrs>    = e[K_instrs]
          local <V_zero>      = 0              -- (or e[K_zero])
          local <V_consts>    = e[K_consts]
          local <V_other>     = e[K_other]     -- another scalar, ignored
          return(function(...)
            ...
            local <D> = <V_instrs>[<V_zero>]   -- first instruction
            ...
            -- inside dispatch:
            <regs>[e[<L>]] = <V_consts>[e[<N>]]      -- LOADK from constants
            <regs>[e[<L>]] = E(<V_subprotos>[e[<N>]], (nil), <ARG3>)  -- CLOSURE
            for e = ?+1, <V_regs> do <regs>[e]=nil end   -- regs cap
          end)
        end
    """
    # Locate the runner FN
    m = re.search(r'local function (\w+)\(e,(\w),(\w),\.\.\.\)', lua_src)
    if not m:
        m = re.search(r'local function (\w+)\(e,(\w),\.\.\.\)', lua_src)
    assert m, 'cannot find runner header'
    fn_name = m.group(1)
    # Header (locals) up to `return(function(...)`
    after = lua_src[m.end():]
    inner = after.find('return(function(...)')
    assert inner != -1, 'cannot find runner inner closure'
    header = after[:inner]
    locals_ = {}
    for mm in re.finditer(r'local\s+(\w+)\s*=\s*([^;]+);', header):
        locals_[mm.group(1)] = mm.group(2).strip()

    # Body of inner closure (next ~6000 chars)
    body = after[inner + len('return(function(...)'):inner + 8000]

    # Find subprotos: pattern `<NAME>(<V_subprotos>[e[...]],(nil),...)` where NAME == fn_name
    # The CLOSURE op does: o[e[l]]=E(m[e[n]],(nil),f);
    sub_m = re.search(re.escape(fn_name) + r'\((\w+)\[e\[\w\]\],\(nil\)', body)
    v_subprotos = sub_m.group(1) if sub_m else None

    # Find constants: pattern `<X>[e[<B>]]=<V_consts>[e[<N>]]`
    # Look for `=(\w+)\[e\[\w\]\];` pattern that appears in MOVE-style fused chains.
    # Easier: any `(\w+)\[e\[\w\]\]` on RHS used as value, where the var matches a local.
    # Use the LOADK pattern: `<X>[e[<L>]]=<V_consts>[e[<N>]]`
    cons_matches = re.findall(r'=(\w+)\[e\[\w\]\];', body)
    # The most common RHS table-lookup is constants (LOADK is the most frequent op).
    from collections import Counter
    counts = Counter(cons_matches)
    # Filter out vars that we recognize as not-constants
    v_consts = None
    for v, c in counts.most_common():
        # exclude env (`f`), subprotos (we know it), regs (we don't know yet)
        if v == v_subprotos:
            continue
        v_consts = v
        break

    # Find regs upper bound: `for e=<X>+1,<V_regs> do <Y>[e]=nil end`
    reg_m = re.search(r'for\s+\w+=\w+\+1,(\w+)\s+do\s+(\w+)\[\w+\]=nil', body)
    v_regs = reg_m.group(1) if reg_m else None
    v_regsfile = reg_m.group(2) if reg_m else None

    # Find instructions: `local <V_instr>[<V_zero>]` is the very first table read from a local
    # Easier: in body, the first `<X>[<Y>]` after `local d=` is the instruction read.
    # `local <D>=<V_instr>[<V_zero>];`
    instr_m = re.search(r'local\s+\w+=(\w+)\[(\w+)\];', body[:600])
    v_instrs = instr_m.group(1) if instr_m else None

    roles = {}
    if v_subprotos and v_subprotos in locals_:
        roles['subprotos'] = resolve_e_lookup(locals_[v_subprotos], None)
    if v_instrs and v_instrs in locals_:
        roles['instructions'] = resolve_e_lookup(locals_[v_instrs], None)
    if v_consts and v_consts in locals_:
        roles['constants'] = resolve_e_lookup(locals_[v_consts], None)
    if v_regs and v_regs in locals_:
        roles['regs_top'] = resolve_e_lookup(locals_[v_regs], None)
    return roles


def stringify_key(v):
    if isinstance(v, (int, float)):
        # JSON dump uses string repr of these via Lua tostring
        if isinstance(v, float) and v == int(v) and abs(v) < 1e15:
            return str(int(v))
        return str(v)
    return str(v)


# For ops that index the constants pool, mark which fields are pool indices.
# Operands: 'A' = the field labeled A in our output (= e[n] in psu_mid)
#           'C' = the field labeled C in our output (= e[i] in psu_mid)
CONST_INDEXED = {
    'psu_mid_mode': {
        # opcode -> set of fields that are constant-pool indices
        1: {'A'},
        11: {'A'},
        4: {'C'},      # GETTABLE_K: C is the const index
        # Other LOADK-like ops in fused chains too, but fused ops are pre-collapsed.
    },
}


def disasm(lua_path: pathlib.Path, json_path: pathlib.Path, out_path: pathlib.Path, op_table=None, const_indexed=None):
    src = lua_path.read_text(encoding='utf-8', errors='replace')
    fn_name, vm_keys = extract_field_keys(src)
    proto_keys = extract_proto_keys(src)
    if op_table is None:
        op_table = OP_NAMES_PSU
    if const_indexed is None:
        const_indexed = {}

    # Map roles to JSON keys:
    field = {
        'opcode': stringify_key(vm_keys['w']),
        'A': stringify_key(vm_keys['l']),
        'B': stringify_key(vm_keys['n']),
        'C': stringify_key(vm_keys['i']),
        'next': stringify_key(vm_keys['t']),
    }
    proto = {
        'instructions': stringify_key(proto_keys['instructions']),
        'subprotos': stringify_key(proto_keys['subprotos']),
        'constants': stringify_key(proto_keys.get('constants', '')),
    }
    print(f'  VM closure: {fn_name}(...)')
    print(f'  field map: {field}')
    print(f'  proto map: {proto}')

    with open(json_path, 'r', encoding='utf-8') as f:
        d = json.load(f)
    nodes = d['nodes']

    def deref(node, key):
        v = node.get(key)
        if isinstance(v, dict) and '$ref' in v:
            return nodes[str(v['$ref'])]
        return v

    def fmt_op(v, ref_to_id):
        if isinstance(v, dict) and '$ref' in v:
            rid = v['$ref']
            return f'->[{ref_to_id.get(rid, "#" + str(rid))}]'
        if isinstance(v, str):
            return repr(v)
        return str(v)

    def walk_proto(p, depth, name, lines):
        indent = '  ' * depth
        instr_arr = deref(p, proto['instructions'])
        subprotos = deref(p, proto['subprotos'])
        consts_arr = deref(p, proto['constants']) if proto.get('constants') else None
        lines.append(f'{indent}== proto {name} ==')
        if not isinstance(instr_arr, dict):
            lines.append(f'{indent}  (no instruction array)')
            return

        def lookup_const(idx):
            """Resolve a constants-pool index to its value if available."""
            if not isinstance(consts_arr, dict):
                return None
            v = consts_arr.get(str(idx))
            if v is None:
                return None
            if isinstance(v, dict) and '$ref' in v:
                return f'<table#{v["$ref"]}>'
            return v

        keys = sorted(
            (k for k in instr_arr.keys() if k.lstrip('-').isdigit()), key=int
        )
        ref_to_id = {}
        for k in keys:
            v = instr_arr.get(k)
            if isinstance(v, dict) and '$ref' in v:
                ref_to_id[v['$ref']] = k

        for k in keys:
            ins = deref(instr_arr, k)
            if not isinstance(ins, dict):
                continue
            op = ins.get(field['opcode'], '?')
            slot = ins.get(field['A'])
            A = ins.get(field['B'])
            C = ins.get(field['C'])
            opname = op_table.get(op, f'OP{op}') if isinstance(op, int) else f'OP{op}'

            # Dereference constant-pool indices for this op.
            const_fields = const_indexed.get(op, set())
            a_repr = fmt_op(A, ref_to_id)
            c_repr = fmt_op(C, ref_to_id)
            if 'A' in const_fields and isinstance(A, int):
                v = lookup_const(A)
                if v is not None:
                    a_repr = f'K[{A}]={v!r}'
            if 'C' in const_fields and isinstance(C, int):
                v = lookup_const(C)
                if v is not None:
                    c_repr = f'K[{C}]={v!r}'

            lines.append(
                f'{indent}  [{k:>3}] (R{slot}) {opname:<14} A={a_repr:<40} C={c_repr:<25}'
            )

        if isinstance(subprotos, dict):
            sub_keys = sorted(
                (k for k in subprotos.keys() if k.lstrip('-').isdigit()), key=int
            )
            for k in sub_keys:
                sp = deref(subprotos, k)
                if isinstance(sp, dict):
                    walk_proto(sp, depth + 1, f'{name}.sub[{k}]', lines)

    root = nodes[str(d['root'])]
    lines = []
    walk_proto(root, 0, 'main', lines)
    out_path.write_text('\n'.join(lines), encoding='utf-8')
    print(f'  wrote {out_path} ({len(lines)} lines)')


def main():
    if len(sys.argv) < 2:
        target = 'psu_mid_mode'
    else:
        target = sys.argv[1]
    base = pathlib.Path(r'E:/dec_bot2') / target
    op_table = OP_TABLES.get(target, OP_NAMES_PSU)
    const_idx = CONST_INDEXED.get(target, {})
    disasm(
        base / 'print_hi.lua',
        base / 'print_hi.proto.json',
        base / 'print_hi.disasm.txt',
        op_table=op_table,
        const_indexed=const_idx,
    )


if __name__ == '__main__':
    main()

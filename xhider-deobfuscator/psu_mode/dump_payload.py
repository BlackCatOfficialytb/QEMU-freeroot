"""Patch psu_mode/print_hi.lua to dump (1) the LZW bytecode and (2) the parsed proto as JSON.

The proto is a graph (instructions are linked-listed via V760m AND held by an array).
Use an iterative serializer that assigns ids to tables and emits a flat dict {id: fields}.
"""
import subprocess
import pathlib
import os
import sys

ROOT = pathlib.Path(os.environ.get('PSU_MODE_DIR', pathlib.Path(__file__).parent))
SRC = ROOT / 'print_hi.lua'
PATCHED = ROOT / 'print_hi.dump.lua'
DUMP_BYTECODE = ROOT / 'print_hi.bytecode.bin'
DUMP_PROTO = ROOT / 'print_hi.proto.json'

# Auto-detect Lua with QEMU cross-arch support
LUA = os.environ.get('LUA', r'E:/lua5.5/lua55.exe')


def inject(s, marker, code):
    idx = s.find(marker)
    assert idx != -1, f'marker not found: {marker[:60]!r}'
    return s[:idx] + code + s[idx:]


# Lua flat serializer: BFS the graph, assign integer IDs, write as JSON.
LUA_FLAT_SER = r"""
local function flatser(root)
  local ids = {}
  local order = {}
  local function getid(v)
    if type(v) ~= 'table' then return nil end
    local id = ids[v]
    if id then return id end
    id = #order + 1
    ids[v] = id
    order[id] = v
    return id
  end
  getid(root)
  local function jstr(s)
    local r = {'"'}
    for i = 1, #s do
      local b = string.byte(s, i)
      if b == 34 then r[#r+1] = '\\"'
      elseif b == 92 then r[#r+1] = '\\\\'
      elseif b == 10 then r[#r+1] = '\\n'
      elseif b == 13 then r[#r+1] = '\\r'
      elseif b == 9 then r[#r+1] = '\\t'
      elseif b < 32 or b == 127 then r[#r+1] = string.format('\\u%04x', b)
      else r[#r+1] = string.char(b) end
    end
    r[#r+1] = '"'
    return table.concat(r)
  end
  local function jval(v)
    local tv = type(v)
    if tv == 'nil' then return 'null'
    elseif tv == 'boolean' then return tostring(v)
    elseif tv == 'number' then
      if v ~= v then return '"NaN"'
      elseif v == math.huge then return '"Inf"'
      elseif v == -math.huge then return '"-Inf"'
      elseif v == math.floor(v) and math.abs(v) < 1e15 then
        return string.format('%d', v)
      else
        return string.format('%.17g', v)
      end
    elseif tv == 'string' then return jstr(v)
    elseif tv == 'table' then return string.format('{"$ref":%d}', getid(v))
    else return string.format('"<%s>"', tv) end
  end
  local out = {'{"root":1,"nodes":{'}
  local i = 1
  while i <= #order do
    local node = order[i]
    if i > 1 then out[#out+1] = ',' end
    out[#out+1] = string.format('"%d":{', i)
    local first = true
    for k, v in pairs(node) do
      if not first then out[#out+1] = ',' end
      first = false
      out[#out+1] = jstr(tostring(k))
      out[#out+1] = ':'
      out[#out+1] = jval(v)
    end
    out[#out+1] = '}'
    i = i + 1
    for _, v in pairs(node) do
      if type(v) == 'table' then getid(v) end
    end
  end
  out[#out+1] = '}}'
  return table.concat(out)
end
"""


def patch_source(s: str) -> str:
    bcpath = str(DUMP_BYTECODE).replace('\\', '/')
    propath = str(DUMP_PROTO).replace('\\', '/')

    seam1 = ';local function o'
    code1 = (
        ' do local _f=io.open([[' + bcpath + ']],[[wb]]) _f:write(u) _f:close() end '
    )
    s = inject(s, seam1, code1)

    needle = 'return p(X(),{},D())(...);'
    repl = (
        'do local proto=X() ' +
        LUA_FLAT_SER.replace('\n', ' ') +
        ' local data = flatser(proto) '
        'local f=io.open([[' + propath + ']],[[w]]) '
        'f:write(data) f:close() '
        'os.exit(0) end '
    )
    s = s.replace(needle, repl, 1)
    assert 'flatser' in s, 'replacement failed'
    return s


def _get_lua_cmd(script):
    """Build command to run Lua, using QEMU if cross-arch."""
    # Add parent dir to sys.path so we can import qemu_helper
    project_root = pathlib.Path(__file__).parent.parent
    if str(project_root) not in sys.path:
        sys.path.insert(0, str(project_root))
    try:
        from qemu_helper import get_run_command
        return get_run_command(LUA, [script])
    except ImportError:
        # qemu_helper not available, run directly
        return [LUA, script]


def main():
    src = SRC.read_text(encoding='utf-8')
    patched = patch_source(src)
    PATCHED.write_text(patched, encoding='utf-8')
    print(f'patched -> {PATCHED} (len={len(patched)})')
    for p in (DUMP_BYTECODE, DUMP_PROTO):
        if p.exists():
            p.unlink()
    try:
        cmd = _get_lua_cmd(str(PATCHED))
        print(f'Running: {" ".join(cmd)}')
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
        print('rc:', r.returncode)
        if r.stdout:
            print('stdout:', r.stdout[:1500])
        if r.stderr:
            print('stderr:', r.stderr[:1500])
    except subprocess.TimeoutExpired:
        print('TIMEOUT')
    print()
    for p in (DUMP_BYTECODE, DUMP_PROTO):
        if p.exists():
            print(f'  {p.name}: {p.stat().st_size} bytes')
        else:
            print(f'  {p.name}: MISSING')


if __name__ == '__main__':
    main()

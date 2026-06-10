# psu_max Cracking Strategy

> **If psu_max is fully cracked, delete this file.** It is a working notebook
> for the lone holdout mode and has no value once the work is done.

## Status

`psu_max_mode/` is the only XHider mode in the repo we cannot dynamic-dump.
Everything else (`m1`, `m2`, `m3`, `basic`, `hard`, `normal`, `ibs`, `ibv`,
`mid_mode`, `evil`, `strong`, `env`, `max_security`, `basic_b1`, `psu`,
`psu_mid`, `psu_hard`) yields its plaintext output via
`env_mode/hook_universal.lua`.

`psu_max` errors with:

```
Error executing: [string "local d=(function(n,...)return n(...);end)l..."]:1:
  attempt to call global 'Calculate' (a nil value)
```

`Calculate` is a Roblox-runtime global the obfuscator expects to exist.
Outside Roblox it has to be reconstructed.

## What we already know

### Outer wrapper (`print_hi.lua`, `fibo.lua`)

Pure metatable-trap junk. Every literal is replaced with an expression like
`(not n)._`, `((-#(not n)))._`, `((-#{(#n)._;[(((-(not n)))._)]=((not n))();}))._`, etc.
The script defines a chain of nested `local function n(...)` that all share
the same name `n`, then evaluates these expressions against a custom
metatable. There are no string literals at all, no obvious entry-point name.

The wrapper does exactly one thing externally observable: it calls
`loadstring(<70929-byte chunk>)` and runs the result.

You can dump the inner chunk with:
```
cd D:/dec_bot2/psu_max_mode
XHIDER_DUMP_CHUNKS=1 lua5.1 ../env_mode/hook_universal.lua print_hi.lua
# → print_hi.lua.chunk_1.lua  (70929 bytes)
```

### Inner chunk (chunk_1)

Begins with the same prelude as `max_security_mode/print_hi.lua`:

```lua
local d=(function(n,...)return n(...);end)
local n=(function(n,o)return(n<o);end)        -- alias for <
local n=(function(o,n)return(o%n);end)        -- aliases for %
local Y=(function(o,n)return(o..n);end)       --                ..
local b=(function(o,n)return(o-n);end)        --                -
…
local A=(function(o,n)return(o+n);end)        --                +
return(function(o,...)
  local x="This file was obfuscated Fork By Xhider | https://discord.gg/hATuHQaQRb"
  local V=((getfenv)or(function(...)return(_ENV);end))
  local l,a,_=({}),(""),(V(1))
  local e=((_[""..o[255806744].."\105\116\51"..o[303909627]])
        or (_["\98\105"..o[676273207]])
        or ({}))                              -- → bit32
  local t=(((e)and(e["\98\120"..o[926356572]..o[828614386]]))
        or  pure_lua_bxor)                    -- → bxor
  …
```

The byte escapes decode to the strings `it3`, `bi`, `bx` — so:

* `_["?it3?"]` = `_G["bit32"]`  (with `?` being characters from `o`)
* `_["bi?"]`   = `_G["bit"]`    (Lua 5.1 fallback)
* `e["bx??"]`  = `bit32.bxor`

The values `o[255806744]`, `o[303909627]`, `o[676273207]`, `o[926356572]`,
`o[828614386]` must yield characters `b`, `2`, `b`, `i`, `t`, `o`, `r`, `x`
in the right places.

`Calculate(...)` is then called ~10× with two integer args inside an opcode-
dispatch tree (`if e<=Calculate(a,b) then … elseif e==Calculate(c,d) then …`),
which is exactly how `bit32.band` is used as a comparator in similar VMs.
**`Calculate` is almost certainly `bit32.band` installed under that name in
the env.**

But naive `Calculate=bit32.band` injection fails — the wrapper raises
`attempt to index local '_' (a number value)`. So the wrapper is doing more
than just defining `Calculate`: it's also installing the table `o` with the
right entries at those big-integer keys, and probably setting `_` (the env)
to something specific too.

## The "PSU + Max-Security combination" idea

User observation (2026-05-01): psu_max is structurally a PSU mode wrapping a
max_security_mode payload, so combining the existing crackers might work.

### Compare

* `max_security_mode/print_hi.lua` line 3 begins:
  ```
  return(function(...)local K,H,V,z,e,c,R,T,r,p,v,a,Y,F=string.byte,string.sub,
    string.char,string.gsub,string.rep,setmetatable,pcall,type,tostring,assert,
    loadstring,unpack,string.pack,{}local M={}local i=bit32 …
  ```
* `psu_max chunk_1` begins:
  ```
  local d=(function(n,...)return n(...);end)local n=(function(n,o)return(n<o);end)
  …
  return(function(o,...) local x="This file was obfuscated Fork By Xhider …"
  local V=((getfenv)or(function(...)return(_ENV);end))
  local l,a,_=({}),(""),(V(1))
  local e=((_[""..o[255806744].."\105\116\51"..o[303909627]]) … → bit32
  ```

Both grab `bit32` (or its bxor) early and use a function-table dispatch,
**but the prelude shapes are different** — max_security inlines binop
references via `string.byte,string.sub,…`, while psu_max chunk_1 wraps each
binop in its own `function(o,n) return o ⊕ n end` and pulls `o[bigint]`
characters at runtime.

So the two are sibling obfuscators built on the same VM family, not nested
versions of each other. Combining the existing decoders verbatim won't work
— but their VM dispatch shape (`if e<=X(a,b) then … elseif e==Y(c,d)`) is
the same, which is the encouraging signal.

## Strategy ladder (cheapest → hardest)

### 1. Find the canonical PSU table layout

Diff psu / psu_mid / psu_hard / psu_max wrappers. The first three crack with
the universal hook because their outer wrapper just runs a small VM that
calls `print` directly. psu_max's outer wrapper instead `loadstring`s a
70929-byte body. **Look for what's different about the outer wrapper**: is
it the same VM emitting the same opcode table but compiled to "build chunk
+ loadstring it" instead of "execute opcodes directly"? If so, one debug
hook on the outer's opcode dispatcher will tell us how `o`, `Calculate`,
and `_G` are populated.

Concrete first step: dump the outer wrapper's `_G` immediately before its
first `loadstring` call. Use `debug.sethook("c", call_hook)` and intercept
when `loadstring` is on the stack — at that point inspect the locals and
upvalues of the calling frame.

### 2. Stub `Calculate` smarter

Naive `Calculate = bit32.band` fails because `_` becomes a number, meaning
something downstream is computing on the wrong return type. Try:

* `Calculate = function(a, b) return bit32.band(a, b) end` — wrap in a Lua
  closure so identity / __metatable checks don't see it as a C function.
* `Calculate = function(a, b) return a end` — first-arg passthrough; will
  steer the VM down a fixed branch and may at least let it print one
  observable thing.
* `Calculate = bit32.bxor`, `bit32.bor`, `bit32.bnot` — try each.

If any of these reaches a `print` call, we win.

### 3. Sniff the metatable trap

The outer's metatable on `n` is what produces all values. Replace global
`setmetatable` with a wrapper that tees every set/get on the metatable:

```lua
local original_setmetatable = setmetatable
setmetatable = function(t, mt)
  if mt and (mt.__index or mt.__newindex or mt.__sub or mt.__mul) then
    local wrapped = {}
    for k, v in pairs(mt) do
      if type(v) == "function" then
        wrapped[k] = function(...) print("MT", k, ...) ; return v(...) end
      else wrapped[k] = v end
    end
    return original_setmetatable(t, wrapped)
  end
  return original_setmetatable(t, mt)
end
```

Run psu_max under that — the trace will reveal what `o`/`Calculate`/`_G`
are being indexed by during chunk construction, and the constants
`255806744`, `303909627`, etc. should appear paired with the chars `b`,
`i`, `t`, `3`, `2`, …

### 4. Roblox emulation host

Last resort: stand up a small Roblox-game environment shim. The script
clearly assumes Roblox globals (`Calculate` is one, there may be more once
the VM gets further). Tools like `lune` or a stub-`Instance.new`/`game` set
might let it run. Skip until #1–#3 are exhausted.

## What NOT to do

* Don't try to translate the metatable-trap junk to Python regex. Each
  expression depends on the metatable defined later in the script — only
  Lua itself can evaluate them correctly.
* Don't extend the universal hook with psu_max-specific wrapping. Per the
  identity-preservation lesson from this session, any extra wrapping on
  `loadstring`/`load`/`io.write` will silently break other modes (mid,
  evil, env, max_security, basic) that detect non-identity functions.
  Keep psu_max work in a separate `hook_psumax.lua` (or whatever) and
  iterate there.

## Useful artefacts already on disk

* `psu_max_mode/print_hi.lua.chunk_1.lua` — the dumped 70929-byte inner
  chunk (regenerate with `XHIDER_DUMP_CHUNKS=1 lua5.1 env_mode/hook_universal.lua psu_max_mode/print_hi.lua`).
* `psu_max_mode/fibo.lua.chunk_1.lua` — same for fibo.
* `env_mode/hook_loadstring.lua` — chunk-dump hook (slightly older, but
  works as a starting point for the metatable-trace strategy).

## Definition of done

Cracked = `psu_max_mode/print_hi.decrypted.lua` and
`psu_max_mode/fibo.decrypted.lua` exist and contain reconstructed
`print("hi")` / fibonacci source.

Once both files exist:

1. Update `current_state.md` to mark psu_max **FULLY CRACKED**.
2. Add a `psu_max` entry to `cracked_modes.md` with the actual crack
   pipeline.
3. **Delete this file.** It documents speculation, not facts; once the
   real recipe is in `cracked_modes.md` this is just clutter.

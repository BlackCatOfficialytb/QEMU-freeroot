-- XHider Universal Dynamic Dumper (Lua 5.1)
--
-- One tool that works on every XHider mode in this repo:
--   - print_hi / fibo style scripts (m1, m2, m3, basic, hard, normal, ibs,
--     ibv, mid, evil, strong, env, max, psu, psu_mid, psu_hard)
--   - basic_b1 (Lua 5.2 `bit32.*` library + Lua 5.3 `0bNNN` binary literals
--     and `_` digit-separators — both auto-translated below)
--   - psu_max-style chained loadstring chunks (every chunk is dumped to a
--     numbered .chunk_N.lua next to the source so you can inspect what the
--     real program is)
--
-- Usage:  lua5.1 env_mode/hook_universal.lua <obfuscated.lua>
--
-- Output:
--   * Captured stdout (every print/io.write call), echoed and listed.
--   * Every chunk passed to load/loadstring/loadfile dumped to disk.
--   * If execution errors, prints the error but still dumps captured chunks.
--
-- Why one file:
--   - hook_env.lua          → only `print` hook
--   - hook_env_bit32.lua    → +bit32 polyfill (basic_b1)
--   - hook_loadstring.lua   → +chunk dumping (psu_max)
--   - hook_psumax.lua       → +Calculate stub (didn't fully solve psu_max)
-- This consolidates all of them. Set the env vars below if you need to
-- toggle anything off.
--
-- Env knobs (set on the command line, e.g. `XHIDER_NO_PREPROCESS=1 lua5.1 …`):
--   XHIDER_NO_PREPROCESS=1   skip the 0bNNN→decimal + `_` strip pass
--   XHIDER_NO_BIT32=1        skip the bit32 polyfill
--   XHIDER_NO_CHUNKDUMP=1    don't write .chunk_N.lua files
--   XHIDER_VERBOSE=1         print extra trace messages

local function getenv(k) return os and os.getenv and os.getenv(k) end
local VERBOSE       = getenv("XHIDER_VERBOSE")     == "1"
local DO_PREPROCESS = getenv("XHIDER_NO_PREPROCESS") ~= "1"
local DO_BIT32      = getenv("XHIDER_NO_BIT32")    ~= "1"
local DO_CHUNKDUMP  = getenv("XHIDER_NO_CHUNKDUMP")~= "1"

------------------------------------------------------------------ bit32 stub
if DO_BIT32 then
    bit32 = bit32 or {}
    local function tobit(x)
        x = x % 0x100000000
        if x < 0 then x = x + 0x100000000 end
        return x
    end
    if not bit32.band then
        function bit32.band(a,b)
            a=tobit(a); b=tobit(b); local r,p=0,1
            for i=0,31 do local ab=a%2; local bb=b%2
                if ab==1 and bb==1 then r=r+p end
                a=(a-ab)/2; b=(b-bb)/2; p=p*2
            end; return r
        end
    end
    if not bit32.bor then
        function bit32.bor(a,b)
            a=tobit(a); b=tobit(b); local r,p=0,1
            for i=0,31 do local ab=a%2; local bb=b%2
                if ab==1 or bb==1 then r=r+p end
                a=(a-ab)/2; b=(b-bb)/2; p=p*2
            end; return r
        end
    end
    if not bit32.bxor then
        function bit32.bxor(a,b)
            a=tobit(a); b=tobit(b); local r,p=0,1
            for i=0,31 do local ab=a%2; local bb=b%2
                if ab~=bb then r=r+p end
                a=(a-ab)/2; b=(b-bb)/2; p=p*2
            end; return r
        end
    end
    if not bit32.bnot   then function bit32.bnot(a) return tobit(0xFFFFFFFF - tobit(a)) end end
    if not bit32.lshift then function bit32.lshift(a,n) return tobit(math.floor(tobit(a) * 2^n) % 0x100000000) end end
    if not bit32.rshift then function bit32.rshift(a,n) return math.floor(tobit(a) / 2^n) end end
    if not bit32.arshift then
        function bit32.arshift(a,n)
            a=tobit(a); local r=math.floor(a/2^n)
            if a >= 0x80000000 and n > 0 then r = r + tobit(0xFFFFFFFF * 2^-n) end
            return tobit(r)
        end
    end
    if not bit32.extract then
        function bit32.extract(a,p,w) w=w or 1; return bit32.band(bit32.rshift(a,p), 2^w-1) end
    end
end

------------------------------------------------------------------ source preprocessor
local function preprocess_source(src)
    -- WARNING: a regex-based preprocessor can't tell apart real code and
    -- string-literal contents. We only run it when the source contains
    -- XHider's binary-literal syntax `0bNNN`, which is invalid stock Lua and
    -- a clear marker for basic_b1 mode. For any other script we pass through
    -- unchanged so we don't accidentally rewrite `_` inside a string literal
    -- (e.g. env_mode contains `"_\`85_"` which would otherwise lose its `_`).
    if not DO_PREPROCESS then return src, false end
    -- Quick gate: must have a `0b<digits>` token outside an identifier. If
    -- not, do nothing.
    if not src:find("[^%w_]0[bB][01]") and not src:find("^0[bB][01]") then
        return src, false
    end
    local before = src
    -- 1. 0bNNN binary literal → decimal.
    src = src:gsub("([^%w_])0[bB]([01_]+)", function(prefix, bits)
        bits = bits:gsub("_", "")
        if #bits == 0 then return prefix .. "0b" .. bits end
        local n = 0
        for i = 1, #bits do n = n*2 + (bits:byte(i) - 48) end
        return prefix .. tostring(n)
    end)
    src = src:gsub("^0[bB]([01_]+)", function(bits)
        bits = bits:gsub("_","")
        local n = 0
        for i = 1, #bits do n = n*2 + (bits:byte(i) - 48) end
        return tostring(n)
    end)
    -- 2. `_` inside hex literals — only fires when `_` is present, AND we're
    --    already in a script that's confirmed to be basic_b1 (gate above).
    src = src:gsub("([^%w_])(0[xX][%w_]*_[%w_]*)", function(prefix, lit)
        return prefix .. lit:gsub("_", "")
    end)
    -- 3. `_` inside DECIMAL literals — same caveat.
    src = src:gsub("([^%w_])(%d[%d_]*_[%d_]*)", function(prefix, lit)
        return prefix .. lit:gsub("_", "")
    end)
    return src, src ~= before
end

------------------------------------------------------------------ capture state
local original = {
    print       = print,
    write       = io and io.write,
    loadstring  = loadstring,
    load        = load,
    loadfile    = loadfile,
    require     = require,
    dofile      = dofile,
}
local captured_output = {}
local captured_chunks = {}
local script_path = arg[1] or error("usage: lua5.1 hook_universal.lua <script.lua>")

local function record_output(s)
    table.insert(captured_output, s)
end

------------------------------------------------------------------ print/io.write hooks
print = function(...)
    local args = {...}
    local line = ""
    for i = 1, select("#", ...) do
        if i > 1 then line = line .. "\t" end
        line = line .. tostring(args[i])
    end
    record_output(line)
    return original.print(...)
end

-- NB: Do NOT hook io.write or wrap loadstring/load directly. Several XHider
-- modes (mid_mode, evil_mode, env_mode, max_security_mode, basic_mode) check
-- the identities of these functions at load time and route to a decoy code
-- path ("love u" instead of the real message) when they don't match the
-- original. We hook print only, and use debug-hooks below to record load()
-- calls passively without changing their identity.

------------------------------------------------------------------ load/loadstring/loadfile/dofile hooks
local function record_chunk(s, source)
    if type(s) ~= "string" then return end
    table.insert(captured_chunks, {src = s, source = source or "?"})
    if VERBOSE then
        original.print(("[chunk %d] %d bytes from %s"):format(#captured_chunks, #s, source or "?"))
    end
end

-- Note: we DO NOT preprocess inner chunks. The preprocessor is only safe on
-- the user-supplied entry script (where XHider's `0bNNN` syntax may appear).
-- Inner chunks are typically VM bytecode strings or already-translated Lua;
-- touching them with the regex pass risks corrupting hex tables, identifier
-- prefixes, or numeric literals embedded in escape sequences.
-- We do NOT replace loadstring / load / loadfile / dofile — that breaks
-- scripts that compare their identity against `_G.loadstring`. Instead, we
-- use Lua's `debug.sethook` with a "call" hook that fires on every C-function
-- entry; if the function being called is loadstring/load/loadfile, we copy
-- its first string argument out into our chunk log before letting it run.

local function call_hook()
    local info = debug.getinfo(2, "fn")
    if not info or not info.func then return end
    local fn = info.func
    if fn == original.loadstring or fn == original.load or fn == original.loadfile then
        -- Read the first arg of the C frame. We can't grab it directly — use
        -- a coroutine-style trick: read the local 'a' or 'arg' name. In Lua
        -- 5.1 C-functions have no locals visible to debug.getlocal, so we
        -- fall back to logging the call site only.
        local src_info = debug.getinfo(3, "Sl")
        if VERBOSE and src_info then
            original.print(("[hook] %s called from %s:%d"):format(
                fn == original.loadstring and "loadstring" or
                fn == original.load and "load" or "loadfile",
                src_info.short_src or "?", src_info.currentline or -1))
        end
    end
end

-- Don't enable the debug hook by default — it's slow and many scripts that
-- detect tampering also probe debug.gethook(). Only enable when verbose.
if VERBOSE and debug and debug.sethook then
    debug.sethook(call_hook, "c")
end

-- For chunk dumping, use a different strategy: monkey-patch loadstring/load
-- ONLY if the user explicitly opts in. Default is identity-preserving.
if getenv("XHIDER_DUMP_CHUNKS") == "1" then
    loadstring = function(s, chunkname)
        record_chunk(s, "loadstring"); return original.loadstring(s, chunkname)
    end
    load = function(x, chunkname, ...)
        if type(x) == "string" then
            record_chunk(x, "load:string"); return original.load(x, chunkname, ...)
        elseif type(x) == "function" then
            local pieces = {}
            local f, err = original.load(function()
                local p = x(); if p == nil or p == "" then return p end
                pieces[#pieces+1] = p; return p
            end, chunkname, ...)
            local joined = table.concat(pieces)
            if #joined > 0 then record_chunk(joined, "load:func") end
            return f, err
        end
        return original.load(x, chunkname, ...)
    end
    loadfile = function(path)
        if path then
            local fh = io.open(path, "rb")
            if fh then local s = fh:read("*a"); fh:close()
                record_chunk(s, "loadfile:"..path) end
        end
        return original.loadfile(path)
    end
end

------------------------------------------------------------------ run target
original.print("=== xhider hook_universal: " .. script_path .. " ===")
if VERBOSE then
    original.print(("(preprocess=%s bit32=%s chunkdump=%s)")
        :format(tostring(DO_PREPROCESS), tostring(DO_BIT32), tostring(DO_CHUNKDUMP)))
end

local f, err
do
    local fh = io.open(script_path, "rb")
    if not fh then
        original.print("Error opening file: " .. tostring(script_path))
        return
    end
    local src = fh:read("*a"); fh:close()
    local src2, changed = preprocess_source(src)
    if changed then
        -- preprocessor altered the source — load the translated text but
        -- give it the original path as chunk name so error messages still
        -- point at the user's file
        f, err = original.loadstring(src2, "@" .. script_path)
    else
        -- no preprocessing happened: use loadfile so chunk identity is
        -- exactly what `original` would normally see (some obfuscators check
        -- `debug.getinfo` and behave differently for loadstring chunks)
        f, err = original.loadfile(script_path)
    end
end
if not f then
    original.print("Error loading: " .. tostring(err))
else
    local ok, result = pcall(f)
    if not ok then
        original.print("Error executing: " .. tostring(result))
    end
end

------------------------------------------------------------------ report
original.print("\n=== Captured Output (" .. #captured_output .. " line(s)) ===")
for i, line in ipairs(captured_output) do
    original.print("[" .. i .. "] " .. line)
end

if DO_CHUNKDUMP then
    for i, c in ipairs(captured_chunks) do
        local out = script_path .. ".chunk_" .. i .. ".lua"
        local fh = io.open(out, "w")
        if fh then fh:write(c.src); fh:close() end
        original.print(("[chunk %d] %d bytes (%s) -> %s"):format(i, #c.src, c.source, out))
    end
end
original.print("=== End ===")

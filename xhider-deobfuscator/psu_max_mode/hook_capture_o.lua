-- Hook for psu_max: capture the `o` table passed by the outer wrapper to
-- chunk_1, then dump it to stdout (and a file) before letting execution proceed.
-- Strategy: wrap loadstring so the returned function is wrapped — when it is
-- called, we serialize the first arg (`o`) before running.
--
-- Usage: lua55 hook_capture_o.lua <obfuscated.lua>

-- bit32 polyfill (Lua 5.5)
if not bit32 then
    bit32 = {}
    local function tobit(x)
        x = math.floor(x) % 0x100000000
        if x < 0 then x = x + 0x100000000 end
        return x
    end
    function bit32.band(a,b)
        a=tobit(a); b=tobit(b); local r,p=0,1
        for i=0,31 do local ab=a%2; local bb=b%2
            if ab==1 and bb==1 then r=r+p end
            a=(a-ab)/2; b=(b-bb)/2; p=p*2
        end; return r
    end
    function bit32.bor(a,b)
        a=tobit(a); b=tobit(b); local r,p=0,1
        for i=0,31 do local ab=a%2; local bb=b%2
            if ab==1 or bb==1 then r=r+p end
            a=(a-ab)/2; b=(b-bb)/2; p=p*2
        end; return r
    end
    function bit32.bxor(a,b)
        a=tobit(a); b=tobit(b); local r,p=0,1
        for i=0,31 do local ab=a%2; local bb=b%2
            if ab~=bb then r=r+p end
            a=(a-ab)/2; b=(b-bb)/2; p=p*2
        end; return r
    end
    function bit32.bnot(a) return tobit(0xFFFFFFFF - tobit(a)) end
    function bit32.lshift(a,n) return tobit(math.floor(tobit(a) * 2^n) % 0x100000000) end
    function bit32.rshift(a,n) return math.floor(tobit(a) / 2^n) end
end

ldexp     = ldexp     or function(x, e) return x * 2^e end
unpack    = unpack    or table.unpack
loadstring= loadstring or load
getfenv   = getfenv   or function() return _ENV end

-- Calculate stub — env-overridable
local stub = os.getenv("CALC_STUB") or "band"
local function make_stub()
    if stub == "band" then return function(a,b) return bit32.band(a,b) end
    elseif stub == "bxor" then return function(a,b) return bit32.bxor(a,b) end
    elseif stub == "bor"  then return function(a,b) return bit32.bor(a,b) end
    elseif stub == "passa" then return function(a,b) return a end
    elseif stub == "passb" then return function(a,b) return b end
    elseif stub == "min" then return function(a,b) return math.min(a,b) end
    elseif stub == "max" then return function(a,b) return math.max(a,b) end
    elseif stub == "sub" then return function(a,b) return a-b end
    elseif stub == "add" then return function(a,b) return a+b end
    elseif stub == "mul" then return function(a,b) return a*b end
    elseif stub == "mod" then return function(a,b) return a%b end
    elseif stub == "zero" then return function(a,b) return 0 end
    end
    error("unknown stub: " .. stub)
end
_G.Calculate = make_stub()
print = print
print("[hook] Calculate stub = " .. stub)

local script_path = arg[1] or error("usage: hook_capture_o.lua <obf.lua>")
local original_loadstring = loadstring
local original_load = load
local original_print = print
local captured_chunks = {}
local captured_o_tables = {}

local function serialize(t, depth)
    depth = depth or 0
    if depth > 4 then return "<deep>" end
    local tt = type(t)
    if tt ~= "table" then
        if tt == "string" then
            if #t > 200 then
                return string.format("<string len=%d head=%q>", #t, t:sub(1, 80))
            end
            return string.format("%q", t)
        end
        return tostring(t)
    end
    local out = {"{"}
    local n = 0
    for k, v in pairs(t) do
        n = n + 1
        if n > 200 then table.insert(out, "<...truncated>"); break end
        local ks
        if type(k) == "string" then ks = string.format("[%q]", k)
        else ks = "[" .. tostring(k) .. "]" end
        table.insert(out, ks .. "=" .. serialize(v, depth + 1) .. ",")
    end
    table.insert(out, "}")
    return table.concat(out, "")
end

-- Wrap loadstring/load: when called with a string, record it and return a
-- proxy function that captures its args.
local decoder_calls = {}
local function wrap_decoder(orig, name)
    return function(...)
        local args = {...}
        local n = select("#", ...)
        local arg_repr = {}
        for i = 1, n do arg_repr[i] = tostring(args[i]) end
        local res = {pcall(orig, ...)}
        local ok = res[1]
        if ok then
            local r = res[2]
            table.insert(decoder_calls, {name=name, args=arg_repr, ok=true, ret=tostring(r)})
            original_print(("[decoder %s] args=(%s) -> %s"):format(name, table.concat(arg_repr, ","), tostring(r)))
            return select(2, table.unpack(res))
        else
            table.insert(decoder_calls, {name=name, args=arg_repr, ok=false, err=tostring(res[2])})
            original_print(("[decoder %s] args=(%s) -> ERROR %s"):format(name, table.concat(arg_repr, ","), tostring(res[2])))
            error(res[2], 2)
        end
    end
end

local function wrap_loaded(real_fn, src_chunk)
    return function(...)
        local args = {...}
        local nargs = select("#", ...)
        if nargs > 0 and type(args[1]) == "table" then
            -- This is the key insight — record the o table.
            local snapshot = {}
            for k, v in pairs(args[1]) do snapshot[k] = v end
            local extra = {}
            for i = 2, nargs do extra[i-1] = args[i] end
            table.insert(captured_o_tables, {chunk_idx = #captured_chunks, o = snapshot, nargs = nargs, extra = extra})
            original_print(("[wrap_loaded] called with %d args (1 = o table; %d extra)"):format(nargs, nargs-1))
            -- Wrap the decoder slots so we log what they return.
            local o_table = args[1]
            if type(o_table[500910416]) == "function" then
                o_table[500910416] = wrap_decoder(o_table[500910416], "o[500910416]")
            end
            if type(o_table.BUe9QJZn) == "function" then
                o_table.BUe9QJZn = wrap_decoder(o_table.BUe9QJZn, "o.BUe9QJZn")
            end
        end
        return real_fn(...)
    end
end

loadstring = function(s, chunkname)
    if type(s) == "string" then
        table.insert(captured_chunks, s)
        local idx = #captured_chunks
        local out = script_path .. ".chunk_" .. idx .. ".lua"
        local fh = io.open(out, "w"); if fh then fh:write(s); fh:close() end
        original_print(("[chunk %d] %d bytes -> %s"):format(idx, #s, out))
        local f, err = original_loadstring(s, chunkname)
        if not f then return f, err end
        return wrap_loaded(f, idx)
    end
    return original_loadstring(s, chunkname)
end

load = function(x, chunkname, ...)
    if type(x) == "string" then
        table.insert(captured_chunks, x)
        local idx = #captured_chunks
        local out = script_path .. ".chunk_" .. idx .. ".lua"
        local fh = io.open(out, "w"); if fh then fh:write(x); fh:close() end
        original_print(("[chunk %d] %d bytes -> %s"):format(idx, #x, out))
        local f, err = original_load(x, chunkname, ...)
        if not f then return f, err end
        return wrap_loaded(f, idx)
    end
    return original_load(x, chunkname, ...)
end

-- print hook
local captured = {}
print = function(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[i] = tostring(select(i, ...)) end
    local line = table.concat(parts, "\t")
    table.insert(captured, line)
    original_print("[print] " .. line)
end

-- Run target
original_print("=== running " .. script_path .. " ===")
local fh = io.open(script_path, "rb")
local src = fh:read("*a"); fh:close()
local f, err = original_loadstring(src, "@" .. script_path)
if not f then original_print("load err: " .. tostring(err)); os.exit(1) end
local ok, result = pcall(f)
if not ok then original_print("EXEC ERROR: " .. tostring(result)) end

original_print(("=== captured %d chunk(s), %d o-table snapshot(s) ==="):format(#captured_chunks, #captured_o_tables))
for i, ent in ipairs(captured_o_tables) do
    original_print(("--- o-table snapshot #%d (for chunk %d) ---"):format(i, ent.chunk_idx))
    -- Sort keys nicely
    local keys = {}
    for k in pairs(ent.o) do keys[#keys+1] = k end
    table.sort(keys, function(a, b)
        if type(a) == type(b) then return tostring(a) < tostring(b) end
        return type(a) < type(b)
    end)
    for _, k in ipairs(keys) do
        local ks = type(k) == "string" and string.format("%q", k) or tostring(k)
        original_print(("  o[%s] = %s"):format(ks, serialize(ent.o[k], 1)))
    end
    -- Dump full o to file
    local out = script_path .. ".o_table_" .. i .. ".txt"
    local oh = io.open(out, "w")
    if oh then
        for _, k in ipairs(keys) do
            local ks = type(k) == "string" and string.format("%q", k) or tostring(k)
            oh:write(("o[%s] = %s\n"):format(ks, serialize(ent.o[k], 1)))
        end
        oh:close()
        original_print("  -> " .. out)
    end
end

original_print("=== captured " .. #captured .. " print line(s) ===")
for i, l in ipairs(captured) do original_print("  " .. i .. ": " .. l) end

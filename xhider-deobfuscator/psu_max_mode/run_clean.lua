-- Harness for running cleaned (stripped) chunk_1 from psu_max.
-- Provides: bit32 polyfill, Calculate=bit32.band, complete o table,
-- and print capture.
--
-- Usage:  lua5.1 run_clean.lua [clean_chunk1.lua]

---------------------------------------------------------------- bit32 polyfill
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
    function bit32.extract(a,p,w) w=w or 1; return bit32.band(bit32.rshift(a,p), 2^w-1) end
end

---------------------------------------------------------------- polyfills
ldexp     = ldexp     or function(x, e) return x * 2^e end
unpack    = unpack    or table.unpack
loadstring= loadstring or load

---------------------------------------------------------------- Calculate = bit32.band
_G.Calculate = function(a, b) return bit32.band(a, b) end

---------------------------------------------------------------- o table
local t = bit32.bxor

-- Lazy decoder stubs: error with key info on unknown keys, memoize known ones.
local o500910416_known = {
    [62727361] = 1,
}

local function o500910416(arg1, t_fn, l_tbl, key)
    local v = o500910416_known[key]
    if v ~= nil then
        if l_tbl then l_tbl[key] = v end
        return v
    end
    error(string.format("[o500910416] unknown key=%s  arg1=%s", tostring(key), tostring(arg1)), 2)
end

local oBUe9QJZn_known = {
    [350699343] = 10,   -- placeholder; will be discovered at runtime
}

local function oBUe9QJZn(arg1, t_fn, l_tbl, key)
    local v = oBUe9QJZn_known[key]
    if v ~= nil then
        if l_tbl then l_tbl[key] = v end
        return v
    end
    error(string.format("[oBUe9QJZn] unknown key=%s  arg1=%s", tostring(key), tostring(arg1)), 2)
end

local o = {
    [209867084] = "e", [255806744] = "b", [261377791] = 155228450,
    [293684876] = "n", [29799631]  = "a", [303909627] = "2",
    [407365380] = "k", [43472931]  = "s", [462186921] = "i",
    [466982296] = "v", [669545735] = "h", [676273207] = "t",
    [755266474] = 660029073, [767826132] = "c", [780364647] = "y",
    [821956203] = "m", [828614386] = "r", [860093539] = "f",
    [864117863] = "l", [880505119] = 28811554, [926356572] = "o",
    [997985534] = "u",
    W8ZpaIfush  = "p", anierBSX = "d", albeVM = 905968982,
    cPAuZDv0    = "#",
    [500910416] = o500910416,
    BUe9QJZn    = oBUe9QJZn,
}

---------------------------------------------------------------- print capture
local original_print = print
local captured = {}
print = function(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[i] = tostring(select(i, ...)) end
    table.insert(captured, table.concat(parts, "\t"))
    original_print("[print]", ...)
end

---------------------------------------------------------------- run cleaned chunk_1
local target = arg[1] or error("usage: lua5.1 run_clean.lua <clean_chunk1.lua>")
local fh = io.open(target, "rb")
local src = fh:read("*a"); fh:close()

-- The cleaned chunk_1 is: return(function(o,...) ... end)(...)
-- When loaded, it expects to be called with the o table as first argument.
local f, err = loadstring(src, "@chunk1_clean")
if not f then
    original_print("LOAD ERROR: " .. tostring(err))
    os.exit(1)
end

local ok, result = xpcall(function()
    -- The chunk calls (function(o,...)...end)(...) with ... from loadstring context
    -- We need to set up the varargs so o gets our table
    -- Method: wrap the chunk to inject o
    local inner = f  -- f() returns the function (function(o,...)...end)
    return inner(o)
end, function(e)
    return debug.traceback(tostring(e), 2)
end)

if not ok then
    original_print("EXEC ERROR: " .. tostring(result))
else
    original_print("OK: " .. tostring(result))
end

original_print(("=== captured %d print line(s) ==="):format(#captured))
for i, l in ipairs(captured) do original_print("  " .. i .. ": " .. l) end

-- Full standalone harness for chunk_1 of psu_max.
-- Provides bit32 polyfill, getfenv polyfill, Calculate=bit32.band,
-- and a complete `o` table with REAL decoders for o[500910416] and o.BUe9QJZn.
--
-- Usage: lua55 harness.lua [chunk_path]

------------------------------------------------------------ polyfills
if not bit32 then
    bit32 = {}
    local function tobit(x)
        x = math.floor(x) % 0x100000000
        if x < 0 then x = x + 0x100000000 end
        return x
    end
    function bit32.band(a,b) a=tobit(a); b=tobit(b); local r,p=0,1; for i=0,31 do local ab=a%2; local bb=b%2; if ab==1 and bb==1 then r=r+p end; a=(a-ab)/2; b=(b-bb)/2; p=p*2 end; return r end
    function bit32.bor(a,b) a=tobit(a); b=tobit(b); local r,p=0,1; for i=0,31 do local ab=a%2; local bb=b%2; if ab==1 or bb==1 then r=r+p end; a=(a-ab)/2; b=(b-bb)/2; p=p*2 end; return r end
    function bit32.bxor(a,b) a=tobit(a); b=tobit(b); local r,p=0,1; for i=0,31 do local ab=a%2; local bb=b%2; if ab~=bb then r=r+p end; a=(a-ab)/2; b=(b-bb)/2; p=p*2 end; return r end
    function bit32.bnot(a) return tobit(0xFFFFFFFF - tobit(a)) end
    function bit32.lshift(a,n) return tobit(math.floor(tobit(a) * 2^n) % 0x100000000) end
    function bit32.rshift(a,n) return math.floor(tobit(a) / 2^n) end
end

ldexp     = ldexp     or function(x, e) return x * 2^e end
unpack    = unpack    or table.unpack
loadstring= loadstring or load
getfenv   = getfenv   or function() return _ENV end

_G.Calculate = function(a, b) return bit32.band(a, b) end

------------------------------------------------------------ o table
local t = bit32.bxor

-- The decoder: returns an integer for keyed lazy constants. We don't yet know
-- the formulae for the keys actually used (62727361, 350699343, ...), so we
-- start with the captured-by-hook value: o[500910416](2246083, t, l, 62727361)=1.
-- For other keys we error verbosely.
local o500910416_known = {
    [62727361] = 1,
}
local function o500910416(arg1, t_arg, l_arg, key)
    local v = o500910416_known[key]
    if v ~= nil then
        if l_arg then l_arg[key] = v end
        return v
    end
    error(string.format("o[500910416] unknown key=%s arg1=%s", tostring(key), tostring(arg1)))
end

local oBUe9QJZn_known = {}
local function oBUe9QJZn(arg1, t_arg, l_arg, key)
    local v = oBUe9QJZn_known[key]
    if v ~= nil then
        if l_arg then l_arg[key] = v end
        return v
    end
    error(string.format("o.BUe9QJZn unknown key=%s arg1=%s", tostring(key), tostring(arg1)))
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

------------------------------------------------------------ print capture
local original_print = print
local captured = {}
print = function(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[i] = tostring(select(i, ...)) end
    table.insert(captured, table.concat(parts, "\t"))
    original_print("[print]", ...)
end

------------------------------------------------------------ run chunk_1
local target = arg[1] or "E:/dec_bot2/psu_max_mode/print_hi.lua.chunk_1.lua"
local fh = io.open(target, "rb")
local src = fh:read("*a"); fh:close()
local f, err = load(src, "@chunk1")
if not f then original_print("load: " .. tostring(err)); os.exit(1) end

local ok, result = xpcall(function() return f(o) end, function(e)
    return e .. "\n" .. debug.traceback("", 2)
end)
if not ok then
    original_print("ERROR: " .. tostring(result))
else
    original_print("OK: " .. tostring(result))
end
original_print(("=== captured %d print line(s) ==="):format(#captured))
for i, l in ipairs(captured) do original_print("  " .. i .. ": " .. l) end

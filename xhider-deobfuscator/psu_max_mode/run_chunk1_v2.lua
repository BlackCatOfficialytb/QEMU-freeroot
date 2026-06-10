-- Run formatted chunk_1 with the captured `o` table to get a real line number.

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

-- The o table — captured snapshot
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
    -- Functions for o[500910416] and o.BUe9QJZn — these are likely lazy
    -- proto-builders. Without dumping them too, we set them to placeholder
    -- error-emitters so we can see if exec ever reaches them.
    [500910416] = function(...) error("o[500910416] called", 2) end,
    BUe9QJZn    = function(...) error("o.BUe9QJZn called", 2) end,
}

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

local original_print = print
local captured = {}
print = function(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[i] = tostring(select(i, ...)) end
    table.insert(captured, table.concat(parts, "\t"))
    original_print("[print]", ...)
end

local target = arg[1] or "E:/dec_bot2/psu_max_mode/print_hi.lua.chunk_1.formatted.lua"
local fh = io.open(target, "rb")
local src = fh:read("*a"); fh:close()
local f, err = load(src, "@chunk1")
if not f then original_print("load: " .. tostring(err)); os.exit(1) end

original_print(("=== chunk_1 stub=%s ==="):format(stub))
local ok, result = xpcall(function() return f(o) end, function(e)
    return e .. "\n" .. debug.traceback()
end)
if not ok then original_print("ERROR: " .. tostring(result))
else original_print("OK: " .. tostring(result)) end
original_print(("=== captured %d print line(s) ==="):format(#captured))
for i, l in ipairs(captured) do original_print("  " .. i .. ": " .. l) end

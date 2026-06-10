-- Run chunk_1 of psu_max with a reconstructed `o` table and various Calculate stubs.
-- Usage: lua55 run_chunk1.lua [stub_name]
--   stub_name in {band, bxor, bor, bnot, passa, passb}; default "band"

local stub_name = arg[1] or "band"

-- bit32 polyfill (Lua 5.5 has no bit32)
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

-- Lua 5.5 fallbacks
ldexp = ldexp or function(x, e) return x * 2^e end
unpack = unpack or table.unpack
loadstring = loadstring or load
getfenv = getfenv or function() return _ENV end

-- Reconstructed o table (chars from solve_o.py + 4 unknown int constants)
local o = {
    [255806744] = 'b',  [303909627] = '2',  [676273207] = 't',
    [926356572] = 'o',  [828614386] = 'r',  [209867084] = 'e',
    [864117863] = 'l',  [780364647] = 'y',  [821956203] = 'm',
    [29799631]  = 'a',  [997985534] = 'u',  [462186921] = 'i',
    [407365380] = 'k',  [767826132] = 'c',  [669545735] = 'h',
    [860093539] = 'f',  [466982296] = 'v',  [293684876] = 'n',
    W8ZpaIfush  = 'p',  anierBSX    = 'd',
    [43472931]  = 's',
    -- The four unknown int constants used inside t(...) (= bit32.bxor):
    -- They appear as XOR keys; reasonable starting guess: zero (then xor result == first arg).
    -- We'll try various values via env knob.
    [261377791] = tonumber(os.getenv("OK1")) or 0,
    [880505119] = tonumber(os.getenv("OK2")) or 0,
    [755266474] = tonumber(os.getenv("OK3")) or 0,
    albeVM      = tonumber(os.getenv("OK4")) or 0,
    -- The two function entries; if absent the fallback `(l[K]) or o[K](...)` will run o[K].
    -- Make them nil so the fallback path runs.
}

-- Calculate stub
local Calculate
if stub_name == "band" then Calculate = function(a,b) return bit32.band(a,b) end
elseif stub_name == "bxor" then Calculate = function(a,b) return bit32.bxor(a,b) end
elseif stub_name == "bor"  then Calculate = function(a,b) return bit32.bor(a,b)  end
elseif stub_name == "bnot" then Calculate = function(a,b) return bit32.bnot(a)   end
elseif stub_name == "passa" then Calculate = function(a,b) return a end
elseif stub_name == "passb" then Calculate = function(a,b) return b end
elseif stub_name == "min"  then Calculate = function(a,b) return math.min(a,b) end
elseif stub_name == "max"  then Calculate = function(a,b) return math.max(a,b) end
else error("unknown stub: " .. stub_name) end

_G.Calculate = Calculate

-- Hook print to capture output
local captured = {}
local original_print = print
print = function(...)
    local args = {...}
    local line = ""
    for i = 1, select("#", ...) do
        if i > 1 then line = line .. "\t" end
        line = line .. tostring(args[i])
    end
    table.insert(captured, line)
    original_print("[print] " .. line)
end

-- Read chunk_1 source and load it
local target = arg[2] or "E:/dec_bot2/psu_max_mode/print_hi.lua.chunk_1.lua"
local fh = io.open(target, "rb")
local src = fh:read("*a"); fh:close()

-- chunk_1 starts with "local d=(function..." and ends with the inner `return ...`
-- It's already a full chunk that defines globals and at the end does
--    return(function(o,...) ... end)
-- WAIT — actually the outer wrapper does loadstring(chunk_1)() and that returned
-- function is then called with the o table. But in our dump, what we have is the
-- full chunk_1 source. Look: the chunk starts with `local d=(function...`...
-- ends with `return s(E(),{},V())(...);end)(...);`
-- Note the trailing `(...)` — chunk_1 is itself called with varargs from outer.
-- So the structure is: chunk_1 = "<defines binops> return(function(o,...) ... end)(o, ...)"
-- The outer evaluates chunk_1 as a chunk; the chunk's `(...)` are the args passed
-- to loadstring()'s returned function. So `o` is the FIRST vararg of the chunk.

-- We'll wrap: load(src) returns f; call f(o, ...) so chunk's (...) = (o, ...).
local f, err = load(src, "psu_max_chunk1")
if not f then
    print("load error: " .. tostring(err))
    os.exit(1)
end

original_print(("=== running chunk_1 with stub=%s ==="):format(stub_name))
local ok, result = pcall(f, o)
if not ok then
    original_print("ERROR: " .. tostring(result))
else
    original_print("OK: " .. tostring(result))
end

original_print(("=== Captured %d print line(s) ==="):format(#captured))
for i, l in ipairs(captured) do original_print("  " .. i .. ": " .. l) end

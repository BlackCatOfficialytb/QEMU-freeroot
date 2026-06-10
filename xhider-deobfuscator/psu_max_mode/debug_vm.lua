-- debug_vm.lua: Run clean chunk_1 with detailed VM instruction tracing
-- Usage: /tmp/lua-5.1.5/src/lua debug_vm.lua print_hi.lua.chunk_1.clean.lua

---------------------------------------------------------------- bit32 polyfill
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

---------------------------------------------------------------- polyfills
_G.Calculate = function(a, b) return bit32.band(a, b) end

---------------------------------------------------------------- o table
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
    [500910416] = function(arg1, t_fn, l_tbl, key)
        if l_tbl then l_tbl[key] = arg1 end
        return arg1
    end,
    BUe9QJZn = function(arg1, t_fn, l_tbl, key)
        if l_tbl then l_tbl[key] = arg1 end
        return arg1
    end,
}

---------------------------------------------------------------- print capture
local captured = {}
_G.captured = captured
local orig_print = print
print = function(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[i] = tostring(select(i, ...)) end
    table.insert(captured, table.concat(parts, "\t"))
    orig_print("[print]", ...)
end

---------------------------------------------------------------- Load chunk_1 and patch to trace VM
local target = arg[1] or error("usage: lua5.1 debug_vm.lua <clean_chunk1.lua>", 0)
local fh = io.open(target, "rb")
local src = fh:read("*a"); fh:close()

local f, err = loadstring(src, "@chunk1_clean")
if not f then
    orig_print("LOAD ERROR:", err)
    os.exit(1)
end

-- Run it with a nil-index protection on tables
-- Patch: after creating register file n, add metatable that warns on nil
local instr_count = 0
local max_trace = 500

local ok, result = xpcall(function()
    return f(o)
end, function(e)
    local msg = tostring(e)
    orig_print("ERROR: " .. msg)
    return debug.traceback(msg, 2)
end)

if not ok then
    orig_print("EXEC ERROR:", result)
else
    orig_print("OK:", tostring(result))
end

orig_print(("=== captured %d print line(s) ==="):format(#captured))
for i, l in ipairs(captured) do orig_print("  " .. i .. ": " .. l) end

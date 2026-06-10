-- hook_setfenv.lua: Hook setfenv in psu_max outer wrapper
-- Intercepts setfenv(f, env) to keep env as a proper table
-- Also provides bit32 polyfill and Calculate
-- Usage: lua5.1 hook_setfenv.lua print_hi.lua

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

---------------------------------------------------------------- Calculate
_G.Calculate = function(a, b) return bit32.band(a, b) end

---------------------------------------------------------------- Hook setfenv
local orig_setfenv = setfenv
setfenv = function(f, t)
    print("[HOOK] setfenv called, env type=" .. type(t) .. " val=" .. tostring(t))
    -- If env is a number, replace with _G to keep table access working
    if type(t) == "number" then
        print("[HOOK] Replacing number env with _G proxy")
        -- Create a proxy table that also responds to numeric indexing
        local proxy = setmetatable({}, {
            __index = function(self, k)
                if type(k) == "string" then return _G[k] end
                return nil
            end,
            __newindex = function(self, k, v)
                if type(k) == "string" then _G[k] = v end
            end
        })
        return orig_setfenv(f, proxy)
    end
    return orig_setfenv(f, t)
end

---------------------------------------------------------------- Hook getfenv
local orig_getfenv = getfenv
getfenv = function(level)
    local env = orig_getfenv(level)
    if type(env) == "number" then
        print("[HOOK] getfenv returned number, returning _G instead")
        return _G
    end
    return env
end

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

---------------------------------------------------------------- Load and run the outer wrapper
local target = arg[1] or error("usage: lua5.1 hook_setfenv.lua <psu_max_script.lua>", 0)
local fh = io.open(target, "rb")
local src = fh:read("*a"); fh:close()

local f, err = loadstring(src, "@" .. target)
if not f then
    orig_print("LOAD ERROR:", err)
    os.exit(1)
end

local ok, result = xpcall(function()
    return f()
end, function(e)
    return debug.traceback(tostring(e), 2)
end)

if not ok then
    orig_print("EXEC ERROR:", result)
else
    orig_print("OK:", tostring(result))
end

orig_print(("=== captured %d print line(s) ==="):format(#captured))
for i, l in ipairs(captured) do orig_print("  " .. i .. ": " .. l) end

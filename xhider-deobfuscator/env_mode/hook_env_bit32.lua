-- Variant of hook_env.lua that injects a pure-Lua bit32 polyfill before loading.
-- Lua 5.1 lacks bit32; XHider basic_b1 mode requires it.

bit32 = bit32 or {}
local function tobit(x) x = x % 0x100000000; if x < 0 then x = x + 0x100000000 end; return x end
function bit32.band(a,b) a=tobit(a); b=tobit(b); local r,p=0,1; for i=0,31 do local ab=a%2; local bb=b%2; if ab==1 and bb==1 then r=r+p end; a=(a-ab)/2; b=(b-bb)/2; p=p*2 end; return r end
function bit32.bor(a,b) a=tobit(a); b=tobit(b); local r,p=0,1; for i=0,31 do local ab=a%2; local bb=b%2; if ab==1 or bb==1 then r=r+p end; a=(a-ab)/2; b=(b-bb)/2; p=p*2 end; return r end
function bit32.bxor(a,b) a=tobit(a); b=tobit(b); local r,p=0,1; for i=0,31 do local ab=a%2; local bb=b%2; if ab~=bb then r=r+p end; a=(a-ab)/2; b=(b-bb)/2; p=p*2 end; return r end
function bit32.bnot(a) return tobit(0xFFFFFFFF - tobit(a)) end
function bit32.lshift(a,n) return tobit(math.floor(tobit(a) * 2^n) % 0x100000000) end
function bit32.rshift(a,n) return math.floor(tobit(a) / 2^n) end
function bit32.arshift(a,n) a=tobit(a); local r=math.floor(a/2^n); if a >= 0x80000000 and n > 0 then r = r + tobit(0xFFFFFFFF * 2^-n) end; return tobit(r) end
function bit32.extract(a,p,w) w=w or 1; return bit32.band(bit32.rshift(a,p), 2^w-1) end

local original_print = print
local original_tostring = tostring
local captured_output = {}
print = function(...)
    local args = {...}
    local line = ""
    for i, v in ipairs(args) do
        if i > 1 then line = line .. "\t" end
        line = line .. tostring(v)
    end
    table.insert(captured_output, line)
    original_print(...)
end

local script_path = arg[1]
original_print("=== Loading script: " .. script_path .. " ===")
local f, err = loadfile(script_path)
if not f then original_print("Error loading: " .. tostring(err)); return end
local ok, result = pcall(f)
if not ok then original_print("Error executing: " .. tostring(result)) end

original_print("\n=== Captured Output ===")
for i, line in ipairs(captured_output) do
    original_print("[" .. i .. "] " .. line)
end
original_print("=== End ===")

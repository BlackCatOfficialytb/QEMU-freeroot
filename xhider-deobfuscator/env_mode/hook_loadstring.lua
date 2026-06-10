-- Hooks loadstring/load + print, captures every string passed to them.
-- For psu_max-style obfuscators that build their real program at runtime
-- and feed it to load()/loadstring().

local original_print = print
local original_loadstring = loadstring
local original_load = load

local captured_chunks = {}
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

loadstring = function(s, chunkname)
    table.insert(captured_chunks, s)
    original_print("[loadstring] captured "..#s.." bytes (chunk #"..#captured_chunks..")")
    return original_loadstring(s, chunkname)
end

load = function(x, chunkname, ...)
    if type(x) == "string" then
        table.insert(captured_chunks, x)
        original_print("[load:string] captured "..#x.." bytes (chunk #"..#captured_chunks..")")
    elseif type(x) == "function" then
        -- collect chunks fed by the function loader
        local pieces = {}
        local wrapped = function()
            local p = x()
            if p == nil or p == "" then return p end
            table.insert(pieces, p)
            return p
        end
        local f, err = original_load(wrapped, chunkname, ...)
        local joined = table.concat(pieces)
        if #joined > 0 then
            table.insert(captured_chunks, joined)
            original_print("[load:func] captured "..#joined.." bytes (chunk #"..#captured_chunks..")")
        end
        return f, err
    end
    return original_load(x, chunkname, ...)
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

-- Dump captured chunks to numbered files so we can inspect them.
for i, chunk in ipairs(captured_chunks) do
    local out = script_path .. ".chunk_" .. i .. ".lua"
    local fh = io.open(out, "w")
    if fh then fh:write(chunk); fh:close() end
    original_print("[chunk " .. i .. "] wrote " .. out .. " (" .. #chunk .. " bytes)")
end
original_print("=== End ===")

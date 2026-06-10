-- XHider ENV Mode Dynamic Dumper
-- Hooks print and other functions to capture deobfuscated output

local original_print = print
local original_tostring = tostring

-- Capture all print calls
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

-- Load and execute the obfuscated script
local script_path = arg[1] or [[E:\dec bot2\env_mode\print_hi.lua]]

original_print("=== Loading script: " .. script_path .. " ===")

local f, err = loadfile(script_path)
if not f then
    original_print("Error loading: " .. tostring(err))
    return
end

local ok, result = pcall(f)
if not ok then
    original_print("Error executing: " .. tostring(result))
end

original_print("\n=== Captured Output ===")
for i, line in ipairs(captured_output) do
    original_print("[" .. i .. "] " .. line)
end
original_print("=== End ===")

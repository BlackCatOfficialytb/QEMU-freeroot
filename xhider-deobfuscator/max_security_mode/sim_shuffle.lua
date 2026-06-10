-- Simulate the K[2] shuffle
local seed = 1
if arg[1] then seed = tonumber(arg[1]) end
math.randomseed(seed)

local K2 = {}
local K4 = {}
for H = 1, 256 do K4[H] = H end

repeat
    local r_idx = math.random(1, #K4)
    local val = table.remove(K4, r_idx)
    K2[string.char(val - 1)] = val - 1
until #K4 == 0

-- Print standard Base64 characters to see their mapped values
local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789=+/"
for i = 1, #b64 do
    local c = b64:sub(i, i)
    io.write(string.format("%s:%d ", c, K2[c] or -1))
end
io.write("\n")

-- Print the whole K2 map in a way Python can read
for i = 0, 255 do
    local c = string.char(i)
    io.write(K2[c], ",")
end
io.write("\n")

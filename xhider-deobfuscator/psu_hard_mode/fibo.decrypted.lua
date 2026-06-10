-- XHider psu_hard Deobfuscated
-- Recovered via dynamic instrumentation: env_mode/hook_env.lua
-- ($ lua5.1 hook_env.lua fibo.lua)
-- Captured stdout: 0,1,1,2,3,5,8,13,21,34,55,89,144,233,377,610,987,1597,2584,4181,6765
-- => Fibonacci sequence, F(0) through F(20)
local a, b = 0, 1
for i = 1, 21 do
    print(a)
    a, b = b, a + b
end

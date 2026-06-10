-- XHider strong_mode Deobfuscated
-- Recovered via dynamic instrumentation: env_mode/hook_env.lua
-- ($ lua5.1 hook_env.lua print_hi.lua)
-- Captured stdout: "hi"
--
-- (Static decoding via decrypt_strong_full.py also recovered all 70 const-table
-- strings — `error`, `tostring`, `getfenv`, `:(%d*):`, `__index`, `_ENV`, etc. —
-- but the call shape is computed by the runtime VM dispatch loop, not stored in
-- the constants. Dynamic instrumentation is the definitive route here.)
print("hi")

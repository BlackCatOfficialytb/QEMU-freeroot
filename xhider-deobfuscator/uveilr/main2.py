#!/usr/bin/env python3
"""Environment Logger Tool - wraps a Lua/Luau script with environment logging proxies."""

import argparse
import sys

ENV_WRAPPER = r'''-- ===== Environment Logger Wrapper =====
local __ENV_LOG__ = {}
local __log_index__ = 0
local __start_time__ = os.clock()

local function __env_log__(action, key, value, extra)
    __log_index__ = __log_index__ + 1
    local entry = {
        n = __log_index__,
        t = os.clock() - __start_time__,
        action = action,
        key = tostring(key),
    }
    if value ~= nil then
        entry.value = tostring(value)
        entry.type = type(value)
    end
    if extra ~= nil then
        entry.extra = tostring(extra)
    end
    __ENV_LOG__[__log_index__] = entry
end

-- Save originals
local __real_G__ = _G
local __real_getfenv__ = getfenv
local __real_setfenv__ = setfenv
local __real_require__ = require
local __real_loadstring__ = loadstring
local __real_print__ = print
local __real_tostring__ = tostring
local __real_type__ = type
local __real_setmetatable__ = setmetatable
local __real_select__ = select
local __real_pcall__ = pcall
local __real_string__ = string
local __real_os__ = os
local __real_table__ = table

-- Hook getfenv
getfenv = function(level)
    __env_log__("getfenv", level or 1)
    return __real_getfenv__(level)
end

-- Hook setfenv
setfenv = function(target, env)
    __env_log__("setfenv", target, env)
    return __real_setfenv__(target, env)
end

-- Hook require
require = function(module)
    __env_log__("require", module)
    return __real_require__(module)
end

-- Hook loadstring
loadstring = function(code, chunkname)
    __env_log__("loadstring", chunkname or "(string)", __real_string__.sub(__real_tostring__(code), 1, 80))
    return __real_loadstring__(code, chunkname)
end

-- Proxy _G with __index/__newindex logging
local __G_proxy__ = __real_setmetatable__({}, {
    __index = function(_, key)
        local val = __real_G__[key]
        __env_log__("read", key, val)
        return val
    end,
    __newindex = function(_, key, value)
        __env_log__("write", key, value)
        __real_G__[key] = value
    end,
})

-- Load and run the original script with the proxy environment
local __chunk__, __err__ = __real_loadstring__(__ORIGINAL_SOURCE__, "@original_script")
if not __chunk__ then
    __real_print__("Error loading original script: " .. __real_tostring__(__err__))
    return
end
__real_setfenv__(__chunk__, __G_proxy__)
local __ok__, __result__ = __real_pcall__(__chunk__, ...)

-- Print environment log
__real_print__("\n===== ENVIRONMENT ACCESS LOG =====")
__real_print__(__real_string__.format("Total accesses: %d", #__ENV_LOG__))
__real_print__(__real_string__.rep("-", 60))
for __i__ = 1, #__ENV_LOG__ do
    local __e__ = __ENV_LOG__[__i__]
    local __line__ = __real_string__.format("[%04d] %.4fs  %-12s  %-30s", __e__.n, __e__.t, __e__.action, __e__.key)
    if __e__.value then
        __line__ = __line__ .. "  = " .. __e__.value .. " (" .. (__e__.type or "?") .. ")"
    end
    if __e__.extra then
        __line__ = __line__ .. "  | " .. __e__.extra
    end
    __real_print__(__line__)
end
__real_print__(__real_string__.rep("-", 60))
if not __ok__ then
    __real_print__("Script error: " .. __real_tostring__(__result__))
end
__real_print__("===== END LOG =====")

if __ok__ then return __result__ end
'''


def main():
    parser = argparse.ArgumentParser(description="Wrap a Lua/Luau script with environment logging.")
    parser.add_argument("input", help="Input Lua/Luau file")
    parser.add_argument("-o", "--output", required=True, help="Output file path")
    args = parser.parse_args()

    try:
        with open(args.input, "r", encoding="utf-8") as f:
            source = f.read()
    except FileNotFoundError:
        print(f"Error: Input file not found: {args.input}", file=sys.stderr)
        sys.exit(1)

    # Escape the source for embedding as a Lua long string
    # Find a long-string bracket level that doesn't appear in the source
    level = 0
    while (']' + '=' * level + ']') in source:
        level += 1
    open_bracket = '[' + '=' * level + '['
    close_bracket = ']' + '=' * level + ']'

    embedded_source = f'local __ORIGINAL_SOURCE__ = {open_bracket}\n{source}\n{close_bracket}\n'

    result = embedded_source + ENV_WRAPPER

    with open(args.output, "w", encoding="utf-8") as f:
        f.write(result)

    print(f"Wrote environment-logged script to {args.output}")


if __name__ == "__main__":
    main()

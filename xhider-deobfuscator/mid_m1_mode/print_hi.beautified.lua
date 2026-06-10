--// This file was created by XHider v1.2 [https://discord.gg/hATuHQaQRb]
return(
function( ... )
    local X =
    function(D)
        local b, X = D[ # D], ""
        for E = 1, # b, 1 do
            X = X .. b[D[E]]
        end
        return X
    end
    local D, b do
        local E = math.floor
        local T = math["random"]
        local o = table["remove"]
        local H = string.char
        local v = 0
        local r = 2
        local i = {}
        local x = {}
        local P = 0
        local a = {}
        for D = 1 , 256 , 1 do
            a[D] = D
        end
        repeat
        local D = T( 1 , # a)
        local b = o(a, D)x[b] = H(b - 1 )
    until # a == 0
    local O = {}
    local function q()
    if # O == 0 then
        v = (v * 19111530725610 ) % 35184372088832
        repeat r = (r * 203 ) % 257
    until r ~= 1
    local D = r % 32
    local b = (E(v / 2 ^ ( 13 - (r - D) / 32 )) % 4294967296 ) / 2 ^ D
    local T = E((b % 1 ) * 4294967296 ) + E(b)
    local o = T % 65536
    local H = (T - o) / 65536
    local i = o % 256
    local x = (o - i) / 256
    local P = H % 256
    local a = (H - P) / 256 O = {i, x, P, a}
end
return table["remove"](O)
end
local J = {}b = setmetatable({}, {["__index"] = J;
["__metatable"] = nil})
function D(b, X)
    local E = J
    if E[X]then
    else
        O = {}
        local D = x v = X % 35184372088832 r = X % 257
        local T = string.len(b)E[X] = ""
        local o = 155
        for T = 1 , T, 1 do
            o = ((string.byte(b, T) + q()) + o) % 256 E[X] = E[X] .. D[o + 1 ]
        end
    end
    return X
end
end
return(
function(E, o, H, v, r, i, x, q, V, P, B, S, a, J, T, O)P, q, a, V, T, J, B, S, O = {}, 0 , {},
    function(D)a[D] = a[D] - 1
        if a[D] == 0 then
            a[D], P[D] = nil, nil
        end
    end,
    function(T, H, v, r)
        local x, a, P
        while T do
            P = H x = b["print"]T = E[x]a = b["you cracked it yay, hi"]x = T(a)x = {}T = E[b["MS3ayrtjxTSakl"]]
        end T = # r
        return o(x)
    end,
    function(E)
        for D = 1 , # E, 1 do
            a[E[D]] = a[E[D]] + 1
        end
        if H then
            local T = H(true)
            local o = r(T)o[b["__index"]], o[b["__gc"]], o[b["__len"]] = E, B,
            function()
                return - 25856
            end
            return T else
                return v({}, {[b["__gc"]] = B;
                [b["__index"]] = E;
                [b["__len"]] =
                function()
                    return - 25856
                end})
            end
        end,
        function(D)
            local b, X = 1 , D[ 1 ]
            while X do
                a[X], b = a[X] - 1 , 1 + b
                if a[X] == 0 then
                    a[X], P[X] = nil, nil
                end X = D[b]
            end
        end,
        function(D, b)
            local X = J(b)
            local E =
            function( ... )
                return T(D, { ... }, b, X)
            end
            return E
        end,
        function()q = 1 + q a[q] = 1
            return q
        end
        return(S( 8224256 , {}))(o(x))
    end)(getfenv and getfenv()or _ENV, unpack or table[b["unpack"]], newproxy, setmetatable, getmetatable, select, { ... })
end)( ... )
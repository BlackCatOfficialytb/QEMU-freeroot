--// This file was created by XHider https://discord.com/invite/E2N7w35zkt
-- after beautify (no obf math)
return(
function (...)
local N, K do
local r = math.floor
local j=string.char
local n=string.byte
local function v(K, N)
local j = 0 for n= 0 , 7 , 1 do
local v = K/ 2 +N/ 2 if v~=r(v)then
j = j+ 2 ^n
end
K = r(K/ 2 )N=r(N/ 2 )
end
return j
end
local i = { 112 , 20 ;
744369 - 744335 , 255 }
local H = string.sub
local function y(r)
local K = {}for N= 1 , #r, 2 do
local j = H(r, N, N+ 1 )
local n=tonumber(j, 16 )K[#K+ 1 ]=n
end
return K
end
local b = "761422FF1779438B137C7D1422FF297B57DF316647DF3C7B518B51761422FF02754C9B1F79761422FF137B4C9C1160761422FF057A529E137F761422FF145E6EBA08637F1422FF02526FBA267B4395476D738B0A2672771422FF4A3C079B5A3D18711422FF4A7C1422FF1B2277CA48516A903F7B738D7D1422FF202378863D7269CB124658B604731422FF1D67453E1422FF24754F8F15664B911734469A0471418B15700CDF2078479E0371029C1F7A569E1360028B18710290077A478D507B44DF047C4B8C5067418D196456DF167B50DF11344C9A0734549A02674B901E3A501422FF24754F8F15664B911734469A0471418B15700CDF3566509002344190147118DF431422FF24754F8F15664B911734469A0471418B15700CDF247C4B8C507D4C9C19704791043455961C78029D1534509A007B508B15700C771422FF177156961E724D771422FF2F4B4B9114715A7A1422FF2F4B4C9A077D4C9B156C7B1422FF2F4B4F9A0475569E127847741422FF2F4B459C761422FF2F4B4F901471711422FF1B761422FF2F4B419E1C78751422FF2F4B4E9A1E771422FF2F4B529E196651781422FF2F4B4B8F117D508C771422FF2F4B469A1261457A1422FF2F4B5690036050961E73781422FF2F4B41901E77438B751422FF2F4B57911D751422FF2F4B439B14751422FF2F4B518A12751422FF2F4B4F8A1C751422FF2F4B469606751422FF2F4B4F9014751422FF2F4B529007741422FF2F4B478E741422FF2F4B4E8B741422FF2F4B4E9A7E1422FF00664D8B157756B81C7B409E1C67781422FF16614C9C047D4D91691422FF247C4B8C5079478B1160439D1C71029603344E90137F479B5E7C1422FF00664D8B157756AB11764E9A7F1422FF00664D8B157756B9057A418B197B4C721422FF1F67721422FF197B741422FF167D4E9A751422FF1471408A17771422FF177156971F7B497C1422FF02754C9B1F79718B027D4C98321C22FF1C7B419E1C346EA041386EA04234469050784D9C117802991C7B4D8D5C774A9E0238408604710E8B1F7A5792127150D3036140C21D7556975E724E901F660E8C04664B91173A419711660E8C04664B91173A408604710E8B1F7A5792127150D3036050961E730C8C057602931F7743935072579113604B901E3440871F660A9E5C760B931F77439350661FCF50724D8D507D1FCF5C230ECE50704DDF1C7B419E1C345AC2113B10D4123B10DF197202870E2944931F7B50D7083D5697157A028D4D6609CD2E7D029A1E70029E4D724E901F660A9E5F260B9D4D724E901F660A9D5F260B9A1E70028D1560578D1E3450DF157A46DF1C7B419E1C34499A09250E94156D10C2527D4B96187C4A96197D4B961867518C03360EDD2C2610CF2C2511CA2C2412CA2C667ECD43220ED42C2410C72C2413CA4C4813C7454813CA434810CF414810CE44307E912C2514C82C2410C62C2514C82C2611CA2C2412CF2C2412CF2C2412CE2C2412CF2C2412CF2C2412CE2C757ECF40247ECF40247ECF40247DA0197A469A084812CF464812CF404812CF404812CF404B7D9C11784EA3402417A3402412A3402412A3402412A02F794D9B2C2412CA2C2412CF2C2412CF2C2412CF2F4B4F8A1C364E9013754EDF1B715BCD2F7847914D2217DF1C7B419E1C34519A15707D8C05791FCE41221ADF1C7B419E1C34509A0671508C154B4F9014711F991178519A50784D9C11780299057A418B197B4CDF1471418D096456B7156C0A97156C7D8C04660B931F774393507847912F765B8B15671F840D724D8D507D1FCF5C270ECE50704DDF1C7B419E1C3452C2193E10D441344E9013754EDF18715AA0126D569A4D67579D587C47872F67568D5C640E8F5B250B931F77439350714C9C026D528B15701F8B1F7A5792127150D718715AA0126D569A5C2514D61C7B419E1C34469A13665B8F047146C2583C479113665B8F047146D20371479B2F675792593F10CA463D07CD452202931F774393507F4786414B408604711F9D096047D71B715BCE5C7D07CE463F13D61C7B419E1C34499A09267D9D096047C2126D569A587F478642384BDA1B715BCD2F7847915B250B93157A7D9D0960478C2B7D09CE2D2940871F660A9D087B50D71471418D0964569A1438499A09257D9D096047D65C7F4786424B408604710B9A1E7002931F774393507847914D3C0A93157A7D9D0960478C2B257FD41C714CA0126D569A034F10A25A2617C9593F4E9A1E4B4086047151A4434908C9452111C9593F4E9A1E4B4086047151A4444908CE462315C8422514DF1C7B419E1C34509A03614E8B4D6F5F931F77439350641FC650724D8D507D1FCE5C7847915C25029B1F344E9013754EDF18715AA0126D569A507D44DF0271549A026747A01D7B469A50754C9B507D07CD4D2912DF047C4791507C47872F765B8B1529518A123C4A9A084B518B023852D4413852D4413D0CD1036140D718715AA0036050D3003852D61578519A507C47872F765B8B1529518A123C4A9A084B518B023852D3003F13D6157A46DF1C7B419E1C34479113665B8F047146C2047B4C8A1D76478D587C47872F765B8B153813C959784D9C1178029B157750860060479B4D3C0A9A1E7750860060479B5D67479A144B518A1D3D09CD45220BDA422114DF1C7B419E1C34499A09257D961E7047874D3C4BD2413D07CE463F13DF1C7B419E1C34499A09267D961E7047874D3C4BD2413D0794156D10A01C714CD441344E9013754EDF1B715BCE2F765B8B1529408604710A94156D13D31B715BCE2F7D4C9B156C0B931F774393507F4786424B408604711F9D096047D71B715BCD5C7F4786424B4B9114715AD60271518A1C6079962D29419711660A9D087B50D7126C4D8D5870479C026D528B15700E94156D13A0126D569A5938499A09267D9D096047D659641F8F5B26029A1E70028D1560578D1E34569E127847D1137B4C9C11600A8D15675793043D479114344E9013754EDF157A418D0964569A1450438B1129598446231AC65C3616B9475164BC362114BB41561BCF492D15BD332760BB49231BBE332500820D784D9C1178028D15754EAC04664B9117671F840D587DCD4D67478B1D71569E04754093153C59825C6F7DA0197A469A0829448A1E7756961F7A0A8B5C7F0B8D1560578D1E34509A1178718B027D4C98034F49A2157A46D32F4B419E1C781F99057A418B197B4CD7043849D60271568A027A028D15754EAC04664B91176779942D714C9B5C4B7D921F701F99057A418B197B4CD7043849D60271568A027A028D15754EAC04664B91176779942D714C9B5C4B7D9205781F99057A418B197B4CD7043849D60271568A027A028D15754EAC04664B91176779942D714C9B4B4B7D921560438B11764E9A4D72439303715FD616614C9C047D4D9150587DCE5867479A143D4E9013754EDF02714393236050961E7351B31F7743934D66479E1C47568D197A458C507D44DF1E7B56DF02714393236050961E7351B31F7743932B67479A14495697157A02991F6602964D250EDC157A418D0964569A1450438B113813DF147B02931F77439350714C8B026D1F9A1E7750860060479B3475569E2B7D7F931F77439350714C8B026D7D8C157146C2046D529A58714C8B026D79CE2D3D1FC2527A5792127150DD117A46DF157A568D094F13A21F66029A1E6050862B267F961634479104665BA00371479B4D29519A1570028B18714CDF1C7B419E1C344A9A084B518B0229568600710A9A1E6050862B257FD64D29008C04664B91173643911434479104665BA441494D8D50714C8B026D79CD2D66479E1C47568D197A458C3C7B419E1C4F519A15707FC21471418D096456B7156C0A97156C7D8C04660B9D0271439450714C9B50714C9B50714C9B5066478B05664CDF0371479B50714C9B50714C9B506450961E600AB32F2679B32F250AC9472C1BD62D3D7A1422FF1C7B439B036050961E73741422FF1C7B439B711422FF30"
local q=y(b)
local a={}N=setmetatable({}, {__index=a, __metatable=nil})
function K(r)
local N = a if not N[r]then
local K = r+ 1
local n=((v(q[K], i[ 1 ])+v(q[K+ 1 ], i[ 2 ])* 256 )+v(q[K+ 2 ], i[ 3 ])* 65536 )+v(q[K+ 3 ], i[ 4 ])* 16777216 K=K+ 4
local H={}for r= 1 , n, 1 do
local N = (r- 1 )% 5 H[r]=j(v(q[(K+r)- 1 ], i[N]))
end
N[r]=table.concat(H)
end
return r
end
end
local r = {}do
local r = {}r[ 6 ]=true r[ 5 ]=string["gmatch"]r[ 4 ]=
function ()error("You Are Lost!")
end
r[ 10 ]=false r[ 1 ]=pcall(
function ()r[ 10 ]=true
end
)and r[ 10 ]r[ 3 ]=math["random"]r[ 14 ]=table["concat"]r[ 7 ]=table and table["unpack"]or unpack r[ 8 ]=r[ 3 ]( 3 , 65 )r[ 15 ]= 0 r[ 11 ]= 0 r[ 12 ]={pcall(
function ()
local j = {}j[ 1 ]= 4776465 -"dJLExw"^ 13435881
return "rFMEVoaj7yQtz2P"/j[ 1 ]
end
)}r[ 13 ]=r[ 12 ][ 2 ]r[ 9 ]=tonumber((r[ 5 ](tostring(r[ 13 ]), ":(%d*):"))())for
j = 1 , r[ 8 ], 1 do
local n = {}n[ 5 ]=j n[ 4 ]=math["random"]( 1 , 100 )n[ 3 ]=r[ 3 ]( 0 , 255 )n[ 2 ]=r[ 3 ]( 1 , n[ 4 ])n[ 1 ]=r[ 3 ]( 1 , 2 )== 1 n[ 8 ]=r[ 13 ]:gsub(":(%d*):", ":"..(tostring(r[ 3 ]( 0 , 10000 ))..":"))n[ 6 ]={pcall(
function ()
local j = {}if r[ 3 ]( 1 , 2 )== 1 or n[ 5 ]==r[ 8 ]then
local j = {}j[ 2 ]=tonumber((r[ 5 ](tostring(({pcall(
function ()
local n = {}n[ 2 ]= 606611 -"k6U58EHoOoQr"^ 360890
return "P7ZyMfK4bRzIt"/n[ 2 ]
end
)})[ 2 ]), ":(%d*):"))())r[ 6 ]=r[ 6 ]and r[ 9 ]==j[ 2 ]
end
if n[ 1 ]then
error(n[ 8 ], 0 )
end
j[ 1 ]={}for
K = 1 , n[ 4 ], 1 do
local N = {}N[ 1 ]=K j[ 1 ][N[ 1 ]]=r[ 3 ]( 0 , 255 )
end
j[ 1 ][n[ 2 ]]=n[ 3 ]return r[ 7 ](j[ 1 ])
end
)}if n[ 1 ]then
r[ 6 ]=r[ 6 ]and(n[ 6 ][ 1 ]==false and n[ 6 ][ 2 ]==n[ 8 ])else
r[ 6 ]=r[ 6 ]and n[ 6 ][ 1 ]r[ 15 ]=(r[ 15 ]+n[ 6 ][n[ 2 ]+ 1 ])% 256 r[ 11 ]=(r[ 11 ]+n[ 3 ])% 256
end
end
r[ 6 ]=r[ 6 ]and r[ 15 ]==r[ 11 ]if r[ 6 ]then
else
repeat return(
function ()while true do
l1, l2 = l2, l1 r[ 4 ]()
end
end
)()until true while true do
l2 = r[ 3 ]( 1 , 6 )if l2> 2 then
l2 = tostring(l1)else
l1 = l2
end
end
return
end
end
do
local j = {}j[ 14 ]=true j[ 12 ]=
function ()originalError({["msg"]="Tampering detected. Please contact the owner of this script for a new version."})while true do
end
end
j[ 15 ]=
function ()originalError("Tampering detected. Error code: "..math["random"]( 1000 , 9999 ))while true do
end
end
j[ 28 ]=
function ()originalError(
function ()
return "Tampering detected. This incident will be reported."
end
)while true do
end
end
j[ 23 ]={j[ 12 ];
j[ 15 ], j[ 28 ]}j[ 29 ]=j[ 23 ][math["random"]( 1 , #j[ 23 ])]j[ 39 ]=error j[ 34 ]=pairs j[ 40 ]=setmetatable j[ 46 ]=getmetatable j[ 20 ]=type j[ 2 ]=load j[ 27 ]=loadstring j[ 31 ]=pcall j[ 37 ]=math["random"]j[ 3 ]=xpcall j[ 25 ]=debug j[ 10 ]=debug["getinfo"]j[ 11 ]=package j[ 45 ]=coroutine j[ 19 ]=string j[ 13 ]=math j[ 33 ]=table j[ 5 ]=os j[ 7 ]=io j[ 22 ]=file j[ 18 ]={}j[ 44 ]={}for r, K in j[ 34 ](_G)do
local N = {}N[ 3 ], N[ 1 ]=r, K j[ 44 ][N[ 3 ]]=N[ 1 ]
end
j[ 32 ]=
function (r)
local n = {}n[ 3 ]=r n[ 1 ]={["__index"]=n[ 3 ], ["__newindex"]=
function (r, n, v)
local i = {}i[ 4 ], i[ 2 ], i[ 1 ]=r, n, v if j[ 44 ][i[ 2 ]]then
j[ 29 ]()else
j[ 44 ][i[ 2 ]]=i[ 1 ]
end
end
;
["__metatable"]=false, ["__gc"]=
function ()j[ 29 ]()
end
;
["__mode"]="k";
["__call"]=
function ()j[ 29 ]()
end
;
["__len"]=
function ()j[ 29 ]()
end
;
["__pairs"]=
function ()j[ 29 ]()
end
;
["__ipairs"]=
function ()j[ 29 ]()
end, ["__debug"]=
function ()j[ 29 ]()
end, ["__tostring"]=
function ()j[ 29 ]()
end, ["__concat"]=
function ()j[ 29 ]()
end, ["__unm"]=
function ()j[ 29 ]()
end, ["__add"]=
function ()j[ 29 ]()
end
;
["__sub"]=
function ()j[ 29 ]()
end
;
["__mul"]=
function ()j[ 29 ]()
end, ["__div"]=
function ()j[ 29 ]()
end
;
["__mod"]=
function ()j[ 29 ]()
end, ["__pow"]=
function ()j[ 29 ]()
end, ["__eq"]=
function ()j[ 29 ]()
end, ["__lt"]=
function ()j[ 29 ]()
end
;
["__le"]=
function ()j[ 29 ]()
end
}return j[ 40 ]({}, n[ 1 ])
end
j[ 18 ]["protectGlobals"]=
function ()for r, n in j[ 34 ](_G)do
local v = {}v[ 2 ], v[ 3 ]=r, n if j[ 20 ](v[ 3 ])=="function"then
j[ 44 ][v[ 2 ]]=v[ 3 ]
end
end
_G = j[ 32 ](j[ 44 ])j[ 40 ](_G, {["__metatable"]="This metatable is locked."})
end
j[ 18 ]["protectTable"]=
function (r)
local n = {}n[ 2 ]=r return j[ 32 ](n[ 2 ])
end
j[ 18 ]["protectFunction"]=
function (r)
local n = {}n[ 1 ]=r n[ 2 ]=
function (...)
return n[ 1 ](...)
end
return j[ 40 ]({}, {["__index"]=
function (r, v)
local i = {}i[ 1 ], i[ 3 ]=r, v if i[ 3 ]=="__call"then
return n[ 2 ]else
j[ 29 ]()
end
end
;
["__newindex"]=
function (r, n, v)j[ 29 ]()
end, ["__metatable"]=false;
["__gc"]=
function ()j[ 29 ]()
end
;
["__mode"]="k", ["__call"]=
function ()j[ 29 ]()
end, ["__len"]=
function ()j[ 29 ]()
end
;
["__pairs"]=
function ()j[ 29 ]()
end
;
["__ipairs"]=
function ()j[ 29 ]()
end, ["__debug"]=
function ()j[ 29 ]()
end
})
end
if error~=j[ 39 ]or pairs~=j[ 34 ]or setmetatable~=j[ 40 ]or getmetatable~=j[ 46 ]or type~=j[ 20 ]or load~=j[ 2 ]or loadstring~=j[ 27 ]or pcall~=j[ 31 ]or xpcall~=j[ 3 ]or debug~=j[ 25 ]or package~=j[ 11 ]or coroutine~=j[ 45 ]or string~=j[ 19 ]or math~=j[ 13 ]or table~=j[ 33 ]then
j[ 29 ]()
end
if pcall~=j[ 31 ]or math["random"]~=j[ 37 ]then
j[ 29 ]()
end
j[ 26 ]={"os", "io";
"file", "debug"}for r, n in ipairs(j[ 26 ])do
local v = {}v[ 3 ], v[ 2 ]=r, n if _G[v[ 2 ]]~=j[ 44 ][v[ 2 ]]then
j[ 29 ]()
end
end
j[ 9 ], j[ 4 ]=pcall(j[ 25 ]["gethook"])if j[ 9 ]then
if j[ 4 ]then
j[ 29 ]()
end
end
j[ 1 ]=string["gmatch"]j[ 35 ], j[ 24 ]=pcall(main)for r, K in ipairs(j[ 26 ])do
local N = {}N[ 1 ], N[ 3 ]=r, K if getmetatable(_G[N[ 3 ]])~=getmetatable(j[ 44 ][N[ 3 ]])then
j[ 29 ]()
end
end
j[ 36 ]=false j[ 21 ]=j[ 31 ](
function ()j[ 36 ]=true
end
)and j[ 36 ]j[ 17 ]=math["random"]j[ 41 ]=table["concat"]j[ 6 ]=table and table["unpack"]or unpack
n = j[ 37 ]( 3 , 65 )if n< 3 or n> 65 then
local r = {}r[ 2 ]=j[ 17 ]( 1 , 16777216 )-RandomStrings["randomString"]()^j[ 17 ]( 1 , 16777216 )
return RandomStrings["randomString"]()/r[ 2 ]
end
j[ 38 ]= 0 j[ 30 ]= 0 j[ 16 ]={pcall(
function ()
local r = {}r[ 2 ]=j[ 17 ]( 1 , 16777216 )-RandomStrings["randomString"]()^j[ 17 ]( 1 , 16777216 )
return RandomStrings["randomString"]()/r[ 2 ]
end
)}j[ 43 ]=j[ 16 ][ 2 ]j[ 8 ]=tonumber((j[ 1 ](tostring(j[ 43 ]), ":(%d*):"))())for
r = 1 , 100 , 1 do
local v = {}v[ 7 ]=r v[ 8 ]= 100 v[ 3 ]=v[ 7 ]% 256 v[ 5 ]=v[ 7 ]%v[ 8 ]+ 1 v[ 4 ]=v[ 7 ]% 2 == 0 v[ 6 ]=j[ 43 ]:gsub(":(%d*):", ":"..(tostring(j[ 17 ]( 0 , 10000 ))..":"))v[ 1 ]={pcall(
function ()
local r = {}if j[ 17 ]( 1 , 2 )== 1 or v[ 7 ]==n then
local r = {}r[ 1 ]=tonumber((j[ 1 ](tostring(({pcall(
function ()
local n = {}n[ 2 ]=j[ 17 ]( 1 , 16777216 )-RandomStrings["randomString"]()^j[ 17 ]( 1 , 16777216 )
return RandomStrings["randomString"]()/n[ 2 ]
end
)})[ 2 ]), ":(%d*):"))())j[ 14 ]=j[ 14 ]and j[ 8 ]==r[ 1 ]
end
if v[ 4 ]then
error(v[ 6 ], 0 )
end
r[ 2 ]={}for
K = 1 , v[ 8 ], 1 do
local N = {}N[ 2 ]=K r[ 2 ][N[ 2 ]]=j[ 17 ]( 0 , 255 )
end
r[ 2 ][v[ 5 ]]=v[ 3 ]return j[ 6 ](r[ 2 ])
end
)}if v[ 4 ]then
j[ 14 ]=j[ 14 ]and(v[ 1 ][ 1 ]==false and v[ 1 ][ 2 ]==v[ 6 ])else
j[ 14 ]=j[ 14 ]and v[ 1 ][ 1 ]j[ 38 ]=(j[ 38 ]+v[ 1 ][v[ 5 ]+ 1 ])% 256 j[ 30 ]=(j[ 30 ]+v[ 3 ])% 256
end
end
j[ 14 ]=j[ 14 ]and j[ 38 ]==j[ 30 ]if j[ 14 ]then
else
repeat return(
function ()j[ 29 ]()
end
)()until true return
end
end
r[ 3 ]="local L_1,L_2 do local floor,char,byte,tonumber,sub=math.floor,string.char,string.byte,tonumber,string.sub local function bxor(a,b)local r=0 for i=0,7,1 do local x=a/2+b/2 if x~=floor(x)then r=r+2^i end a=floor(a/2)b=floor(b/2)end return r end local key1,key2=\"iiihhhiiiiihssss\",\"\\220\\135\\005\\r\\236,+\\028\\015<\\185\\153\\201\\214$\\n\\167\\029\\167\\235\\000\\000\\001\\000\\000\\001\\a\\000\\000\\000__index\\006\\000\\000\\000__call\\005\\000\\000\\000__mod\\005\\000\\000\\000__mul\"local key2_len=65 local seed_sum=1168 local reverse_mode=false local function decryptHex(hex_str)local len_bytes={}for i=0,3,1 do local p=i*2+1 local hex_byte=sub(hex_str,p,p+1)local encrypted=tonumber(hex_byte,16)local decrypted=((encrypted-seed_sum)+256)%256 local key1_byte=byte(key1,i%16+1)local key2_byte=byte(key2,i%key2_len+1)len_bytes[i+1]=bxor(bxor(decrypted,key1_byte),key2_byte)end local len=((len_bytes[1]+len_bytes[2]*256)+len_bytes[3]*65536)+len_bytes[4]*16777216 local result={}local p=9 for i=1,len,1 do local hex_byte if reverse_mode and i%2==0 then hex_byte=sub(hex_str,p+1,p+1)..sub(hex_str,p,p)else hex_byte=sub(hex_str,p,p+1)end local encrypted=tonumber(hex_byte,16)local decrypted=((encrypted-seed_sum)+256)%256 local key1_index=(i-1)%16+1 local key2_index=(i-1)%key2_len+1 local key1_byte=byte(key1,key1_index)local key2_byte=byte(key2,key2_index)result[i]=char(bxor(bxor(decrypted,key1_byte),key2_byte))p=p+2 end return table.concat(result)end local encryptedData={{6789,\"4F7EFCF56D1B90997BC3BD979AC1\"}}local realStrings={}L_2=setmetatable({},{__index=function(t,k)return realStrings[k]end,__call=function(t,k)return realStrings[k]end,__mod=function(t,k)return realStrings[k]end,__mul=function(t,k)return realStrings[k]end;__metatable=false})function L_1(seed)local realStringsLocal=realStrings if not realStringsLocal[seed]then for i=1,#encryptedData,1 do local entry=encryptedData[i]local entry_seed=type(entry[1])==\"number\"and entry[1]or entry[2]if entry_seed==seed then local hex_str=type(entry[1])==\"string\"and entry[1]or entry[2]realStringsLocal[seed]=decryptHex(hex_str)break end end end return seed end end print(L_2[L_1(6789)])"r[ 8 ]=getfenv and getfenv()or _ENV r[ 2 ]=r[ 8 ]["loadstring"]or r[ 8 ]["load"]r[ 1 ], r[ 7 ]=r[ 2 ](r[ 3 ], "@")if setfenv then
setfenv(r[ 1 ], r[ 8 ])
end
r[ 5 ], r[ 6 ]=pcall(r[ 1 ])if not r[ 5 ]then
error(r[ 6 ])
end
return r[ 6 ]
end
)(...)
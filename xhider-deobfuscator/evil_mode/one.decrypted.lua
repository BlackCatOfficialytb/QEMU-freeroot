--// This file was created by XHider https://discord.com/invite/E2N7w35zkt

return (function(...)
	local D, M;
	do
		local o = math.floor;
		local p = math.random;
		local n = table.remove;
		local e = string.char;
		local U = 0;
		local g = 2;
		local Z = {};
		local l = {};
		local W = 0;
		local Y = {};
		for D = 1, 256, 1 do
			Y[D] = D;
		end;
		repeat
			local D = p(1, #Y);
			local M = n(Y, D);
			l[M] = e(M - 1);
		until #Y == 0;
		local I = {};
		local function A()
			if #I == 0 then
				U = (U * 89 + 34013992534017) % 35184372088832;
				repeat
					g = (g * 163) % 257;
				until g ~= 1;
				local D = g % 32;
				local M = (o(U / 2 ^ (13 - (g - D) / 32)) % 4294967296.0) / 2 ^ D;
				local p = o((M % 1) * 4294967296.0) + o(M);
				local n = p % 65536;
				local e = (p - n) / 65536;
				local Z = n % 256;
				local l = (n - Z) / 256;
				local W = e % 256;
				local Y = (e - W) / 256;
				I = {
						Z,
						l,
						W,
						Y,
					};
			end;
			return table.remove(I);
		end;
		local f = {};
		M = setmetatable({}, { __index = f, __metatable = nil });
		function D(D, M)
			local o = f;
			if o[M] then
 
			else
				I = {};
				local p = l;
				U = M % 35184372088832;
				g = M % 255 + 2;
				local n = string.len(D);
				o[M] = "";
				local e = 244;
				for n = 1, n, 1 do
					e = ((string.byte(D, n) + A()) + e) % 256;
					o[M] = o[M] .. p[e + 1];
				end;
			end;
			return M;
		end;
	end;
	do
		ply = game["Players"];
		plr = ply["LocalPlayer"];
		Root = plr["Character"]["HumanoidRootPart"];
		replicated = game:GetService("ReplicatedStorage");
		Lv = game["Players"]["LocalPlayer"]["Data"]["Level"]["Value"];
		TeleportService = game:GetService("TeleportService");
		TW = game:GetService("TweenService");
		Lighting = game:GetService("Lighting");
		Enemies = workspace["Enemies"];
		vim1 = game:GetService("VirtualInputManager");
		vim2 = game:GetService("VirtualUser");
		TeamSelf = plr["Team"];
		RunSer = game:GetService("RunService");
		Stats = game:GetService("Stats");
		Energy = plr["Character"]["Energy"]["Value"];
		Boss = {};
		BringConnections = {};
		MaterialList = {};
		NPCList = {};
		shouldTween = false;
		SoulGuitar = false;
		KenTest = true;
		debug = false;
		Brazier1 = false;
		Brazier2 = false;
		Brazier3 = false;
		Sec = .1;
		ClickState = 0;
		Num_self = 25;
	end;
	repeat
		local o = (plr["PlayerGui"]:WaitForChild("Main")):WaitForChild("Loading") and game:IsLoaded();
		wait();
	until o;
	World1 = game["PlaceId"] == 2753915549;
	World2 = game["PlaceId"] == 4442272183;
	World3 = game["PlaceId"] == 7449423635;
	Sea = World1 or World2 or World3 or plr:Kick("â Error : A[12]Blox Fruits â");
	Marines = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("SetTeam", "Marines");
		end;
	Pirates = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("SetTeam", "Pirates");
		end;
	if World1 then
		Boss = {
				"The Gorilla King",
				"Bobby",
				"The Saw",
				"Yeti",
				"Mob Leader",
				"Vice Admiral",
				"Saber Expert",
				"Warden",
				"Chief Warden",
				"Swan",
				"Magma Admiral",
				"Fishman Lord",
				"Wysper",
				"Thunder God",
				"Cyborg",
				"Ice Admiral",
				"Greybeard",
			};
	elseif World2 then
		Boss = {
				"Diamond",
				"Jeremy",
				"Fajita",
				"Don Swan",
				"Smoke Admiral",
				"Awakened Ice Admiral",
				"Tide Keeper",
				"Darkbeard",
				"Cursed Captain",
				"Order",
			};
	elseif World3 then
		Boss = {
				"Stone",
				"Hydra Leader",
				"Kilo Admiral",
				"Captain Elephant",
				"Beautiful Pirate",
				"Cake Queen",
				"Longma",
				"Soul Reaper",
			};
	end;
	if World1 then
		MaterialList = {
				"Leather + Scrap Metal",
				"Angel Wings",
				"Magma Ore",
				"Fish Tail",
			};
	elseif World2 then
		MaterialList = {
				"Leather + Scrap Metal",
				"Radioactive Material",
				"Ectoplasm",
				"Mystic Droplet",
				"Magma Ore",
				"Vampire Fang",
			};
	elseif World3 then
		MaterialList = {
				"Scrap Metal",
				"Demonic Wisp",
				"Conjured Cocoa",
				"Dragon Scale",
				"Gunpowder",
				"Fish Tail",
				"Mini Tusk",
			};
	end;
	local o = {
			"Flame",
			"Ice",
			"Quake",
			"Light",
			"Dark",
			"String",
			"Rumble",
			"Magma",
			"Human: Buddha",
			"Sand",
			"Bird: Phoenix",
			"Dough",
		};
	local p = {
			"Snow Lurker",
			"Arctic Warrior",
			"Hidden Key",
			"Awakened Ice Admiral",
		};
	local n = {
			["Mob"] = "Mythological Pirate",
			["Mob2"] = "Cursed Skeleton",
			"Hell's Messenger",
			["Mob3"] = "Cursed Skeleton",
			"Heaven's Guardian",
		};
	local e = {
			"Part",
			"SpawnLocation",
			"Terrain",
			"WedgePart",
			"MeshPart",
		};
	local U = { "Swan Pirate", "Jeremy" };
	local g = { "Forest Pirate", "Captain Elephant" };
	local Z = { "Fajita", "Jeremy", "Diamond" };
	local l = {
			"Beast Hunter",
			"Lantern",
			"Guardian",
			"Grand Brigade",
			"Dinghy",
			"Sloop",
			"The Sentinel",
		};
	local W = { "Cookie Crafter" };
	local Y = { "Reborn Skeleton" };
	local I = {
			["Pirate Millionaire"] = CFrame["new"](-712.82727050781, 98.577049255371, 5711.9541015625),
			["Pistol Billionaire"] = CFrame["new"](-723.43316650391, 147.42906188965, 5931.9931640625),
			["Dragon Crew Warrior"] = CFrame["new"](7021.5043945312, 55.762702941895, -730.12908935547),
			["Dragon Crew Archer"] = CFrame["new"](6625, 378, 244),
			["Female Islander"] = CFrame["new"](4692.7939453125, 797.97668457031, 858.84802246094),
			["Venomous Assailant"] = CFrame["new"](4902, 670, 39),
			["Marine Commodore"] = CFrame["new"](2401, 123, -7589),
			["Marine Rear Admiral"] = CFrame["new"](3588, 229, -7085),
			["Fishman Raider"] = CFrame["new"](-10941, 332, -8760),
			["Fishman Captain"] = CFrame["new"](-11035, 332, -9087),
			["Forest Pirate"] = CFrame["new"](-13446, 413, -7760),
			["Mythological Pirate"] = CFrame["new"](-13510, 584, -6987),
			["Jungle Pirate"] = CFrame["new"](-11778, 426, -10592),
			["Musketeer Pirate"] = CFrame["new"](-13282, 496, -9565),
			["Reborn Skeleton"] = CFrame["new"](-8764, 142, 5963),
			["Living Zombie"] = CFrame["new"](-10227, 421, 6161),
			["Demonic Soul"] = CFrame["new"](-9579, 6, 6194),
			["Posessed Mummy"] = CFrame["new"](-9579, 6, 6194),
			["Peanut Scout"] = CFrame["new"](-1993, 187, -10103),
			["Peanut President"] = CFrame["new"](-2215, 159, -10474),
			["Ice Cream Chef"] = CFrame["new"](-877, 118, -11032),
			["Ice Cream Commander"] = CFrame["new"](-877, 118, -11032),
			["Cookie Crafter"] = CFrame["new"](-2021, 38, -12028),
			["Cake Guard"] = CFrame["new"](-2024, 38, -12026),
			["Baking Staff"] = CFrame["new"](-1932, 38, -12848),
			["Head Baker"] = CFrame["new"](-1932, 38, -12848),
			["Cocoa Warrior"] = CFrame["new"](95, 73, -12309),
			["Chocolate Bar Battler"] = CFrame["new"](647, 42, -12401),
			["Sweet Thief"] = CFrame["new"](116, 36, -12478),
			["Candy Rebel"] = CFrame["new"](47, 61, -12889),
			["Ghost"] = CFrame["new"](5251, 5, 1111),
		};
	EquipWeapon = function(o)
			if not o then
				return;
			end;
			if plr["Backpack"]:FindFirstChild(o) then
				plr["Character"]["Humanoid"]:EquipTool(plr["Backpack"]:FindFirstChild(o));
			end;
		end;
	weaponSc = function(o)
			for p, n in pairs(plr["Backpack"]:GetChildren()) do
				if n:IsA("Tool") then
					if n["ToolTip"] == o then
						EquipWeapon(n["Name"]);
					end;
				end;
			end;
		end;
	hookfunction(require((game:GetService("ReplicatedStorage"))["Effect"]["Container"]["Death"]), function()
 
	end);
	hookfunction((require((game:GetService("ReplicatedStorage")):WaitForChild("GuideModule")))["ChangeDisplayedNPC"], function()
 
	end);
	hookfunction(error, function()
 
	end);
	hookfunction(warn, function()
 
	end);
	local A = workspace:FindFirstChild("Rocks");
	if A then
		A:Destroy();
	end;
	gay = (function()
			local o = game:GetService("Lighting");
			local p = o:FindFirstChild("LightingLayers");
			if p and (game:GetService("Lighting") and game:GetService("Lighting")) then
				local o = p:FindFirstChild("DarkFog");
				if o then
					o:Destroy();
				end;
			end;
			local n = workspace["_WorldOrigin"]["Foam;"];
			if n and workspace["_WorldOrigin"]["Foam;"] then
				n:Destroy();
			end;
		end)();
	local f = {};
	f["__index"] = f;
	f["Alive"] = function(o)
			if not o then
				return;
			end;
			local p = o:FindFirstChild("Humanoid");
			return p and p["Health"] > 0;
		end;
	f["Pos"] = function(o, p)
			return (Root["Position"] - mode["Position"])["Magnitude"] <= p;
		end;
	f["Dist"] = function(o, p)
			return (Root["Position"] - (o:FindFirstChild("HumanoidRootPart"))["Position"])["Magnitude"] <= p;
		end;
	f["DistH"] = function(o, p)
			return (Root["Position"] - (o:FindFirstChild("HumanoidRootPart"))["Position"])["Magnitude"] > p;
		end;
	f["Kill"] = function(o, p)
			if o and p then
				if not o:GetAttribute("Locked") then
					o:SetAttribute("Locked", o["HumanoidRootPart"]["CFrame"]);
				end;
				PosMon = (o:GetAttribute("Locked"))["Position"];
				BringEnemy();
				EquipWeapon(_G["SelectWeapon"]);
				local p = game["Players"]["LocalPlayer"]["Character"]:FindFirstChildOfClass("Tool");
				local n = p["ToolTip"];
				if n == "Blox Fruit" then
					_tp((o["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 10, 0)) * CFrame["Angles"](0, math["rad"](90), 0));
				else
					_tp((o["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 30, 0)) * CFrame["Angles"](0, math["rad"](180), 0));
				end;
				if RandomCFrame then
					wait(.5);
					_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 30, 25));
					wait(.5);
					_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](25, 30, 0));
					wait(.5);
					_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](-25, 30, 0));
					wait(.5);
					_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 30, 25));
					wait(.5);
					_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](-25, 30, 0));
				end;
			end;
		end;
	f["Kill2"] = function(o, p)
			if o and p then
				if not o:GetAttribute("Locked") then
					o:SetAttribute("Locked", o["HumanoidRootPart"]["CFrame"]);
				end;
				PosMon = (o:GetAttribute("Locked"))["Position"];
				BringEnemy();
				EquipWeapon(_G["SelectWeapon"]);
				local p = game["Players"]["LocalPlayer"]["Character"]:FindFirstChildOfClass("Tool");
				local n = p["ToolTip"];
				if n == "Blox Fruit" then
					_tp((o["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 10, 0)) * CFrame["Angles"](0, math["rad"](90), 0));
				else
					_tp((o["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 30, 8)) * CFrame["Angles"](0, math["rad"](180), 0));
				end;
				if RandomCFrame then
					wait(.1);
					_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 30, 25));
					wait(.1);
					_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](25, 30, 0));
					wait(.1);
					_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](-25, 30, 0));
					wait(.1);
					_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 30, 25));
					wait(.1);
					_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](-25, 30, 0));
				end;
			end;
		end;
	f["KillSea"] = function(o, p)
			if o and p then
				if not o:GetAttribute("Locked") then
					o:SetAttribute("Locked", o["HumanoidRootPart"]["CFrame"]);
				end;
				PosMon = (o:GetAttribute("Locked"))["Position"];
				BringEnemy();
				EquipWeapon(_G["SelectWeapon"]);
				local p = game["Players"]["LocalPlayer"]["Character"]:FindFirstChildOfClass("Tool");
				local n = p["ToolTip"];
				if n == "Blox Fruit" then
					_tp((o["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 10, 0)) * CFrame["Angles"](0, math["rad"](90), 0));
				else
					notween(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 50, 8));
					wait(.85);
					notween(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 400, 0));
					wait(1);
				end;
			end;
		end;
	f["Sword"] = function(o, p)
			if o and p then
				if not o:GetAttribute("Locked") then
					o:SetAttribute("Locked", o["HumanoidRootPart"]["CFrame"]);
				end;
				PosMon = (o:GetAttribute("Locked"))["Position"];
				BringEnemy();
				weaponSc("Sword");
				_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 30, 0));
				if RandomCFrame then
					wait(.1);
					_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 30, 25));
					wait(.1);
					_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](25, 30, 0));
					wait(.1);
					_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](-25, 30, 0));
					wait(.1);
					_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 30, 25));
					wait(.1);
					_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](-25, 30, 0));
				end;
			end;
		end;
	f["Mas"] = function(o, p)
			if o and p then
				if not o:GetAttribute("Locked") then
					o:SetAttribute("Locked", o["HumanoidRootPart"]["CFrame"]);
				end;
				PosMon = (o:GetAttribute("Locked"))["Position"];
				BringEnemy();
				if o["Humanoid"]["Health"] <= HealthM then
					_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 20, 0));
					Useskills("Blox Fruit", "Z");
					Useskills("Blox Fruit", "X");
					Useskills("Blox Fruit", "C");
				else
					weaponSc("Melee");
					_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 30, 0));
				end;
			end;
		end;
	f["Masgun"] = function(o, p)
			if o and p then
				if not o:GetAttribute("Locked") then
					o:SetAttribute("Locked", o["HumanoidRootPart"]["CFrame"]);
				end;
				PosMon = (o:GetAttribute("Locked"))["Position"];
				BringEnemy();
				if o["Humanoid"]["Health"] <= HealthM then
					_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 35, 8));
					Useskills("Gun", "Z");
					Useskills("Gun", "X");
				else
					weaponSc("Melee");
					_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 30, 0));
				end;
			end;
		end;
	statsSetings = function(o, p)
			if o == "Melee" then
				if plr["Data"]["Points"]["Value"] ~= 0 then
					replicated["Remotes"]["CommF_"]:InvokeServer("AddPoint", "Melee", p);
				end;
			elseif o == "Defense" then
				if plr["Data"]["Points"]["Value"] ~= 0 then
					replicated["Remotes"]["CommF_"]:InvokeServer("AddPoint", "Defense", p);
				end;
			elseif o == "Sword" then
				if plr["Data"]["Points"]["Value"] ~= 0 then
					replicated["Remotes"]["CommF_"]:InvokeServer("AddPoint", "Sword", p);
				end;
			elseif o == "Gun" then
				if plr["Data"]["Points"]["Value"] ~= 0 then
					replicated["Remotes"]["CommF_"]:InvokeServer("AddPoint", "Gun", p);
				end;
			elseif o == "Devil" then
				if plr["Data"]["Points"]["Value"] ~= 0 then
					replicated["Remotes"]["CommF_"]:InvokeServer("AddPoint", "Demon Fruit", p);
				end;
			end;
		end;
	BringEnemy = function()
			if not _B then
				return;
			end;
			for o, p in pairs(workspace["Enemies"]:GetChildren()) do
				if p:FindFirstChild("Humanoid") and p["Humanoid"]["Health"] > 0 then
					if (p["PrimaryPart"]["Position"] - PosMon)["Magnitude"] <= 300 then
						p["PrimaryPart"]["CFrame"] = CFrame["new"](PosMon);
						p["PrimaryPart"]["CanCollide"] = true;
						(p:FindFirstChild("Humanoid"))["WalkSpeed"] = 0;
						(p:FindFirstChild("Humanoid"))["JumpPower"] = 0;
						if p["Humanoid"]:FindFirstChild("Animator") then
							p["Humanoid"]["Animator"]:Destroy();
						end;
						plr["SimulationRadius"] = math["huge"];
					end;
				end;
			end;
		end;
	Useskills = function(o, p)
			if o == "Melee" then
				weaponSc("Melee");
				if p == "Z" then
					vim1:SendKeyEvent(true, "Z", false, game);
					vim1:SendKeyEvent(false, "Z", false, game);
				elseif p == "X" then
					vim1:SendKeyEvent(true, "X", false, game);
					vim1:SendKeyEvent(false, "X", false, game);
				elseif p == "C" then
					vim1:SendKeyEvent(true, "C", false, game);
					vim1:SendKeyEvent(false, "C", false, game);
				end;
			elseif o == "Sword" then
				weaponSc("Sword");
				if p == "Z" then
					vim1:SendKeyEvent(true, "Z", false, game);
					vim1:SendKeyEvent(false, "Z", false, game);
				elseif p == "X" then
					vim1:SendKeyEvent(true, "X", false, game);
					vim1:SendKeyEvent(false, "X", false, game);
				end;
			elseif o == "Blox Fruit" then
				weaponSc("Blox Fruit");
				if p == "Z" then
					vim1:SendKeyEvent(true, "Z", false, game);
					vim1:SendKeyEvent(false, "Z", false, game);
				elseif p == "X" then
					vim1:SendKeyEvent(true, "X", false, game);
					vim1:SendKeyEvent(false, "X", false, game);
				elseif p == "C" then
					vim1:SendKeyEvent(true, "C", false, game);
					vim1:SendKeyEvent(false, "C", false, game);
				elseif p == "V" then
					vim1:SendKeyEvent(true, "V", false, game);
					vim1:SendKeyEvent(false, "V", false, game);
				end;
			elseif o == "Gun" then
				weaponSc("Gun");
				if p == "Z" then
					vim1:SendKeyEvent(true, "Z", false, game);
					vim1:SendKeyEvent(false, "Z", false, game);
				elseif p == "X" then
					vim1:SendKeyEvent(true, "X", false, game);
					vim1:SendKeyEvent(false, "X", false, game);
				end;
			end;
			if o == "nil" and p == "Y" then
				vim1:SendKeyEvent(true, "Y", false, game);
				vim1:SendKeyEvent(false, "Y", false, game);
			end;
		end;
	local z = getrawmetatable(game);
	local N = z["__namecall"];
	setreadonly(z, false);
	z["__namecall"] = newcclosure(function(...)
			local o = getnamecallmethod();
			local p = { ... };
			if tostring(o) == "FireServer" then
				if tostring(p[1]) == "RemoteEvent" then
					if tostring(p[2]) ~= "true" and tostring(p[2]) ~= "false" then
						if _G["FarmMastery_G"] and not SoulGuitar or _G["FarmMastery_Dev"] or _G["FarmBlazeEM"] or _G["Prehis_Skills"] or _G["SeaBeast1"] or _G["FishBoat"] or _G["PGB"] or _G["Leviathan1"] or _G["Complete_Trials"] or _G["AimMethod"] and ABmethod == "AimBots Skill" or _G["AimMethod"] and ABmethod == "Auto Aimbots" then
							p[2] = MousePos;
							return N(unpack(p));
						end;
					end;
				end;
			end;
			return N(...);
		end);
	GetConnectionEnemies = function(o)
			for p, n in pairs(replicated:GetChildren()) do
				if n:IsA("Model") and ((typeof(o) == "table" and table["find"](o, n["Name"]) or n["Name"] == o) and (n:FindFirstChild("Humanoid") and n["Humanoid"]["Health"] > 0)) then
					return n;
				end;
			end;
			for p, n in next, game["Workspace"]["Enemies"]:GetChildren() do
				if n:IsA("Model") and ((typeof(o) == "table" and table["find"](o, n["Name"]) or n["Name"] == o) and (n:FindFirstChild("Humanoid") and n["Humanoid"]["Health"] > 0)) then
					return n;
				end;
			end;
		end;
	LowCpu = function()
			local o = true;
			local p = game;
			local n = p["Workspace"];
			local e = p["Lighting"];
			local U = n["Terrain"];
			U["WaterWaveSize"] = 0;
			U["WaterWaveSpeed"] = 0;
			U["WaterReflectance"] = 0;
			U["WaterTransparency"] = 0;
			e["GlobalShadows"] = false;
			e["FogEnd"] = 9000000000.0;
			e["Brightness"] = 0;
			(settings())["Rendering"]["QualityLevel"] = "Level01";
			for p, n in pairs(p:GetDescendants()) do
				if n:IsA("Part") or n:IsA("Union") or n:IsA("CornerWedgePart") or n:IsA("TrussPart") then
					n["Material"] = "Plastic";
					n["Reflectance"] = 0;
				elseif n:IsA("Decal") or n:IsA("Texture") and o then
					n["Transparency"] = 1;
				elseif n:IsA("ParticleEmitter") or n:IsA("Trail") then
					n["Lifetime"] = NumberRange["new"](0);
				elseif n:IsA("Explosion") then
					n["BlastPressure"] = 1;
					n["BlastRadius"] = 1;
				elseif n:IsA("Fire") or n:IsA("SpotLight") or n:IsA("Smoke") or n:IsA("Sparkles") then
					n["Enabled"] = false;
				elseif n:IsA("MeshPart") then
					n["Material"] = "Plastic";
					n["Reflectance"] = 0;
					n["TextureID"] = 10385902758728957;
				end;
			end;
			for o, p in pairs(e:GetChildren()) do
				if p:IsA("BlurEffect") or p:IsA("SunRaysEffect") or p:IsA("ColorCorrectionEffect") or p:IsA("BloomEffect") or p:IsA("DepthOfFieldEffect") then
					p["Enabled"] = false;
				end;
			end;
		end;
	CheckF = function()
			if GetBP("Dragon-Dragon") or GetBP("Gas-Gas") or GetBP("Yeti-Yeti") or GetBP("Kitsune-Kitsune") or GetBP("T-Rex-T-Rex") then
				return true;
			end;
		end;
	CheckBoat = function()
			for o, p in pairs(workspace["Boats"]:GetChildren()) do
				if tostring(p["Owner"]["Value"]) == tostring(plr["Name"]) then
					return p;
				end;
			end;
			return false;
		end;
	CheckEnemiesBoat = function()
			for o, p in pairs(workspace["Enemies"]:GetChildren()) do
				if p["Name"] == "FishBoat" and (p:FindFirstChild("Health"))["Value"] > 0 then
					return true;
				end;
			end;
			return false;
		end;
	CheckPirateGrandBrigade = function()
			for o, p in pairs(workspace["Enemies"]:GetChildren()) do
				if (p["Name"] == "PirateGrandBrigade" or p["Name"] == "PirateBrigade") and (p:FindFirstChild("Health"))["Value"] > 0 then
					return true;
				end;
			end;
			return false;
		end;
	CheckShark = function()
			for o, p in pairs(workspace["Enemies"]:GetChildren()) do
				if p["Name"] == "Shark" and f["Alive"](p) then
					return true;
				end;
			end;
			return false;
		end;
	CheckTerrorShark = function()
			for o, p in pairs(workspace["Enemies"]:GetChildren()) do
				if p["Name"] == "Terrorshark" and f["Alive"](p) then
					return true;
				end;
			end;
			return false;
		end;
	CheckPiranha = function()
			for o, p in pairs(workspace["Enemies"]:GetChildren()) do
				if p["Name"] == "Piranha" and f["Alive"](p) then
					return true;
				end;
			end;
			return false;
		end;
	CheckFishCrew = function()
			for o, p in pairs(workspace["Enemies"]:GetChildren()) do
				if (p["Name"] == "Fish Crew Member" or p["Name"] == "Haunted Crew Member") and f["Alive"](p) then
					return true;
				end;
			end;
			return false;
		end;
	CheckHauntedCrew = function()
			for o, p in pairs(workspace["Enemies"]:GetChildren()) do
				if p["Name"] == "Haunted Crew Member" and f["Alive"](p) then
					return true;
				end;
			end;
			return false;
		end;
	CheckSeaBeast = function()
			if workspace["SeaBeasts"]:FindFirstChild("SeaBeast1") then
				return true;
			end;
			return false;
		end;
	CheckLeviathan = function()
			if workspace["SeaBeasts"]:FindFirstChild("Leviathan") then
				return true;
			end;
			return false;
		end;
	UpdStFruit = function()
			for o, p in next, plr["Backpack"]:GetChildren() do
				StoreFruit = p:FindFirstChild("EatRemote", true);
				if StoreFruit then
					replicated["Remotes"]["CommF_"]:InvokeServer("StoreFruit", StoreFruit["Parent"]:GetAttribute("OriginalName"), plr["Backpack"]:FindFirstChild(p["Name"]));
				end;
			end;
		end;
	collectFruits = function(o)
			if o then
				local o = plr["Character"];
				for p, n in pairs(workspace:GetChildren()) do
					if string["find"](n["Name"], "Fruit") then
						n["Handle"]["CFrame"] = o["HumanoidRootPart"]["CFrame"];
					end;
				end;
			end;
		end;
	Getmoon = function()
			if World1 then
				return Lighting["FantasySky"]["MoonTextureId"];
			elseif World2 then
				return Lighting["FantasySky"]["MoonTextureId"];
			elseif World3 then
				return Lighting["Sky"]["MoonTextureId"];
			end;
		end;
	DropFruits = function()
			for o, p in next, plr["Backpack"]:GetChildren() do
				if string["find"](p["Name"], "Fruit") then
					EquipWeapon(p["Name"]);
					wait(.1);
					if plr["PlayerGui"]["Main"]["Dialogue"]["Visible"] == true then
						plr["PlayerGui"]["Main"]["Dialogue"]["Visible"] = false;
					end;
					EquipWeapon(p["Name"]);
					(plr["Character"]:FindFirstChild(p["Name"]))["EatRemote"]:InvokeServer("Drop");
				end;
			end;
			for o, p in pairs(plr["Character"]:GetChildren()) do
				if string["find"](p["Name"], "Fruit") then
					EquipWeapon(p["Name"]);
					wait(.1);
					if plr["PlayerGui"]["Main"]["Dialogue"]["Visible"] == true then
						plr["PlayerGui"]["Main"]["Dialogue"]["Visible"] = false;
					end;
					EquipWeapon(p["Name"]);
					(plr["Character"]:FindFirstChild(p["Name"]))["EatRemote"]:InvokeServer("Drop");
				end;
			end;
		end;
	GetBP = function(o)
			return plr["Backpack"]:FindFirstChild(o) or plr["Character"]:FindFirstChild(o);
		end;
	GetIn = function(o)
			for p, n in pairs(replicated["Remotes"]["CommF_"]:InvokeServer("getInventory")) do
				if type(n) == "table" then
					if n["Name"] == o or plr["Character"]:FindFirstChild(o) or plr["Backpack"]:FindFirstChild(o) then
						return true;
					end;
				end;
			end;
			return false;
		end;
	GetM = function(o)
			for p, n in pairs(replicated["Remotes"]["CommF_"]:InvokeServer("getInventory")) do
				if type(n) == "table" then
					if n["Type"] == "Material" then
						if n["Name"] == o then
							return n["Count"];
						end;
					end;
				end;
			end;
			return 0;
		end;
	GetWP = function(o)
			for p, n in pairs(replicated["Remotes"]["CommF_"]:InvokeServer("getInventory")) do
				if type(n) == "table" then
					if n["Type"] == "Sword" then
						if n["Name"] == o or plr["Character"]:FindFirstChild(o) or plr["Backpack"]:FindFirstChild(o) then
							return true;
						end;
					end;
				end;
			end;
			return false;
		end;
	getInfinity_Ability = function(o, p)
			if not Root then
				return;
			end;
			if o == "Soru" and p then
				for o, n in next, getgc() do
					if plr["Character"]["Soru"] then
						if typeof(n) == "function" and (getfenv(n))["script"] == plr["Character"]["Soru"] then
							for o, n in next, getupvalues(n) do
								if typeof(n) == "table" then
									repeat
										wait(Sec);
										n["LastUse"] = 0;
									until not p or plr["Character"]["Humanoid"]["Health"] <= 0;
								end;
							end;
						end;
					end;
				end;
			elseif o == "Energy" and p then
				plr["Character"]["Energy"]["Changed"]:connect(function()
					if p then
						plr["Character"]["Energy"]["Value"] = Energy;
					end;
				end);
			elseif o == "Observation" and p then
				local o = plr["VisionRadius"];
				o["Value"] = math["huge"];
			end;
		end;
	Hop = function()
			pcall(function()
				for o = math["random"](1, math["random"](40, 75)), 100, 1 do
					local p = replicated["__ServerBrowser"]:InvokeServer(o);
					for o, p in next, p do
						if tonumber(p["Count"]) < 12 then
							TeleportService:TeleportToPlaceInstance(game["PlaceId"], o);
						end;
					end;
				end;
			end);
		end;
	local E = Instance["new"]("Part", workspace);
	E["Size"] = Vector3["new"](1, 1, 1);
	E["Name"] = "Rip_Indra";
	E["Anchored"] = true;
	E["CanCollide"] = false;
	E["CanTouch"] = false;
	E["Transparency"] = 1;
	local Q = workspace:FindFirstChild(E["Name"]);
	if Q and Q ~= E then
		Q:Destroy();
	end;
	task["spawn"](function()
		while task["wait"]() do
			if E and E["Parent"] == workspace then
				if shouldTween then
					(getgenv())["OnFarm"] = true;
				else
					(getgenv())["OnFarm"] = false;
				end;
			else
				(getgenv())["OnFarm"] = false;
			end;
		end;
	end);
	task["spawn"](function()
		local o = game["Players"]["LocalPlayer"];
		repeat
			task["wait"]();
		until o["Character"] and o["Character"]["PrimaryPart"];
		E["CFrame"] = o["Character"]["PrimaryPart"]["CFrame"];
		while task["wait"]() do
			pcall(function()
				if (getgenv())["OnFarm"] then
					if E and E["Parent"] == workspace then
						local p = o["Character"] and o["Character"]["PrimaryPart"];
						if p and (p["Position"] - E["Position"])["Magnitude"] <= 200 then
							p["CFrame"] = E["CFrame"];
						else
							E["CFrame"] = p["CFrame"];
						end;
					end;
					local p = o["Character"];
					if p then
						for o, p in pairs(p:GetChildren()) do
							if p:IsA("BasePart") then
								p["CanCollide"] = false;
							end;
						end;
					end;
				else
					local p = o["Character"];
					if p then
						for o, p in pairs(p:GetChildren()) do
							if p:IsA("BasePart") then
								p["CanCollide"] = true;
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	_tp = function(o)
			local p = plr["Character"];
			if not p or not p:FindFirstChild("HumanoidRootPart") then
				return;
			end;
			local n = p["HumanoidRootPart"];
			local e = (o["Position"] - n["Position"])["Magnitude"];
			local U = TweenInfo["new"](e / 300, Enum["EasingStyle"]["Linear"]);
			local g = (game:GetService("TweenService")):Create(E, U, { ["CFrame"] = o });
			if plr["Character"]["Humanoid"]["Sit"] == true then
				E["CFrame"] = CFrame["new"](E["Position"]["X"], o["Y"], E["Position"]["Z"]);
			end;
			g:Play();
			task["spawn"](function()
				while g["PlaybackState"] == Enum["PlaybackState"]["Playing"] do
					if not shouldTween then
						g:Cancel();
						break;
					end;
					task["wait"](.1);
				end;
			end);
		end;
	TeleportToTarget = function(o)
			if (o["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] > 1000 then
				_tp(o);
			else
				_tp(o);
			end;
		end;
	notween = function(o)
			plr["Character"]["HumanoidRootPart"]["CFrame"] = o;
		end;
	function BTP(o)
		local p = game["Players"]["LocalPlayer"];
		local n = p["Character"]["HumanoidRootPart"];
		local e = p["Character"]["Humanoid"];
		local U = p["PlayerGui"]["Main"];
		local g = o["Position"];
		local Z = n["Position"];
		repeat
			e["Health"] = 0;
			n["CFrame"] = o;
			U["Quest"]["Visible"] = false;
			if (n["Position"] - Z)["Magnitude"] > 1 then
				Z = n["Position"];
				n["CFrame"] = o;
			end;
			task["wait"](.5);
		until (o["Position"] - n["Position"])["Magnitude"] <= 2000;
	end;
	spawn(function()
		while task["wait"]() do
			pcall(function()
				if _G["SailBoat_Hydra"] or _G["WardenBoss"] or _G["AutoFactory"] or _G["HighestMirage"] or _G["HCM"] or _G["PGB"] or _G["Leviathan1"] or _G["UPGDrago"] or _G["Complete_Trials"] or _G["TpDrago_Prehis"] or _G["BuyDrago"] or _G["AutoFireFlowers"] or _G["DT_Uzoth"] or _G["AutoBerry"] or _G["Prehis_Find"] or _G["Prehis_Skills"] or _G["Prehis_DB"] or _G["Prehis_DE"] or _G["FarmBlazeEM"] or _G["Dojoo"] or _G["CollectPresent"] or _G["AutoLawKak"] or _G["TpLab"] or _G["AutoPhoenixF"] or _G["AutoFarmChest"] or _G["AutoHytHallow"] or _G["LongsWord"] or _G["BlackSpikey"] or _G["AutoHolyTorch"] or _G["TrainDrago"] or _G["AutoSaber"] or _G["FarmMastery_Dev"] or _G["CitizenQuest"] or _G["AutoEctoplasm"] or _G["KeysRen"] or _G["Auto_Rainbow_Haki"] or _G["obsFarm"] or _G["AutoBigmom"] or _G["Doughv2"] or _G["AuraBoss"] or _G["Raiding"] or _G["Auto_Cavender"] or _G["TpPly"] or _G["Bartilo_Quest"] or _G["Level"] or _G["FarmEliteHunt"] or _G["AutoZou"] or _G["AutoFarm_Bone"] or (getgenv())["AutoMaterial"] or _G["CraftVM"] or _G["FrozenTP"] or _G["TPDoor"] or _G["AcientOne"] or _G["AutoFarmNear"] or _G["AutoRaidCastle"] or _G["DarkBladev3"] or _G["AutoFarmRaid"] or _G["Auto_Cake_Prince"] or _G["Addealer"] or _G["TPNpc"] or _G["TwinHook"] or _G["FindMirage"] or _G["FarmChestM"] or _G["Shark"] or _G["TerrorShark"] or _G["Piranha"] or _G["MobCrew"] or _G["SeaBeast1"] or _G["FishBoat"] or _G["AutoPole"] or _G["AutoPoleV2"] or _G["Auto_SuperHuman"] or _G["AutoDeathStep"] or _G["Auto_SharkMan_Karate"] or _G["Auto_Electric_Claw"] or _G["AutoDragonTalon"] or _G["Auto_Def_DarkCoat"] or _G["Auto_God_Human"] or _G["Auto_Tushita"] or _G["AutoMatSoul"] or _G["AutoKenVTWO"] or _G["AutoSerpentBow"] or _G["AutoFMon"] or _G["Auto_Soul_Guitar"] or _G["TPGEAR"] or _G["AutoSaw"] or _G["AutoTridentW2"] or _G["Auto_StartRaid"] or _G["AutoEvoRace"] or _G["AutoGetQuestBounty"] or _G["MarinesCoat"] or _G["TravelDres"] or _G["Defeating"] or _G["DummyMan"] or _G["Auto_Yama"] or _G["Auto_SwanGG"] or _G["SwanCoat"] or _G["AutoEcBoss"] or _G["Auto_Mink"] or _G["Auto_Human"] or _G["Auto_Skypiea"] or _G["Auto_Fish"] or _G["CDK_TS"] or _G["CDK_YM"] or _G["CDK"] or _G["AutoFarmGodChalice"] or _G["AutoFistDarkness"] or _G["AutoMiror"] or _G["Teleport"] or _G["AutoKilo"] or _G["AutoGetUsoap"] or _G["Praying"] or _G["TryLucky"] or _G["AutoColShad"] or _G["AutoUnHaki"] or _G["Auto_DonAcces"] or _G["AutoRipIngay"] or _G["DragoV3"] or _G["DragoV1"] or _G["SailBoats"] or NextIs or _G["FarmGodChalice"] or _G["IceBossRen"] or senth or senth2 or _G["Lvthan"] or _G["beasthunter"] or _G["DangerLV"] or _G["Relic123"] or _G["tweenKitsune"] or _G["Collect_Ember"] or _G["AutofindKitIs"] or _G["snaguine"] or _G["TwFruits"] or _G["tweenKitShrine"] or _G["Tp_LgS"] or _G["Tp_MasterA"] or _G["tweenShrine"] or _G["FarmMastery_G"] or _G["FarmMastery_S"] then
					shouldTween = true;
					if not plr["Character"]["HumanoidRootPart"]:FindFirstChild("BodyClip") then
						local o = Instance["new"]("BodyVelocity");
						o["Name"] = "BodyClip";
						o["Parent"] = plr["Character"]["HumanoidRootPart"];
						o["MaxForce"] = Vector3["new"](100000, 100000, 100000);
						o["Velocity"] = Vector3["new"](0, 0, 0);
					end;
					if not plr["Character"]:FindFirstChild("highlight") then
						local o = Instance["new"]("Highlight");
						o["Name"] = "highlight";
						o["Enabled"] = true;
						o["FillColor"] = Color3["fromRGB"](2, 197, 60);
						o["OutlineColor"] = Color3["fromRGB"](255, 255, 255);
						o["FillTransparency"] = .5;
						o["OutlineTransparency"] = .2;
						o["Parent"] = plr["Character"];
					end;
					for o, p in pairs(plr["Character"]:GetDescendants()) do
						if p:IsA("BasePart") then
							p["CanCollide"] = false;
						end;
					end;
				else
					shouldTween = false;
					if plr["Character"]["HumanoidRootPart"]:FindFirstChild("BodyClip") then
						(plr["Character"]["HumanoidRootPart"]:FindFirstChild("BodyClip")):Destroy();
					end;
					if plr["Character"]:FindFirstChild("highlight") then
						(plr["Character"]:FindFirstChild("highlight")):Destroy();
					end;
				end;
			end);
		end;
	end);
	QuestB = function()
			if World1 then
				if _G["FindBoss"] == "The Gorilla King" then
					bMon = "The Gorilla King";
					Qname = "JungleQuest";
					Qdata = 3;
					PosQBoss = CFrame["new"](-1601.6553955078, 36.85213470459, 153.38809204102);
					PosB = CFrame["new"](-1088.75977, 8.13463783, -488.559906, -0.707134247, 0, .707079291, 0, 1, 0, -0.707079291, 0, -0.707134247);
				elseif _G["FindBoss"] == "Bobby" then
					bMon = "Bobby";
					Qname = "BuggyQuest1";
					Qdata = 3;
					PosQBoss = CFrame["new"](-1140.1761474609, 4.752049446106, 3827.4057617188);
					PosB = CFrame["new"](-1087.3760986328, 46.949409484863, 4040.1462402344);
				elseif _G["FindBoss"] == "The Saw" then
					bMon = "The Saw";
					PosB = CFrame["new"](-784.89715576172, 72.427383422852, 1603.5822753906);
				elseif _G["FindBoss"] == "Yeti" then
					bMon = "Yeti";
					Qname = "SnowQuest";
					Qdata = 3;
					PosQBoss = CFrame["new"](1386.8073730469, 87.272789001465, -1298.3576660156);
					PosB = CFrame["new"](1218.7956542969, 138.01184082031, -1488.0262451172);
				elseif _G["FindBoss"] == "Mob Leader" then
					bMon = "Mob Leader";
					PosB = CFrame["new"](-2844.7307128906, 7.4180502891541, 5356.6723632813);
				elseif _G["FindBoss"] == "Vice Admiral" then
					bMon = "Vice Admiral";
					Qname = "MarineQuest2";
					Qdata = 2;
					PosQBoss = CFrame["new"](-5036.2465820313, 28.677835464478, 4324.56640625);
					PosB = CFrame["new"](-5006.5454101563, 88.032081604004, 4353.162109375);
				elseif _G["FindBoss"] == "Saber Expert" then
					bMon = "Saber Expert";
					PosB = CFrame["new"](-1458.89502, 29.8870335, -50.633564);
				elseif _G["FindBoss"] == "Warden" then
					bMon = "Warden";
					Qname = "ImpelQuest";
					Qdata = 1;
					PosB = CFrame["new"](5278.04932, 2.15167475, 944.101929, .220546961, -4.49946401e-006, .975376427, -1.95412576e-005, 1, 9.03162072e-006, -0.975376427, -2.10519756e-005, .220546961);
					PosQBoss = CFrame["new"](5191.86133, 2.84020686, 686.438721, -0.731384635, 0, .681965172, 0, 1, 0, -0.681965172, 0, -0.731384635);
				elseif _G["FindBoss"] == "Chief Warden" then
					bMon = "Chief Warden";
					Qname = "ImpelQuest";
					Qdata = 2;
					PosB = CFrame["new"](5206.92578, .997753382, 814.976746, .342041343, -0.00062915677, .939684749, .00191645394, .999998152, -2.80422337e-005, -0.939682961, .00181045406, .342041939);
					PosQBoss = CFrame["new"](5191.86133, 2.84020686, 686.438721, -0.731384635, 0, .681965172, 0, 1, 0, -0.681965172, 0, -0.731384635);
				elseif _G["FindBoss"] == "Swan" then
					bMon = "Swan";
					Qname = "ImpelQuest";
					Qdata = 3;
					PosB = CFrame["new"](5325.09619, 7.03906584, 719.570679, -0.309060812, 0, .951042235, 0, 1, 0, -0.951042235, 0, -0.309060812);
					PosQBoss = CFrame["new"](5191.86133, 2.84020686, 686.438721, -0.731384635, 0, .681965172, 0, 1, 0, -0.681965172, 0, -0.731384635);
				elseif _G["FindBoss"] == "Magma Admiral" then
					bMon = "Magma Admiral";
					Qname = "MagmaQuest";
					Qdata = 3;
					PosQBoss = CFrame["new"](-5314.6220703125, 12.262420654297, 8517.279296875);
					PosB = CFrame["new"](-5765.8969726563, 82.92064666748, 8718.3046875);
				elseif _G["FindBoss"] == "Fishman Lord" then
					bMon = "Fishman Lord";
					Qname = "FishmanQuest";
					Qdata = 3;
					PosQBoss = CFrame["new"](61122.65234375, 18.497442245483, 1569.3997802734);
					PosB = CFrame["new"](61260.15234375, 30.950881958008, 1193.4329833984);
				elseif _G["FindBoss"] == "Wysper" then
					bMon = "Wysper";
					Qname = "SkyExp1Quest";
					Qdata = 3;
					PosQBoss = CFrame["new"](-7861.947265625, 5545.517578125, -379.85974121094);
					PosB = CFrame["new"](-7866.1333007813, 5576.4311523438, -546.74816894531);
				elseif _G["FindBoss"] == "Thunder God" then
					bMon = "Thunder God";
					Qname = "SkyExp2Quest";
					Qdata = 3;
					PosQBoss = CFrame["new"](-7903.3828125, 5635.9897460938, -1410.923828125);
					PosB = CFrame["new"](-7994.984375, 5761.025390625, -2088.6479492188);
				elseif _G["FindBoss"] == "Cyborg" then
					bMon = "Cyborg";
					Qname = "FountainQuest";
					Qdata = 3;
					PosQBoss = CFrame["new"](5258.2788085938, 38.526931762695, 4050.044921875);
					PosB = CFrame["new"](6094.0249023438, 73.770050048828, 3825.7348632813);
				elseif _G["FindBoss"] == "Ice Admiral" then
					bMon = "Ice Admiral";
					Qdata = nil;
					PosQBoss = CFrame["new"](1266.08948, 26.1757946, -1399.57678, -0.573599219, 0, -0.81913656, 0, 1, 0, .81913656, 0, -0.573599219);
					PosB = CFrame["new"](1266.08948, 26.1757946, -1399.57678, -0.573599219, 0, -0.81913656, 0, 1, 0, .81913656, 0, -0.573599219);
				elseif _G["FindBoss"] == "Greybeard" then
					bMon = "Greybeard";
					Qdata = nil;
					PosQBoss = CFrame["new"](-5081.3452148438, 85.221641540527, 4257.3588867188);
					PosB = CFrame["new"](-5081.3452148438, 85.221641540527, 4257.3588867188);
				end;
			end;
			if World2 then
				if _G["FindBoss"] == "Diamond" then
					bMon = "Diamond";
					Qname = "Area1Quest";
					Qdata = 3;
					PosQBoss = CFrame["new"](-427.5666809082, 73.313781738281, 1835.4208984375);
					PosB = CFrame["new"](-1576.7166748047, 198.59265136719, 13.724286079407);
				elseif _G["FindBoss"] == "Jeremy" then
					bMon = "Jeremy";
					Qname = "Area2Quest";
					Qdata = 3;
					PosQBoss = CFrame["new"](636.79943847656, 73.413787841797, 918.00415039063);
					PosB = CFrame["new"](2006.9261474609, 448.95666503906, 853.98284912109);
				elseif _G["FindBoss"] == "Fajita" then
					bMon = "Fajita";
					Qname = "MarineQuest3";
					Qdata = 3;
					PosQBoss = CFrame["new"](-2441.986328125, 73.359344482422, -3217.5324707031);
					PosB = CFrame["new"](-2172.7399902344, 103.32216644287, -4015.025390625);
				elseif _G["FindBoss"] == "Don Swan" then
					bMon = "Don Swan";
					PosB = CFrame["new"](2286.2004394531, 15.177839279175, 863.8388671875);
				elseif _G["FindBoss"] == "Smoke Admiral" then
					bMon = "Smoke Admiral";
					Qname = "IceSideQuest";
					Qdata = 3;
					PosQBoss = CFrame["new"](-5429.0473632813, 15.977565765381, -5297.9614257813);
					PosB = CFrame["new"](-5275.1987304688, 20.757257461548, -5260.6669921875);
				elseif _G["FindBoss"] == "Awakened Ice Admiral" then
					bMon = "Awakened Ice Admiral";
					Qname = "FrostQuest";
					Qdata = 3;
					PosQBoss = CFrame["new"](5668.9780273438, 28.519989013672, -6483.3520507813);
					PosB = CFrame["new"](6403.5439453125, 340.29766845703, -6894.5595703125);
				elseif _G["FindBoss"] == "Tide Keeper" then
					bMon = "Tide Keeper";
					Qname = "ForgottenQuest";
					Qdata = 3;
					PosQBoss = CFrame["new"](-3053.9814453125, 237.18954467773, -10145.0390625);
					PosB = CFrame["new"](-3795.6423339844, 105.88877105713, -11421.307617188);
				elseif _G["FindBoss"] == "Darkbeard" then
					bMon = "Darkbeard";
					Qdata = nil;
					PosQBoss = CFrame["new"](3677.08203125, 62.751937866211, -3144.8332519531);
					PosB = CFrame["new"](3677.08203125, 62.751937866211, -3144.8332519531);
				elseif _G["FindBoss"] == "Cursed Captaim" then
					bMon = "Cursed Captain";
					Qdata = nil;
					PosQBoss = CFrame["new"](916.928589, 181.092773, 33422);
					PosB = CFrame["new"](916.928589, 181.092773, 33422);
				elseif _G["FindBoss"] == "Order" then
					bMon = "Order";
					Qdata = nil;
					PosQBoss = CFrame["new"](-6217.2021484375, 28.047645568848, -5053.1357421875);
					PosB = CFrame["new"](-6217.2021484375, 28.047645568848, -5053.1357421875);
				end;
			end;
			if World3 then
				if _G["FindBoss"] == "Stone" then
					bMon = "Stone";
					Qname = "PiratePortQuest";
					Qdata = 3;
					PosQBoss = CFrame["new"](-289.76705932617, 43.819011688232, 5579.9384765625);
					PosB = CFrame["new"](-1027.6512451172, 92.404174804688, 6578.8530273438);
				elseif _G["FindBoss"] == "Hydra Leader" then
					bMon = "Hydra Leader";
					Qname = "AmazonQuest2";
					Qdata = 3;
					PosQBoss = CFrame["new"](5821.8979492188, 1019.0950927734, -73.719230651855);
					PosB = CFrame["new"](5821.8979492188, 1019.0950927734, -73.719230651855);
				elseif _G["FindBoss"] == "Kilo Admiral" then
					bMon = "Kilo Admiral";
					Qname = "MarineTreeIsland";
					Qdata = 3;
					PosQBoss = CFrame["new"](2179.3010253906, 28.731239318848, -6739.9741210938);
					PosB = CFrame["new"](2764.2233886719, 432.46154785156, -7144.4580078125);
				elseif _G["FindBoss"] == "Captain Elephant" then
					bMon = "Captain Elephant";
					Qname = "DeepForestIsland";
					Qdata = 3;
					PosQBoss = CFrame["new"](-13232.682617188, 332.40396118164, -7626.01171875);
					PosB = CFrame["new"](-13376.7578125, 433.28689575195, -8071.392578125);
				elseif _G["FindBoss"] == "Beautiful Pirate" then
					bMon = "Beautiful Pirate";
					Qname = "DeepForestIsland2";
					Qdata = 3;
					PosQBoss = CFrame["new"](-12682.096679688, 390.88653564453, -9902.1240234375);
					PosB = CFrame["new"](5283.609375, 22.56223487854, -110.78285217285);
				elseif _G["FindBoss"] == "Cake Queen" then
					bMon = "Cake Queen";
					Qname = "IceCreamIslandQuest";
					Qdata = 3;
					PosQBoss = CFrame["new"](-819.376709, 64.9259796, -10967.2832, -0.766061664, 0, .642767608, 0, 1, 0, -0.642767608, 0, -0.766061664);
					PosB = CFrame["new"](-678.648804, 381.353943, -11114.2012, -0.908641815, .00149294338, .41757378, .00837114919, .999857843, .0146408929, -0.417492568, .0167988986, -0.90852499);
				elseif _G["FindBoss"] == "Longma" then
					bMon = "Longma";
					Qdata = nil;
					PosQBoss = CFrame["new"](-10238.875976563, 389.7912902832, -9549.7939453125);
					PosB = CFrame["new"](-10238.875976563, 389.7912902832, -9549.7939453125);
				elseif _G["FindBoss"] == "Soul Reaper" then
					bMon = "Soul Reaper";
					Qdata = nil;
					PosQBoss = CFrame["new"](-9524.7890625, 315.80429077148, 6655.7192382813);
					PosB = CFrame["new"](-9524.7890625, 315.80429077148, 6655.7192382813);
				end;
			end;
		end;
	QuestBeta = function()
			local o = QuestB();
			return {
				[0] = _G["FindBoss"],
				[1] = bMon,
				[2] = Qdata,
				[3] = Qname,
				[4] = PosB,
			};
		end;
	QuestCheck = function()
			local o = game["Players"]["LocalPlayer"]["Data"]["Level"]["Value"];
			if World1 then
				if o == 1 or o <= 9 then
					if tostring(TeamSelf) == "Marines" then
						Mon = "Trainee";
						Qname = "MarineQuest";
						Qdata = 1;
						NameMon = "Trainee";
						PosM = CFrame["new"](-2709.67944, 24.5206585, 2104.24585, -0.744724929, -3.97967455e-008, -0.667371571, 4.32403588e-008, 1, -1.07884304e-007, .667371571, -1.09201515e-007, -0.744724929);
						PosQ = CFrame["new"](-2709.67944, 24.5206585, 2104.24585, -0.744724929, -3.97967455e-008, -0.667371571, 4.32403588e-008, 1, -1.07884304e-007, .667371571, -1.09201515e-007, -0.744724929);
					elseif tostring(TeamSelf) == "Pirates" then
						Mon = "Bandit";
						Qdata = 1;
						Qname = "BanditQuest1";
						NameMon = "Bandit";
						PosM = CFrame["new"](1045.9626464844, 27.002508163452, 1560.8203125);
						PosQ = CFrame["new"](1045.9626464844, 27.002508163452, 1560.8203125);
					end;
				elseif o == 10 or o <= 14 then
					Mon = "Monkey";
					Qdata = 1;
					Qname = "JungleQuest";
					NameMon = "Monkey";
					PosQ = CFrame["new"](-1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, 0, -1, 0, 0);
					PosM = CFrame["new"](-1448.5180664062, 67.853012084961, 11.465796470642);
				elseif o == 15 or o <= 29 then
					Mon = "Gorilla";
					Qdata = 2;
					Qname = "JungleQuest";
					NameMon = "Gorilla";
					PosQ = CFrame["new"](-1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, 0, -1, 0, 0);
					PosM = CFrame["new"](-1129.8836669922, 40.46354675293, -525.42370605469);
				elseif o == 30 or o <= 39 then
					Mon = "Pirate";
					Qdata = 1;
					Qname = "BuggyQuest1";
					NameMon = "Pirate";
					PosQ = CFrame["new"](-1141.07483, 4.10001802, 3831.5498, .965929627, 0, -0.258804798, 0, 1, 0, .258804798, 0, .965929627);
					PosM = CFrame["new"](-1103.5134277344, 13.752052307129, 3896.0910644531);
				elseif o == 40 or o <= 59 then
					Mon = "Brute";
					Qdata = 2;
					Qname = "BuggyQuest1";
					NameMon = "Brute";
					PosQ = CFrame["new"](-1141.07483, 4.10001802, 3831.5498, .965929627, 0, -0.258804798, 0, 1, 0, .258804798, 0, .965929627);
					PosM = CFrame["new"](-1140.0837402344, 14.809885025024, 4322.9213867188);
				elseif o == 60 or o <= 74 then
					Mon = "Desert Bandit";
					Qdata = 1;
					Qname = "DesertQuest";
					NameMon = "Desert Bandit";
					PosQ = CFrame["new"](894.488647, 5.14000702, 4392.43359, .819155693, 0, -0.573571265, 0, 1, 0, .573571265, 0, .819155693);
					PosM = CFrame["new"](924.7998046875, 6.4486746788025, 4481.5859375);
				elseif o == 75 or o <= 89 then
					Mon = "Desert Officer";
					Qdata = 2;
					Qname = "DesertQuest";
					NameMon = "Desert Officer";
					PosQ = CFrame["new"](894.488647, 5.14000702, 4392.43359, .819155693, 0, -0.573571265, 0, 1, 0, .573571265, 0, .819155693);
					PosM = CFrame["new"](1608.2822265625, 8.6142244338989, 4371.0073242188);
				elseif o == 90 or o <= 99 then
					Mon = "Snow Bandit";
					Qdata = 1;
					Qname = "SnowQuest";
					NameMon = "Snow Bandit";
					PosQ = CFrame["new"](1389.74451, 88.1519318, -1298.90796, -0.342042685, 0, .939684391, 0, 1, 0, -0.939684391, 0, -0.342042685);
					PosM = CFrame["new"](1354.3479003906, 87.272773742676, -1393.9465332031);
				elseif o == 100 or o <= 119 then
					Mon = "Snowman";
					Qdata = 2;
					Qname = "SnowQuest";
					NameMon = "Snowman";
					PosQ = CFrame["new"](1389.74451, 88.1519318, -1298.90796, -0.342042685, 0, .939684391, 0, 1, 0, -0.939684391, 0, -0.342042685);
					PosM = CFrame["new"](6241.9951171875, 51.522083282471, -1243.9771728516);
				elseif o == 120 or o <= 149 then
					Mon = "Chief Petty Officer";
					Qdata = 1;
					Qname = "MarineQuest2";
					NameMon = "Chief Petty Officer";
					PosQ = CFrame["new"](-5039.58643, 27.3500385, 4324.68018, 0, 0, -1, 0, 1, 0, 1, 0, 0);
					PosM = CFrame["new"](-4881.2309570312, 22.652044296265, 4273.7524414062);
				elseif o == 150 or o <= 174 then
					Mon = "Sky Bandit";
					Qdata = 1;
					Qname = "SkyQuest";
					NameMon = "Sky Bandit";
					PosQ = CFrame["new"](-4839.53027, 716.368591, -2619.44165, .866007268, 0, .500031412, 0, 1, 0, -0.500031412, 0, .866007268);
					PosM = CFrame["new"](-4953.20703125, 295.74420166016, -2899.2290039062);
				elseif o == 175 or o <= 189 then
					Mon = "Dark Master";
					Qdata = 2;
					Qname = "SkyQuest";
					NameMon = "Dark Master";
					PosQ = CFrame["new"](-4839.53027, 716.368591, -2619.44165, .866007268, 0, .500031412, 0, 1, 0, -0.500031412, 0, .866007268);
					PosM = CFrame["new"](-5259.8447265625, 391.39767456055, -2229.0354003906);
				elseif o == 190 or o <= 209 then
					Mon = "Prisoner";
					Qdata = 1;
					Qname = "PrisonerQuest";
					NameMon = "Prisoner";
					PosQ = CFrame["new"](5308.93115, 1.65517521, 475.120514, -0.0894274712, -5.00292918e-009, -0.995993316, 1.60817859e-009, 1, -5.16744869e-009, .995993316, -2.06384709e-009, -0.0894274712);
					PosM = CFrame["new"](5098.9736328125, -0.3204058110714, 474.23733520508);
				elseif o == 210 or o <= 249 then
					Mon = "Dangerous Prisoner";
					Qdata = 2;
					Qname = "PrisonerQuest";
					NameMon = "Dangerous Prisoner";
					PosQ = CFrame["new"](5308.93115, 1.65517521, 475.120514, -0.0894274712, -5.00292918e-009, -0.995993316, 1.60817859e-009, 1, -5.16744869e-009, .995993316, -2.06384709e-009, -0.0894274712);
					PosM = CFrame["new"](5654.5634765625, 15.633401870728, 866.29919433594);
				elseif o == 250 or o <= 274 then
					Mon = "Toga Warrior";
					Qdata = 1;
					Qname = "ColosseumQuest";
					NameMon = "Toga Warrior";
					PosQ = CFrame["new"](-1580.04663, 6.35000277, -2986.47534, -0.515037298, 0, -0.857167721, 0, 1, 0, .857167721, 0, -0.515037298);
					PosM = CFrame["new"](-1820.21484375, 51.683856964111, -2740.6650390625);
				elseif o == 275 or o <= 299 then
					Mon = "Gladiator";
					Qdata = 2;
					Qname = "ColosseumQuest";
					NameMon = "Gladiator";
					PosQ = CFrame["new"](-1580.04663, 6.35000277, -2986.47534, -0.515037298, 0, -0.857167721, 0, 1, 0, .857167721, 0, -0.515037298);
					PosM = CFrame["new"](-1292.8381347656, 56.380882263184, -3339.0314941406);
				elseif o == 300 or o <= 324 then
					Boubty = false;
					Mon = "Military Soldier";
					Qdata = 1;
					Qname = "MagmaQuest";
					NameMon = "Military Soldier";
					PosQ = CFrame["new"](-5313.37012, 10.9500084, 8515.29395, -0.499959469, 0, .866048813, 0, 1, 0, -0.866048813, 0, -0.499959469);
					PosM = CFrame["new"](-5411.1645507812, 11.081554412842, 8454.29296875);
				elseif o == 325 or o <= 374 then
					Mon = "Military Spy";
					Qdata = 2;
					Qname = "MagmaQuest";
					NameMon = "Military Spy";
					PosQ = CFrame["new"](-5313.37012, 10.9500084, 8515.29395, -0.499959469, 0, .866048813, 0, 1, 0, -0.866048813, 0, -0.499959469);
					PosM = CFrame["new"](-5802.8681640625, 86.262413024902, 8828.859375);
				elseif o == 375 or o <= 399 then
					Mon = "Fishman Warrior";
					Qdata = 1;
					Qname = "FishmanQuest";
					NameMon = "Fishman Warrior";
					PosQ = CFrame["new"](61122.65234375, 18.497442245483, 1569.3997802734);
					PosM = CFrame["new"](60878.30078125, 18.482830047607, 1543.7574462891);
					if _G["Level"] and (PosQ["Position"] - game["Players"]["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] > 10000 then
						replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](61163.8515625, 11.6796875, 1819.7841796875));
					end;
				elseif o == 400 or o <= 449 then
					Mon = "Fishman Commando";
					Qdata = 2;
					Qname = "FishmanQuest";
					NameMon = "Fishman Commando";
					PosQ = CFrame["new"](61122.65234375, 18.497442245483, 1569.3997802734);
					PosM = CFrame["new"](61922.6328125, 18.482830047607, 1493.9343261719);
					if _G["Level"] and (PosQ["Position"] - game["Players"]["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] > 10000 then
						replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](61163.8515625, 11.6796875, 1819.7841796875));
					end;
				elseif o == 450 or o <= 474 then
					Mon = "God's Guard";
					Qdata = 1;
					Qname = "SkyExp1Quest";
					NameMon = "God's Guard";
					PosQ = CFrame["new"](-4721.88867, 843.874695, -1949.96643, .996191859, 0, -0.0871884301, 0, 1, 0, .0871884301, 0, .996191859);
					PosM = CFrame["new"](-4710.04296875, 845.27697753906, -1927.3079833984);
					if _G["Level"] and (PosQ["Position"] - game["Players"]["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] > 10000 then
						replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](-4607.82275, 872.54248, -1667.55688));
					end;
				elseif o == 475 or o <= 524 then
					Mon = "Shanda";
					Qdata = 2;
					Qname = "SkyExp1Quest";
					NameMon = "Shanda";
					PosQ = CFrame["new"](-7859.09814, 5544.19043, -381.476196, -0.422592998, 0, .906319618, 0, 1, 0, -0.906319618, 0, -0.422592998);
					PosM = CFrame["new"](-7678.4897460938, 5566.4038085938, -497.21560668945);
					if _G["Level"] and (PosQ["Position"] - game["Players"]["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] > 10000 then
						replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](-7894.6176757813, 5547.1416015625, -380.29119873047));
					end;
				elseif o == 525 or o <= 549 then
					Mon = "Royal Squad";
					Qdata = 1;
					Qname = "SkyExp2Quest";
					NameMon = "Royal Squad";
					PosQ = CFrame["new"](-7906.81592, 5634.6626, -1411.99194, 0, 0, -1, 0, 1, 0, 1, 0, 0);
					PosM = CFrame["new"](-7624.2524414062, 5658.1333007812, -1467.3542480469);
				elseif o == 550 or o <= 624 then
					Mon = "Royal Soldier";
					Qdata = 2;
					Qname = "SkyExp2Quest";
					NameMon = "Royal Soldier";
					PosQ = CFrame["new"](-7906.81592, 5634.6626, -1411.99194, 0, 0, -1, 0, 1, 0, 1, 0, 0);
					PosM = CFrame["new"](-7836.7534179688, 5645.6640625, -1790.6236572266);
				elseif o == 625 or o <= 649 then
					Mon = "Galley Pirate";
					Qdata = 1;
					Qname = "FountainQuest";
					NameMon = "Galley Pirate";
					PosQ = CFrame["new"](5259.81982, 37.3500175, 4050.0293, .087131381, 0, .996196866, 0, 1, 0, -0.996196866, 0, .087131381);
					PosM = CFrame["new"](5551.0219726562, 78.901351928711, 3930.4128417969);
				elseif o >= 650 then
					Mon = "Galley Captain";
					Qdata = 2;
					Qname = "FountainQuest";
					NameMon = "Galley Captain";
					PosQ = CFrame["new"](5259.81982, 37.3500175, 4050.0293, .087131381, 0, .996196866, 0, 1, 0, -0.996196866, 0, .087131381);
					PosM = CFrame["new"](5441.9516601562, 42.502059936523, 4950.09375);
				end;
			elseif World2 then
				if o == 700 or o <= 724 then
					Mon = "Raider";
					Qdata = 1;
					Qname = "Area1Quest";
					NameMon = "Raider";
					PosQ = CFrame["new"](-429.543518, 71.7699966, 1836.18188, -0.22495985, 0, -0.974368095, 0, 1, 0, .974368095, 0, -0.22495985);
					PosM = CFrame["new"](-728.32672119141, 52.779319763184, 2345.7705078125);
				elseif o == 725 or o <= 774 then
					Mon = "Mercenary";
					Qdata = 2;
					Qname = "Area1Quest";
					NameMon = "Mercenary";
					PosQ = CFrame["new"](-429.543518, 71.7699966, 1836.18188, -0.22495985, 0, -0.974368095, 0, 1, 0, .974368095, 0, -0.22495985);
					PosM = CFrame["new"](-1004.3244018555, 80.158866882324, 1424.6193847656);
				elseif o == 775 or o <= 799 then
					Mon = "Swan Pirate";
					Qdata = 1;
					Qname = "Area2Quest";
					NameMon = "Swan Pirate";
					PosQ = CFrame["new"](638.43811, 71.769989, 918.282898, .139203906, 0, .99026376, 0, 1, 0, -0.99026376, 0, .139203906);
					PosM = CFrame["new"](1068.6643066406, 137.61428833008, 1322.1060791016);
				elseif o == 800 or o <= 874 then
					Mon = "Factory Staff";
					Qname = "Area2Quest";
					Qdata = 2;
					NameMon = "Factory Staff";
					PosQ = CFrame["new"](632.698608, 73.1055908, 918.666321, -0.0319722369, 8.96074881e-010, -0.999488771, 1.36326533e-010, 1, 8.92172336e-010, .999488771, -1.07732087e-010, -0.0319722369);
					PosM = CFrame["new"](73.078674316406, 81.863441467285, -27.470672607422);
				elseif o == 875 or o <= 899 then
					Mon = "Marine Lieutenant";
					Qdata = 1;
					Qname = "MarineQuest3";
					NameMon = "Marine Lieutenant";
					PosQ = CFrame["new"](-2440.79639, 71.7140732, -3216.06812, .866007268, 0, .500031412, 0, 1, 0, -0.500031412, 0, .866007268);
					PosM = CFrame["new"](-2821.3723144531, 75.897277832031, -3070.0891113281);
				elseif o == 900 or o <= 949 then
					Mon = "Marine Captain";
					Qdata = 2;
					Qname = "MarineQuest3";
					NameMon = "Marine Captain";
					PosQ = CFrame["new"](-2440.79639, 71.7140732, -3216.06812, .866007268, 0, .500031412, 0, 1, 0, -0.500031412, 0, .866007268);
					PosM = CFrame["new"](-1861.2310791016, 80.176582336426, -3254.6975097656);
				elseif o == 950 or o <= 974 then
					Mon = "Zombie";
					Qdata = 1;
					Qname = "ZombieQuest";
					NameMon = "Zombie";
					PosQ = CFrame["new"](-5497.06152, 47.5923004, -795.237061, -0.29242146, 0, -0.95628953, 0, 1, 0, .95628953, 0, -0.29242146);
					PosM = CFrame["new"](-5657.7768554688, 78.969734191895, -928.68701171875);
				elseif o == 975 or o <= 999 then
					Mon = "Vampire";
					Qdata = 2;
					Qname = "ZombieQuest";
					NameMon = "Vampire";
					PosQ = CFrame["new"](-5497.06152, 47.5923004, -795.237061, -0.29242146, 0, -0.95628953, 0, 1, 0, .95628953, 0, -0.29242146);
					PosM = CFrame["new"](-6037.66796875, 32.184638977051, -1340.6597900391);
				elseif o == 1000 or o <= 1049 then
					Mon = "Snow Trooper";
					Qdata = 1;
					Qname = "SnowMountainQuest";
					NameMon = "Snow Trooper";
					PosQ = CFrame["new"](609.858826, 400.119904, -5372.25928, -0.374604106, 0, .92718488, 0, 1, 0, -0.92718488, 0, -0.374604106);
					PosM = CFrame["new"](549.14733886719, 427.38705444336, -5563.6987304688);
				elseif o == 1050 or o <= 1099 then
					Mon = "Winter Warrior";
					Qdata = 2;
					Qname = "SnowMountainQuest";
					NameMon = "Winter Warrior";
					PosQ = CFrame["new"](609.858826, 400.119904, -5372.25928, -0.374604106, 0, .92718488, 0, 1, 0, -0.92718488, 0, -0.374604106);
					PosM = CFrame["new"](1142.7451171875, 475.63980102539, -5199.4165039062);
				elseif o == 1100 or o <= 1124 then
					Mon = "Lab Subordinate";
					Qdata = 1;
					Qname = "IceSideQuest";
					NameMon = "Lab Subordinate";
					PosQ = CFrame["new"](-6064.06885, 15.2422857, -4902.97852, .453972578, 0, -0.891015649, 0, 1, 0, .891015649, 0, .453972578);
					PosM = CFrame["new"](-5707.4716796875, 15.951709747314, -4513.3920898438);
				elseif o == 1125 or o <= 1174 then
					Mon = "Horned Warrior";
					Qdata = 2;
					Qname = "IceSideQuest";
					NameMon = "Horned Warrior";
					PosQ = CFrame["new"](-6064.06885, 15.2422857, -4902.97852, .453972578, 0, -0.891015649, 0, 1, 0, .891015649, 0, .453972578);
					PosM = CFrame["new"](-6341.3666992188, 15.951770782471, -5723.162109375);
				elseif o == 1175 or o <= 1199 then
					Mon = "Magma Ninja";
					Qdata = 1;
					Qname = "FireSideQuest";
					NameMon = "Magma Ninja";
					PosQ = CFrame["new"](-5428.03174, 15.0622921, -5299.43457, -0.882952213, 0, .469463557, 0, 1, 0, -0.469463557, 0, -0.882952213);
					PosM = CFrame["new"](-5449.6728515625, 76.658744812012, -5808.2006835938);
				elseif o == 1200 or o <= 1249 then
					Mon = "Lava Pirate";
					Qdata = 2;
					Qname = "FireSideQuest";
					NameMon = "Lava Pirate";
					PosQ = CFrame["new"](-5428.03174, 15.0622921, -5299.43457, -0.882952213, 0, .469463557, 0, 1, 0, -0.469463557, 0, -0.882952213);
					PosM = CFrame["new"](-5213.3315429688, 49.737880706787, -4701.451171875);
				elseif o == 1250 or o <= 1274 then
					Mon = "Ship Deckhand";
					Qdata = 1;
					Qname = "ShipQuest1";
					NameMon = "Ship Deckhand";
					PosQ = CFrame["new"](1037.80127, 125.092171, 32911.6016);
					PosM = CFrame["new"](1212.0111083984, 150.79205322266, 33059.24609375);
					if _G["Level"] and (PosQ["Position"] - game["Players"]["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] > 500 then
						replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](923.21252441406, 126.9760055542, 32852.83203125));
					end;
				elseif o == 1275 or o <= 1299 then
					Mon = "Ship Engineer";
					Qdata = 2;
					Qname = "ShipQuest1";
					NameMon = "Ship Engineer";
					PosQ = CFrame["new"](1037.80127, 125.092171, 32911.6016);
					PosM = CFrame["new"](919.47863769531, 43.544013977051, 32779.96875);
					if _G["Level"] and (PosQ["Position"] - game["Players"]["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] > 500 then
						replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](923.21252441406, 126.9760055542, 32852.83203125));
					end;
				elseif o == 1300 or o <= 1324 then
					Mon = "Ship Steward";
					Qdata = 1;
					Qname = "ShipQuest2";
					NameMon = "Ship Steward";
					PosQ = CFrame["new"](968.80957, 125.092171, 33244.125);
					PosM = CFrame["new"](919.43853759766, 129.55599975586, 33436.03515625);
					if _G["Level"] and (PosQ["Position"] - game["Players"]["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] > 500 then
						replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](923.21252441406, 126.9760055542, 32852.83203125));
					end;
				elseif o == 1325 or o <= 1349 then
					Mon = "Ship Officer";
					Qdata = 2;
					Qname = "ShipQuest2";
					NameMon = "Ship Officer";
					PosQ = CFrame["new"](968.80957, 125.092171, 33244.125);
					PosM = CFrame["new"](1036.0179443359, 181.4390411377, 33315.7265625);
					if _G["Level"] and (PosQ["Position"] - game["Players"]["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] > 500 then
						replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](923.21252441406, 126.9760055542, 32852.83203125));
					end;
				elseif o == 1350 or o <= 1374 then
					Mon = "Arctic Warrior";
					Qdata = 1;
					Qname = "FrostQuest";
					NameMon = "Arctic Warrior";
					PosQ = CFrame["new"](5667.6582, 26.7997818, -6486.08984, -0.933587909, 0, -0.358349502, 0, 1, 0, .358349502, 0, -0.933587909);
					PosM = CFrame["new"](5966.24609375, 62.970020294189, -6179.3828125);
					if _G["Level"] and (PosQ["Position"] - game["Players"]["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] > 1000 then
						BTP(PosM);
					end;
				elseif o == 1375 or o <= 1424 then
					Mon = "Snow Lurker";
					Qdata = 2;
					Qname = "FrostQuest";
					NameMon = "Snow Lurker";
					PosQ = CFrame["new"](5667.6582, 26.7997818, -6486.08984, -0.933587909, 0, -0.358349502, 0, 1, 0, .358349502, 0, -0.933587909);
					PosM = CFrame["new"](5407.0737304688, 69.194374084473, -6880.8803710938);
				elseif o == 1425 or o <= 1449 then
					Mon = "Sea Soldier";
					Qdata = 1;
					Qname = "ForgottenQuest";
					NameMon = "Sea Soldier";
					PosQ = CFrame["new"](-3054.44458, 235.544281, -10142.8193, .990270376, 0, -0.13915664, 0, 1, 0, .13915664, 0, .990270376);
					PosM = CFrame["new"](-3028.2236328125, 64.674514770508, -9775.4267578125);
				elseif o >= 1450 then
					Mon = "Water Fighter";
					Qdata = 2;
					Qname = "ForgottenQuest";
					NameMon = "Water Fighter";
					PosQ = CFrame["new"](-3054.44458, 235.544281, -10142.8193, .990270376, 0, -0.13915664, 0, 1, 0, .13915664, 0, .990270376);
					PosM = CFrame["new"](-3352.9013671875, 285.01556396484, -10534.841796875);
				end;
			elseif World3 then
				if o == 1500 or o <= 1524 then
					Mon = "Pirate Millionaire";
					Qdata = 1;
					Qname = "PiratePortQuest";
					NameMon = "Pirate Millionaire";
					PosQ = CFrame["new"](-712.82727050781, 98.577049255371, 5711.9541015625);
					PosM = CFrame["new"](-712.82727050781, 98.577049255371, 5711.9541015625);
				elseif o == 1525 or o <= 1574 then
					Mon = "Pistol Billionaire";
					Qdata = 2;
					Qname = "PiratePortQuest";
					NameMon = "Pistol Billionaire";
					PosQ = CFrame["new"](-723.43316650391, 147.42906188965, 5931.9931640625);
					PosM = CFrame["new"](-723.43316650391, 147.42906188965, 5931.9931640625);
				elseif o == 1575 or o <= 1599 then
					Mon = "Dragon Crew Warrior";
					Qdata = 1;
					Qname = "AmazonQuest";
					NameMon = "Dragon Crew Warrior";
					PosQ = CFrame["new"](6779.0327148438, 111.16865539551, -801.21307373047);
					PosM = CFrame["new"](6779.0327148438, 111.16865539551, -801.21307373047);
				elseif o == 1600 or o <= 1624 then
					Mon = "Dragon Crew Archer";
					Qname = "AmazonQuest";
					Qdata = 2;
					NameMon = "Dragon Crew Archer";
					PosQ = CFrame["new"](6955.8974609375, 546.66589355469, 309.04013061523);
					PosM = CFrame["new"](6955.8974609375, 546.66589355469, 309.04013061523);
				elseif o == 1625 or o <= 1649 then
					Mon = "Hydra Enforcer";
					Qname = "VenomCrewQuest";
					Qdata = 1;
					NameMon = "Hydra Enforcer";
					PosQ = CFrame["new"](4620.6157226562, 1002.2954711914, 399.08688354492);
					PosM = CFrame["new"](4620.6157226562, 1002.2954711914, 399.08688354492);
				elseif o == 1650 or o <= 1699 then
					Mon = "Venomous Assailant";
					Qname = "VenomCrewQuest";
					Qdata = 2;
					NameMon = "Venomous Assailant";
					PosQ = CFrame["new"](4697.5918, 1100.65137, 946.401978, .579397917, -4.19689783e-010, .81504482, -1.49287818e-010, 1, 6.21053986e-010, -0.81504482, -4.81513662e-010, .579397917);
					PosM = CFrame["new"](4697.5918, 1100.65137, 946.401978, .579397917, -4.19689783e-010, .81504482, -1.49287818e-010, 1, 6.21053986e-010, -0.81504482, -4.81513662e-010, .579397917);
				elseif o == 1700 or o <= 1724 then
					Mon = "Marine Commodore";
					Qdata = 1;
					Qname = "MarineTreeIsland";
					NameMon = "Marine Commodore";
					PosQ = CFrame["new"](2180.54126, 27.8156815, -6741.5498, -0.965929747, 0, .258804798, 0, 1, 0, -0.258804798, 0, -0.965929747);
					PosM = CFrame["new"](2286.0078125, 73.133918762207, -7159.8090820312);
				elseif o == 1725 or o <= 1774 then
					Mon = "Marine Rear Admiral";
					NameMon = "Marine Rear Admiral";
					Qname = "MarineTreeIsland";
					Qdata = 2;
					PosQ = CFrame["new"](2179.98828125, 28.731239318848, -6740.0551757813);
					PosM = CFrame["new"](3656.7736816406, 160.52406311035, -7001.5986328125);
				elseif o == 1775 or o <= 1799 then
					Mon = "Fishman Raider";
					Qdata = 1;
					Qname = "DeepForestIsland3";
					NameMon = "Fishman Raider";
					PosQ = CFrame["new"](-10581.6563, 330.872955, -8761.18652, -0.882952213, 0, .469463557, 0, 1, 0, -0.469463557, 0, -0.882952213);
					PosM = CFrame["new"](-10407.526367188, 331.76263427734, -8368.5166015625);
				elseif o == 1800 or o <= 1824 then
					Mon = "Fishman Captain";
					Qdata = 2;
					Qname = "DeepForestIsland3";
					NameMon = "Fishman Captain";
					PosQ = CFrame["new"](-10581.6563, 330.872955, -8761.18652, -0.882952213, 0, .469463557, 0, 1, 0, -0.469463557, 0, -0.882952213);
					PosM = CFrame["new"](-10994.701171875, 352.38140869141, -9002.1103515625);
				elseif o == 1825 or o <= 1849 then
					Mon = "Forest Pirate";
					Qdata = 1;
					Qname = "DeepForestIsland";
					NameMon = "Forest Pirate";
					PosQ = CFrame["new"](-13234.04, 331.488495, -7625.40137, .707134247, 0, -0.707079291, 0, 1, 0, .707079291, 0, .707134247);
					PosM = CFrame["new"](-13274.478515625, 332.37814331055, -7769.5805664062);
				elseif o == 1850 or o <= 1899 then
					Mon = "Mythological Pirate";
					Qdata = 2;
					Qname = "DeepForestIsland";
					NameMon = "Mythological Pirate";
					PosQ = CFrame["new"](-13234.04, 331.488495, -7625.40137, .707134247, 0, -0.707079291, 0, 1, 0, .707079291, 0, .707134247);
					PosM = CFrame["new"](-13680.607421875, 501.08154296875, -6991.189453125);
				elseif o == 1900 or o <= 1924 then
					Mon = "Jungle Pirate";
					Qdata = 1;
					Qname = "DeepForestIsland2";
					NameMon = "Jungle Pirate";
					PosQ = CFrame["new"](-12680.3818, 389.971039, -9902.01953, -0.0871315002, 0, .996196866, 0, 1, 0, -0.996196866, 0, -0.0871315002);
					PosM = CFrame["new"](-12256.16015625, 331.73828125, -10485.836914062);
				elseif o == 1925 or o <= 1974 then
					Mon = "Musketeer Pirate";
					Qdata = 2;
					Qname = "DeepForestIsland2";
					NameMon = "Musketeer Pirate";
					PosQ = CFrame["new"](-12680.3818, 389.971039, -9902.01953, -0.0871315002, 0, .996196866, 0, 1, 0, -0.996196866, 0, -0.0871315002);
					PosM = CFrame["new"](-13457.904296875, 391.54565429688, -9859.177734375);
				elseif o == 1975 or o <= 1999 then
					Mon = "Reborn Skeleton";
					Qdata = 1;
					Qname = "HauntedQuest1";
					NameMon = "Reborn Skeleton";
					PosQ = CFrame["new"](-9479.2168, 141.215088, 5566.09277, 0, 0, 1, 0, 1, 0, -1, 0, 0);
					PosM = CFrame["new"](-8763.7236328125, 165.72299194336, 6159.8618164062);
				elseif o == 2000 or o <= 2024 then
					Mon = "Living Zombie";
					Qdata = 2;
					Qname = "HauntedQuest1";
					NameMon = "Living Zombie";
					PosQ = CFrame["new"](-9479.2168, 141.215088, 5566.09277, 0, 0, 1, 0, 1, 0, -1, 0, 0);
					PosM = CFrame["new"](-10144.131835938, 138.6266784668, 5838.0888671875);
				elseif o == 2025 or o <= 2049 then
					Mon = "Demonic Soul";
					Qdata = 1;
					Qname = "HauntedQuest2";
					NameMon = "Demonic Soul";
					PosQ = CFrame["new"](-9516.99316, 172.017181, 6078.46533, 0, 0, -1, 0, 1, 0, 1, 0, 0);
					PosM = CFrame["new"](-9505.8720703125, 172.10482788086, 6158.9931640625);
				elseif o == 2050 or o <= 2074 then
					Mon = "Posessed Mummy";
					Qdata = 2;
					Qname = "HauntedQuest2";
					NameMon = "Posessed Mummy";
					PosQ = CFrame["new"](-9516.99316, 172.017181, 6078.46533, 0, 0, -1, 0, 1, 0, 1, 0, 0);
					PosM = CFrame["new"](-9582.0224609375, 6.2515273094177, 6205.478515625);
				elseif o == 2075 or o <= 2099 then
					Mon = "Peanut Scout";
					Qdata = 1;
					Qname = "NutsIslandQuest";
					NameMon = "Peanut Scout";
					PosQ = CFrame["new"](-2104.3908691406, 38.104167938232, -10194.21875, 0, 0, -1, 0, 1, 0, 1, 0, 0);
					PosM = CFrame["new"](-2143.2419433594, 47.721984863281, -10029.995117188);
				elseif o == 2100 or o <= 2124 then
					Mon = "Peanut President";
					Qdata = 2;
					Qname = "NutsIslandQuest";
					NameMon = "Peanut President";
					PosQ = CFrame["new"](-2104.3908691406, 38.104167938232, -10194.21875, 0, 0, -1, 0, 1, 0, 1, 0, 0);
					PosM = CFrame["new"](-1859.3540039062, 38.103168487549, -10422.4296875);
				elseif o == 2125 or o <= 2149 then
					Mon = "Ice Cream Chef";
					Qdata = 1;
					Qname = "IceCreamIslandQuest";
					NameMon = "Ice Cream Chef";
					PosQ = CFrame["new"](-820.64825439453, 65.819526672363, -10965.795898438, 0, 0, -1, 0, 1, 0, 1, 0, 0);
					PosM = CFrame["new"](-872.24658203125, 65.81957244873, -10919.95703125);
				elseif o == 2150 or o <= 2199 then
					Mon = "Ice Cream Commander";
					Qdata = 2;
					Qname = "IceCreamIslandQuest";
					NameMon = "Ice Cream Commander";
					PosQ = CFrame["new"](-820.64825439453, 65.819526672363, -10965.795898438, 0, 0, -1, 0, 1, 0, 1, 0, 0);
					PosM = CFrame["new"](-558.06103515625, 112.04895782471, -11290.774414062);
				elseif o == 2200 or o <= 2224 then
					Mon = "Cookie Crafter";
					Qdata = 1;
					Qname = "CakeQuest1";
					NameMon = "Cookie Crafter";
					PosQ = CFrame["new"](-2021.32007, 37.7982254, -12028.7295, .957576931, -8.80302053e-008, .288177818, 6.9301187e-008, 1, 7.51931211e-008, -0.288177818, -5.2032135e-008, .957576931);
					PosM = CFrame["new"](-2374.13671875, 37.798263549805, -12125.30859375);
				elseif o == 2225 or o <= 2249 then
					Mon = "Cake Guard";
					Qdata = 2;
					Qname = "CakeQuest1";
					NameMon = "Cake Guard";
					PosQ = CFrame["new"](-2021.32007, 37.7982254, -12028.7295, .957576931, -8.80302053e-008, .288177818, 6.9301187e-008, 1, 7.51931211e-008, -0.288177818, -5.2032135e-008, .957576931);
					PosM = CFrame["new"](-1598.3070068359, 43.773197174072, -12244.581054688);
				elseif o == 2250 or o <= 2274 then
					Mon = "Baking Staff";
					Qdata = 1;
					Qname = "CakeQuest2";
					NameMon = "Baking Staff";
					PosQ = CFrame["new"](-1927.91602, 37.7981339, -12842.5391, -0.96804446, 4.22142143e-008, .250778586, 4.74911062e-008, 1, 1.49904711e-008, -0.250778586, 2.64211941e-008, -0.96804446);
					PosM = CFrame["new"](-1887.8099365234, 77.618507385254, -12998.350585938);
				elseif o == 2275 or o <= 2299 then
					Mon = "Head Baker";
					Qdata = 2;
					Qname = "CakeQuest2";
					NameMon = "Head Baker";
					PosQ = CFrame["new"](-1927.91602, 37.7981339, -12842.5391, -0.96804446, 4.22142143e-008, .250778586, 4.74911062e-008, 1, 1.49904711e-008, -0.250778586, 2.64211941e-008, -0.96804446);
					PosM = CFrame["new"](-2216.1882324219, 82.884521484375, -12869.293945312);
				elseif o == 2300 or o <= 2324 then
					Mon = "Cocoa Warrior";
					Qdata = 1;
					Qname = "ChocQuest1";
					NameMon = "Cocoa Warrior";
					PosQ = CFrame["new"](233.22836303711, 29.876001358032, -12201.233398438);
					PosM = CFrame["new"](-21.553283691406, 80.574996948242, -12352.387695312);
				elseif o == 2325 or o <= 2349 then
					Mon = "Chocolate Bar Battler";
					Qdata = 2;
					Qname = "ChocQuest1";
					NameMon = "Chocolate Bar Battler";
					PosQ = CFrame["new"](233.22836303711, 29.876001358032, -12201.233398438);
					PosM = CFrame["new"](582.59057617188, 77.188095092773, -12463.162109375);
				elseif o == 2350 or o <= 2374 then
					Mon = "Sweet Thief";
					Qdata = 1;
					Qname = "ChocQuest2";
					NameMon = "Sweet Thief";
					PosQ = CFrame["new"](150.50663757324, 30.693693161011, -12774.502929688);
					PosM = CFrame["new"](165.1884765625, 76.058853149414, -12600.836914062);
				elseif o == 2375 or o <= 2399 then
					Mon = "Candy Rebel";
					Qdata = 2;
					Qname = "ChocQuest2";
					NameMon = "Candy Rebel";
					PosQ = CFrame["new"](150.50663757324, 30.693693161011, -12774.502929688);
					PosM = CFrame["new"](134.86563110352, 77.247680664062, -12876.547851562);
				elseif o == 2400 or o <= 2449 then
					Mon = "Candy Pirate";
					Qdata = 1;
					Qname = "CandyQuest1";
					NameMon = "Candy Pirate";
					PosQ = CFrame["new"](-1150.0400390625, 20.378934860229, -14446.334960938);
					PosM = CFrame["new"](-1310.5003662109, 26.016523361206, -14562.404296875);
				elseif o == 2450 or o <= 2474 then
					Mon = "Isle Outlaw";
					Qdata = 1;
					Qname = "TikiQuest1";
					NameMon = "Isle Outlaw";
					PosQ = CFrame["new"](-16548.8164, 55.6059914, -172.8125, .213092566, 0, -0.977032006, 0, 1, 0, .977032006, 0, .213092566);
					PosM = CFrame["new"](-16479.900390625, 226.6117401123, -300.31143188477);
				elseif o == 2475 or o <= 2499 then
					Mon = "Island Boy";
					Qdata = 2;
					Qname = "TikiQuest1";
					NameMon = "Island Boy";
					PosQ = CFrame["new"](-16548.8164, 55.6059914, -172.8125, .213092566, 0, -0.977032006, 0, 1, 0, .977032006, 0, .213092566);
					PosM = CFrame["new"](-16849.396484375, 192.86505126953, -150.78532409668);
				elseif o == 2500 or o <= 2524 then
					Mon = "Sun-kissed Warrior";
					Qdata = 1;
					Qname = "TikiQuest2";
					NameMon = "kissed Warrior";
					PosM = CFrame["new"](-16347, 64, 984);
					PosQ = CFrame["new"](-16538, 55, 1049);
				elseif o == 2525 or o <= 2550 then
					Mon = "Isle Champion";
					Qdata = 2;
					Qname = "TikiQuest2";
					NameMon = "Isle Champion";
					PosQ = CFrame["new"](-16541.0215, 57.3082275, 1051.46118, .0410757065, 0, -0.999156058, 0, 1, 0, .999156058, 0, .0410757065);
					PosM = CFrame["new"](-16602.1015625, 130.38734436035, 1087.2456054688);
				elseif o == 2551 or o <= 2574 then
					Mon = "Serpent Hunter";
					Qdata = 1;
					Qname = "TikiQuest3";
					NameMon = "Serpent Hunter";
					PosQ = CFrame["new"](-16679.478515625, 176.74737548828, 1474.3995361328);
					PosM = CFrame["new"](-16679.478515625, 176.74737548828, 1474.3995361328);
				elseif o >= 2575 then
					Mon = "Skull Slayer";
					Qdata = 2;
					Qname = "TikiQuest3";
					NameMon = "Skull Slayer";
					PosQ = CFrame["new"](-16759.58984375, 71.283767700195, 1595.3399658203);
					PosM = CFrame["new"](-16759.58984375, 71.283767700195, 1595.3399658203);
				end;
			end;
		end;
	MaterialMon = function()
			local o = game["Players"]["LocalPlayer"];
			local p = o["Character"] and o["Character"]:FindFirstChild("HumanoidRootPart");
			if not p then
				return;
			end;
			shouldRequestEntrance = function(o, n)
					local e = (p["Position"] - o)["Magnitude"];
					if e >= n then
						replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", o);
					end;
				end;
			if World1 then
				if SelectMaterial == "Angel Wings" then
					MMon = {
							"Shanda",
							"Royal Squad",
							"Royal Soldier",
							"Wysper",
							"Thunder God",
						};
					MPos = CFrame["new"](-4698, 845, -1912);
					SP = "Default";
					local o = Vector3["new"](-4607.82275, 872.54248, -1667.55688);
					shouldRequestEntrance(o, 10000);
				elseif SelectMaterial == "Leather + Scrap Metal" then
					MMon = { "Brute", "Pirate" };
					MPos = CFrame["new"](-1145, 15, 4350);
					SP = "Default";
				elseif SelectMaterial == "Magma Ore" then
					MMon = { "Military Soldier", "Military Spy", "Magma Admiral" };
					MPos = CFrame["new"](-5815, 84, 8820);
					SP = "Default";
				elseif SelectMaterial == "Fish Tail" then
					MMon = { "Fishman Warrior", "Fishman Commando", "Fishman Lord" };
					MPos = CFrame["new"](61123, 19, 1569);
					SP = "Default";
					local o = Vector3["new"](61163.8515625, 5.342342376709, 1819.7841796875);
					shouldRequestEntrance(o, 17000);
				end;
			elseif World2 then
				if SelectMaterial == "Leather + Scrap Metal" then
					MMon = { "Marine Captain" };
					MPos = CFrame["new"](-2010.5059814453, 73.001159667969, -3326.6208496094);
					SP = "Default";
				elseif SelectMaterial == "Magma Ore" then
					MMon = { "Magma Ninja", "Lava Pirate" };
					MPos = CFrame["new"](-5428, 78, -5959);
					SP = "Default";
				elseif SelectMaterial == "Ectoplasm" then
					MMon = {
							"Ship Deckhand",
							"Ship Engineer",
							"Ship Steward",
							"Ship Officer",
						};
					MPos = CFrame["new"](911.35827636719, 125.95812988281, 33159.5390625);
					SP = "Default";
					local o = Vector3["new"](61163.8515625, 5.342342376709, 1819.7841796875);
					shouldRequestEntrance(o, 18000);
				elseif SelectMaterial == "Mystic Droplet" then
					MMon = { "Water Fighter" };
					MPos = CFrame["new"](-3385, 239, -10542);
					SP = "Default";
				elseif SelectMaterial == "Radioactive Material" then
					MMon = { "Factory Staff" };
					MPos = CFrame["new"](295, 73, -56);
					SP = "Default";
				elseif SelectMaterial == "Vampire Fang" then
					MMon = { "Vampire" };
					MPos = CFrame["new"](-6033, 7, -1317);
					SP = "Default";
				end;
			elseif World3 then
				if SelectMaterial == "Scrap Metal" then
					MMon = { "Jungle Pirate", "Forest Pirate" };
					MPos = CFrame["new"](-11975.78515625, 331.77340698242, -10620.030273438);
					SP = "Default";
				elseif SelectMaterial == "Fish Tail" then
					MMon = { "Fishman Raider", "Fishman Captain" };
					MPos = CFrame["new"](-10993, 332, -8940);
					SP = "Default";
				elseif SelectMaterial == "Conjured Cocoa" then
					MMon = { "Chocolate Bar Battler", "Cocoa Warrior" };
					MPos = CFrame["new"](620.63446044922, 78.936447143555, -12581.369140625);
					SP = "Default";
				elseif SelectMaterial == "Dragon Scale" then
					MMon = { "Dragon Crew Archer", "Dragon Crew Warrior" };
					MPos = CFrame["new"](6594, 383, 139);
					SP = "Default";
				elseif SelectMaterial == "Gunpowder" then
					MMon = { "Pistol Billionaire" };
					MPos = CFrame["new"](-84.855690002441, 85.620613098145, 6132.0087890625);
					SP = "Default";
				elseif SelectMaterial == "Mini Tusk" then
					MMon = { "Mythological Pirate" };
					MPos = CFrame["new"](-13545, 470, -6917);
					SP = "Default";
				elseif SelectMaterial == "Demonic Wisp" then
					MMon = { "Demonic Soul" };
					MPos = CFrame["new"](-9495.6806640625, 453.58624267578, 5977.3486328125);
					SP = "Default";
				end;
			end;
		end;
	QuestNeta = function()
			local D = QuestCheck();
			return {
				[1] = Mon,
				[2] = Qdata,
				[3] = Qname,
				[4] = PosM,
				[5] = NameMon,
				[6] = PosQ,
			};
		end;
	local s = (loadstring(game:HttpGet("https://raw.githubusercontent.com/hoangthangvuong50-alt/Test/refs/heads/main/test%201.txt")))();
	local J = s:CreateWindow({
			["Title"] = "bananahub(kaitoMC276)",
			["SubTitle"] = "",
			["TabWidth"] = 155,
			["Size"] = UDim2["fromOffset"](485, 370),
			["Acrylic"] = false,
			["Theme"] = "Banana",
			["MinimizeKey"] = Enum["KeyCode"]["End"],
		});
	local t = {
			["Main"] = J:AddTab({ ["Title"] = "Farm", ["Icon"] = "" }),
			["Settings"] = J:AddTab({ ["Title"] = "Config", ["Icon"] = "" }),
			["Melee"] = J:AddTab({ ["Title"] = "Fighting Style", ["Icon"] = "" }),
			["Quests"] = J:AddTab({ ["Title"] = "Items Farm", ["Icon"] = "" }),
			["New"] = J:AddTab({ ["Title"] = "New Events", ["Icon"] = "" }),
			["SeaEvent"] = J:AddTab({ ["Title"] = "Sea Events", ["Icon"] = "" }),
			["Mirage"] = J:AddTab({ ["Title"] = "Mirage + RaceV4", ["Icon"] = "" }),
			["Drago"] = J:AddTab({ ["Title"] = "Drago Dojo", ["Icon"] = "" }),
			["Prehistoric"] = J:AddTab({ ["Title"] = "Prehistoric", ["Icon"] = "" }),
			["Raids"] = J:AddTab({ ["Title"] = "Raid", ["Icon"] = "" }),
			["Combat"] = J:AddTab({ ["Title"] = "Combat PVP", ["Icon"] = "" }),
			["Travel"] = J:AddTab({ ["Title"] = "Teleport", ["Icon"] = "" }),
			["Fruit"] = J:AddTab({ ["Title"] = "Fruits", ["Icon"] = "" }),
			["Shop"] = J:AddTab({ ["Title"] = "Shop", ["Icon"] = "" }),
			["Misc"] = J:AddTab({ ["Title"] = "Misc", ["Icon"] = "" }),
		};
	local B = t["Main"]:AddToggle("FarmLevel", { ["Title"] = "Auto Farm Level", ["Description"] = "", ["Default"] = false });
	B:OnChanged(function(o)
		_G["Level"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["Level"] then
				pcall(function()
					local o = plr["PlayerGui"]["Main"]["Quest"]["Container"]["QuestTitle"]["Title"]["Text"];
					if not string["find"](o, (QuestNeta())[5]) then
						replicated["Remotes"]["CommF_"]:InvokeServer("AbandonQuest");
					end;
					if plr["PlayerGui"]["Main"]["Quest"]["Visible"] == false then
						_tp((QuestNeta())[6]);
						if (Root["Position"] - (QuestNeta())[6]["Position"])["Magnitude"] <= 5 then
							replicated["Remotes"]["CommF_"]:InvokeServer("StartQuest", (QuestNeta())[3], (QuestNeta())[2]);
						end;
					elseif plr["PlayerGui"]["Main"]["Quest"]["Visible"] == true then
						if workspace["Enemies"]:FindFirstChild((QuestNeta())[1]) then
							for p, n in pairs(workspace["Enemies"]:GetChildren()) do
								if f["Alive"](n) then
									if n["Name"] == (QuestNeta())[1] then
										if string["find"](o, (QuestNeta())[5]) then
											repeat
												wait();
												f["Kill"](n, _G["Level"]);
											until not _G["Level"] or n["Humanoid"]["Health"] <= 0 or not n["Parent"] or plr["PlayerGui"]["Main"]["Quest"]["Visible"] == false;
										else
											replicated["Remotes"]["CommF_"]:InvokeServer("AbandonQuest");
										end;
									end;
								end;
							end;
						else
							_tp((QuestNeta())[4]);
							if replicated:FindFirstChild((QuestNeta())[1]) then
								_tp((replicated:FindFirstChild((QuestNeta())[1]))["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 30, 0));
							end;
						end;
					end;
				end);
			end;
		end;
	end);
	local K = t["Main"]:AddToggle("TravelDress", { ["Title"] = "Auto Travel Dressrosa", ["Description"] = "", ["Default"] = false });
	K:OnChanged(function(o)
		_G["TravelDres"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["TravelDres"] then
					if plr["Data"]["Level"]["Value"] >= 700 then
						if workspace["Map"]["Ice"]["Door"]["CanCollide"] == true and workspace["Map"]["Ice"]["Door"]["Transparency"] == 0 then
							replicated["Remotes"]["CommF_"]:InvokeServer("DressrosaQuestProgress", "Detective");
							EquipWeapon("Key");
							repeat
								wait();
								_tp(CFrame["new"](1347.7124, 37.3751602, -1325.6488));
							until not _G["TravelDres"] or Root["Position"] == (CFrame["new"](1347.7124, 37.3751602, -1325.6488))["Position"];
						elseif workspace["Map"]["Ice"]["Door"]["CanCollide"] == false and workspace["Map"]["Ice"]["Door"]["Transparency"] == 1 then
							if Enemies:FindFirstChild("Ice Admiral") then
								for o, p in pairs(Enemies:GetChildren()) do
									if p["Name"] == "Ice Admiral" and f["Alive"](p) then
										repeat
											task["wait"]();
											f["Kill"](p, _G["TravelDres"]);
										until _G["TravelDres"] == false or p["Humanoid"]["Health"] <= 0;
										replicated["Remotes"]["CommF_"]:InvokeServer("TravelDressrosa");
									end;
								end;
							else
								_tp(CFrame["new"](1347.7124, 37.3751602, -1325.6488));
							end;
						else
							replicated["Remotes"]["CommF_"]:InvokeServer("TravelDressrosa");
						end;
					end;
				end;
			end);
		end;
	end);
	local a = t["Main"]:AddToggle("Zou", { ["Title"] = "Auto Zou Quest", ["Description"] = "", ["Default"] = false });
	a:OnChanged(function(o)
		_G["AutoZou"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["AutoZou"] then
					if plr["Data"]["Level"]["Value"] >= 1500 then
						if replicated["Remotes"]["CommF_"]:InvokeServer("BartiloQuestProgress", "Bartilo") == 3 then
							if (replicated["Remotes"]["CommF_"]:InvokeServer("GetUnlockables"))["FlamingoAccess"] ~= nil then
								replicated["Remotes"]["CommF_"]:InvokeServer("F_", "TravelZou");
								if replicated["Remotes"]["CommF_"]:InvokeServer("ZQuestProgress", "Check") == 0 then
									local o = GetConnectionEnemies("rip_indra");
									if o then
										repeat
											wait();
											f["Kill"](o, _G["AutoZou"]);
										until not _G["AutoZou"] or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
										Check = 2;
										repeat
											wait();
											replicated["Remotes"]["CommF_"]:InvokeServer("F_", "TravelZou");
										until Check == 1;
									else
										replicated["Remotes"]["CommF_"]:InvokeServer("F_", "ZQuestProgress", "Check");
										wait(.1);
										replicated["Remotes"]["CommF_"]:InvokeServer("F_", "ZQuestProgress", "Begin");
									end;
								elseif replicated["Remotes"]["CommF_"]:InvokeServer("ZQuestProgress", "Check") == 1 then
									replicated["Remotes"]["CommF_"]:InvokeServer("F_", "TravelZou");
								else
									local o = GetConnectionEnemies("Don Swan");
									if o then
										repeat
											wait();
											f["Kill"](o, _G["AutoZou"]);
										until not _G["AutoZou"] or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
									else
										repeat
											wait();
											_tp(CFrame["new"](2288.802, 15.1870775, 863.034607));
										until not _G["AutoZou"] or Root["Position"] == (CFrame["new"](2288.802, 15.1870775, 863.034607))["Position"];
										if Root["CFrame"] == CFrame["new"](2288.802, 15.1870775, 863.034607) then
											notween(CFrame["new"](2288.802, 15.1870775, 863.034607));
										end;
									end;
								end;
							else
								if (replicated["Remotes"]["CommF_"]:InvokeServer("GetUnlockables"))["FlamingoAccess"] == nil then
									TabelDevilFruitStore = {};
									TabelDevilFruitOpen = {};
									for o, p in pairs(replicated["Remotes"]["CommF_"]:InvokeServer("getInventoryFruits")) do
										for o, p in pairs(p) do
											if o == "Name" then
												table["insert"](TabelDevilFruitStore, p);
											end;
										end;
									end;
									for o, p in next, (game["ReplicatedStorage"]:WaitForChild("Remotes"))["CommF_"]:InvokeServer("GetFruits") do
										if p["Price"] >= 1000000 then
											table["insert"](TabelDevilFruitOpen, p["Name"]);
										end;
									end;
									for o, p in pairs(TabelDevilFruitOpen) do
										for o, n in pairs(TabelDevilFruitStore) do
											if p == n and (replicated["Remotes"]["CommF_"]:InvokeServer("GetUnlockables"))["FlamingoAccess"] == nil then
												if not plr["Backpack"]:FindFirstChild(n) then
													replicated["Remotes"]["CommF_"]:InvokeServer("F_", "LoadFruit", n);
												else
													replicated["Remotes"]["CommF_"]:InvokeServer("F_", "TalkTrevor", "1");
													replicated["Remotes"]["CommF_"]:InvokeServer("F_", "TalkTrevor", "2");
													replicated["Remotes"]["CommF_"]:InvokeServer("F_", "TalkTrevor", "3");
												end;
											end;
										end;
									end;
									replicated["Remotes"]["CommF_"]:InvokeServer("F_", "TalkTrevor", "1");
									replicated["Remotes"]["CommF_"]:InvokeServer("F_", "TalkTrevor", "2");
									replicated["Remotes"]["CommF_"]:InvokeServer("F_", "TalkTrevor", "3");
								end;
							end;
						else
							if replicated["Remotes"]["CommF_"]:InvokeServer("BartiloQuestProgress", "Bartilo") == 0 then
								if string["find"](plr["PlayerGui"]["Main"]["Quest"]["Container"]["QuestTitle"]["Title"]["Text"], "Swan Pirates") and (string["find"](plr["PlayerGui"]["Main"]["Quest"]["Container"]["QuestTitle"]["Title"]["Text"], "50") and plr["PlayerGui"]["Main"]["Quest"]["Visible"] == true) then
									local o = GetConnectionEnemies("Swan Pirate");
									if o then
										pcall(function()
											repeat
												wait();
												f["Kill"](o, _G["AutoZou"]);
											until not o["Parent"] or o["Humanoid"]["Health"] <= 0 or _G["AutoZou"] == false or plr["PlayerGui"]["Main"]["Quest"]["Visible"] == false;
										end);
									else
										_tp(CFrame["new"](1057.92761, 137.614319, 1242.08069));
									end;
								else
									_tp(CFrame["new"](-456.28952, 73.0200958, 299.895966));
								end;
							elseif replicated["Remotes"]["CommF_"]:InvokeServer("BartiloQuestProgress", "Bartilo") == 1 then
								local o = GetConnectionEnemies("Jeremy");
								if o then
									repeat
										wait();
										f["Kill"](o, _G["AutoZou"]);
									until not o["Parent"] or o["Humanoid"]["Health"] <= 0 or _G["AutoZou"] == false;
								else
									_tp(CFrame["new"](2099.88159, 448.931, 648.997375));
								end;
							elseif replicated["Remotes"]["CommF_"]:InvokeServer("BartiloQuestProgress", "Bartilo") == 2 then
								repeat
									wait();
									_tp(CFrame["new"](-1836, 11, 1714));
								until not _G["AutoZou"] or Root["Position"] == (CFrame["new"](-1836, 11, 1714))["Position"];
								if Root["CFrame"] == CFrame["new"](-1836, 11, 1714) then
									notween(CFrame["new"](-1836, 11, 1714));
								end;
								notween(CFrame["new"](-1850.49329, 13.1789551, 1750.89685));
								wait(.1);
								notween(CFrame["new"](-1858.87305, 19.3777466, 1712.01807));
								wait(.1);
								notween(CFrame["new"](-1803.94324, 16.5789185, 1750.89685));
								wait(.1);
								notween(CFrame["new"](-1858.55835, 16.8604317, 1724.79541));
								wait(.1);
								notween(CFrame["new"](-1869.54224, 15.987854, 1681.00659));
								wait(.1);
								notween(CFrame["new"](-1800.0979, 16.4978027, 1684.52368));
								wait(.1);
								notween(CFrame["new"](-1819.26343, 14.795166, 1717.90625));
								wait(.1);
								notween(CFrame["new"](-1813.51843, 14.8604736, 1724.79541));
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	t["Main"]:AddSection("Miscellanea / Quest");
	local h = t["Main"]:AddToggle("ClosetMons", { ["Title"] = "Auto Farm Nearest", ["Description"] = "", ["Default"] = false });
	h:OnChanged(function(o)
		_G["AutoFarmNear"] = o;
	end);
	spawn(function()
		while wait() do
			pcall(function()
				if _G["AutoFarmNear"] then
					for o, p in pairs(workspace["Enemies"]:GetChildren()) do
						if p:FindFirstChild("Humanoid") or p:FindFirstChild("HumanoidRootPart") then
							if p["Humanoid"]["Health"] > 0 then
								repeat
									wait();
									f["Kill"](p, _G["AutoFarmNear"]);
								until not _G["AutoFarmNear"] or not p["Parent"] or p["Humanoid"]["Health"] <= 0;
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	local i = t["Main"]:AddToggle("FactoryRaids", { ["Title"] = "Auto Factory Raid", ["Description"] = "", ["Default"] = false });
	i:OnChanged(function(o)
		_G["AutoFactory"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["AutoFactory"] then
					local o = GetConnectionEnemies("Core");
					if o then
						repeat
							wait();
							EquipWeapon(_G["SelectWeapon"]);
							_tp(CFrame["new"](448.46756, 199.356781, -441.389252));
						until o["Humanoid"]["Health"] <= 0 or _G["AutoFactory"] == false;
					else
						_tp(CFrame["new"](448.46756, 199.356781, -441.389252));
					end;
				end;
			end);
		end;
	end);
	local X = t["Main"]:AddToggle("CastleRaids", { ["Title"] = "Auto Pirate Raid", ["Description"] = "", ["Default"] = false });
	X:OnChanged(function(o)
		_G["AutoRaidCastle"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["AutoRaidCastle"] then
				pcall(function()
					local o = CFrame["new"](-5496.17432, 313.768921, -2841.53027, .924894512, 7.37058015e-009, .380223751, 3.5881019e-008, 1, -1.06665446e-007, -0.380223751, 1.12297109e-007, .924894512);
					if ((CFrame["new"](-5539.3115234375, 313.80053710938, -2972.3723144531))["Position"] - Root["Position"])["Magnitude"] <= 500 then
						for o, p in pairs(workspace["Enemies"]:GetChildren()) do
							if p:FindFirstChild("HumanoidRootPart") and (p:FindFirstChild("Humanoid") and p["Humanoid"]["Health"] > 0) then
								if p["Name"] then
									if (p["HumanoidRootPart"]["Position"] - Root["Position"])["Magnitude"] <= 2000 then
										repeat
											wait();
											f["Kill"](p, _G["AutoRaidCastle"]);
										until not _G["AutoRaidCastle"] or not p["Parent"] or p["Humanoid"]["Health"] <= 0 or not workspace["Enemies"]:FindFirstChild(p["Name"]);
									end;
								end;
							end;
						end;
					else
						local p = {
								"Galley Pirate",
								"Galley Captain",
								"Raider",
								"Mercenary",
								"Vampire",
								"Zombie",
								"Snow Trooper",
								"Winter Warrior",
								"Lab Subordinate",
								"Horned Warrior",
								"Magma Ninja",
								"Lava Pirate",
								"Ship Deckhand",
								"Ship Engineer",
								"Ship Steward",
								"Ship Officer",
								"Arctic Warrior",
								"Snow Lurker",
								"Sea Soldier",
								"Water Fighter",
							};
						for n = 1, #p, 1 do
							if replicated:FindFirstChild(p[n]) then
								for n, e in pairs(replicated:GetChildren()) do
									if table["find"](p, e["Name"]) then
										_tp(o);
									end;
								end;
							end;
						end;
					end;
				end);
			end;
		end;
	end);
	Test = t["Main"]:AddDropdown("Test", {
			["Title"] = "Choose Material",
			["Values"] = MaterialList,
			["Multi"] = false,
			["Default"] = nil,
		});
	Test:OnChanged(function(o)
		(getgenv())["SelectMaterial"] = o;
	end);
	Toggle = t["Main"]:AddToggle("Toggle", { ["Title"] = "Auto Materials", ["Description"] = "", ["Default"] = false });
	Toggle:OnChanged(function(o)
		(getgenv())["AutoMaterial"] = o;
	end);
	spawn(function()
		local function o(o, p)
			if o:FindFirstChild("Humanoid") and (o:FindFirstChild("HumanoidRootPart") and o["Humanoid"]["Health"] > 0) then
				if o["Name"] == p then
					repeat
						wait();
						f["Kill"](o, (getgenv())["AutoMaterial"]);
					until not (getgenv())["AutoMaterial"] or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
				end;
			end;
		end;
		local function p()
			for o, p in pairs((game:GetService("Workspace"))["_WorldOrigin"]["EnemySpawns"]:GetChildren()) do
				for o, n in ipairs(MMon) do
					if string["find"](p["Name"], n) then
						if (game["Players"]["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"] - p["Position"])["Magnitude"] >= 10 then
							_tp(p["CFrame"] * Pos);
						end;
					end;
				end;
			end;
		end;
		while wait() do
			if (getgenv())["AutoMaterial"] then
				pcall(function()
					if (getgenv())["SelectMaterial"] then
						MaterialMon((getgenv())["SelectMaterial"]);
						_tp(MPos);
					end;
					for p, n in ipairs(MMon) do
						for D, M in pairs(workspace["Enemies"]:GetChildren()) do
							o(M, n);
						end;
					end;
					p();
				end);
			end;
		end;
	end);
	local d = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Farm Ectoplasm", ["Description"] = "", ["Default"] = false });
	d:OnChanged(function(o)
		_G["AutoEctoplasm"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["AutoEctoplasm"] then
					local o = {
							"Ship Deckhand",
							"Ship Engineer",
							"Ship Steward",
							"Ship Officer",
							"Arctic Warrior",
						};
					local p = GetConnectionEnemies(o);
					if f["Alive"](p) then
						repeat
							wait();
							f["Kill"](p, _G["AutoEctoplasm"]);
						until not _G["AutoEctoplasm"] or not p["Parent"] or p["Humanoid"]["Health"] <= 0;
					else
						replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](923.21252441406, 126.9760055542, 32852.83203125));
					end;
				end;
			end);
		end;
	end);
	local H = t["Main"]:AddToggle("Bartilo", { ["Title"] = "Auto Done Bartilo Quest", ["Description"] = "", ["Default"] = false });
	H:OnChanged(function(o)
		_G["Bartilo_Quest"] = o;
	end);
	spawn(function()
		while wait(.1) do
			pcall(function()
				if _G["Bartilo_Quest"] and Lv >= 850 then
					local o = plr["PlayerGui"]["Main"]["Quest"];
					if replicated["Remotes"]["CommF_"]:InvokeServer("BartiloQuestProgress", "Bartilo") == 0 then
						_G["Level"] = false;
						if o["Visible"] == true then
							local p = GetConnectionEnemies("Swan Pirate");
							if p then
								local p = GetConnectionEnemies(U);
								if p then
									repeat
										task["wait"]();
										if not string["find"](plr["PlayerGui"]["Main"]["Quest"]["Container"]["QuestTitle"]["Title"]["Text"], "Swan Pirate") then
											replicated["Remotes"]["CommF_"]:InvokeServer("AbandonQuest");
										else
											f["Kill"](p, _G["Bartilo_Quest"]);
										end;
									until _G["Bartilo_Quest"] == false or not p["Parent"] or p["Humanoid"]["Health"] <= 0 or o["Visible"] == false or not p:FindFirstChild("HumanoidRootPart");
								end;
							else
								_tp(CFrame["nee"](970.369446, 142.653198, 1217.3667, .162079468, -4.85452638e-008, -0.986777723, 1.03357589e-008, 1, -4.74980872e-008, .986777723, -2.50063148e-009, .162079468));
							end;
						else
							repeat
								wait();
								_tp(CFrame["new"](-461.533203, 72.3478546, 300.311096, .050853312, 0, -0.998706102, 0, 1, 0, .998706102, 0, .050853312));
							until ((CFrame["new"](-461.533203, 72.3478546, 300.311096, .050853312, 0, -0.998706102, 0, 1, 0, .998706102, 0, .050853312))["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 20 or _G["Bartilo_Quest"] == false;
							if ((CFrame["new"](-461.533203, 72.3478546, 300.311096, .050853312, 0, -0.998706102, 0, 1, 0, .998706102, 0, .050853312))["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 1 then
								replicated["Remotes"]["CommF_"]:InvokeServer("StartQuest", "BartiloQuest", 1);
							end;
						end;
					elseif replicated["Remotes"]["CommF_"]:InvokeServer("BartiloQuestProgress", "Bartilo") == 1 then
						_G["Level"] = false;
						local p = GetConnectionEnemies("Jeremy");
						if p then
							repeat
								task["wait"]();
								f["Kill"](p, _G["Bartilo_Quest"]);
							until _G["Bartilo_Quest"] == false or not p["Parent"] or p["Humanoid"]["Health"] <= 0 or o["Visible"] == false or not p:FindFirstChild("HumanoidRootPart");
						else
							_tp(CFrame["new"](2158.97412, 449.056244, 705.411682, -0.754199564, -4.17389057e-009, -0.656645238, -4.47752875e-008, 1, 4.50709301e-008, .656645238, 6.3393955e-008, -0.754199564));
						end;
					elseif replicated["Remotes"]["CommF_"]:InvokeServer("BartiloQuestProgress", "Bartilo") == 2 then
						repeat
							wait();
							_tp(CFrame["new"](-1830.83972, 10.5578213, 1680.60229, .979988456, -2.02152783e-008, -0.199054286, 2.20792113e-008, 1, 7.1442483e-009, .199054286, -1.13962431e-008, .979988456));
						until ((CFrame["new"](-1830.83972, 10.5578213, 1680.60229, .979988456, -2.02152783e-008, -0.199054286, 2.20792113e-008, 1, 7.1442483e-009, .199054286, -1.13962431e-008, .979988456))["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 1 or _G["Bartilo_Quest"] == false;
						wait(.5);
						plr["Character"]["HumanoidRootPart"]["CFrame"] = workspace["Map"]["Dressrosa"]["BartiloPlates"]["Plate1"]["CFrame"];
						wait(.5);
						plr["Character"]["HumanoidRootPart"]["CFrame"] = workspace["Map"]["Dressrosa"]["BartiloPlates"]["Plate2"]["CFrame"];
						wait(.5);
						plr["Character"]["HumanoidRootPart"]["CFrame"] = workspace["Map"]["Dressrosa"]["BartiloPlates"]["Plate3"]["CFrame"];
						wait(.5);
						plr["Character"]["HumanoidRootPart"]["CFrame"] = workspace["Map"]["Dressrosa"]["BartiloPlates"]["Plate4"]["CFrame"];
						wait(.5);
						plr["Character"]["HumanoidRootPart"]["CFrame"] = workspace["Map"]["Dressrosa"]["BartiloPlates"]["Plate5"]["CFrame"];
						wait(.5);
						plr["Character"]["HumanoidRootPart"]["CFrame"] = workspace["Map"]["Dressrosa"]["BartiloPlates"]["Plate6"]["CFrame"];
						wait(.5);
						plr["Character"]["HumanoidRootPart"]["CFrame"] = workspace["Map"]["Dressrosa"]["BartiloPlates"]["Plate7"]["CFrame"];
						wait(.5);
						plr["Character"]["HumanoidRootPart"]["CFrame"] = workspace["Map"]["Dressrosa"]["BartiloPlates"]["Plate8"]["CFrame"];
						wait(2.5);
					end;
				end;
			end);
		end;
	end);
	local R = t["Main"]:AddToggle("CitizenQ", { ["Title"] = "Auto Done Citizen Quest", ["Description"] = "", ["Default"] = false });
	R:OnChanged(function(o)
		_G["CitizenQuest"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["CitizenQuest"] then
					if Lv >= 1800 and (replicated["Remotes"]["CommF_"]:InvokeServer("CitizenQuestProgress"))["KilledBandits"] == false then
						if string["find"](plr["PlayerGui"]["Main"]["Quest"]["Container"]["QuestTitle"]["Title"]["Text"], "Forest Pirate") and (string["find"](plr["PlayerGui"]["Main"]["Quest"]["Container"]["QuestTitle"]["Title"]["Text"], "50") and plr["PlayerGui"]["Main"]["Quest"]["Visible"] == true) then
							local o = GetConnectionEnemies("Forest Pirate");
							if o then
								repeat
									task["wait"]();
									f["Kill"](o, _G["CitizenQuest"]);
								until _G["CitizenQuest"] == false or not o["Parent"] or o["Humanoid"]["Health"] <= 0 or plr["PlayerGui"]["Main"]["Quest"]["Visible"] == false;
							else
								_tp(CFrame["new"](-13206.452148438, 425.89199829102, -7964.5537109375));
							end;
						else
							_tp(CFrame["new"](-12443.8671875, 332.40396118164, -7675.4892578125));
							if (Vector3["new"](-12443.8671875, 332.40396118164, -7675.4892578125) - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 30 then
								wait(1.5);
								replicated["Remotes"]["CommF_"]:InvokeServer("StartQuest", "CitizenQuest", 1);
							end;
						end;
					elseif Lv >= 1800 and (replicated["Remotes"]["CommF_"]:InvokeServer("CitizenQuestProgress"))["KilledBoss"] == false then
						local o = GetConnectionEnemies("Captain Elephant");
						if plr["PlayerGui"]["Main"]["Quest"]["Visible"] and (string["find"](plr["PlayerGui"]["Main"]["Quest"]["Container"]["QuestTitle"]["Title"]["Text"], "Captain Elephant") and plr["PlayerGui"]["Main"]["Quest"]["Visible"] == true) then
							if o then
								repeat
									task["wait"]();
									f["Kill"](o, _G["CitizenQuest"]);
								until _G["CitizenQuest"] == false or o["Humanoid"]["Health"] <= 0 or not o["Parent"] or plr["PlayerGui"]["Main"]["Quest"]["Visible"] == false;
							else
								_tp(CFrame["new"](-13374.889648438, 421.27752685547, -8225.208984375));
							end;
						else
							_tp(CFrame["new"](-12443.8671875, 332.40396118164, -7675.4892578125));
							if ((CFrame["new"](-12443.8671875, 332.40396118164, -7675.4892578125))["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 4 then
								wait(1.5);
								replicated["Remotes"]["CommF_"]:InvokeServer("CitizenQuestProgress", "Citizen");
							end;
						end;
					elseif Lv >= 1800 and replicated["Remotes"]["CommF_"]:InvokeServer("CitizenQuestProgress", "Citizen") == 2 then
						_tp(CFrame["new"](-12512.138671875, 340.39279174805, -9872.8203125));
					end;
				end;
			end);
		end;
	end);
	local P = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Training Dummy", ["Description"] = "", ["Default"] = false });
	P:OnChanged(function(o)
		_G["DummyMan"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["DummyMan"] then
				pcall(function()
					if plr["PlayerGui"]["Main"]["Quest"]["Visible"] == false then
						local o = { [1] = "ArenaTrainer" };
						((replicated:WaitForChild("Remotes")):WaitForChild("CommF_")):InvokeServer(unpack(o));
					else
						local o = GetConnectionEnemies("Training Dummy");
						if o then
							repeat
								wait();
								f["Kill"](o, _G["DummyMan"]);
							until not _G["DummyMan"] or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
						else
							_tp(CFrame["new"](3688.0051269531, 12.746943473816, 170.20953369141));
						end;
					end;
				end);
			end;
		end;
	end);
	local b = t["Main"]:AddToggle("Berry", { ["Title"] = "Auto Collect Berry", ["Description"] = "", ["Default"] = false });
	b:OnChanged(function(o)
		_G["AutoBerry"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["AutoBerry"] then
				local o = game:GetService("CollectionService");
				local p = game:GetService("Players");
				local n = p["LocalPlayer"];
				local e = o:GetTagged("BerryBush");
				local U, g = math["huge"];
				for o = 1, #e, 1 do
					local p = e[o];
					for o, n in pairs(p:GetAttributes()) do
						if not BerryArray or table["find"](BerryArray, n) then
							_tp(p["Parent"]:GetPivot());
							for o = 1, #e, 1 do
								local p = e[o];
								for o, p in pairs(p:GetChildren()) do
									if not BerryArray or table["find"](BerryArray, p) then
										_tp(p["WorldPivot"]);
										fireproximityprompt(p["ProximityPrompt"], math["huge"]);
									end;
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	end);
	local O = t["Main"]:AddToggle("Chest", { ["Title"] = "Auto Collect Chest", ["Description"] = "", ["Default"] = false });
	O:OnChanged(function(o)
		_G["AutoFarmChest"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["AutoFarmChest"] then
				pcall(function()
					local o = game:GetService("CollectionService");
					local p = game:GetService("Players");
					local n = p["LocalPlayer"];
					local e = n["Character"] or n["CharacterAdded"]:Wait();
					if not e then
						return;
					end;
					local U = (e:GetPivot())["Position"];
					local g = o:GetTagged("_ChestTagged");
					local Z, l = math["huge"], nil;
					for o = 1, #g, 1 do
						local p = g[o];
						local n = ((p:GetPivot())["Position"] - U)["Magnitude"];
						if not SelectedIsland or p:IsDescendantOf(SelectedIsland) then
							if not p:GetAttribute("IsDisabled") and n < Z then
								Z = n;
								l = p;
							end;
						end;
					end;
					if l then
						_tp(l:GetPivot());
					end;
				end);
			end;
		end;
	end);
	t["Main"]:AddSection("Miscellanea / Mastery");
	local j = { "Cake", "Bone" };
	local w = t["Main"]:AddDropdown("Mastery_Config", {
			["Title"] = "Choose Island",
			["Values"] = j,
			["Multi"] = false,
			["Default"] = 1,
		});
	w:OnChanged(function(D)
		SelectIsland = D;
	end);
	local G = t["Main"]:AddToggle("MasteryFruits", { ["Title"] = "Auto Mastery Fruits", ["Description"] = "", ["Default"] = false });
	G:OnChanged(function(o)
		_G["FarmMastery_Dev"] = o;
	end);
	spawn(function()
		RunSer["RenderStepped"]:Connect(function()
			pcall(function()
				if _G["FarmMastery_Dev"] or _G["FarmMastery_G"] or _G["FarmMastery_S"] then
					for o, p in pairs(plr["PlayerGui"]["Notifications"]:GetChildren()) do
						if p["Name"] == "NotificationTemplate" then
							if string["find"](p["Text"], "Skill locked!") then
								p:Destroy();
							end;
						end;
					end;
				end;
			end);
		end);
	end);
	spawn(function()
		while wait(Sec) do
			if _G["FarmMastery_Dev"] then
				pcall(function()
					if SelectIsland == "Cake" then
						local o = GetConnectionEnemies(W);
						if o then
							HealthM = (o["Humanoid"]["MaxHealth"] * 70) / 100;
							repeat
								wait();
								MousePos = o["HumanoidRootPart"]["Position"];
								f["Mas"](o, _G["FarmMastery_Dev"]);
							until _G["FarmMastery_Dev"] == false or o["Humanoid"]["Health"] <= 0 or not o["Parent"];
						else
							_tp(CFrame["new"](-1943.6765136719, 251.50956726074, -12337.880859375));
						end;
					elseif SelectIsland == "Bone" then
						local o = GetConnectionEnemies(Y);
						if o then
							HealthM = (o["Humanoid"]["MaxHealth"] * 70) / 100;
							repeat
								wait();
								MousePos = o["HumanoidRootPart"]["Position"];
								f["Mas"](o, _G["FarmMastery_Dev"]);
							until _G["FarmMastery_Dev"] == false or o["Humanoid"]["Health"] <= 0 or not o["Parent"];
						else
							_tp(CFrame["new"](-9495.6806640625, 453.58624267578, 5977.3486328125));
						end;
					end;
				end);
			end;
		end;
	end);
	local T = t["Main"]:AddToggle("MasteryGun", { ["Title"] = "Auto Mastery Gun", ["Description"] = "", ["Default"] = false });
	T:OnChanged(function(o)
		_G["FarmMastery_G"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["FarmMastery_G"] then
				pcall(function()
					if SelectIsland == "Cake" then
						local o = GetConnectionEnemies(W);
						if o then
							HealthM = (o["Humanoid"]["MaxHealth"] * 70) / 100;
							repeat
								wait();
								MousePos = o["HumanoidRootPart"]["Position"];
								f["Masgun"](o, _G["FarmMastery_G"]);
								local p = replicated:FindFirstChild("Modules");
								local n = p:FindFirstChild("Net");
								local e = n:FindFirstChild("RE/ShootGunEvent");
								if (plr["Character"]:FindFirstChildOfClass("Tool"))["ToolTip"] ~= "Gun" then
									return;
								end;
								if plr["Character"]:FindFirstChildOfClass("Tool") and (plr["Character"]:FindFirstChildOfClass("Tool"))["Name"] == "Skull Guitar" then
									SoulGuitar = true;
									(plr["Character"]:FindFirstChildOfClass("Tool"))["RemoteEvent"]:FireServer("TAP", MousePos);
									if _G["FarmMastery_G"] then
										vim1:SendMouseButtonEvent(0, 0, 0, true, game, 1);
										wait(.05);
										vim1:SendMouseButtonEvent(0, 0, 0, false, game, 1);
										wait(.05);
									end;
								elseif plr["Character"]:FindFirstChildOfClass("Tool") and (plr["Character"]:FindFirstChildOfClass("Tool"))["Name"] ~= "Skull Guitar" then
									SoulGuitar = false;
									e:FireServer(MousePos, { o["HumanoidRootPart"] });
									if _G["FarmMastery_G"] then
										vim1:SendMouseButtonEvent(0, 0, 0, true, game, 1);
										wait(.05);
										vim1:SendMouseButtonEvent(0, 0, 0, false, game, 1);
										wait(.05);
									end;
								end;
							until _G["FarmMastery_G"] == false or o["Humanoid"]["Health"] <= 0 or not o["Parent"];
							SoulGuitar = false;
						else
							_tp(CFrame["new"](-1943.6765136719, 251.50956726074, -12337.880859375));
						end;
					elseif SelectIsland == "Bone" then
						local o = GetConnectionEnemies(Y);
						if o then
							HealthM = (o["Humanoid"]["MaxHealth"] * 70) / 100;
							repeat
								wait();
								MousePos = o["HumanoidRootPart"]["Position"];
								f["Masgun"](o, _G["FarmMastery_G"]);
								local p = replicated:FindFirstChild("Modules");
								local n = p:FindFirstChild("Net");
								local e = n:FindFirstChild("RE/ShootGunEvent");
								if (plr["Character"]:FindFirstChildOfClass("Tool"))["ToolTip"] ~= "Gun" then
									return;
								end;
								if plr["Character"]:FindFirstChildOfClass("Tool") and (plr["Character"]:FindFirstChildOfClass("Tool"))["Name"] == "Skull Guitar" then
									SoulGuitar = true;
									(plr["Character"]:FindFirstChildOfClass("Tool"))["RemoteEvent"]:FireServer("TAP", MousePos);
									if _G["FarmMastery_G"] then
										vim1:SendMouseButtonEvent(0, 0, 0, true, game, 1);
										wait(.05);
										vim1:SendMouseButtonEvent(0, 0, 0, false, game, 1);
										wait(.05);
									end;
								elseif plr["Character"]:FindFirstChildOfClass("Tool") and (plr["Character"]:FindFirstChildOfClass("Tool"))["Name"] ~= "Skull Guitar" then
									SoulGuitar = false;
									e:FireServer(MousePos, { o["HumanoidRootPart"] });
									if _G["FarmMastery_G"] then
										vim1:SendMouseButtonEvent(0, 0, 0, true, game, 1);
										wait(.05);
										vim1:SendMouseButtonEvent(0, 0, 0, false, game, 1);
										wait(.05);
									end;
								end;
							until _G["FarmMastery_G"] == false or o["Humanoid"]["Health"] <= 0 or not o["Parent"];
							SoulGuitar = false;
						else
							_tp(CFrame["new"](-9495.6806640625, 453.58624267578, 5977.3486328125));
						end;
					end;
				end);
			end;
		end;
	end);
	local r = t["Main"]:AddToggle("MasterySword", { ["Title"] = "Auto Mastery All Sword", ["Description"] = "", ["Default"] = false });
	r:OnChanged(function(o)
		_G["FarmMastery_S"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["FarmMastery_S"] then
					if SelectIsland == "Cake" then
						for o, p in next, replicated["Remotes"]["CommF_"]:InvokeServer("getInventory") do
							if type(p) == "table" then
								if p["Type"] == "Sword" then
									SwordName = p["Name"];
									if tonumber(p["Mastery"]) >= 1 or tonumber(p["Mastery"]) <= 599 then
										local o = GetConnectionEnemies(W);
										if GetBP(SwordName) then
											if o then
												repeat
													wait();
													f["Sword"](o, _G["FarmMastery_S"]);
												until _G["FarmMastery_S"] == false or not o["Parent"] or o["Humanoid"]["Healh"] <= 0;
											else
												_tp(CFrame["new"](-1943.6765136719, 251.50956726074, -12337.880859375));
											end;
										else
											replicated["Remotes"]["CommF_"]:InvokeServer("LoadItem", SwordName);
										end;
									elseif tonumber(p["Mastery"]) >= 600 then
										if GetBP(SwordName) then
											return nil;
										else
											replicated["Remotes"]["CommF_"]:InvokeServer("LoadItem", SwordName);
										end;
									end;
									break;
								end;
							end;
						end;
					elseif SelectIsland == "Bone" then
						for o, p in next, replicated["Remotes"]["CommF_"]:InvokeServer("getInventory") do
							if type(p) == "table" then
								if p["Type"] == "Sword" then
									SwordName = p["Name"];
									if tonumber(p["Mastery"]) >= 1 or tonumber(p["Mastery"]) <= 599 then
										local o = GetConnectionEnemies(Y);
										if GetBP(SwordName) then
											if o then
												repeat
													wait();
													f["Sword"](o, _G["FarmMastery_S"]);
												until _G["FarmMastery_S"] == false or not o["Parent"] or o["Humanoid"]["Healh"] <= 0;
											else
												_tp(CFrame["new"](-9495.6806640625, 453.58624267578, 5977.3486328125));
											end;
										else
											replicated["Remotes"]["CommF_"]:InvokeServer("LoadItem", SwordName);
										end;
									elseif tonumber(p["Mastery"]) >= 600 then
										if GetBP(SwordName) then
											return nil;
										else
											replicated["Remotes"]["CommF_"]:InvokeServer("LoadItem", SwordName);
										end;
									end;
									break;
								end;
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	t["Main"]:AddSection("Generals Quests / Items");
	local F = t["Main"]:AddParagraph({ ["Title"] = "Cake Princes :", ["Content"] = "" });
	spawn(function()
		while wait(.2) do
			pcall(function()
				local o = string["match"](replicated["Remotes"]["CommF_"]:InvokeServer("CakePrinceSpawner"), "%d+");
				if o then
					F:SetDesc(" Killed : " .. 500 - o);
				end;
			end);
		end;
	end);
	local c = t["Main"]:AddParagraph({ ["Title"] = " Bones :", ["Content"] = "" });
	spawn(function()
		while wait(.2) do
			pcall(function()
				c:SetDesc(" Bones : " .. GetM("Bones"));
			end);
		end;
	end);
	local u = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Cake Prince", ["Description"] = "", ["Default"] = false });
	u:OnChanged(function(o)
		_G["Auto_Cake_Prince"] = o;
	end);
	spawn(function()
		while wait() do
			if _G["Auto_Cake_Prince"] then
				pcall(function()
					local o = game["Players"]["LocalPlayer"];
					local p = o["Character"] and o["Character"]:FindFirstChild("HumanoidRootPart");
					local n = o["PlayerGui"]["Main"]["Quest"];
					local e = workspace["Enemies"];
					local U = workspace["Map"]["CakeLoaf"]["BigMirror"];
					if not p then
						return;
					end;
					if not U:FindFirstChild("Other") then
						_tp(CFrame["new"](-2077, 252, -12373));
					end;
					if U["Other"]["Transparency"] == 0 or e:FindFirstChild("Cake Prince") then
						local o = GetConnectionEnemies("Cake Prince");
						if o then
							repeat
								wait();
								f["Kill2"](o, _G["Auto_Cake_Prince"]);
							until not _G["Auto_Cake_Prince"] or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
						else
							if U["Other"]["Transparency"] == 0 and ((CFrame["new"](-1990.67, 4533, -14973.67))["Position"] - p["Position"])["Magnitude"] >= 2000 then
								_tp(CFrame["new"](-2151.82, 149.32, -12404.91));
							end;
						end;
					else
						local o = {
								"Cookie Crafter",
								"Cake Guard",
								"Baking Staff",
								"Head Baker",
							};
						local e = GetConnectionEnemies(o);
						if e then
							if _G["AcceptQuestC"] and not n["Visible"] then
								local o = CFrame["new"](-1927.92, 37.8, -12842.54);
								_tp(o);
								while (o["Position"] - p["Position"])["Magnitude"] > 50 do
									wait(.2);
								end;
								local n = math["random"](1, 4);
								local e = {
										[1] = { "StartQuest", "CakeQuest2", 2 },
										[2] = { "StartQuest", "CakeQuest2", 1 },
										[3] = { "StartQuest", "CakeQuest1", 1 },
										[4] = { "StartQuest", "CakeQuest1", 2 },
									};
								local U, g = pcall(function()
										return game["ReplicatedStorage"]["Remotes"]["CommF_"]:InvokeServer(unpack(e[n]));
									end);
							end;
							repeat
								wait();
								f["Kill"](e, _G["Auto_Cake_Prince"]);
							until not _G["Auto_Cake_Prince"] or e["Humanoid"]["Health"] <= 0 or U["Other"]["Transparency"] == 0 or _G["AcceptQuestC"] and not n["Visible"];
						else
							_tp(CFrame["new"](-2077, 252, -12373));
						end;
					end;
				end);
			end;
		end;
	end);
	local y = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Bones", ["Description"] = "", ["Default"] = false });
	y:OnChanged(function(o)
		_G["AutoFarm_Bone"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["AutoFarm_Bone"] then
				pcall(function()
					local o = game["Players"]["LocalPlayer"];
					local p = o["Character"] and o["Character"]:FindFirstChild("HumanoidRootPart");
					local n = o["PlayerGui"]["Main"]["Quest"];
					local e = {
							"Reborn Skeleton",
							"Living Zombie",
							"Demonic Soul",
							"Posessed Mummy",
						};
					if not p then
						return;
					end;
					local U = GetConnectionEnemies(e);
					if U then
						if _G["AcceptQuestC"] and not n["Visible"] then
							local o = CFrame["new"](-9516.99316, 172.017181, 6078.46533, 0, 0, -1, 0, 1, 0, 1, 0, 0);
							_tp(o);
							while (o["Position"] - p["Position"])["Magnitude"] > 50 do
								wait(.2);
							end;
							local n = math["random"](1, 4);
							local e = {
									[1] = { "StartQuest", "HauntedQuest2", 2 },
									[2] = { "StartQuest", "HauntedQuest2", 1 },
									[3] = { "StartQuest", "HauntedQuest1", 1 },
									[4] = { "StartQuest", "HauntedQuest1", 2 },
								};
							local U, g = pcall(function()
									return game["ReplicatedStorage"]["Remotes"]["CommF_"]:InvokeServer(unpack(e[n]));
								end);
						end;
						repeat
							task["wait"]();
							f["Kill"](U, _G["AutoFarm_Bone"]);
						until not _G["AutoFarm_Bone"] or U["Humanoid"]["Health"] <= 0 or not U["Parent"] or _G["AcceptQuestC"] and not n["Visible"];
					else
						_tp(CFrame["new"](-9495.6806640625, 453.58624267578, 5977.3486328125));
					end;
				end);
			end;
		end;
	end);
	local m = t["Main"]:AddToggle("Q", { ["Title"] = "Accept Quests", ["Description"] = "", ["Default"] = false });
	m:OnChanged(function(o)
		_G["AcceptQuestC"] = o;
	end);
	local x = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Farm Mirror", ["Description"] = "", ["Default"] = false });
	x:OnChanged(function(o)
		_G["AutoMiror"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["AutoMiror"] then
				pcall(function()
					local o = GetConnectionEnemies("Dough King");
					if o then
						repeat
							wait();
							f["Kill"](o, _G["AutoMiror"]);
						until not _G["AutoMiror"] or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
					else
						_tp(CFrame["new"](-1943.6765136719, 251.50956726074, -12337.880859375));
					end;
				end);
			end;
		end;
	end);
	local v = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Soul Reaper [Fully]", ["Description"] = "", ["Default"] = false });
	v:OnChanged(function(o)
		_G["AutoHytHallow"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["AutoHytHallow"] then
				pcall(function()
					local o = GetConnectionEnemies("Soul Reaper");
					if o then
						repeat
							task["wait"]();
							f["Kill"](o, _G["AutoHytHallow"]);
						until o["Humanoid"]["Health"] <= 0 or _G["AutoHytHallow"] == false;
					else
						if not GetBP("Hallow Essence") then
							repeat
								task["wait"](.1);
								replicated["Remotes"]["CommF_"]:InvokeServer("Bones", "Buy", 1, 1);
							until _G["AutoHytHallow"] == false or GetBP("Hallow Essence");
						else
							repeat
								wait(.1);
								_tp(CFrame["new"](-8932.322265625, 146.83154296875, 6062.55078125));
							until _G["AutoHytHallow"] == false or plr["Character"]["HumanoidRootPart"]["CFrame"] == CFrame["new"](-8932.322265625, 146.83154296875, 6062.55078125);
							EquipWeapon("Hallow Essence");
						end;
					end;
				end);
			end;
		end;
	end);
	local C = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Random Bones", ["Description"] = "", ["Default"] = false });
	C:OnChanged(function(o)
		_G["Auto_Random_Bone"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Auto_Random_Bone"] then
					repeat
						task["wait"]();
						replicated["Remotes"]["CommF_"]:InvokeServer("Bones", "Buy", 1, 1);
					until not _G["Auto_Random_Bone"];
				end;
			end);
		end;
	end);
	local S = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Try Luck Gravestone", ["Description"] = "", ["Default"] = false });
	S:OnChanged(function(o)
		_G["TryLucky"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["TryLucky"] then
				local o = CFrame["new"](-8761.3154296875, 164.85829162598, 6161.1567382813);
				if plr["Character"]["HumanoidRootPart"]["CFrame"] ~= o then
					_tp(CFrame["new"](-8761.3154296875, 164.85829162598, 6161.1567382813));
				elseif plr["Character"]["HumanoidRootPart"]["CFrame"] == o then
					replicated["Remotes"]["CommF_"]:InvokeServer("gravestoneEvent", 1);
				end;
			end;
		end;
	end);
	local V = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Pray Gravestone", ["Description"] = "", ["Default"] = false });
	V:OnChanged(function(o)
		_G["Praying"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["Praying"] then
				local o = CFrame["new"](-8761.3154296875, 164.85829162598, 6161.1567382813);
				if plr["Character"]["HumanoidRootPart"]["CFrame"] ~= o then
					_tp(CFrame["new"](-8761.3154296875, 164.85829162598, 6161.1567382813));
				elseif plr["Character"]["HumanoidRootPart"]["CFrame"] == o then
					replicated["Remotes"]["CommF_"]:InvokeServer("gravestoneEvent", 2);
				end;
			end;
		end;
	end);
	t["Main"]:AddSection("Unlocked Dungeon");
	local q = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Unlock Dough dungeon", ["Description"] = "", ["Default"] = false });
	q:OnChanged(function(o)
		_G["Doughv2"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["Doughv2"] then
				pcall(function()
					if not workspace["Map"]["CakeLoaf"]:FindFirstChild("RedDoor") then
						if GetBP("Red Key") then
							replicated["Remotes"]["CommF_"]:InvokeServer("CakeScientist", "Check");
							replicated["Remotes"]["CommF_"]:InvokeServer("RaidsNpc", "Check");
						end;
					elseif workspace["Map"]["CakeLoaf"]:FindFirstChild("RedDoor") then
						if GetBP("Red Key") then
							repeat
								wait();
								_tp(CFrame["new"](-2681.97998, 64.3921585, -12853.7363, .149007782, -1.87902192e-008, .98883605, 3.60619588e-008, 1, 1.35681812e-008, -0.98883605, 3.36376011e-008, .149007782));
							until not _G["Doughv2"] or (plr["Character"]["HumanoidRootPart"]["CFrame"] - CFrame["new"](-2681.97998, 64.3921585, -12853.7363, .149007782, -1.87902192e-008, .98883605, 3.60619588e-008, 1, 1.35681812e-008, -0.98883605, 3.36376011e-008, .149007782))["Magnitude"] <= 5;
							EquipWeapon("Red Key");
						end;
					elseif GetConnectionEnemies("Dough King") then
						local o = GetConnectionEnemies("Dough King");
						if o then
							repeat
								wait();
								f["Kill"](o, _G["Doughv2"]);
							until not _G["Doughv2"] or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
						else
							_tp(CFrame["new"](-1943.6765136719, 251.50956726074, -12337.880859375));
						end;
					end;
					if GetBP("Sweet Chalice") then
						replicated["Remotes"]["CommF_"]:InvokeServer("CakePrinceSpawner", true);
						_G["AutoMiror"] = true;
					else
						_G["AutoMiror"] = false;
					end;
					if GetBP("God's Chalice") and GetM("Conjured Cocoa") >= 10 then
						replicated["Remotes"]["CommF_"]:InvokeServer("SweetChaliceNpc");
					end;
					if not plr["Backpack"]:FindFirstChild("God's Chalice") or plr["Character"]:FindFirstChild("God's Chalice") then
						_G["FarmEliteHunt"] = true;
					else
						_G["FarmEliteHunt"] = false;
					end;
					if GetM("Conjured Cocoa") <= 10 then
						local o = { "Cocoa Warrior", "Chocolate Bar Battler" };
						local p = GetConnectionEnemies(o);
						if p then
							repeat
								wait();
								f["Kill"](p, _G["Doughv2"]);
							until _G["Doughv2"] == false or not p["Parent"] or p["Humanoid"]["Health"] <= 0;
						else
							_tp(CFrame["new"](402.71890258789, 81.060501098633, -12259.54296875));
						end;
					end;
				end);
			end;
		end;
	end);
	local L = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Unlock Phoenix dungeon", ["Description"] = "", ["Default"] = false });
	L:OnChanged(function(o)
		_G["AutoPhoenixF"] = o;
	end);
	spawn(function()
		while wait(.1) do
			if _G["AutoPhoenixF"] then
				pcall(function()
					if GetBP("Bird-Bird: Phoenix") then
						if plr["Backpack"]:FindFirstChild(plr["Data"]["DevilFruit"]["Value"]) then
							if (plr["Backpack"]:FindFirstChild(plr["Data"]["DevilFruit"]["Value"]))["Level"]["Value"] >= 400 then
								_tp(CFrame["new"](-2812.7670898438, 254.80346679688, -12595.560546875));
								if ((CFrame["new"](-2812.7670898438, 254.80346679688, -12595.560546875))["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 10 then
									replicated["Remotes"]["CommF_"]:InvokeServer("SickScientist", "Check");
									replicated["Remotes"]["CommF_"]:InvokeServer("SickScientist", "Heal");
								end;
							end;
						elseif plr["Character"]:FindFirstChild(plr["Data"]["DevilFruit"]["Value"]) then
							if (plr["Character"]:FindFirstChild(plr["Data"]["DevilFruit"]["Value"]))["Level"]["Value"] >= 400 then
								_tp(CFrame["new"](-2812.7670898438, 254.80346679688, -12595.560546875));
								if ((CFrame["new"](-2812.7670898438, 254.80346679688, -12595.560546875))["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 10 then
									replicated["Remotes"]["CommF_"]:InvokeServer("SickScientist", "Check");
									replicated["Remotes"]["CommF_"]:InvokeServer("SickScientist", "Heal");
								end;
							end;
						end;
					end;
				end);
			end;
		end;
	end);
	t["Main"]:AddSection("Buso/Aura Colours");
	local DW = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Teleport Barista Cousin", ["Description"] = "", ["Default"] = false });
	DW:OnChanged(function(o)
		_G["Tp_MasterA"] = o;
	end);
	spawn(function()
		while wait() do
			if _G["Tp_MasterA"] then
				pcall(function()
					for o, p in pairs(replicated["NPCs"]:GetChildren()) do
						if p["Name"] == "Barista Cousin" then
							_tp(p["HumanoidRootPart"]["CFrame"]);
						end;
					end;
				end);
			end;
		end;
	end);
	t["Main"]:AddButton({ ["Title"] = "Buy Buso Colors", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("ColorsDealer", "2");
		end });
	local MW = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Rainbow Colors", ["Description"] = "", ["Default"] = false });
	MW:OnChanged(function(o)
		_G["Auto_Rainbow_Haki"] = o;
	end);
	spawn(function()
		pcall(function()
			while wait(Sec) do
				if _G["Auto_Rainbow_Haki"] then
					if plr["PlayerGui"]["Main"]["Quest"]["Visible"] == false then
						if _G["GetQFast"] then
							if plr["PlayerGui"]["Main"]["Quest"]["Visible"] == false then
								replicated["Remotes"]["CommF_"]:InvokeServer("HornedMan", "Bet");
							end;
						else
							Rainbow1 = CFrame["new"](-11892.0703125, 930.57672119141, -8760.1591796875);
							if plr["Character"]["HumanoidRootPart"]["CFrame"] ~= Rainbow1 then
								_tp(Rainbow1);
							elseif plr["Character"]["HumanoidRootPart"]["CFrame"] == Rainbow1 then
								wait(1);
								replicated["Remotes"]["CommF_"]:InvokeServer("HornedMan", "Bet");
							end;
						end;
					elseif plr["PlayerGui"]["Main"]["Quest"]["Visible"] == true and string["find"](plr["PlayerGui"]["Main"]["Quest"]["Container"]["QuestTitle"]["Title"]["Text"], "Stone") then
						local o = GetConnectionEnemies("Stone");
						if o then
							repeat
								wait();
								f["Kill"](o, _G["Auto_Rainbow_Haki"]);
							until _G["Auto_Rainbow_Haki"] == false or o["Humanoid"]["Health"] <= 0 or not o["Parent"] or plr["PlayerGui"]["Main"]["Quest"]["Visible"] == false;
						else
							_tp(CFrame["new"](-1086.11621, 38.8425903, 6768.71436, .0231462717, -0.592676699, .805107772, 2.03251839e-005, .805323839, .592835128, -0.999732077, -0.0137055516, .0186523199));
						end;
					elseif plr["PlayerGui"]["Main"]["Quest"]["Visible"] == true and string["find"](plr["PlayerGui"]["Main"]["Quest"]["Container"]["QuestTitle"]["Title"]["Text"], "Hydra Leader") then
						local o = GetConnectionEnemies("Hydra Leader");
						if o then
							repeat
								task["wait"]();
								f["Kill"](o, _G["Auto_Rainbow_Haki"]);
							until _G["Auto_Rainbow_Haki"] == false or o["Humanoid"]["Health"] <= 0 or not o["Parent"] or plr["PlayerGui"]["Main"]["Quest"]["Visible"] == false;
						else
							replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](5643.4526367188, 1013.0858154297, -340.51025390625));
							local o = Vector3["new"](5643.4526367188, 1013.0858154297, -340.51025390625);
							local p = CFrame["new"](5821.8979492188, 1019.0950927734, -73.719230651855);
							if plr["Character"]["HumanoidRootPart"]["CFrame"]["Position"] == o then
								_tp(p);
							end;
						end;
					elseif plr["PlayerGui"]["Main"]["Quest"]["Visible"] == true and string["find"](plr["PlayerGui"]["Main"]["Quest"]["Container"]["QuestTitle"]["Title"]["Text"], "Kilo Admiral") then
						local o = GetConnectionEnemies("Kilo Admiral");
						if o then
							repeat
								task["wait"]();
								f["Kill"](o, _G["Auto_Rainbow_Haki"]);
							until _G["Auto_Rainbow_Haki"] == false or o["Humanoid"]["Health"] <= 0 or not o["Parent"] or plr["PlayerGui"]["Main"]["Quest"]["Visible"] == false;
						else
							_tp(CFrame["new"](2877.61743, 423.558685, -7207.31006, -0.989591599, 0, -0.143904909, 0, 1.00000012, 0, .143904924, 0, -0.989591479));
						end;
					elseif plr["PlayerGui"]["Main"]["Quest"]["Visible"] == true and string["find"](plr["PlayerGui"]["Main"]["Quest"]["Container"]["QuestTitle"]["Title"]["Text"], "Captain Elephant") then
						local o = GetConnectionEnemies("Captain Elephant");
						if o then
							repeat
								task["wait"]();
								f["Kill"](o, _G["Auto_Rainbow_Haki"]);
							until _G["Auto_Rainbow_Haki"] == false or o["Humanoid"]["Health"] <= 0 or not o["Parent"] or plr["PlayerGui"]["Main"]["Quest"]["Visible"] == false;
						else
							local o = Vector3["new"](-12471.169921875, 374.94024658203, -7551.677734375);
							local p = CFrame["new"](-13376.7578125, 433.28689575195, -8071.392578125);
							if plr["Character"]["HumanoidRootPart"]["CFrame"]["Position"] ~= o then
								replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](-12471.169921875, 374.94024658203, -7551.677734375));
							elseif plr["Character"]["HumanoidRootPart"]["CFrame"]["Position"] == o then
								_tp(p);
							end;
						end;
					elseif plr["PlayerGui"]["Main"]["Quest"]["Visible"] == true and string["find"](plr["PlayerGui"]["Main"]["Quest"]["Container"]["QuestTitle"]["Title"]["Text"], "Beautiful Pirate") then
						local o = GetConnectionEnemies("Captain Elephant");
						if o then
							repeat
								task["wait"]();
								f["Kill"](o, _G["Auto_Rainbow_Haki"]);
							until _G["Auto_Rainbow_Haki"] == false or o["Humanoid"]["Health"] <= 0 or not o["Parent"] or plr["PlayerGui"]["Main"]["Quest"]["Visible"] == false;
						else
							replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](5314.5463867188, 22.562219619751, -127.06755065918));
						end;
					end;
				end;
			end;
		end);
	end);
	local oW = t["Main"]:AddToggle("Q", { ["Title"] = "Accept Rainbow Quest Faster", ["Description"] = "", ["Default"] = false });
	oW:OnChanged(function(o)
		_G["GetQFast"] = o;
	end);
	t["Main"]:AddSection("Instinct / Observation");
	local pW = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Farm Observation", ["Description"] = "", ["Default"] = false });
	pW:OnChanged(function(o)
		_G["obsFarm"] = o;
	end);
	spawn(function()
		while wait(.2) do
			pcall(function()
				if _G["obsFarm"] then
					replicated["Remotes"]["CommE"]:FireServer("Ken", true);
					if plr:GetAttribute("KenDodgesLeft") == 0 then
						KenTest = false;
					elseif plr:GetAttribute("KenDodgesLeft") > 0 then
						replicated["Remotes"]["CommE"]:FireServer("Ken", true);
						KenTest = true;
					end;
				end;
			end);
		end;
	end);
	spawn(function()
		while wait(.2) do
			pcall(function()
				if _G["obsFarm"] then
					if World1 then
						if workspace["Enemies"]:FindFirstChild("Galley Captain") then
							if KenTest then
								repeat
									wait();
									plr["Character"]["HumanoidRootPart"]["CFrame"] = (workspace["Enemies"]:FindFirstChild("Galley Captain"))["HumanoidRootPart"]["CFrame"] * CFrame["new"](3, 0, 0);
								until _G["obsFarm"] == false or KenTest == false;
							else
								repeat
									wait();
									plr["Character"]["HumanoidRootPart"]["CFrame"] = (workspace["Enemies"]:FindFirstChild("Galley Captain"))["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 50, 0);
								until _G["obsFarm"] == false or KenTest;
							end;
						else
							_tp(CFrame["new"](5533.29785, 88.1079102, 4852.3916));
						end;
					elseif World2 then
						if workspace["Enemies"]:FindFirstChild("Lava Pirate") then
							if KenTest then
								repeat
									wait();
									plr["Character"]["HumanoidRootPart"]["CFrame"] = (workspace["Enemies"]:FindFirstChild("Lava Pirate"))["HumanoidRootPart"]["CFrame"] * CFrame["new"](3, 0, 0);
								until _G["obsFarm"] == false or KenTest == false;
							else
								repeat
									wait();
									plr["Character"]["HumanoidRootPart"]["CFrame"] = (workspace["Enemies"]:FindFirstChild("Lava Pirate"))["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 50, 0);
								until _G["obsFarm"] == false or KenTest;
							end;
						else
							_tp(CFrame["new"](-5478.39209, 15.9775667, -5246.9126));
						end;
					elseif World3 then
						if workspace["Enemies"]:FindFirstChild("Venomous Assailant") then
							if KenTest then
								repeat
									wait();
									_tp((workspace["Enemies"]:FindFirstChild("Venomous Assailant"))["HumanoidRootPart"]["CFrame"] * CFrame["new"](3, 0, 0));
								until _G["obsFarm"] == false or KenTest == false;
							else
								repeat
									wait();
									_tp((workspace["Enemies"]:FindFirstChild("Venomous Assailant"))["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 50, 0));
								until _G["obsFarm"] == false or KenTest;
							end;
						else
							_tp(CFrame["new"](4530.3540039063, 656.75695800781, -131.60952758789));
						end;
					end;
				end;
			end);
		end;
	end);
	local nW = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Observation V2", ["Description"] = "", ["Default"] = false });
	nW:OnChanged(function(o)
		_G["AutoKenVTWO"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["AutoKenVTWO"] then
				pcall(function()
					local o = CFrame["new"](-12444.78515625, 332.40396118164, -7673.1806640625);
					local p = "Kuy";
					local n = CFrame["new"](-10920.125, 624.20275878906, -10266.995117188);
					local e = CFrame["new"](-13277.568359375, 370.34185791016, -7821.1572265625);
					local U = CFrame["new"](-13493.12890625, 318.89553833008, -8373.7919921875);
					if plr["PlayerGui"]["Main"]["Quest"]["Visible"] == true and string["find"](plr["PlayerGui"]["Main"]["Quest"]["Container"]["QuestTitle"]["Title"]["Text"], "Defeat 50 Forest Pirates") then
						local o = GetConnectionEnemies("Forest Pirate");
						if o then
							repeat
								wait();
								f["Kill"](o, _G["AutoKenVTWO"]);
							until not _G["AutoKenVTWO"] or o["Humanoid"]["Health"] <= 0 or plr["PlayerGui"]["Main"]["Quest"]["Visible"] == false;
						else
							_tp(e);
						end;
					elseif plr["PlayerGui"]["Main"]["Quest"]["Visible"] == true then
						local o = GetConnectionEnemies("Captain Elephant");
						if o then
							repeat
								wait();
								f["Kill"](o, _G["AutoKenVTWO"]);
							until not _G["AutoKenVTWO"] or o["Humanoid"]["Health"] <= 0 or plr["PlayerGui"]["Main"]["Quest"]["Visible"] == false;
						else
							_tp(U);
						end;
					elseif plr["PlayerGui"]["Main"]["Quest"]["Visible"] == false then
						replicated["Remotes"]["CommF_"]:InvokeServer("CitizenQuestProgress", "Citizen");
						wait(.1);
						replicated["Remotes"]["CommF_"]:InvokeServer("StartQuest", "CitizenQuest", 1);
					end;
					if replicated["Remotes"]["CommF_"]:InvokeServer("CitizenQuestProgress", "Citizen") == 2 then
						_tp(CFrame["new"](-12513.51953125, 340.11373901367, -9873.048828125));
					end;
					if not plr["Backpack"]:FindFirstChild("Fruit Bowl") or not plr["Character"]:FindFirstChild("Fruit Bowl") then
						if not GetBP("Fruit Bowl") then
							if not GetBP("Apple") then
								replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](-12471.169921875, 374.94024658203, -7551.677734375));
								for o, p in pairs(workspace:GetDescendants()) do
									if p["Name"] == "Apple" then
										p["Handle"]["CFrame"] = plr["Character"]["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 1, 10);
										wait();
										firetouchinterest(plr["Character"]["HumanoidRootPart"], p["Handle"], 0);
										wait();
									end;
								end;
							elseif not GetBP("Banana") then
								_tp(CFrame["new"](2286.0078125, 73.133918762207, -7159.8090820312));
								for o, p in pairs(workspace:GetDescendants()) do
									if p["Name"] == "Banana" then
										p["Handle"]["CFrame"] = plr["Character"]["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 1, 10);
										wait();
										firetouchinterest(plr["Character"]["HumanoidRootPart"], p["Handle"], 0);
										wait();
									end;
								end;
							elseif not GetBP("Pineapple") then
								_tp(CFrame["new"](-712.82727050781, 98.577049255371, 5711.9541015625));
								for o, p in pairs(workspace:GetDescendants()) do
									if p["Name"] == "Pineapple" then
										p["Handle"]["CFrame"] = plr["Character"]["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 1, 10);
										wait();
										firetouchinterest(plr["Character"]["HumanoidRootPart"], p["Handle"], 0);
										wait();
									end;
								end;
							end;
						end;
						if plr["Backpack"]:FindFirstChild("Banana") and (plr["Backpack"]:FindFirstChild("Apple") and plr["Backpack"]:FindFirstChild("Pineapple")) or plr:FindFirstChild("Banana") and (plr:FindFirstChild("Apple") and plr:FindFirstChild("Pineapple")) then
							repeat
								wait();
								_tp(o);
							until _G["AutoKenVTWO"] or plr["Character"]["HumanoidRootPart"]["CFrame"] == o;
							replicated["Remotes"]["CommF_"]:InvokeServer("CitizenQuestProgress", "Citizen");
						end;
						if plr["Backpack"]:FindFirstChild("Fruit Bowl") or plr["Character"]:FindFirstChild("Fruit Bowl") then
							if plr["Character"]["HumanoidRootPart"]["CFrame"] ~= n then
								_tp(n);
							elseif plr["Character"]["HumanoidRootPart"]["CFrame"] == n then
								replicated["Remotes"]["CommF_"]:InvokeServer("KenTalk2", "Start");
								wait(.1);
								replicated["Remotes"]["CommF_"]:InvokeServer("KenTalk2", "Buy");
							end;
						end;
					end;
				end);
			end;
		end;
	end);
	t["Main"]:AddSection("Upgrade Races V3");
	local eW = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Upgrade Mink V3", ["Description"] = "", ["Default"] = false });
	eW:OnChanged(function(o)
		_G["Auto_Mink"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Auto_Mink"] then
					if replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "1") ~= 2 then
						if replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "1") == 0 then
							replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "2");
						elseif replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "1") == 1 then
							if not plr["Backpack"]:FindFirstChild("Flower 1") and not plr["Character"]:FindFirstChild("Flower 1") then
								_tp(workspace["Flower1"]["CFrame"]);
							elseif not plr["Backpack"]:FindFirstChild("Flower 2") and not plr["Character"]:FindFirstChild("Flower 2") then
								_tp(workspace["Flower2"]["CFrame"]);
							elseif not plr["Backpack"]:FindFirstChild("Flower 3") and not plr["Character"]:FindFirstChild("Flower 3") then
								local o = GetConnectionEnemies("Swan Pirate");
								if o then
									repeat
										wait();
										f["Kill"](o, _G["Auto_Mink"]);
									until GetBP("Flower 3") or not o["Parent"] or o["Humanoid"]["Health"] <= 0 or _G["Auto_Mink"] == false;
								else
									_tp(CFrame["new"](980.09851074219, 121.33129882812, 1287.2093505859));
								end;
							end;
						elseif replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "1") == 2 then
							replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "3");
						end;
					elseif replicated["Remotes"]["CommF_"]:InvokeServer("Wenlocktoad", "1") == 0 then
						replicated["Remotes"]["CommF_"]:InvokeServer("Wenlocktoad", "2");
					elseif replicated["Remotes"]["CommF_"]:InvokeServer("Wenlocktoad", "1") == 1 then
						_G["AutoFarmChest"] = true;
					else
						_G["AutoFarmChest"] = false;
					end;
				end;
			end);
		end;
	end);
	local UW = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Upgrade Human V3", ["Description"] = "", ["Default"] = false });
	UW:OnChanged(function(o)
		_G["Auto_Human"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Auto_Human"] then
					if replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "1") ~= -2 then
						if replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "1") == 0 then
							replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "2");
						elseif replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "1") == 1 then
							if not plr["Backpack"]:FindFirstChild("Flower 1") and not plr["Character"]:FindFirstChild("Flower 1") then
								_tp(workspace["Flower1"]["CFrame"]);
							elseif not plr["Backpack"]:FindFirstChild("Flower 2") and not plr["Character"]:FindFirstChild("Flower 2") then
								_tp(workspace["Flower2"]["CFrame"]);
							elseif not plr["Backpack"]:FindFirstChild("Flower 3") and not plr["Character"]:FindFirstChild("Flower 3") then
								local o = GetConnectionEnemies("Swan Pirate");
								if o then
									repeat
										wait();
										f["Kill"](o, _G["Auto_Human"]);
									until plr["Backpack"]:FindFirstChild("Flower 3") or not o["Parent"] or o["Humanoid"]["Health"] <= 0 or _G["Auto_Human"] == false;
								else
									_tp(CFrame["new"](980.09851074219, 121.33129882812, 1287.2093505859));
								end;
							end;
						elseif replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "1") == 2 then
							replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "3");
						end;
					elseif replicated["Remotes"]["CommF_"]:InvokeServer("Wenlocktoad", "1") == 0 then
						replicated["Remotes"]["CommF_"]:InvokeServer("Wenlocktoad", "2");
					elseif replicated["Remotes"]["CommF_"]:InvokeServer("Wenlocktoad", "1") == 1 then
						local o = GetConnectionEnemies(Z[1]);
						if o then
							repeat
								wait();
								f["Kill"](o, _G["Auto_Human"]);
							until o["Humanoid"]["Health"] <= 0 or not o["Parent"] or not _G["Auto_Human"];
						else
							_tp(CFrame["new"](-2172.7399902344, 103.32216644287, -4015.025390625));
						end;
						local p = GetConnectionEnemies(Z[2]);
						if p then
							repeat
								wait();
								f["Kill"](p, _G["Auto_Human"]);
							until p["Humanoid"]["Health"] <= 0 or not p["Parent"] or not _G["Auto_Human"];
						else
							_tp(CFrame["new"](2006.9261474609, 448.95666503906, 853.98284912109));
						end;
						local n = GetConnectionEnemies(Z[3]);
						if n then
							repeat
								wait();
								f["Kill"](n, _G["Auto_Human"]);
							until n["Humanoid"]["Health"] <= 0 or not n["Parent"] or not _G["Auto_Human"];
						else
							_tp(CFrame["new"](-1576.7166748047, 198.59265136719, 13.724286079407));
						end;
					end;
				end;
			end);
		end;
	end);
	local gW = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Upgrade Skypiea V3", ["Description"] = "", ["Default"] = false });
	gW:OnChanged(function(o)
		_G["Auto_Skypiea"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Auto_Skypiea"] then
					if replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "1") ~= -2 then
						if replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "1") == 0 then
							replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "2");
						elseif replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "1") == 1 then
							if not plr["Backpack"]:FindFirstChild("Flower 1") and not plr["Character"]:FindFirstChild("Flower 1") then
								_tp(workspace["Flower1"]["CFrame"]);
							elseif not plr["Backpack"]:FindFirstChild("Flower 2") and not plr["Character"]:FindFirstChild("Flower 2") then
								_tp(workspace["Flower2"]["CFrame"]);
							elseif not plr["Backpack"]:FindFirstChild("Flower 3") and not plr["Character"]:FindFirstChild("Flower 3") then
								local o = GetConnectionEnemies("Swan Pirate");
								if o then
									repeat
										wait();
										f["Kill"](o, _G["Auto_Skypiea"]);
									until plr["Backpack"]:FindFirstChild("Flower 3") or not o["Parent"] or o["Humanoid"]["Health"] <= 0 or _G["Auto_Skypiea"] == false;
								else
									_tp(CFrame["new"](980.09851074219, 121.33129882812, 1287.2093505859));
								end;
							end;
						elseif replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "1") == 2 then
							replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "3");
						end;
					elseif replicated["Remotes"]["CommF_"]:InvokeServer("Wenlocktoad", "1") == 0 then
						replicated["Remotes"]["CommF_"]:InvokeServer("Wenlocktoad", "2");
					elseif replicated["Remotes"]["CommF_"]:InvokeServer("Wenlocktoad", "1") == 1 then
						for o, p in pairs(game["Players"]:GetChildren()) do
							if p["Name"] ~= plr["Name"] and tostring(p["Data"]["Race"]["Value"]) == "Skypiea" then
								repeat
									task["wait"]();
									_tp((p["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 8, 0)) * CFrame["Angles"](math["rad"](-45), 0, 0));
								until p["Humanoid"]["Health"] <= 0 or _G["Auto_Skypiea"] == false;
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	local ZW = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Upgrade FishMan V3", ["Description"] = "", ["Default"] = false });
	ZW:OnChanged(function(o)
		_G["Auto_Fish"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Auto_Fish"] then
					if replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "1") ~= -2 then
						if replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "1") == 0 then
							replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "2");
						elseif replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "1") == 1 then
							if not plr["Backpack"]:FindFirstChild("Flower 1") and not plr["Character"]:FindFirstChild("Flower 1") then
								_tp(workspace["Flower1"]["CFrame"]);
							elseif not plr["Backpack"]:FindFirstChild("Flower 2") and not plr["Character"]:FindFirstChild("Flower 2") then
								_tp(workspace["Flower2"]["CFrame"]);
							elseif not plr["Backpack"]:FindFirstChild("Flower 3") and not plr["Character"]:FindFirstChild("Flower 3") then
								local o = GetConnectionEnemies("Swan Pirate");
								if o then
									repeat
										wait();
										f["Kill"](o, _G["Auto_Fish"]);
									until plr["Backpack"]:FindFirstChild("Flower 3") or not o["Parent"] or o["Humanoid"]["Health"] <= 0 or _G["Auto_Fish"] == false;
								else
									_tp(CFrame["new"](980.09851074219, 121.33129882812, 1287.2093505859));
								end;
							end;
						elseif replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "1") == 2 then
							replicated["Remotes"]["CommF_"]:InvokeServer("Alchemist", "3");
						end;
					elseif replicated["Remotes"]["CommF_"]:InvokeServer("Wenlocktoad", "1") == 0 then
						replicated["Remotes"]["CommF_"]:InvokeServer("Wenlocktoad", "2");
					elseif replicated["Remotes"]["CommF_"]:InvokeServer("Wenlocktoad", "1") == 1 then
						warn("Sea Beast Soon");
					end;
				end;
			end);
		end;
	end);
	t["Main"]:AddSection("Dark Dragger + Valkyrie");
	local lW = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Valkyrie", ["Description"] = "", ["Default"] = false });
	lW:OnChanged(function(o)
		_G["AutoRipIngay"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["AutoRipIngay"] then
					local o = GetConnectionEnemies("rip_indra");
					if not GetWP("Dark Dagger") or not GetIn("Valkyrie") and o then
						repeat
							wait();
							f["Kill"](o, _G["AutoRipIngay"]);
						until not _G["AutoRipIngay"] or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
					else
						replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](-5097.93164, 316.447021, -3142.66602, -0.405007899, -4.31682743e-008, .914313197, -1.90943332e-008, 1, 3.8755779e-008, -0.914313197, -1.76180437e-009, -0.405007899));
						wait(.1);
						_tp(CFrame["new"](-5344.822265625, 423.98541259766, -2725.0930175781));
					end;
				end;
			end);
		end;
	end);
	local WW = t["Main"]:AddToggle("Q", { ["Title"] = "Auto Unlocked Puzzle", ["Description"] = "", ["Default"] = false });
	WW:OnChanged(function(o)
		_G["AutoUnHaki"] = o;
	end);
	AuraSkin = function(o)
			local p = { [1] = { ["StorageName"] = o, ["Type"] = "AuraSkin", ["Context"] = "Equip" } };
			(((replicated:WaitForChild("Modules")):WaitForChild("Net")):WaitForChild("RF/FruitCustomizerRF")):InvokeServer(unpack(p));
		end;
	VaildColor = function(o)
			if o and o["BrickColor"] then
				return tostring(o["BrickColor"]) == "Lime green";
			end;
		end;
	HakiCalculate = function(o)
			local p = { ["Really red"] = "Pure Red", ["Oyster"] = "Snow White", ["Hot pink"] = "Winter Sky" };
			if o and o["BrickColor"] then
				return p[tostring(o["BrickColor"])];
			end;
		end;
	spawn(function()
		while wait(Sec) do
			if _G["AutoUnHaki"] then
				pcall(function()
					local o = workspace["Map"]["Boat Castle"]:FindFirstChild("Summoner");
					if o and o:FindFirstChild("Circle") then
						for o, p in pairs((o:FindFirstChild("Circle")):GetChildren()) do
							if p["Name"] == "Part" then
								local o = p:FindFirstChild("Part");
								if VaildColor(o) == false then
									AuraSkin(HakiCalculate(p));
									repeat
										wait();
										_tp(p["CFrame"]);
									until VaildColor(o) == true or not _G["AutoUnHaki"];
								end;
							end;
						end;
					end;
				end);
			end;
		end;
	end);
	t["Settings"]:AddSection("Settings / Configure");
	local YW = {
			"Melee",
			"Sword",
			"Blox Fruit",
			"Gun",
		};
	local IW = t["Settings"]:AddDropdown("Weapon_Config", {
			["Title"] = "Select Weapon",
			["Values"] = YW,
			["Multi"] = false,
			["Default"] = 1,
		});
	IW:OnChanged(function(o)
		_G["ChooseWP"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["ChooseWP"] == "Melee" then
					for o, p in pairs(plr["Backpack"]:GetChildren()) do
						if p["ToolTip"] == "Melee" then
							if plr["Backpack"]:FindFirstChild(tostring(p["Name"])) then
								_G["SelectWeapon"] = p["Name"];
							end;
						end;
					end;
				elseif _G["ChooseWP"] == "Sword" then
					for o, p in pairs(plr["Backpack"]:GetChildren()) do
						if p["ToolTip"] == "Sword" then
							if plr["Backpack"]:FindFirstChild(tostring(p["Name"])) then
								_G["SelectWeapon"] = p["Name"];
							end;
						end;
					end;
				elseif _G["ChooseWP"] == "Gun" then
					for o, p in pairs(plr["Backpack"]:GetChildren()) do
						if p["ToolTip"] == "Gun" then
							if plr["Backpack"]:FindFirstChild(tostring(p["Name"])) then
								_G["SelectWeapon"] = p["Name"];
							end;
						end;
					end;
				elseif _G["ChooseWP"] == "Blox Fruit" then
					for o, p in pairs(plr["Backpack"]:GetChildren()) do
						if p["ToolTip"] == "Blox Fruit" then
							if plr["Backpack"]:FindFirstChild(tostring(p["Name"])) then
								_G["SelectWeapon"] = p["Name"];
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	local AW = t["Settings"]:AddToggle("Initialize", { ["Title"] = "Initialize Attack [M1/Melee/Sword]", ["Description"] = "[ Not Supported Gas M1 ]", ["Default"] = true });
	AW:OnChanged(function(o)
		_G["Seriality"] = o;
	end);
	local fW = t["Settings"]:AddToggle("Bringmob", { ["Title"] = "Bring Mobs", ["Description"] = "", ["Default"] = true });
	fW:OnChanged(function(D)
		_B = D;
	end);
	local zW = t["Settings"]:AddToggle("BusuAura", { ["Title"] = "Auto Turn on Buso", ["Description"] = "", ["Default"] = true });
	zW:OnChanged(function(D)
		Boud = D;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if Boud then
					local o = { "HasBuso", "Buso" };
					if not plr["Character"]:FindFirstChild(o[1]) then
						replicated["Remotes"]["CommF_"]:InvokeServer(o[2]);
					end;
				end;
			end);
		end;
	end);
	local NW = t["Settings"]:AddToggle("RaceV3Aura", { ["Title"] = "Auto Turn on Race V3", ["Description"] = "", ["Default"] = false });
	NW:OnChanged(function(o)
		_G["RaceClickAutov3"] = o;
	end);
	spawn(function()
		while wait(.2) do
			pcall(function()
				if _G["RaceClickAutov3"] then
					repeat
						replicated["Remotes"]["CommE"]:FireServer("ActivateAbility");
						wait(30);
					until not _G["RaceClickAutov3"];
				end;
			end);
		end;
	end);
	local EW = t["Settings"]:AddToggle("RaceV4Aura", { ["Title"] = "Auto Turn on Race V4", ["Description"] = "", ["Default"] = false });
	EW:OnChanged(function(o)
		_G["RaceClickAutov4"] = o;
	end);
	spawn(function()
		while wait(.2) do
			pcall(function()
				if _G["RaceClickAutov4"] then
					if plr["Character"]:FindFirstChild("RaceEnergy") then
						if (plr["Character"]:FindFirstChild("RaceEnergy"))["Value"] == 1 then
							Useskills("nil", "Y");
						end;
					end;
				end;
			end);
		end;
	end);
	local QW = t["Settings"]:AddToggle("RandomAround", { ["Title"] = "Auto Turn on Spin Position", ["Description"] = "", ["Default"] = false });
	QW:OnChanged(function(D)
		RandomCFrame = D;
	end);
	local sW = t["Settings"]:AddToggle("Byp", { ["Title"] = "Turn on Bypass Teleport", ["Description"] = "", ["Default"] = false });
	sW:OnChanged(function(o)
		_G["Bypass"] = o;
	end);
	local JW = t["Settings"]:AddToggle("SafeModes", { ["Title"] = "Panic Mode", ["Description"] = "turn on for safe ur health if low", ["Default"] = false });
	JW:OnChanged(function(o)
		_G["Safemode"] = o;
	end);
	spawn(function()
		while task["wait"](Sec) do
			pcall(function()
				if _G["Safemode"] then
					local o = (plr["Character"]["Humanoid"]["Health"] / plr["Character"]["Humanoid"]["MaxHealth"]) * 100;
					if o < Num_self then
						shouldTween = true;
						_tp(Root["CFrame"] * CFrame["new"](0, 500, 0));
					else
						shouldTween = false;
					end;
				end;
			end);
		end;
	end);
	local tW = t["Settings"]:AddToggle("UnDetectedAFK", { ["Title"] = "Anti AFK", ["Description"] = "", ["Default"] = true });
	tW:OnChanged(function(o)
		_G["AntiAFK"] = o;
	end);
	plr["Idled"]:connect(function()
		vim2:Button2Down(Vector2["new"](0, 0), workspace["CurrentCamera"]["CFrame"]);
		wait(1);
		vim2:Button2Up(Vector2["new"](0, 0), workspace["CurrentCamera"]["CFrame"]);
	end);
	local BW = t["Settings"]:AddToggle("DisblesVFX", { ["Title"] = "Remove Hit VFX", ["Description"] = "", ["Default"] = false });
	BW:OnChanged(function(o)
		_G["DistroyHit"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["DistroyHit"] then
				pcall(function()
					local o = {
							"SlashHit",
							"CurvedRing",
							"SwordSlash",
							"SlashTail",
						};
					for o, p in pairs(workspace["_WorldOrigin"]:GetChildren()) do
						if table["find"](__Effect, p["Name"]) then
							p:Destroy();
						end;
					end;
				end);
			end;
		end;
	end);
	local KW = t["Settings"]:AddToggle("DisblesVFX", { ["Title"] = "Remove Death & Respawned VFX", ["Description"] = "", ["Default"] = false });
	KW:OnChanged(function(D)
		RDeath = D;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if RDeath then
					if replicated["Effect"]["Container"]:FindFirstChild("Death") then
						replicated["Effect"]["Container"]["Death"]:Destroy();
					end;
					if replicated["Effect"]["Container"]:FindFirstChild("Respawn") then
						replicated["Effect"]["Container"]["Respawn"]:Destroy();
					end;
				end;
			end);
		end;
	end);
	local aW = t["Settings"]:AddToggle("DisblesVFX", { ["Title"] = "Disable Notify", ["Description"] = "", ["Default"] = false });
	aW:OnChanged(function(D)
		RemoveDamage = D;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if RemoveDamage then
					replicated["Assets"]["GUI"]["DamageCounter"]["Enabled"] = false;
					plr["PlayerGui"]["Notifications"]["Enabled"] = false;
				else
					replicated["Assets"]["GUI"]["DamageCounter"]["Enabled"] = true;
					plr["PlayerGui"]["Notifications"]["Enabled"] = true;
				end;
			end);
		end;
	end);
	t["Settings"]:AddSection("Stats Upgrade");
	local hW = t["Settings"]:AddSlider("StatusSelect", {
			["Title"] = "Stats Value",
			["Description"] = "choose your point need to upgrade",
			["Default"] = 10,
			["Min"] = 0,
			["Max"] = 1000,
			["Rounding"] = 1,
			["Callback"] = function(D)
				pSats = D;
			end,
		});
	hW:OnChanged(function(D)
		pSats = D;
	end);
	local iW = t["Settings"]:AddToggle("StatsUpg", { ["Title"] = "Auto Melee", ["Description"] = "", ["Default"] = false });
	iW:OnChanged(function(o)
		_G["Auto_Melee"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Auto_Melee"] then
					statsSetings("Melee", pSats);
				end;
			end);
		end;
	end);
	local XW = t["Settings"]:AddToggle("StatsUpg", { ["Title"] = "Auto Swords", ["Description"] = "", ["Default"] = false });
	XW:OnChanged(function(o)
		_G["Auto_Sword"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Auto_Sword"] then
					statsSetings("Sword", pSats);
				end;
			end);
		end;
	end);
	local dW = t["Settings"]:AddToggle("StatsUpg", { ["Title"] = "Auto Gun", ["Description"] = "", ["Default"] = false });
	dW:OnChanged(function(o)
		_G["Auto_Gun"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Auto_Gun"] then
					statsSetings("Gun", pSats);
				end;
			end);
		end;
	end);
	local HW = t["Settings"]:AddToggle("StatsUpg", { ["Title"] = "Auto Blox Fruit", ["Description"] = "", ["Default"] = false });
	HW:OnChanged(function(o)
		_G["Auto_DevilFruit"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Auto_DevilFruit"] then
					statsSetings("Devil", pSats);
				end;
			end);
		end;
	end);
	local RW = t["Settings"]:AddToggle("StatsUpg", { ["Title"] = "Auto Defense", ["Description"] = "", ["Default"] = false });
	RW:OnChanged(function(o)
		_G["Auto_Defense"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Auto_Defense"] then
					statsSetings("Defense", pSats);
				end;
			end);
		end;
	end);
	t["Melee"]:AddSection("Fighting Melee Styles");
	local PW = t["Melee"]:AddToggle("SuperHuman", { ["Title"] = "Auto Superhuman", ["Description"] = "", ["Default"] = false });
	PW:OnChanged(function(o)
		_G["Auto_SuperHuman"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Auto_SuperHuman"] then
					local o = plr["Data"]["Beli"]["Value"];
					local p = plr["Data"]["Fragments"]["Value"];
					if plr:FindFirstChild("WeaponAssetCache") then
						if not GetBP("Superhuman") then
							if not GetBP("Black Leg") then
								if o >= 150000 then
									replicated["Remotes"]["CommF_"]:InvokeServer("BuyBlackLeg");
								end;
							elseif GetBP("Black Leg") and (GetBP("Black Leg"))["Level"]["Value"] < 299 then
								_G["Level"] = true;
							elseif GetBP("Black Leg") and (GetBP("Black Leg"))["Level"]["Value"] >= 300 then
								_G["Level"] = false;
							end;
							if not GetBP("Electro") then
								if o >= 500000 then
									replicated["Remotes"]["CommF_"]:InvokeServer("BuyElectro");
								end;
							elseif GetBP("Electro") and (GetBP("Electro"))["Level"]["Value"] < 299 then
								_G["Level"] = true;
							elseif GetBP("Electro") and (GetBP("Electro"))["Level"]["Value"] >= 300 then
								_G["Level"] = false;
							end;
							if not GetBP("Fishman Karate") then
								if o >= 750000 then
									replicated["Remotes"]["CommF_"]:InvokeServer("BuyFishmanKarate");
								end;
							elseif GetBP("Fishman Karate") and (GetBP("Fishman Karate"))["Level"]["Value"] < 299 then
								_G["Level"] = true;
							elseif GetBP("Fishman Karate") and (GetBP("Fishman Karate"))["Level"]["Value"] >= 300 then
								_G["Level"] = false;
							end;
							if not GetBP("Dragon Claw") then
								if p >= 1500 then
									replicated["Remotes"]["CommF_"]:InvokeServer("BlackbeardReward", "DragonClaw", "2");
								end;
							elseif GetBP("Dragon Claw") and (GetBP("Dragon Claw"))["Level"]["Value"] < 299 then
								_G["Level"] = true;
							elseif GetBP("Dragon Claw") and (GetBP("Dragon Claw"))["Level"]["Value"] >= 300 then
								_G["Level"] = false;
							end;
							replicated["Remotes"]["CommF_"]:InvokeServer("BuySuperhuman");
						end;
					end;
				end;
			end);
		end;
	end);
	local bW = t["Melee"]:AddToggle("DeathStep", { ["Title"] = "Auto DeathStep", ["Description"] = "", ["Default"] = false });
	bW:OnChanged(function(o)
		_G["AutoDeathStep"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["AutoDeathStep"] then
				pcall(function()
					if plr:FindFirstChild("WeaponAssetCache") then
						if not GetBP("Death Step") then
							if not GetBP("Black Leg") then
								replicated["Remotes"]["CommF_"]:InvokeServer("BuyBlackLeg");
							end;
							if GetBP("Black Leg") and (GetBP("Black Leg"))["Level"]["Value"] >= 400 then
								replicated["Remotes"]["CommF_"]:InvokeServer("BuyDeathStep");
								_G["Level"] = false;
							elseif GetBP("Black Leg") and (GetBP("Black Leg"))["Level"]["Value"] < 399 then
								_G["Level"] = true;
							end;
							if GetBP("Black Leg") or (GetBP("Black Leg"))["Level"]["Value"] >= 400 then
								if workspace["Map"]["IceCastle"]["Hall"]["LibraryDoor"]["PhoeyuDoor"]["Transparency"] == 0 then
									if GetBP("Library Key") then
										repeat
											wait();
											_tp(CFrame["new"](6371.2001953125, 296.63433837891, -6841.1811523438));
										until not _G["AutoDeathStep"] or Root["Position"] == (CFrame["new"](6371.2001953125, 296.63433837891, -6841.1811523438))["Position"];
										if Root["CFrame"] == CFrame["new"](6371.2001953125, 296.63433837891, -6841.1811523438) then
											replicated["Remotes"]["CommF_"]:InvokeServer("BuyDeathStep");
										end;
									elseif not GetBP("Library Key") then
										local o = GetConnectionEnemies("Awakened Ice Admiral");
										if o then
											repeat
												wait();
												f["Kill"](o, _G["AutoDeathStep"]);
											until not o["Parent"] or o["Humanoid"]["Health"] <= 0 or _G["AutoDeathStep"] == false or GetBP("Library Key") or GetBP("Death Step");
										else
											_tp(CFrame["new"](5668.9780273438, 28.519989013672, -6483.3520507813));
										end;
									end;
								end;
							end;
						end;
					end;
				end);
			end;
		end;
	end);
	local OW = t["Melee"]:AddToggle("SharkManV2", { ["Title"] = "Auto Sharkman Karate", ["Description"] = "", ["Default"] = false });
	OW:OnChanged(function(o)
		_G["Auto_SharkMan_Karate"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["Auto_SharkMan_Karate"] then
				pcall(function()
					if plr:FindFirstChild("WeaponAssetCache") then
						if not GetBP("Sharkman Karate") then
							if not GetBP("Fishman Karate") then
								replicated["Remotes"]["CommF_"]:InvokeServer("BuyFishmanKarate");
							end;
							if GetBP("Fishman Karate") and (GetBP("Fishman Karate"))["Level"]["Value"] >= 400 then
								replicated["Remotes"]["CommF_"]:InvokeServer("BuySharkmanKarate");
								_G["Level"] = false;
							elseif GetBP("Fishman Karate") and (GetBP("Fishman Karate"))["Level"]["Value"] < 399 then
								_G["Level"] = true;
							end;
							if GetBP("Fishman Karate") or (GetBP("Fishman Karate"))["Level"]["Value"] >= 400 then
								if GetBP("Water Key") then
									if string["find"](replicated["Remotes"]["CommF_"]:InvokeServer("BuySharkmanKarate"), "keys") then
										if GetBP("Water Key") then
											repeat
												wait();
												_tp(CFrame["new"](-2604.6958, 239.432526, -10315.1982, .0425701365, 0, -0.999093413, 0, 1, 0, .999093413, 0, .0425701365));
											until not _G["Auto_SharkMan_Karate"] or Root["Position"] == (CFrame["new"](-2604.6958, 239.432526, -10315.1982, .0425701365, 0, -0.999093413, 0, 1, 0, .999093413, 0, .0425701365))["Position"];
											replicated["Remotes"]["CommF_"]:InvokeServer("BuySharkmanKarate");
										end;
									end;
								elseif not GetBP("Water Key") then
									local o = GetConnectionEnemies("Tide Keeper");
									if o then
										repeat
											wait();
											f["Kill"](o, _G["Auto_SharkMan_Karate"]);
										until not o["Parent"] or o["Humanoid"]["Health"] <= 0 or _G["Auto_SharkMan_Karate"] == false or GetBP("Water Key") or GetBP("Sharkman Karate");
									else
										_tp(CFrame["new"](-3053.9814453125, 237.18954467773, -10145.0390625));
									end;
								end;
							end;
						end;
					end;
				end);
			end;
		end;
	end);
	local jW = t["Melee"]:AddToggle("ElectricClaw", { ["Title"] = "Auto ElectricClaw", ["Description"] = "", ["Default"] = false });
	jW:OnChanged(function(o)
		_G["Auto_Electric_Claw"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["Auto_Electric_Claw"] then
				pcall(function()
					if plr:FindFirstChild("WeaponAssetCache") then
						if not GetBP("Electro") then
							replicated["Remotes"]["CommF_"]:InvokeServer("BuyElectro");
						end;
						if GetBP("Electro") and (GetBP("Electro"))["Level"]["Value"] >= 400 then
							if replicated["Remotes"]["CommF_"]:InvokeServer("BuyElectricClaw", "Start") == nil then
								notween(CFrame["new"](-12548, 337, -7481));
							end;
							replicated["Remotes"]["CommF_"]:InvokeServer("BuyElectricClaw");
						elseif GetBP("Electro") and (GetBP("Electro"))["Level"]["Value"] < 400 then
							repeat
								_G["AutoFarm_Bone"] = true;
								wait();
							until not _G["Auto_Electric_Claw"] or GetBP("Electric Claw");
							_G["AutoFarm_Bone"] = false;
						end;
					end;
				end);
			end;
		end;
	end);
	local wW = t["Melee"]:AddToggle("DragonTalon", { ["Title"] = "Auto DragonTalon", ["Description"] = "", ["Default"] = false });
	wW:OnChanged(function(o)
		_G["AutoDragonTalon"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["AutoDragonTalon"] then
				pcall(function()
					if plr:FindFirstChild("WeaponAssetCache") then
						if not GetBP("Dragon Claw") then
							replicated["Remotes"]["CommF_"]:InvokeServer("BlackbeardReward", "DragonClaw", "2");
						end;
						if GetBP("Dragon Claw") and (GetBP("Dragon Claw"))["Level"]["Value"] >= 400 then
							replicated["Remotes"]["CommF_"]:InvokeServer("Bones", "Buy", 1, 1);
							replicated["Remotes"]["CommF_"]:InvokeServer("BuyDragonTalon");
						elseif GetBP("Dragon Claw") and (GetBP("Dragon Claw"))["Level"]["Value"] < 400 then
							repeat
								_G["AutoFarm_Bone"] = true;
								wait();
							until not _G["AutoDragonTalon"] or GetBP("Dragon Talon");
							_G["AutoFarm_Bone"] = false;
						end;
					end;
				end);
			end;
		end;
	end);
	local GW = t["Melee"]:AddToggle("Godhuman", { ["Title"] = "Auto Godhuman", ["Description"] = "", ["Default"] = false });
	GW:OnChanged(function(o)
		_G["Auto_God_Human"] = o;
	end);
	spawn(function()
		while wait() do
			pcall(function()
				if _G["AutoGodHuman"] then
					if replicated["Remotes"]["CommF_"]:InvokeServer("BuyGodhuman", true) == "Bring me 20 Fish Tails, 20 Magma Ore, 10 Dragon Scales and 10 Mystic Droplets." then
						if GetM("Dragon Scale") == false or GetM("Dragon Scale") < 10 then
							if World3 then
								Lv = 1575;
								_G["Level"] = true;
							else
								replicated["Remotes"]["CommF_"]:InvokeServer("TravelZou");
							end;
						elseif GetM("Fish Tail") == false or GetM("Fish Tail") < 20 then
							if World3 then
								Lv = 1775;
								_G["Level"] = true;
							else
								replicated["Remotes"]["CommF_"]:InvokeServer("TravelZou");
							end;
						elseif GetM("Mystic Droplet") == false or GetM("Mystic Droplet") < 10 then
							if World2 then
								Lv = 1425;
								_G["Level"] = true;
							else
								replicated["Remotes"]["CommF_"]:InvokeServer("TravelDressrosa");
							end;
						elseif GetM("Magma Ore") == false or GetM("Magma Ore") < 20 then
							if World2 then
								Lv = 1175;
								_G["Level"] = true;
							else
								replicated["Remotes"]["CommF_"]:InvokeServer("TravelDressrosa");
							end;
						end;
					elseif replicated["Remotes"]["CommF_"]:InvokeServer("BuyGodhuman", true) == 3 then
						return nil;
					else
						replicated["Remotes"]["CommF_"]:InvokeServer("BuyGodhuman");
					end;
				end;
			end);
		end;
	end);
	local rW = t["Melee"]:AddToggle("SanguineArt", { ["Title"] = "Auto SanguineArt", ["Description"] = "", ["Default"] = false });
	rW:OnChanged(function(o)
		_G["snaguine"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["snaguine"] then
				pcall(function()
					if not GetBP("Sanguine Art") then
						replicated["Remotes"]["CommF_"]:InvokeServer("Sanguine Art");
					end;
					if not GetBP("Sanguine Art") then
						if GetM("Leviathan Heart") >= 1 then
							print("Completed!!");
						else
							if World3 then
								_G["DangerSc"] = "Lv Infinite";
								_G["SailBoats"] = true;
							else
								_G["SailBoats"] = false;
							end;
						end;
						if GetM("Vampire Fang") <= 19 then
							if World2 then
								local o = GetConnectionEnemies("Vampire");
								if o then
									repeat
										task["wait"]();
										f["Kill"](o, _G["snaguine"]);
									until not _G["snaguine"] or o["Humanoid"]["Health"] <= 0 or not o["Parent"];
								else
									_tp(CFrame["new"](-6041.2924804688, 6.4027109146118, -1304.6333007812));
								end;
							else
								replicated["Remotes"]["CommF_"]:InvokeServer("TravelDressrosa");
							end;
						end;
						if GetM("Vampire Fang") >= 20 and GetM("Demonic Wisp") <= 19 then
							if World3 then
								local o = GetConnectionEnemies("Demonic Soul");
								if o then
									repeat
										task["wait"]();
										f["Kill"](o, _G["snaguine"]);
									until not _G["snaguine"] or o["Humanoid"]["Health"] <= 0 or not o["Parent"];
								else
									_tp(CFrame["new"](-9495.6806640625, 453.58624267578, 5977.3486328125));
								end;
							else
								replicated["Remotes"]["CommF_"]:InvokeServer("TravelZou");
							end;
						end;
						if GetM("Vampire Fang") >= 20 and (GetM("Demonic Wisp") >= 20 and GetM("Dark Fragment") <= 1) then
							if World2 then
								local o = GetConnectionEnemies("Darkbeard");
								if o then
									repeat
										task["wait"]();
										f["Kill"](black, _G["snaguine"]);
									until _G["snaguine"] or black["Humanoid"]["Health"] <= 0 or not black["Parent"];
								else
									_tp(CFrame["new"](3798.4575195313, 13.826690673828, -3399.806640625));
								end;
							else
								replicated["Remotes"]["CommF_"]:InvokeServer("TravelDressrosa");
							end;
						end;
					else
						replicated["Remotes"]["CommF_"]:InvokeServer("BuySanguineArt");
					end;
				end);
			end;
		end;
	end);
	t["Quests"]:AddSection("Tushita + Yama");
	local FW = t["Quests"]:AddParagraph({ ["Title"] = "Elites Process ", ["Content"] = "" });
	spawn(function()
		while wait(Sec) do
			pcall(function()
				FW:SetDesc("Elite Procress :  " .. replicated["Remotes"]["CommF_"]:InvokeServer("EliteHunter", "Progress"));
			end);
		end;
	end);
	local cW = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Elite Quest", ["Description"] = "", ["Default"] = false });
	cW:OnChanged(function(o)
		_G["FarmEliteHunt"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["FarmEliteHunt"] then
					if plr["PlayerGui"]["Main"]["Quest"]["Visible"] == true then
						if string["find"](plr["PlayerGui"]["Main"]["Quest"]["Container"]["QuestTitle"]["Title"]["Text"], "Diablo") or string["find"](plr["PlayerGui"]["Main"]["Quest"]["Container"]["QuestTitle"]["Title"]["Text"], "Urban") or string["find"](plr["PlayerGui"]["Main"]["Quest"]["Container"]["QuestTitle"]["Title"]["Text"], "Deandre") then
							for o, p in pairs(replicated:GetChildren()) do
								if string["find"](p["Name"], "Diablo") or string["find"](p["Name"], "Urban") or string["find"](p["Name"], "Deandre") then
									_tp(p["HumanoidRootPart"]["CFrame"]);
								end;
							end;
							for o, p in pairs(Enemies:GetChildren()) do
								if (string["find"](p["Name"], "Diablo") or string["find"](p["Name"], "Urban") or string["find"](p["Name"], "Deandre")) and f["Alive"](p) then
									repeat
										wait();
										f["Kill"](p, _G["FarmEliteHunt"]);
									until not _G["FarmEliteHunt"] or plr["PlayerGui"]["Main"]["Quest"]["Visible"] == false or not p["Parent"] or p["Humanoid"]["Health"] <= 0;
								end;
							end;
						end;
					else
						replicated["Remotes"]["CommF_"]:InvokeServer("EliteHunter");
					end;
				end;
			end);
		end;
	end);
	local uW = t["Quests"]:AddToggle("Q", { ["Title"] = "Stop when got God's Chalice", ["Description"] = "", ["Default"] = true });
	uW:OnChanged(function(o)
		_G["StopWhenChalice"] = o;
	end);
	spawn(function()
		while wait(.2) do
			if _G["StopWhenChalice"] and _G["FarmEliteHunt"] then
				pcall(function()
					if GetBP("God's Chalice") or GetBP("Sweet Chalice") or GetBP("Fist of Darkness") then
						_G["FarmEliteHunt"] = false;
					end;
				end);
			end;
		end;
	end);
	local kW = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Tushita Sword", ["Description"] = "", ["Default"] = false });
	kW:OnChanged(function(o)
		_G["Auto_Tushita"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Auto_Tushita"] then
					if workspace["Map"]["Turtle"]:FindFirstChild("TushitaGate") then
						if not GetBP("Holy Torch") then
							_tp(CFrame["new"](5148.03613, 162.352493, 910.548218));
							wait(.7);
						else
							EquipWeapon("Holy Torch");
							task["wait"](1);
							repeat
								task["wait"]();
								_tp(CFrame["new"](-10752, 417, -9366));
							until not _G["Auto_Tushita"] or ((CFrame["new"](-10752, 417, -9366))["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 10;
							wait(.7);
							repeat
								task["wait"]();
								_tp(CFrame["new"](-11672, 334, -9474));
							until not _G["Auto_Tushita"] or ((CFrame["new"](-11672, 334, -9474))["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 10;
							wait(.7);
							repeat
								task["wait"]();
								_tp(CFrame["new"](-12132, 521, -10655));
							until not _G["Auto_Tushita"] or ((CFrame["new"](-12132, 521, -10655))["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 10;
							wait(.7);
							repeat
								task["wait"]();
								_tp(CFrame["new"](-13336, 486, -6985));
							until not _G["Auto_Tushita"] or ((CFrame["new"](-13336, 486, -6985))["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 10;
							wait(.7);
							repeat
								task["wait"]();
								_tp(CFrame["new"](-13489, 332, -7925));
							until not _G["Auto_Tushita"] or ((CFrame["new"](-13489, 332, -7925))["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 10;
						end;
					else
						local o = GetConnectionEnemies("Longma");
						if o then
							repeat
								task["wait"]();
								f["Kill"](o, _G["Auto_Tushita"]);
							until o["Humanoid"]["Health"] <= 0 or not _G["Auto_Tushita"] or not o["Parent"];
						else
							if replicated:FindFirstChild("Longma") then
								_tp((replicated:FindFirstChild("Longma"))["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 40, 0));
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	local yW = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Yama Sword", ["Description"] = "", ["Default"] = false });
	yW:OnChanged(function(o)
		_G["Auto_Yama"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Auto_Yama"] then
					if replicated["Remotes"]["CommF_"]:InvokeServer("EliteHunter", "Progress") < 30 then
						_G["FarmEliteHunt"] = true;
					elseif replicated["Remotes"]["CommF_"]:InvokeServer("EliteHunter", "Progress") > 30 then
						_G["FarmEliteHunt"] = false;
						if (workspace["Map"]["Waterfall"]["SealedKatana"]["Handle"]["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] >= 20 then
							_tp(workspace["Map"]["Waterfall"]["SealedKatana"]["Handle"]["CFrame"]);
							local o = GetConnectionEnemies("Ghost");
							if o then
								repeat
									wait();
									f["Kill"](o, _G["Auto_Yama"]);
								until o["Humanoid"]["Health"] <= 0 or not o["Parent"] or not _G["Auto_Yama"];
								fireclickdetector(workspace["Map"]["Waterfall"]["SealedKatana"]["Handle"]["ClickDetector"]);
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	t["Quests"]:AddSection("Cursed Dual Katana");
	local mW = t["Quests"]:AddParagraph({ ["Title"] = " Number Cursed dual katana quests ", ["Content"] = "Quest Numbers :" });
	spawn(function()
		while wait(.2) do
			if QuestYama_1 == true then
				mW:SetDesc(" Quest Numbers : yama quest 1");
			elseif QuestYama_2 == true then
				mW:SetDesc(" Quest Numbers : yama quest 2");
			elseif QuestYama_3 == true then
				mW:SetDesc(" Quest Numbers : yama quest 3");
			elseif QuestTushita_1 == true then
				mW:SetDesc(" Quest Numbers : tushita quest 1");
			elseif QuestTushita_2 == true then
				mW:SetDesc(" Quest Numbers : tushita quest 2");
			elseif QuestTushita_1 == true then
				mW:SetDesc(" Quest Numbers: tushita quest 2");
			elseif GetWP("Cursed Dual Katana") then
				mW:SetDesc(" Quest Numbers: CDK done!!");
			end;
		end;
	end);
	local xW = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Get CDK [ Last Quest ]", ["Description"] = "", ["Default"] = false });
	xW:OnChanged(function(o)
		_G["CDK"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["CDK"] then
					replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress", "Good");
					replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress", "Evil");
					replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "StartTrial", "Boss");
					local o = GetConnectionEnemies("Cursed Skeleton Boss");
					if o then
						repeat
							wait();
							if plr["Character"]:FindFirstChild("Yama") or plr["Backpack"]:FindFirstChild("Yama") then
								EquipWeapon("Yama");
							elseif plr["Character"]:FindFirstChild("Tushita") or plr["Backpack"]:FindFirstChild("Tushita") then
								EquipWeapon("Tushita");
							end;
							_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 20, 0));
						until not _G["CDK"] or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
					else
						_tp(CFrame["new"](-12318.193359375, 601.95184326172, -6538.662109375));
						wait(.5);
						_tp(workspace["Map"]["Turtle"]["Cursed"]["BossDoor"]["CFrame"]);
					end;
				end;
			end);
		end;
	end);
	local vW = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Yama CDK", ["Description"] = "", ["Default"] = false });
	vW:OnChanged(function(o)
		_G["CDK_YM"] = o;
	end);
	spawn(function()
		while wait() do
			pcall(function()
				if _G["CDK_YM"] then
					if tostring(replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "OpenDoor")) ~= "opened" then
						replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "OpenDoor");
						replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "OpenDoor", true);
					else
						if (replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Finished"] == nil then
							replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "StartTrial", "Evil");
							replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "StartTrial", "Evil");
						elseif (replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Finished"] == false then
							if tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Evil"]) == -3 then
								QuestYama_1 = true;
								QuestYama_2 = false;
								QuestYama_3 = false;
								repeat
									task["wait"]();
									if not workspace["Enemies"]:FindFirstChild("Forest Pirate") then
										_tp(CFrame["new"](-13223.521484375, 428.19381713867, -7766.0678710938));
									else
										local o = GetConnectionEnemies("Forest Pirate");
										if o then
											_tp((workspace["Enemies"]:FindFirstChild("Forest Pirate"))["HumanoidRootPart"]["CFrame"]);
										end;
									end;
								until tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Evil"]) == 1 or not _G["CDK_YM"];
							elseif tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Evil"]) == -4 then
								QuestYama_1 = false;
								QuestYama_2 = true;
								QuestYama_3 = false;
								for o, p in pairs((game:GetService("Players"))["LocalPlayer"]["QuestHaze"]:GetChildren()) do
									for o, n in pairs(I) do
										if string["find"](o, p["Name"]) and p["Value"] > 0 then
											if (n["Position"] - Root["Position"])["Magnitude"] <= 1000 and workspace["Enemies"]:FindFirstChild(o) then
												for o, p in pairs(workspace["Enemies"]:GetChildren()) do
													if p:FindFirstChild("HumanoidRootPart") and (p:FindFirstChild("Humanoid") and ((p:FindFirstChild("Humanoid"))["Health"] > 0 and p:FindFirstChild("HazeESP"))) then
														repeat
															wait();
															f["Kill"](p, _G["CDK_YM"]);
														until not _G["CDK_YM"] or tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Evil"]) == 2 or not p:FindFirstChild("HazeESP") or p["Humanoid"]["Health"] <= 0;
													end;
												end;
											else
												_tp(n);
											end;
										end;
									end;
								end;
							elseif tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Evil"]) == -5 then
								QuestYama_1 = false;
								QuestYama_2 = false;
								QuestYama_3 = true;
								if workspace["Map"]:FindFirstChild("HellDimension") then
									if (Root["Position"] - workspace["Map"]["HellDimension"]["Spawn"]["Position"])["Magnitude"] <= 1000 then
										for o, p in pairs(workspace["Map"]["HellDimension"]["Exit"]:GetChildren()) do
											if tonumber(o) == 2 then
												repeat
													task["wait"]();
													Root["CFrame"] = workspace["Map"]["HellDimension"]["Exit"]["CFrame"];
												until not _G["CDK_YM"] or tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Evil"]) == 3;
											end;
										end;
										EquipWeapon(_G["SelectWeapon"]);
										if tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Evil"]) ~= 3 then
											repeat
												task["wait"]();
												repeat
													task["wait"]();
													_tp(workspace["Map"]["HellDimension"]["Torch1"]["Particles"]["CFrame"]);
													for o, p in pairs(workspace["Map"]["HellDimension"]:GetDescendants()) do
														if p:IsA("ProximityPrompt") then
															fireproximityprompt(p);
														end;
													end;
												until (workspace["Map"]["HellDimension"]["Torch1"]["Particles"]["Position"] - Root["Position"])["Magnitude"] < 5;
												wait(2);
												_G["T1Yama"] = true;
											until not _G["CDK_YM"] or _G["T1Yama"] or tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Evil"]) == 3;
											repeat
												task["wait"]();
												repeat
													task["wait"]();
													_tp(workspace["Map"]["HellDimension"]["Torch2"]["Particles"]["CFrame"]);
													for o, p in pairs(workspace["Map"]["HellDimension"]:GetDescendants()) do
														if p:IsA("ProximityPrompt") then
															fireproximityprompt(p);
														end;
													end;
												until (workspace["Map"]["HellDimension"]["Torch2"]["Particles"]["Position"] - Root["Position"])["Magnitude"] < 5;
												wait(2);
												_G["T2Yama"] = true;
											until _G["T2Yama"] or _G["CDK_YM"] == false or tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Evil"]) == 3;
											repeat
												wait();
												repeat
													task["wait"]();
													_tp(workspace["Map"]["HellDimension"]["Torch3"]["Particles"]["CFrame"]);
													for o, p in pairs(workspace["Map"]["HellDimension"]:GetDescendants()) do
														if p:IsA("ProximityPrompt") then
															fireproximityprompt(p);
														end;
													end;
												until (workspace["Map"]["HellDimension"]["Torch3"]["Particles"]["Position"] - Root["Position"])["Magnitude"] < 5;
												wait(2);
												_G["T3Yama"] = true;
											until _G["T3Yama"] or _G["CDK_YM"] == false or tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Evil"]) == 3;
										end;
										for o, p in pairs(workspace["Enemies"]:GetChildren()) do
											if ((p:FindFirstChild("HumanoidRootPart"))["Position"] - workspace["Map"]["HellDimension"]["Spawn"]["Position"])["Magnitude"] <= 300 then
												if p:FindFirstChild("HumanoidRootPart") and (p:FindFirstChild("Humanoid") and (p:FindFirstChild("Humanoid"))["Health"] > 0) then
													repeat
														task["wait"]();
														f["Kill"](p, _G["CDK_YM"]);
													until not _G["CDK_YM"] or p["Humanoid"]["Health"] <= 0 or not p["Parent"] or tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Evil"]) == 3;
												end;
											end;
										end;
									end;
								end;
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	spawn(function()
		while wait() do
			pcall(function()
				if _G["CDK_YM"] then
					if tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Evil"]) == -5 then
						if not workspace["Map"]:FindFirstChild("HellDimension") or (Root["Position"] - workspace["Map"]["HellDimension"]["Spawn"]["Position"])["Magnitude"] > 1000 then
							local o = GetConnectionEnemies("Soul Reaper");
							if o then
								repeat
									task["wait"]();
									_tp(o["HumanoidRootPart"]["CFrame"]);
								until o["Humanoid"]["Health"] <= 0 or not _G["CDK_YM"] or not o["Parent"] or tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Evil"]) == 3 or workspace["Map"]:FindFirstChild("HellDimension") and (Root["Position"] - workspace["Map"]["HellDimension"]["Spawn"]["Position"])["Magnitude"] <= 1000;
							elseif plr["Backpack"]:FindFirstChild("Hallow Essence") or plr["Character"]:FindFirstChild("Hallow Essence") then
								repeat
									_tp(CFrame["new"](-8932.322265625, 146.83154296875, 6062.55078125));
									task["wait"]();
								until ((CFrame["new"](-8932.322265625, 146.83154296875, 6062.55078125))["Position"] - Root["Position"])["Magnitude"] <= 8;
								EquipWeapon("Hallow Essence");
							elseif replicated:FindFirstChild("Soul Reaper") and (replicated:FindFirstChild("Soul Reaper"))["Humanoid"]["Health"] > 0 then
								_tp((replicated:FindFirstChild("Soul Reaper"))["HumanoidRootPart"]["CFrame"]);
							else
								if replicated["Remotes"]["CommF_"]:InvokeServer("Bones", "Check") < 50 and (not workspace["Enemies"]:FindFirstChild("Soul Reaper") and (not replicated:FindFirstChild("Soul Reaper") and not workspace["Map"]:FindFirstChild("HellDimension"))) then
									if workspace["Enemies"]:FindFirstChild("Reborn Skeleton") or workspace["Enemies"]:FindFirstChild("Living Zombie") or workspace["Enemies"]:FindFirstChild("Domenic Soul") or workspace["Enemies"]:FindFirstChild("Posessed Mummy") then
										for o, p in pairs(workspace["Enemies"]:GetChildren()) do
											if p["Name"] == "Reborn Skeleton" or p["Name"] == "Living Zombie" or p["Name"] == "Demonic Soul" or p["Name"] == "Posessed Mummy" then
												if p:FindFirstChild("HumanoidRootPart") and (p:FindFirstChild("Humanoid") and (p:FindFirstChild("Humanoid"))["Health"] > 0) then
													repeat
														task["wait"]();
														f["Kill"](p, _G["CDK_YM"]);
													until not _G["CDK_YM"] or p["Humanoid"]["Health"] <= 0 or not p["Parent"];
												end;
											end;
										end;
									else
										_tp(CFrame["new"](-9515.2255859375, 164.00622558594, 5785.3833007812));
									end;
								else
									replicated["Remotes"]["CommF_"]:InvokeServer("Bones", "Buy", 1, 1);
								end;
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	local CW = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Tushita CDK", ["Description"] = "", ["Default"] = false });
	CW:OnChanged(function(o)
		_G["CDK_TS"] = o;
	end);
	spawn(function()
		while wait() do
			pcall(function()
				if _G["CDK_TS"] then
					if tostring(replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "OpenDoor")) ~= "opened" then
						wait(.7);
						replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "OpenDoor");
						wait(.3);
						replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "OpenDoor", true);
					else
						if (replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Finished"] == nil then
							replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "StartTrial", "Good");
						elseif (replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Finished"] == false then
							if tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Good"]) == -3 then
								QuestTushita_1 = true;
								QuestTushita_2 = false;
								QuestTushita_3 = false;
								repeat
									wait();
									_tp(CFrame["new"](-4602.5107421875, 16.446542739868, -2880.998046875));
								until ((CFrame["new"](-4602.5107421875, 16.446542739868, -2880.998046875))["Position"] - (game:GetService("Players"))["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 3 or not _G["CDK_TS"] or tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Good"]) == 1;
								if ((CFrame["new"](-4602.5107421875, 16.446542739868, -2880.998046875))["Position"] - (game:GetService("Players"))["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 10 then
									wait(.7);
									replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "BoatQuest", workspace["NPCs"]:FindFirstChild("Luxury Boat Dealer"), "Check");
									wait(.5);
									replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "BoatQuest", workspace["NPCs"]:FindFirstChild("Luxury Boat Dealer"));
								end;
								wait(1);
								repeat
									wait();
									_tp(CFrame["new"](4001.1853027344, 10.089399337769, -2654.86328125));
								until ((CFrame["new"](4001.1853027344, 10.089399337769, -2654.86328125))["Position"] - (game:GetService("Players"))["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 3 or not _G["CDK_TS"] or tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Good"]) == 1;
								if ((CFrame["new"](4001.1853027344, 10.089399337769, -2654.86328125))["Position"] - (game:GetService("Players"))["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 10 then
									wait(.7);
									replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "BoatQuest", workspace["NPCs"]:FindFirstChild("Luxury Boat Dealer"), "Check");
									wait(.5);
									replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "BoatQuest", workspace["NPCs"]:FindFirstChild("Luxury Boat Dealer"));
								end;
								wait(1);
								repeat
									wait();
									_tp(CFrame["new"](-9530.763671875, 7.2452087402344, -8375.5087890625));
								until ((CFrame["new"](-9530.763671875, 7.2452087402344, -8375.5087890625))["Position"] - (game:GetService("Players"))["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 3 or not _G["CDK_TS"] or tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Good"]) == 1;
								if ((CFrame["new"](-9530.763671875, 7.2452087402344, -8375.5087890625))["Position"] - (game:GetService("Players"))["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 10 then
									wait(.7);
									replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "BoatQuest", workspace["NPCs"]:FindFirstChild("Luxury Boat Dealer"), "Check");
									wait(.5);
									replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "BoatQuest", workspace["NPCs"]:FindFirstChild("Luxury Boat Dealer"));
								end;
								wait(1);
							elseif tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Good"]) == -4 then
								QuestTushita_1 = false;
								QuestTushita_2 = true;
								QuestTushita_3 = false;
								repeat
									wait();
									_G["AutoRaidCastle"] = true;
								until not _G["CDK_TS"] or tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Good"]) == 2;
								_G["AutoRaidCastle"] = false;
							elseif tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Good"]) == -5 then
								QuestTushita_1 = false;
								QuestTushita_2 = false;
								QuestTushita_3 = true;
								if workspace["Enemies"]:FindFirstChild("Cake Queen") then
									for o, p in pairs(workspace["Enemies"]:GetChildren()) do
										if p["Name"] == "Cake Queen" then
											if p:FindFirstChild("Humanoid") and (p:FindFirstChild("HumanoidRootPart") and p["Humanoid"]["Health"] > 0) then
												repeat
													wait();
													f["Kill"](p, _G["CDK_TS"]);
												until not _G["CDK_TS"] or not p["Parent"] or p["Humanoid"]["Health"] <= 0 or tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Good"]) == 3;
											end;
										end;
									end;
								elseif replicated:FindFirstChild("Cake Queen") and (replicated:FindFirstChild("Cake Queen"))["Humanoid"]["Health"] > 0 then
									_tp((replicated:FindFirstChild("Cake Queen"))["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 30, 0));
								else
									if (game["Players"]["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"] - workspace["Map"]["HeavenlyDimension"]["Spawn"]["Position"])["Magnitude"] <= 1000 then
										for D, M in pairs(workspace["Map"]["HeavenlyDimension"]["Exit"]:GetChildren()) do
											Ex = D;
										end;
										if Ex == 2 then
											repeat
												wait();
												game["Players"]["LocalPlayer"]["Character"]["HumanoidRootPart"]["CFrame"] = workspace["Map"]["HeavenlyDimension"]["Exit"]["CFrame"];
											until not _G["CDK_TS"] or tonumber((replicated["Remotes"]["CommF_"]:InvokeServer("CDKQuest", "Progress"))["Good"]) == 3;
										end;
										repeat
											wait();
											repeat
												wait();
												_tp(CFrame["new"](-22529.6171875, 5275.7739257812, 3873.5712890625));
												for o, p in pairs(workspace["Map"]["HeavenlyDimension"]:GetDescendants()) do
													if p:IsA("ProximityPrompt") then
														fireproximityprompt(p);
													end;
												end;
											until ((CFrame["new"](-22529.6171875, 5275.7739257812, 3873.5712890625))["Position"] - game["Players"]["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] < 5;
											wait(2);
											_G["DoneT1"] = true;
										until not _G["CDK_TS"] or _G["DoneT1"];
										repeat
											wait();
											repeat
												wait();
												_tp(CFrame["new"](-22637.291015625, 5281.365234375, 3749.2885742188));
												for o, p in pairs(workspace["Map"]["HeavenlyDimension"]:GetDescendants()) do
													if p:IsA("ProximityPrompt") then
														fireproximityprompt(p);
													end;
												end;
											until ((CFrame["new"](-22637.291015625, 5281.365234375, 3749.2885742188))["Position"] - game["Players"]["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] < 5;
											wait(2);
											_G["DoneT2"] = true;
										until _G["DoneT2"] or _G["CDK_TS"] == false;
										repeat
											wait();
											repeat
												task["wait"]();
												_tp(CFrame["new"](-22791.14453125, 5277.1655273438, 3764.5700683594));
												for o, p in pairs(workspace["Map"]["HeavenlyDimension"]:GetDescendants()) do
													if p:IsA("ProximityPrompt") then
														fireproximityprompt(p);
													end;
												end;
											until ((CFrame["new"](-22791.14453125, 5277.1655273438, 3764.5700683594))["Position"] - game["Players"]["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] < 5;
											wait(2);
											_G["DoneT3"] = true;
										until _G["DoneT3"] or _G["CDK_TS"] == false;
										for o, p in pairs(workspace["Enemies"]:GetChildren()) do
											if ((p:FindFirstChild("HumanoidRootPart"))["Position"] - (CFrame["new"](-22695.7012, 5270.93652, 3814.42847, .11794927, 3.32185834e-008, .99301964, -8.73070718e-008, 1, -2.30819008e-008, -0.99301964, -8.3975138e-008, .11794927))["Position"])["Magnitude"] <= 300 then
												if p:FindFirstChild("HumanoidRootPart") and (p:FindFirstChild("Humanoid") and (p:FindFirstChild("Humanoid"))["Health"] > 0) then
													repeat
														wait();
														f["Kill"](p, _G["CDK_TS"]);
													until not _G["CDK_TS"] or p["Humanoid"]["Health"] <= 0 or not p["Parent"];
												end;
											end;
										end;
									end;
								end;
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	t["Quests"]:AddSection("True Triple Katana Sword");
	t["Quests"]:AddButton({ ["Title"] = "Buy Legendary Sword", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("LegendarySwordDealer", "1");
			replicated["Remotes"]["CommF_"]:InvokeServer("LegendarySwordDealer", "2");
			replicated["Remotes"]["CommF_"]:InvokeServer("LegendarySwordDealer", "3");
		end });
	t["Quests"]:AddButton({ ["Title"] = "Buy True Triple Katana Sword", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("MysteriousMan", "2");
		end });
	local SW = t["Quests"]:AddToggle("Q", { ["Title"] = "Tween to Legendary Sword Dealer", ["Description"] = "", ["Default"] = false });
	SW:OnChanged(function(o)
		_G["Tp_LgS"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["Tp_LgS"] then
				pcall(function()
					for o, p in pairs(replicated["NPCs"]:GetChildren()) do
						if p["Name"] == "Legendary Sword Dealer " then
							_tp(p["HumanoidRootPart"]["CFrame"]);
						end;
					end;
				end);
			end;
		end;
	end);
	t["Quests"]:AddSection("Pole / God Enal's");
	local VW = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Pole V1", ["Description"] = "", ["Default"] = false });
	VW:OnChanged(function(o)
		_G["AutoPole"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["AutoPole"] then
				pcall(function()
					local o = GetConnectionEnemies("Thunder God");
					if o then
						repeat
							task["wait"]();
							f["Kill"](o, _G["AutoPole"]);
						until not _G["AutoPole"] or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
					else
						_tp(CFrame["new"](-7994.984375, 5761.025390625, -2088.6479492188));
					end;
				end);
			end;
		end;
	end);
	local qW = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Pole V2 [Beta]", ["Description"] = "", ["Default"] = false });
	qW:OnChanged(function(o)
		_G["AutoPoleV2"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["AutoPoleV2"] then
					if not GetBP("Pole (1st Form)") then
						replicated["Remotes"]["CommF_"]:InvokeServer("LoadItem", "Pole (1st Form)");
					end;
					if not GetBP("Pole (2nd Form)") then
						replicated["Remotes"]["CommF_"]:InvokeServer("LoadItem", "Pole (2nd Form)");
					end;
					if GetBP("Pole (1st Form)") and (GetBP("Pole (1st Form)"))["Level"]["Value"] <= 179 then
						_G["Level"] = true;
					elseif GetBP("Pole (1st Form)") and (GetBP("Pole (1st Form)"))["Level"]["Value"] >= 180 then
						_G["Level"] = false;
					end;
					if not GetBP("Rumble Fruit") then
						return;
					end;
					if (GetBP("Rumble Fruit"))["AwakenedMoves"]:FindFirstChild("Z") and ((GetBP("Rumble Fruit"))["AwakenedMoves"]:FindFirstChild("X") and ((GetBP("Rumble Fruit"))["AwakenedMoves"]:FindFirstChild("C") and ((GetBP("Rumble Fruit"))["AwakenedMoves"]:FindFirstChild("V") and (GetBP("Rumble Fruit"))["AwakenedMoves"]:FindFirstChild("F")))) then
						_G["SelectChip"] = nil;
						_G["Raiding"] = false;
						_G["Auto_Awakener"] = false;
						if plr["Data"]["Fragments"]["Value"] >= 5000 then
							replicated["Remotes"]["CommF_"]:InvokeServer("Thunder God", "Talk");
							wait(Sec);
							replicated["Remotes"]["CommF_"]:InvokeServer("Thunder God", "Sure");
						end;
					elseif replicated["Remotes"]["CommF_"]:InvokeServer("Awakener", "Check") == nil or replicated["Remotes"]["CommF_"]:InvokeServer("Awakener", "Check") == 0 then
						_G["SelectChip"] = "Rumble";
						local o = replicated["Remotes"]["CommF_"]:InvokeServer("RaidsNpc", "Select", _G["SelectChip"]);
						if o then
							o:Stop();
						end;
						_G["Raiding"] = true;
						_G["Auto_Awakener"] = true;
					end;
				end;
			end);
		end;
	end);
	t["Quests"]:AddSection("Items Law/Order Sword");
	local LW = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Law Sword", ["Description"] = "", ["Default"] = false });
	LW:OnChanged(function(o)
		_G["AutoLawKak"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["AutoLawKak"] then
				pcall(function()
					local o = GetConnectionEnemies("Order");
					if o then
						repeat
							task["wait"]();
							f["Kill"](o, _G["AutoLawKak"]);
						until _G["AutoLawKak"] == false or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
					else
						_tp(CFrame["new"](-6217.2021484375, 28.047645568848, -5053.1357421875));
					end;
				end);
			end;
		end;
	end);
	t["Quests"]:AddButton({ ["Title"] = "Buy Microchip Law", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BlackbeardReward", "Microchip", "2");
		end });
	t["Quests"]:AddButton({ ["Title"] = "Start Law Raids", ["Description"] = "", ["Callback"] = function()
			fireclickdetector(workspace["Map"]["CircleIsland"]["RaidSummon"]["Button"]["Main"]["ClickDetector"]);
		end });
	t["Quests"]:AddSection("East Blue Misc");
	local DM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Saw Sword", ["Description"] = "", ["Default"] = false });
	DM:OnChanged(function(o)
		_G["AutoSaw"] = o;
	end);
	spawn(function()
		while wait(.2) do
			pcall(function()
				if _G["AutoSaw"] then
					local o = GetConnectionEnemies("The Saw");
					if o then
						repeat
							task["wait"]();
							f["Kill"](o, _G["AutoSaw"]);
						until _G["AutoSaw"] == false or o["Humanoid"]["Health"] <= 0;
					else
						_tp(CFrame["new"](-784.89715576172, 72.427383422852, 1603.5822753906));
					end;
				end;
			end);
		end;
	end);
	local MM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Saber Sword", ["Description"] = "", ["Default"] = false });
	MM:OnChanged(function(o)
		_G["AutoSaber"] = o;
	end);
	spawn(function()
		while wait(.2) do
			pcall(function()
				if _G["AutoSaber"] and (plr["Data"]["Level"]["Value"] >= 200 and (not plr["Backpack"]:FindFirstChild("Saber") and not plr["Character"]:FindFirstChild("Saber"))) then
					if workspace["Map"]["Jungle"]["Final"]["Part"]["Transparency"] == 0 then
						if workspace["Map"]["Jungle"]["QuestPlates"]["Door"]["Transparency"] == 0 then
							if ((CFrame["new"](-1612.55884, 36.9774132, 148.719543, .37091279, 3.0717151e-009, -0.928667724, 3.97099491e-008, 1, 1.91679348e-008, .928667724, -4.39869794e-008, .37091279))["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 100 then
								_tp(plr["Character"]["HumanoidRootPart"]["CFrame"]);
								wait(.5);
								plr["Character"]["HumanoidRootPart"]["CFrame"] = workspace["Map"]["Jungle"]["QuestPlates"]["Plate1"]["Button"]["CFrame"];
								wait(.5);
								plr["Character"]["HumanoidRootPart"]["CFrame"] = workspace["Map"]["Jungle"]["QuestPlates"]["Plate2"]["Button"]["CFrame"];
								wait(.5);
								plr["Character"]["HumanoidRootPart"]["CFrame"] = workspace["Map"]["Jungle"]["QuestPlates"]["Plate3"]["Button"]["CFrame"];
								wait(.5);
								plr["Character"]["HumanoidRootPart"]["CFrame"] = workspace["Map"]["Jungle"]["QuestPlates"]["Plate4"]["Button"]["CFrame"];
								wait(.5);
								plr["Character"]["HumanoidRootPart"]["CFrame"] = workspace["Map"]["Jungle"]["QuestPlates"]["Plate5"]["Button"]["CFrame"];
								wait(.5);
							else
								_tp(CFrame["new"](-1612.55884, 36.9774132, 148.719543, .37091279, 3.0717151e-009, -0.928667724, 3.97099491e-008, 1, 1.91679348e-008, .928667724, -4.39869794e-008, .37091279));
							end;
						else
							if workspace["Map"]["Desert"]["Burn"]["Part"]["Transparency"] == 0 then
								if plr["Backpack"]:FindFirstChild("Torch") or plr["Character"]:FindFirstChild("Torch") then
									EquipWeapon("Torch");
									firetouchinterest(plr["Character"]["Torch"]["Handle"], workspace["Map"]["Desert"]["Burn"]["Fire"], 0);
									firetouchinterest(plr["Character"]["Torch"]["Handle"], workspace["Map"]["Desert"]["Burn"]["Fire"], 1);
									_tp(CFrame["new"](1114.61475, 5.04679728, 4350.22803, -0.648466587, -1.28799094e-009, .761243105, -5.70652914e-010, 1, 1.20584542e-009, -0.761243105, 3.47544882e-010, -0.648466587));
								else
									_tp(CFrame["new"](-1610.00757, 11.5049858, 164.001587, .984807551, -0.167722285, -0.0449818149, .17364943, .951244235, .254912198, 3.42372805e-005, -0.258850515, .965917408));
								end;
							else
								if replicated["Remotes"]["CommF_"]:InvokeServer("ProQuestProgress", "SickMan") ~= 0 then
									replicated["Remotes"]["CommF_"]:InvokeServer("ProQuestProgress", "GetCup");
									wait(.5);
									EquipWeapon("Cup");
									wait(.5);
									replicated["Remotes"]["CommF_"]:InvokeServer("ProQuestProgress", "FillCup", plr["Character"]["Cup"]);
									wait(Sec);
									replicated["Remotes"]["CommF_"]:InvokeServer("ProQuestProgress", "SickMan");
								else
									if replicated["Remotes"]["CommF_"]:InvokeServer("ProQuestProgress", "RichSon") == nil then
										replicated["Remotes"]["CommF_"]:InvokeServer("ProQuestProgress", "RichSon");
									elseif replicated["Remotes"]["CommF_"]:InvokeServer("ProQuestProgress", "RichSon") == 0 then
										if workspace["Enemies"]:FindFirstChild("Mob Leader") or replicated:FindFirstChild("Mob Leader") then
											_tp(CFrame["new"](-2967.59521, -4.91089821, 5328.70703, .342208564, -0.0227849055, .939347804, .0251603816, .999569714, .0150796166, -0.939287126, .0184739735, .342634559));
											for o, p in pairs(workspace["Enemies"]:GetChildren()) do
												if p["Name"] == "Mob Leader" and f["Alive"](p) then
													repeat
														task["wait"]();
														f["Kill"](p, _G["AutoSaber"]);
													until p["Humanoid"]["Health"] <= 0 or _G["AutoSaber"] == false;
												end;
											end;
										end;
									elseif replicated["Remotes"]["CommF_"]:InvokeServer("ProQuestProgress", "RichSon") == 1 then
										replicated["Remotes"]["CommF_"]:InvokeServer("ProQuestProgress", "RichSon");
										EquipWeapon("Relic");
										_tp(CFrame["new"](-1404.91504, 29.9773273, 3.80598116, .876514494, 5.66906877e-009, .481375456, 2.53851997e-008, 1, -5.79995607e-008, -0.481375456, 6.30572643e-008, .876514494));
									end;
								end;
							end;
						end;
					else
						if workspace["Enemies"]:FindFirstChild("Saber Expert") or replicated:FindFirstChild("Saber Expert") then
							for o, p in pairs(workspace["Enemies"]:GetChildren()) do
								if p["Name"] == "Saber Expert" and f["Alive"](p) then
									repeat
										task["wait"]();
										f["Kill"](p, _G["AutoSaber"]);
									until p["Humanoid"]["Health"] <= 0 or _G["AutoSaber"] == false;
									if p["Humanoid"]["Health"] <= 0 then
										replicated["Remotes"]["CommF_"]:InvokeServer("ProQuestProgress", "PlaceRelic");
									end;
								end;
							end;
						else
							_tp(CFrame["new"](-1401.85046, 29.9773273, 8.81916237, .85820812, 8.76083845e-008, .513301849, -8.55007443e-008, 1, -2.77243419e-008, -0.513301849, -2.00944328e-008, .85820812));
						end;
					end;
				end;
			end);
		end;
	end);
	local oM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Cybrog", ["Description"] = "", ["Default"] = false });
	oM:OnChanged(function(o)
		_G["AutoColShad"] = o;
	end);
	spawn(function()
		while wait(.2) do
			if _G["AutoColShad"] then
				pcall(function()
					local o = GetConnectionEnemies("Cyborg");
					if o then
						repeat
							task["wait"]();
							f["Kill"](o, _G["AutoColShad"]);
						until _G["AutoColShad"] == false or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
					else
						_tp(CFrame["new"](6094.0249023438, 73.770050048828, 3825.7348632813));
					end;
				end);
			end;
		end;
	end);
	local pM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Usoap's Hat", ["Description"] = "", ["Default"] = false });
	pM:OnChanged(function(o)
		_G["AutoGetUsoap"] = o;
	end);
	spawn(function()
		while task["wait"](Sec) do
			pcall(function()
				if _G["AutoGetUsoap"] then
					for o, p in pairs(workspace["Characters"]:GetChildren()) do
						if p["Name"] ~= plr["Name"] then
							if p["Humanoid"]["Health"] > 0 and (p:FindFirstChild("HumanoidRootPart") and (p["Parent"] and (Root["Position"] - p["HumanoidRootPart"]["Position"])["Magnitude"] <= 230)) then
								repeat
									task["wait"]();
									EquipWeapon(_G["SelectWeapon"]);
									_tp(p["HumanoidRootPart"]["CFrame"] * CFrame["new"](1, 1, 2));
								until _G["AutoGetUsoap"] == false or p["Humanoid"]["Health"] <= 0 or not p["Parent"] or not p:FindFirstChild("HumanoidRootPart") or not p:FindFirstChild("Humanoid");
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	local nM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Bisento V2", ["Description"] = "", ["Default"] = false });
	nM:OnChanged(function(o)
		_G["Greybeard"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["Greybeard"] then
				pcall(function()
					if not GetWP("Bisento") then
						replicated["Remotes"]["CommF_"]:InvokeServer("BuyItem", "Bisento");
					elseif GetWP("Bisento") then
						replicated["Remotes"]["CommF_"]:InvokeServer("LoadItem", "Bisento");
						local o = GetConnectionEnemies("Greybeard");
						if o then
							repeat
								wait();
								f["Kill"](o, _G["Greybeard"]);
							until _G["Greybeard"] == false or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
						else
							_tp(CFrame["new"](-5023.3833007812, 28.652032852173, 4332.3818359375));
						end;
					end;
				end);
			end;
		end;
	end);
	local eM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Warden Sword", ["Description"] = "", ["Default"] = false });
	eM:OnChanged(function(o)
		_G["WardenBoss"] = o;
	end);
	spawn(function()
		while wait(.1) do
			if _G["WardenBoss"] then
				pcall(function()
					local o = GetConnectionEnemies("Chief Warden");
					if o then
						repeat
							wait();
							f["Kill"](o, _G["WardenBoss"]);
						until _G["WardenBoss"] == false or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
					else
						_tp(CFrame["new"](5206.92578, .997753382, 814.976746, .342041343, -0.00062915677, .939684749, .00191645394, .999998152, -2.80422337e-005, -0.939682961, .00181045406, .342041939));
					end;
				end);
			end;
		end;
	end);
	local UM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Marine Coat", ["Description"] = "", ["Default"] = false });
	UM:OnChanged(function(o)
		_G["MarinesCoat"] = o;
	end);
	spawn(function()
		while wait(.1) do
			if _G["MarinesCoat"] then
				pcall(function()
					local o = GetConnectionEnemies("Vice Admiral");
					if o then
						repeat
							wait();
							f["Kill"](o, _G["MarinesCoat"]);
						until _G["MarinesCoat"] == false or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
					else
						_tp(CFrame["new"](-5006.5454101563, 88.032081604004, 4353.162109375));
					end;
				end);
			end;
		end;
	end);
	local gM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Swan Coat", ["Description"] = "", ["Default"] = false });
	gM:OnChanged(function(o)
		_G["SwanCoat"] = o;
	end);
	spawn(function()
		while wait(.1) do
			if _G["SwanCoat"] then
				pcall(function()
					local o = GetConnectionEnemies("Swan");
					if o then
						repeat
							wait();
							f["Kill"](o, _G["SwanCoat"]);
						until _G["SwanCoat"] == false or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
					else
						_tp(CFrame["new"](5325.09619, 7.03906584, 719.570679, -0.309060812, 0, .951042235, 0, 1, 0, -0.951042235, 0, -0.309060812));
					end;
				end);
			end;
		end;
	end);
	t["Quests"]:AddSection("Rengoku Sword");
	local ZM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Rengoku Sword", ["Description"] = "", ["Default"] = false });
	ZM:OnChanged(function(o)
		_G["IceBossRen"] = o;
	end);
	spawn(function()
		pcall(function()
			while wait(.1) do
				if _G["IceBossRen"] then
					local o = GetConnectionEnemies("Awakened Ice Admiral");
					if o then
						repeat
							task["wait"]();
							f["Kill"](o, _G["IceBossRen"]);
						until _G["IceBossRen"] == false or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
					else
						_tp(CFrame["new"](5668.9780273438, 28.519989013672, -6483.3520507813));
					end;
				end;
			end;
		end);
	end);
	local lM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Key Rengoku", ["Description"] = "", ["Default"] = false });
	lM:OnChanged(function(o)
		_G["KeysRen"] = o;
	end);
	spawn(function()
		while wait(.1) do
			pcall(function()
				if _G["KeysRen"] then
					if plr["Backpack"]:FindFirstChild(p[3]) or plr["Character"]:FindFirstChild(p[3]) then
						EquipWeapon(p[3]);
						wait(.1);
						_tp(CFrame["new"](6571.1201171875, 299.23028564453, -6967.841796875));
					else
						local o = GetConnectionEnemies(p);
						if o then
							repeat
								task["wait"]();
								f["Kill"](o, _G["KeysRen"]);
							until plr["Backpack"]:FindFirstChild(p[3]) or _G["KeysRen"] == false or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
						else
							_tp(CFrame["new"](5439.716796875, 84.420944213867, -6715.1635742188));
						end;
					end;
				end;
			end);
		end;
	end);
	local WM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Dragon Trident", ["Description"] = "", ["Default"] = false });
	WM:OnChanged(function(o)
		_G["AutoTridentW2"] = o;
	end);
	spawn(function()
		while wait(.1) do
			pcall(function()
				if _G["AutoTridentW2"] then
					local o = GetConnectionEnemies("Tide Keeper");
					if o then
						repeat
							task["wait"]();
							f["Kill"](o, _G["AutoTridentW2"]);
						until _G["AutoTridentW2"] == false or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
					else
						_tp(CFrame["new"](-3795.6423339844, 105.88877105713, -11421.307617188));
					end;
				end;
			end);
		end;
	end);
	local YM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Long Sword", ["Description"] = "", ["Default"] = false });
	YM:OnChanged(function(o)
		_G["LongsWord"] = o;
	end);
	spawn(function()
		while wait(.1) do
			pcall(function()
				if _G["LongsWord"] then
					local o = GetConnectionEnemies("Diamond");
					if o then
						repeat
							task["wait"]();
							f["Kill"](o, _G["LongsWord"]);
						until _G["LongsWord"] == false or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
					else
						_tp(CFrame["new"](-1576.7166748047, 198.59265136719, 13.724286079407));
					end;
				end;
			end);
		end;
	end);
	local IM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Black Spikey", ["Description"] = "", ["Default"] = false });
	IM:OnChanged(function(o)
		_G["BlackSpikey"] = o;
	end);
	spawn(function()
		while wait(.1) do
			if _G["BlackSpikey"] then
				pcall(function()
					local o = GetConnectionEnemies("Jeremy");
					if o then
						repeat
							wait();
							f["Kill"](o, _G["BlackSpikey"]);
						until _G["BlackSpikey"] == false or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
					else
						_tp(CFrame["new"](2006.9261474609, 448.95666503906, 853.98284912109));
					end;
				end);
			end;
		end;
	end);
	local AM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Dark Blade V3", ["Description"] = "", ["Default"] = false });
	AM:OnChanged(function(o)
		_G["DarkBladev3"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["DarkBladev3"] and World2 then
					if not GetBP("Dark Blade") then
						replicated["Remotes"]["CommF_"]:InvokeServer("LoadItem", "Dark Blade");
					end;
					if GetBP("Fist of Darkness") > 1 then
						if not workspace["Enemies"]:FindFirstChild("Darkbeard") then
							_tp(CFrame["new"](3677.08203125, 62.751937866211, -3144.8332519531));
						elseif GetConnectionEnemies("Darkbeard") and GetBP("Fist of Darkness") >= 1 then
							repeat
								wait();
								_tp(CFrame["new"](-5719.3637695312, 48.505905151367, -782.97595214844));
							until not _G["DarkBladev3"] or Root["Position"] == (CFrame["new"](-5719.3637695312, 48.505905151367, -782.97595214844))["Position"];
							fireclickdetector(workspace["Map"]["GraveIsland"]["Mountain"]["Rocks"]["Button"]["ClickDetector"]);
						end;
					else
						_G["AutoFarmChest"] = true;
					end;
				end;
			end);
		end;
	end);
	local fM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Midnight Blade", ["Description"] = "", ["Default"] = false });
	fM:OnChanged(function(o)
		_G["AutoEcBoss"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["AutoEcBoss"] then
					if GetM("Ectoplasm") >= 99 then
						replicated["Remotes"]["CommF_"]:InvokeServer("Ectoplasm", "Buy", 3);
					elseif GetM("Ectoplasm") <= 99 then
						local o = GetConnectionEnemies("Cursed Captain");
						if o then
							repeat
								wait();
								f["Kill"](o, _G["AutoEcBoss"]);
							until not _G["AutoEcBoss"] or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
						else
							replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](923.21252441406, 126.9760055542, 32852.83203125));
							wait(.5);
							_tp(CFrame["new"](916.928589, 181.092773, 33422));
						end;
					end;
				end;
			end);
		end;
	end);
	local zM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Darkbeard", ["Description"] = "", ["Default"] = false });
	zM:OnChanged(function(o)
		_G["Auto_Def_DarkCoat"] = o;
	end);
	spawn(function()
		while wait(.1) do
			if _G["Auto_Def_DarkCoat"] then
				pcall(function()
					if GetBP("Fist of Darkness") and not workspace["Enemies"]:FindFirstChild("Darkbeard") then
						_tp(CFrame["new"](3677.08203125, 62.751937866211, -3144.8332519531));
					elseif GetConnectionEnemies("Darkbeard") then
						local o = GetConnectionEnemies("Darkbeard");
						if o then
							repeat
								wait();
								f["Kill"](o, _G["Auto_Def_DarkCoat"]);
							until _G["Auto_Def_DarkCoat"] == false or not o["Parent"] or o["Humanoid"]["Helath"] <= 0;
						end;
					elseif not GetBP("Fist of Darkness") and not GetConnectionEnemies("Darkbeard") then
						repeat
							wait(.1);
							_G["AutoFarmChest"] = true;
						until not _G["Auto_Def_DarkCoat"] or GetBP("Fist of Darkness") or GetConnectionEnemies("Darkbeard");
						_G["AutoFarmChest"] = false;
					end;
				end);
			end;
		end;
	end);
	local NM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Unlocked DonSwan", ["Description"] = "", ["Default"] = false });
	NM:OnChanged(function(o)
		_G["Auto_DonAcces"] = o;
	end);
	spawn(function()
		while wait(.1) do
			if _G["Auto_DonAcces"] then
				pcall(function()
					if (replicated["Remotes"]["CommF_"]:InvokeServer("GetUnlockables"))["FlamingoAccess"] == nil and plr["Data"]["Level"]["Value"] >= 1500 then
						FruitPrice = {};
						FruitStore = {};
						for o, p in next, (replicated:WaitForChild("Remotes"))["CommF_"]:InvokeServer("GetFruits") do
							if p["Price"] >= 1000000 then
								table["insert"](FruitPrice, p["Name"]);
							end;
						end;
						for o, p in pairs(replicated["Remotes"]["CommF_"]:InvokeServer("getInventoryFruits")) do
							for o, p in pairs(p) do
								if o == "Name" then
									table["insert"](FruitStore, p);
								end;
							end;
							replicated["Remotes"]["CommF_"]:InvokeServer("Cousin", "Buy");
							for o, p in pairs(FruitPrice) do
								for o, n in pairs(FruitStore) do
									if p == n and (replicated["Remotes"]["CommF_"]:InvokeServer("GetUnlockables"))["FlamingoAccess"] == nil then
										_G["StoreF"] = false;
										if not plr["Backpack"]:FindFirstChild(FruitStore) then
											replicated["Remotes"]["CommF_"]:InvokeServer("LoadFruit", tostring(p));
										else
											replicated["Remotes"]["CommF_"]:InvokeServer("TalkTrevor", "1");
											replicated["Remotes"]["CommF_"]:InvokeServer("TalkTrevor", "2");
											replicated["Remotes"]["CommF_"]:InvokeServer("TalkTrevor", "3");
										end;
									end;
								end;
							end;
							if (replicated["Remotes"]["CommF_"]:InvokeServer("GetUnlockables"))["FlamingoAccess"] ~= nil then
								_G["StoreF"] = true;
								_G["Auto_DonAcces"] = false;
							end;
						end;
					end;
				end);
			end;
		end;
	end);
	local EM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Swan Glasses", ["Description"] = "", ["Default"] = false });
	EM:OnChanged(function(o)
		_G["Auto_SwanGG"] = o;
	end);
	spawn(function()
		while wait(.2) do
			if _G["Auto_SwanGG"] then
				pcall(function()
					local o = GetConnectionEnemies("Don Swan");
					if o then
						repeat
							wait();
							f["Kill"](o, _G["Auto_SwanGG"]);
						until _G["Auto_SwanGG"] == false or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
					else
						_tp(CFrame["new"](2286.2004394531, 15.177839279175, 863.8388671875));
					end;
				end);
			end;
		end;
	end);
	t["Quests"]:AddSection("Cavender + Twin Hooks + Bigmom");
	local QM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Bigmom", ["Description"] = "", ["Default"] = false });
	QM:OnChanged(function(o)
		_G["AutoBigmom"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["AutoBigmom"] then
				pcall(function()
					local o = GetConnectionEnemies("Cake Queen");
					if o then
						repeat
							task["wait"]();
							f["Kill"](o, _G["AutoBigmom"]);
						until not _G["AutoBigmom"] or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
					else
						_tp(CFrame["new"](-709.31329345703, 381.6005859375, -11011.396484375));
					end;
				end);
			end;
		end;
	end);
	local sM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Canvendish Sword", ["Description"] = "", ["Default"] = false });
	sM:OnChanged(function(o)
		_G["Auto_Cavender"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Auto_Cavender"] then
					local o = GetConnectionEnemies("Beautiful Pirate");
					if o then
						repeat
							wait();
							f["Kill"](o, _G["Auto_Cavender"]);
						until not _G["Auto_Cavender"] or o["Humanoid"]["Health"] <= 0;
					else
						_tp(CFrame["new"](5283.609375, 22.56223487854, -110.78285217285));
					end;
				end;
			end);
		end;
	end);
	local JM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Twin Hooks", ["Description"] = "", ["Default"] = false });
	JM:OnChanged(function(o)
		_G["TwinHook"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["TwinHook"] then
					local o = GetConnectionEnemies("Captain Elephant");
					if o then
						repeat
							wait();
							f["Kill"](o, _G["TwinHook"]);
						until not _G["TwinHook"] or o["Humanoid"]["Health"] <= 0;
					else
						replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](-12471.169921875, 374.94024658203, -7551.677734375));
						wait(.2);
						_tp(CFrame["new"](-13376.7578125, 433.28689575195, -8071.392578125));
					end;
				end;
			end);
		end;
	end);
	local tM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Serpent Bow", ["Description"] = "", ["Default"] = false });
	tM:OnChanged(function(o)
		_G["AutoSerpentBow"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["AutoSerpentBow"] then
				local o = GetConnectionEnemies("Hydra Leader");
				if o then
					repeat
						wait();
						f["Kill"](o, _G["AutoSerpentBow"]);
					until not _G["AutoSerpentBow"] or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
				else
					_tp(CFrame["new"](5821.8979492188, 1019.0950927734, -73.719230651855));
				end;
			end;
		end;
	end);
	local BM = t["Quests"]:AddToggle("Q", { ["Title"] = "Auto Lei Accessory", ["Description"] = "", ["Default"] = false });
	BM:OnChanged(function(o)
		_G["AutoKilo"] = o;
	end);
	spawn(function()
		while wait(.2) do
			if _G["AutoKilo"] then
				pcall(function()
					local o = GetConnectionEnemies("Kilo Admiral");
					if o then
						repeat
							task["wait"]();
							f["Kill"](o, _G["AutoKilo"]);
						until not _G["AutoKilo"] or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
					else
						_tp(CFrame["new"](2764.2233886719, 432.46154785156, -7144.4580078125));
					end;
				end);
			end;
		end;
	end);
	local KM = t["New"]:AddToggle("Toggle", { ["Title"] = "Farm Summon Token", ["Description"] = "", ["Default"] = false });
	KM:OnChanged(function(o)
		_G["SummerToken"] = o;
	end);
	local aM = {
			"The Saw",
			"The Gorilla King",
			"Bobby",
			"Yeti",
			"Mob Leader",
			"Vice Admiral",
			"Warden",
			"Chief Warden",
			"Swan",
			"Magma Admiral",
			"Fishman Lord",
			"Wysper",
			"Thunder God",
			"Cyborg",
			"Saber Expert",
			"Diamond",
			"Jeremy",
			"Fajita",
			"Don Swan",
			"Smoke Admiral",
			"Cursed Captain",
			"Darkbeard",
			"Order",
			"Awakened Ice Admiral",
			"Tide Keeper",
			"Stone",
			"Island Empress",
			"Kilo Admiral",
			"Captain Elephant",
			"Beautiful Pirate",
			"rip_indra True Form",
			"Longma",
			"Soul Reaper",
			"Cake Queen",
		};
	spawn(function()
		while task["wait"]() do
			if _G["SummerToken"] then
				pcall(function()
					for o, p in ipairs(aM) do
						local n = (game:GetService("Workspace"))["Enemies"]:FindFirstChild(p);
						if n and (n:FindFirstChild("Humanoid") and (n:FindFirstChild("HumanoidRootPart") and n["Humanoid"]["Health"] > 0)) then
							repeat
								task["wait"]();
								EquipWeapon(_G["SelectWeapon"]);
								n["HumanoidRootPart"]["CanCollide"] = false;
								n["Humanoid"]["WalkSpeed"] = 0;
								_tp(n["HumanoidRootPart"]["CFrame"] * Pos);
							until not _G["SummerToken"] or not n["Parent"] or n["Humanoid"]["Health"] <= 0;
						else
							local o = (game:GetService("ReplicatedStorage")):FindFirstChild(p);
							if o and o:FindFirstChild("HumanoidRootPart") then
								_tp(o["HumanoidRootPart"]["CFrame"] * CFrame["new"](5, 10, 7));
							end;
						end;
					end;
				end);
			end;
		end;
	end);
	t["Mirage"]:AddSection("Mystic Island / Full Moon");
	FullMOOn = t["Mirage"]:AddParagraph({ ["Title"] = " FullMoon Status ", ["Content"] = "" });
	Ismirage = t["Mirage"]:AddParagraph({ ["Title"] = " Mirage Island Status ", ["Content"] = "" });
	spawn(function()
		while wait(.2) do
			if workspace["Map"]:FindFirstChild("MysticIsland") or workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Mirage Island") then
				Ismirage:SetDesc(" Mirage Island : True");
			else
				Ismirage:SetDesc(" Mirage Island : False");
			end;
		end;
	end);
	spawn(function()
		while wait(.2) do
			pcall(function()
				moon8 = "http://www.roblox.com/asset/?id=9709150401";
				moon7 = "http://www.roblox.com/asset/?id=9709150086";
				moon6 = "http://www.roblox.com/asset/?id=9709149680";
				moon5 = "http://www.roblox.com/asset/?id=9709149431";
				moon4 = "http://www.roblox.com/asset/?id=9709149052";
				moon3 = "http://www.roblox.com/asset/?id=9709143733";
				moon2 = "http://www.roblox.com/asset/?id=9709139597";
				moon1 = "http://www.roblox.com/asset/?id=9709135895";
				moon = Getmoon();
				if moon == moon1 then
					FullMOOn:SetDesc("Moon : 0 / 8");
				elseif moon == moon2 then
					FullMOOn:SetDesc("Moon : 1 / 8");
				elseif moon == moon3 then
					FullMOOn:SetDesc("Moon : 2 / 8");
				elseif moon == moon4 then
					FullMOOn:SetDesc("Moon : 3 / 8 [ Next Night ]");
				elseif moon == moon5 then
					FullMOOn:SetDesc("Moon : 4 / 8 [ Full Moon ]");
				elseif moon == moon6 then
					FullMOOn:SetDesc("Moon : 5 / 8 [ Last Night ]");
				elseif moon == moon7 then
					FullMOOn:SetDesc("Moon : 6 / 8");
				elseif moon == moon8 then
					FullMOOn:SetDesc("Moon : 7 / 8");
				end;
			end);
		end;
	end);
	local hM = t["Mirage"]:AddToggle("Q", { ["Title"] = "Auto Find Mirage Island", ["Description"] = "turn on for finding & tween mirage island", ["Default"] = false });
	hM:OnChanged(function(o)
		_G["FindMirage"] = o;
	end);
	spawn(function()
		while wait() do
			if _G["FindMirage"] then
				pcall(function()
					if not workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Mirage Island", true) then
						local o = CheckBoat();
						if not o then
							local o = CFrame["new"](-16927.451, 9.086, 433.864);
							TeleportToTarget(o);
							if (o["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 10 then
								replicated["Remotes"]["CommF_"]:InvokeServer("BuyBoat", _G["SelectedBoat"]);
							end;
						else
							if plr["Character"]["Humanoid"]["Sit"] == false then
								local p = o["VehicleSeat"]["CFrame"] * CFrame["new"](0, 1, 0);
								_tp(p);
							else
								repeat
									wait();
									local o = CFrame["new"](-10000000, 31, 37016.25);
									if CheckEnemiesBoat() or CheckTerrorShark() or CheckPirateGrandBrigade() then
										_tp(CFrame["new"](-10000000, 150, 37016.25));
									else
										_tp(CFrame["new"](-10000000, 31, 37016.25));
									end;
								until not _G["FindMirage"] or (o["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 10 or workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Mirage Island") or plr["Character"]["Humanoid"]["Sit"] == false;
								plr["Character"]["Humanoid"]["Sit"] = false;
							end;
						end;
					else
						_tp(workspace["Map"]["MysticIsland"]["Center"]["CFrame"] * CFrame["new"](0, 300, 0));
					end;
				end);
			end;
		end;
	end);
	local iM = t["Mirage"]:AddToggle("Q", { ["Title"] = "Auto Tween To Highest Point", ["Description"] = "", ["Default"] = false });
	iM:OnChanged(function(o)
		_G["HighestMirage"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["HighestMirage"] then
				pcall(function()
					if workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Mirage Island", true) then
						_tp(workspace["Map"]["MysticIsland"]["Center"]["CFrame"] * CFrame["new"](0, 400, 0));
					end;
				end);
			end;
		end;
	end);
	local XM = t["Mirage"]:AddToggle("Q", { ["Title"] = "Auto Collect Gear", ["Description"] = "", ["Default"] = false });
	XM:OnChanged(function(o)
		_G["TPGEAR"] = o;
	end);
	spawn(function()
		pcall(function()
			while wait(.1) do
				if _G["TPGEAR"] then
					for o, p in pairs((workspace["Map"]:FindFirstChild("MysticIsland")):GetChildren()) do
						if p["Name"] == "Part" then
							if p["ClassName"] == "MeshPart" then
								_tp(p["CFrame"]);
							end;
						end;
					end;
				end;
			end;
		end);
	end);
	local dM = t["Mirage"]:AddToggle("Q", { ["Title"] = "Change Transparency can see", ["Description"] = "", ["Default"] = false });
	dM:OnChanged(function(o)
		_G["can"] = o;
	end);
	spawn(function()
		pcall(function()
			while wait(Sec) do
				if _G["can"] then
					for o, p in pairs((workspace["Map"]:FindFirstChild("MysticIsland")):GetChildren()) do
						if p["Name"] == "Part" then
							if p["ClassName"] == "MeshPart" then
								p["Transparency"] = 0;
							else
								p["Transparency"] = 1;
							end;
						end;
					end;
				end;
			end;
		end);
	end);
	local HM = t["Mirage"]:AddToggle("Q", { ["Title"] = "Auto Tween Advanced Fruit Dealer", ["Description"] = "", ["Default"] = false });
	HM:OnChanged(function(o)
		_G["Addealer"] = o;
	end);
	spawn(function()
		while wait() do
			if _G["Addealer"] then
				pcall(function()
					for o, p in pairs(replicated["NPCs"]:GetChildren()) do
						if p["Name"] == "Advanced Fruit Dealer" then
							_tp(p["HumanoidRootPart"]["CFrame"]);
						end;
					end;
				end);
			end;
		end;
	end);
	local RM = t["Mirage"]:AddToggle("Q", { ["Title"] = "Auto Collect Mirage Chest", ["Description"] = "", ["Default"] = false });
	RM:OnChanged(function(o)
		_G["FarmChestM"] = o;
	end);
	spawn(function()
		while wait(.2) do
			if _G["FarmChestM"] then
				pcall(function()
					if workspace["Map"]["MysticIsland"]["Chests"]:FindFirstChild("DiamondChest") or workspace["Map"]["MysticIsland"]["Chests"]:FindFirstChild("FragChest") then
						local o = game:GetService("CollectionService");
						local p = game:GetService("Players");
						local n = p["LocalPlayer"];
						local e = n["Character"] or n["CharacterAdded"]:Wait();
						if not e then
							return;
						end;
						local U = (e:GetPivot())["Position"];
						local g = o:GetTagged("_ChestTagged");
						local Z, l = math["huge"], nil;
						for o = 1, #g, 1 do
							local p = g[o];
							local n = ((p:GetPivot())["Position"] - U)["Magnitude"];
							if not SelectedIsland or p:IsDescendantOf(SelectedIsland) then
								if not p:GetAttribute("IsDisabled") and n < Z then
									Z = n;
									l = p;
								end;
							end;
						end;
						if l then
							_tp(l:GetPivot());
						end;
					end;
				end);
			end;
		end;
	end);
	t["Mirage"]:AddSection("Skull Guitars / Misc");
	local PM = t["Mirage"]:AddParagraph({ ["Title"] = " Skull Guitar Quests ", ["Content"] = "" });
	spawn(function()
		while wait(.2) do
			pcall(function()
				if Quest1 == true then
					PM:SetDesc(" Quest Number : Quest1");
				elseif Quest2 == true then
					PM:SetDesc(" Quest Number : Quest2");
				elseif Quest3 == true then
					PM:SetDesc(" Quest Number : Quest3");
				elseif Quest4 == true then
					PM:SetDesc(" Quest Number : Quest4");
				elseif GetWP("Skull Guitar") then
					PM:SetDesc(" Quest Number : Collect!!");
				else
					PM:SetDesc(" Quest Number : No Quest!!");
				end;
			end);
		end;
	end);
	local bM = t["Mirage"]:AddToggle("Q", { ["Title"] = "Auto Skull Guitar", ["Description"] = "", ["Default"] = false });
	bM:OnChanged(function(o)
		_G["Auto_Soul_Guitar"] = o;
	end);
	task["spawn"](function()
		while wait() do
			if _G["Auto_Soul_Guitar"] then
				pcall(function()
					local o = GetConnectionEnemies("Living Zombie");
					if o then
						o["HumanoidRootPart"]["CFrame"] = CFrame["new"](-10138.397460938, 138.65246582031, 5902.8920898438);
						o["Head"]["CanCollide"] = false;
						o["Humanoid"]["Sit"] = false;
						o["HumanoidRootPart"]["CanCollide"] = false;
						o["Humanoid"]["JumpPower"] = 0;
						o["Humanoid"]["WalkSpeed"] = 0;
						if o["Humanoid"]:FindFirstChild("Animator") then
							(o["Humanoid"]:FindFirstChild("Animator")):Destroy();
						end;
					end;
				end);
			end;
		end;
	end);
	function getT(o)
		local p;
		if o == 1 then
			p = workspace["Map"]["Haunted Castle"]["Tablet"]["Segment1"]["Line"]["Rotation"];
		elseif o == 3 then
			p = workspace["Map"]["Haunted Castle"]["Tablet"]["Segment3"]["Line"]["Rotation"];
		elseif o == 4 then
			p = workspace["Map"]["Haunted Castle"]["Tablet"]["Segment4"]["Line"]["Rotation"];
		elseif o == 7 then
			p = workspace["Map"]["Haunted Castle"]["Tablet"]["Segment7"]["Line"]["Rotation"];
		elseif o == 10 then
			p = workspace["Map"]["Haunted Castle"]["Tablet"]["Segment10"]["Line"]["Rotation"];
		end;
		if p then
			return p["Z"];
		end;
	end;
	function getRT(o)
		local p = workspace["Map"]["Haunted Castle"]["Trophies"]["Quest"];
		local n;
		for p, e in pairs(p:GetChildren()) do
			if o == 1 and (e["Name"] == "Trophy1" and e:FindFirstChild("Handle")) then
				n = e["Handle"]["Rotation"];
			elseif o == 2 and (e["Name"] == "Trophy2" and e:FindFirstChild("Handle")) then
				n = e["Handle"]["Rotation"];
			elseif o == 3 and (e["Name"] == "Trophy3" and e:FindFirstChild("Handle")) then
				n = e["Handle"]["Rotation"];
			elseif o == 4 and (e["Name"] == "Trophy4" and e:FindFirstChild("Handle")) then
				n = e["Handle"]["Rotation"];
			elseif o == 5 and (e["Name"] == "Trophy5" and e:FindFirstChild("Handle")) then
				n = e["Handle"]["Rotation"];
			end;
			if n then
				return n["Z"];
			end;
		end;
	end;
	GetFirePlacard = function(o, p)
			if tostring(workspace["Map"]["Haunted Castle"]["Placard" .. o][p]["Indicator"]["BrickColor"]) ~= "Pearl" then
				fireclickdetector(workspace["Map"]["Haunted Castle"]["Placard" .. o][p]["ClickDetector"]);
			end;
		end;
	spawn(function()
		repeat
			task["wait"]();
		until _G["Auto_Soul_Guitar"];
		while wait(Sec) do
			pcall(function()
				if _G["Auto_Soul_Guitar"] then
					if World3 then
						replicated["Remotes"]["CommF_"]:InvokeServer("gravestoneEvent", 2);
						replicated["Remotes"]["CommF_"]:InvokeServer("gravestoneEvent", 2, true);
						if replicated["Remotes"]["CommF_"]:InvokeServer("GuitarPuzzleProgress", "Check") == nil then
							_tp(CFrame["new"](-8655.0166015625, 141.31669616699, 6160.0224609375));
							replicated["Remotes"]["CommF_"]:InvokeServer("gravestoneEvent", 2);
							replicated["Remotes"]["CommF_"]:InvokeServer("gravestoneEvent", 2, true);
						elseif (replicated["Remotes"]["CommF_"]:InvokeServer("GuitarPuzzleProgress", "Check"))["Swamp"] == false then
							Quest1 = true;
							Quest2 = false;
							Quest3 = false;
							Quest4 = false;
							local o = GetConnectionEnemies("Living Zombie");
							if o then
								repeat
									task["wait"]();
									f["Kill"](o, _G["Auto_Soul_Guitar"]);
								until not _G["Auto_Soul_Guitar"] or o["Humanoid"]["Health"] <= 0 or not o["Parent"] or workspace["Map"]["Haunted Castle"]["SwampWater"]["Color"] ~= Color3["fromRGB"](117, 0, 0);
							else
								_tp(CFrame["new"](-10170.727539062, 138.65246582031, 5934.2651367188));
							end;
						elseif (replicated["Remotes"]["CommF_"]:InvokeServer("GuitarPuzzleProgress", "Check"))["Gravestones"] == false then
							Quest1 = false;
							Quest2 = true;
							Quest3 = false;
							Quest4 = false;
							GetFirePlacard("7", "Left");
							GetFirePlacard("6", "Left");
							GetFirePlacard("5", "Left");
							GetFirePlacard("4", "Right");
							GetFirePlacard("3", "Left");
							GetFirePlacard("2", "Right");
							GetFirePlacard("1", "Right");
						elseif (replicated["Remotes"]["CommF_"]:InvokeServer("GuitarPuzzleProgress", "Check"))["Ghost"] == false then
							replicated["Remotes"]["CommF_"]:InvokeServer("GuitarPuzzleProgress", "Ghost");
							replicated["Remotes"]["CommF_"]:InvokeServer("GuitarPuzzleProgress", "Ghost", true);
						elseif (replicated["Remotes"]["CommF_"]:InvokeServer("GuitarPuzzleProgress", "Check"))["Trophies"] == false then
							Quest1 = false;
							Quest2 = false;
							Quest3 = true;
							Quest4 = false;
							_tp(CFrame["new"](-9532.8232421875, 6.471667766571, 6078.068359375));
							repeat
								wait();
								local o = getRT(1);
								local p = getT(1);
								if o and p then
									fireclickdetector(workspace["Map"]["Haunted Castle"]["Tablet"]["Segment1"]:FindFirstChild("ClickDetector"));
								end;
							until o == p;
							repeat
								wait();
								local o = getRT(2);
								local p = getT(3);
								if o and p then
									fireclickdetector(workspace["Map"]["Haunted Castle"]["Tablet"]["Segment3"]:FindFirstChild("ClickDetector"));
								end;
							until o == p;
							repeat
								wait();
								local o = getRT(3);
								local p = getT(4);
								if o and p then
									fireclickdetector(workspace["Map"]["Haunted Castle"]["Tablet"]["Segment4"]:FindFirstChild("ClickDetector"));
								end;
							until o == p;
							repeat
								wait();
								local o = getRT(4);
								local p = getT(7);
								if o and p then
									fireclickdetector(workspace["Map"]["Haunted Castle"]["Tablet"]["Segment7"]:FindFirstChild("ClickDetector"));
								end;
							until o == p;
							repeat
								wait();
								local o = getRT(5);
								local p = getT(10);
								if o and p then
									fireclickdetector(workspace["Map"]["Haunted Castle"]["Tablet"]["Segment10"]:FindFirstChild("ClickDetector"));
								end;
							until o == p;
							repeat
								wait();
								fireclickdetector(workspace["Map"]["Haunted Castle"]["Tablet"]["Segment2"]:FindFirstChild("ClickDetector"));
								fireclickdetector(workspace["Map"]["Haunted Castle"]["Tablet"]["Segment5"]:FindFirstChild("ClickDetector"));
								fireclickdetector(workspace["Map"]["Haunted Castle"]["Tablet"]["Segment6"]:FindFirstChild("ClickDetector"));
								fireclickdetector(workspace["Map"]["Haunted Castle"]["Tablet"]["Segment8"]:FindFirstChild("ClickDetector"));
								fireclickdetector(workspace["Map"]["Haunted Castle"]["Tablet"]["Segment9"]:FindFirstChild("ClickDetector"));
							until workspace["Map"]["Haunted Castle"]["Tablet"]["Segment2"]["Line"]["Rotation"]["Z"] == 0 or workspace["Map"]["Haunted Castle"]["Tablet"]["Segment5"]["Line"]["Rotation"]["Z"] == 0 or workspace["Map"]["Haunted Castle"]["Tablet"]["Segment6"]["Line"]["Rotation"]["Z"] == 0 or workspace["Map"]["Haunted Castle"]["Tablet"]["Segment8"]["Line"]["Rotation"]["Z"] == 0 or workspace["Map"]["Haunted Castle"]["Tablet"]["Segment9"]["Line"]["Rotation"]["Z"] == 0;
						elseif (replicated["Remotes"]["CommF_"]:InvokeServer("GuitarPuzzleProgress", "Check"))["Pipes"] == false then
							Quest1 = false;
							Quest2 = false;
							Quest3 = false;
							Quest4 = true;
							_tp(workspace["Map"]["Haunted Castle"]["Lab Puzzle"]["ColorFloor"]["Model"]["Part3"]["CFrame"]);
							fireclickdetector(workspace["Map"]["Haunted Castle"]["Lab Puzzle"]["ColorFloor"]["Model"]["Part3"]["ClickDetector"]);
							_tp(workspace["Map"]["Haunted Castle"]["Lab Puzzle"]["ColorFloor"]["Model"]["Part4"]["CFrame"]);
							fireclickdetector(workspace["Map"]["Haunted Castle"]["Lab Puzzle"]["ColorFloor"]["Model"]["Part4"]["ClickDetector"]);
							fireclickdetector(workspace["Map"]["Haunted Castle"]["Lab Puzzle"]["ColorFloor"]["Model"]["Part4"]["ClickDetector"]);
							fireclickdetector(workspace["Map"]["Haunted Castle"]["Lab Puzzle"]["ColorFloor"]["Model"]["Part4"]["ClickDetector"]);
							_tp(workspace["Map"]["Haunted Castle"]["Lab Puzzle"]["ColorFloor"]["Model"]["Part6"]["CFrame"]);
							fireclickdetector(workspace["Map"]["Haunted Castle"]["Lab Puzzle"]["ColorFloor"]["Model"]["Part6"]["ClickDetector"]);
							fireclickdetector(workspace["Map"]["Haunted Castle"]["Lab Puzzle"]["ColorFloor"]["Model"]["Part6"]["ClickDetector"]);
							_tp(workspace["Map"]["Haunted Castle"]["Lab Puzzle"]["ColorFloor"]["Model"]["Part8"]["CFrame"]);
							fireclickdetector(workspace["Map"]["Haunted Castle"]["Lab Puzzle"]["ColorFloor"]["Model"]["Part8"]["ClickDetector"]);
							_tp(workspace["Map"]["Haunted Castle"]["Lab Puzzle"]["ColorFloor"]["Model"]["Part10"]["CFrame"]);
							fireclickdetector(workspace["Map"]["Haunted Castle"]["Lab Puzzle"]["ColorFloor"]["Model"]["Part10"]["ClickDetector"]);
							fireclickdetector(workspace["Map"]["Haunted Castle"]["Lab Puzzle"]["ColorFloor"]["Model"]["Part10"]["ClickDetector"]);
							fireclickdetector(workspace["Map"]["Haunted Castle"]["Lab Puzzle"]["ColorFloor"]["Model"]["Part10"]["ClickDetector"]);
						end;
					end;
				end;
			end);
		end;
	end);
	local OM = t["Mirage"]:AddToggle("Q", { ["Title"] = "Auto Farm Material Skull Guitar", ["Description"] = "", ["Default"] = false });
	OM:OnChanged(function(o)
		_G["AutoMatSoul"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["AutoMatSoul"] and GetWP("Skull Guitar") == false then
					if GetM("Bones") >= 500 and (GetM("Ectoplasm") >= 250 and GetM("Dark Fragment") >= 1) then
						replicated["Remotes"]["CommF_"]:InvokeServer("soulGuitarBuy", true);
					else
						if GetM("Ectoplasm") <= 250 then
							if _G["AutoMatSoul"] and World2 then
								local o = {
										"Ship Deckhand",
										"Ship Engineer",
										"Ship Steward",
										"Ship Officer",
										"Arctic Warrior",
									};
								local p = GetConnectionEnemies(o);
								if p then
									repeat
										task["wait"]();
										f["Kill"](p, _G["AutoMatSoul"]);
									until not _G["AutoMatSoul"] or not p["Parent"] or p["Humanoid"]["Health"] <= 0;
								else
									replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](923.21252441406, 126.9760055542, 32852.83203125));
								end;
							else
								replicated["Remotes"]["CommF_"]:InvokeServer("TravelDressrosa");
							end;
						elseif GetM("Dark Fragment") < 1 then
							if _G["AutoMatSoul"] and World2 then
								local o = GetConnectionEnemies("Darkbeard");
								if o then
									repeat
										task["wait"]();
										f["Kill"](o, _G["AutoMatSoul"]);
									until _G["AutoMatSoul"] or o["Humanoid"]["Health"] <= 0;
								else
									_tp(CFrame["new"](3798.4575195313, 13.826690673828, -3399.806640625));
								end;
							else
								replicated["Remotes"]["CommF_"]:InvokeServer("TravelDressrosa");
							end;
							if not GetConnectionEnemies("Darkbeard") then
								Hop();
							end;
						elseif GetM("Bones") <= 500 then
							if _G["AutoMatSoul"] and World3 then
								local o = {
										"Reborn Skeleton",
										"Living Zombie",
										"Demonic Soul",
										"Posessed Mummy",
									};
								local p = GetConnectionEnemies(o);
								if p then
									repeat
										task["wait"]();
										f["Kill"](p, _G["AutoMatSoul"]);
									until not _G["AutoMatSoul"] or p["Humanoid"]["Health"] <= 0 or not p["Parent"] or p["Humanoid"]["Health"] <= 0;
								else
									_tp(CFrame["new"](-9504.8564453125, 172.14292907715, 6057.259765625));
								end;
							else
								replicated["Remotes"]["CommF_"]:InvokeServer("TravelZou");
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	t["Mirage"]:AddButton({ ["Title"] = "Talk With Stone", ["Description"] = "", ["Callback"] = function()
			((replicated:WaitForChild("Remotes")):WaitForChild("CommF_")):InvokeServer("RaceV4Progress", "Begin");
			((replicated:WaitForChild("Remotes")):WaitForChild("CommF_")):InvokeServer("RaceV4Progress", "Check");
			((replicated:WaitForChild("Remotes")):WaitForChild("CommF_")):InvokeServer("RaceV4Progress", "Teleport");
			((replicated:WaitForChild("Remotes")):WaitForChild("CommF_")):InvokeServer("RaceV4Progress", "Continue");
		end });
	local jM = t["Mirage"]:AddToggle("Q", { ["Title"] = "Auto Look At Moon", ["Description"] = "", ["Default"] = false });
	jM:OnChanged(function(D)
		LookM = D;
	end);
	function MoveCamtoMoon()
		workspace["CurrentCamera"]["CFrame"] = CFrame["new"](workspace["CurrentCamera"]["CFrame"]["Position"], Lighting:GetMoonDirection() + workspace["CurrentCamera"]["CFrame"]["Position"]);
		plr["Character"]["HumanoidRootPart"]["CFrame"] = CFrame["new"](plr["Character"]["HumanoidRootPart"]["Position"], Lighting:GetMoonDirection() + plr["Character"]["HumanoidRootPart"]["CFrame"]["Position"]);
	end;
	task["spawn"](function()
		while task["wait"]() do
			if LookM then
				MoveCamtoMoon();
				wait(.1);
				replicated["Remotes"]["CommE"]:FireServer("ActivateAbility");
			end;
		end;
	end);
	t["Mirage"]:AddSection("Trials Quests / Misc V4");
	local wM = t["Mirage"]:AddParagraph({ ["Title"] = " Tiers V4 Status ", ["Content"] = "" });
	spawn(function()
		pcall(function()
			while wait(.2) do
				wM:SetDesc(" Tiers - V4  :" .. (" " .. plr["Data"]["Race"]["C"]["Value"]));
			end;
		end);
	end);
	local GM = t["Mirage"]:AddToggle("Q", { ["Title"] = "Auto Pull Lever", ["Description"] = "", ["Default"] = false });
	GM:OnChanged(function(o)
		_G["Lver"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["Lver"] then
				pcall(function()
					for o, p in pairs(workspace["Map"]["Temple of Time"]:GetDescendants()) do
						if p["Name"] == "ProximityPrompt" then
							fireproximityprompt(p, math["huge"]);
						end;
					end;
				end);
			end;
		end;
	end);
	local TM = t["Mirage"]:AddToggle("Q", { ["Title"] = "Auto Train V4", ["Description"] = "turn on for farm tier + auto upgrade your tier level", ["Default"] = false });
	TM:OnChanged(function(o)
		_G["AcientOne"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["AcientOne"] then
					local o = {
							"Reborn Skeleton",
							"Living Zombie",
							"Demonic Soul",
							"Posessed Mummy",
						};
					for p = 1, #o, 1 do
						if (plr["Character"]:FindFirstChild("RaceEnergy"))["Value"] == 1 then
							vim1:SendKeyEvent(true, "Y", false, game);
							replicated["Remotes"]["CommF_"]:InvokeServer("UpgradeRace", "Buy");
							_tp(CFrame["new"](-8987.041015625, 215.86206054688, 5886.7104492188));
						elseif (plr["Character"]:FindFirstChild("RaceTransformed"))["Value"] == false then
							local p = GetConnectionEnemies(o);
							if p then
								repeat
									wait();
									f["Kill"](p, _G["AcientOne"]);
								until _G["AcientOne"] == false or p["Humanoid"]["Health"] <= 0 or not p["Parent"];
							else
								_tp(CFrame["new"](-9495.6806640625, 453.58624267578, 5977.3486328125));
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	t["Mirage"]:AddButton({ ["Title"] = "Teleport to Temple of Time", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](28286.35546875, 14895.301757812, 102.62469482422));
		end });
	t["Mirage"]:AddButton({ ["Title"] = "Teleport to Ancient One", ["Description"] = "", ["Callback"] = function()
			notween(CFrame["new"](28981.552734375, 14888.426757812, -120.24584960938));
		end });
	t["Mirage"]:AddButton({ ["Title"] = "Teleport to Ancient Clock", ["Description"] = "", ["Callback"] = function()
			notween(CFrame["new"](29549, 15069, -88));
		end });
	local rM = t["Mirage"]:AddToggle("Q", { ["Title"] = "Auto Teleport to Race Doors", ["Description"] = "", ["Default"] = false });
	rM:OnChanged(function(o)
		_G["TPDoor"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["TPDoor"] then
					if tostring(plr["Data"]["Race"]["Value"]) == "Mink" then
						_tp(CFrame["new"](29020.66015625, 14889.426757812, -379.2682800293));
					elseif tostring(plr["Data"]["Race"]["Value"]) == "Fishman" then
						_tp(CFrame["new"](28224.056640625, 14889.426757812, -210.58720397949));
					elseif tostring(plr["Data"]["Race"]["Value"]) == "Cyborg" then
						_tp(CFrame["new"](28492.4140625, 14894.426757812, -422.11001586914));
					elseif tostring(plr["Data"]["Race"]["Value"]) == "Skypiea" then
						_tp(CFrame["new"](28967.408203125, 14918.075195312, 234.31198120117));
					elseif tostring(plr["Data"]["Race"]["Value"]) == "Ghoul" then
						_tp(CFrame["new"](28672.720703125, 14889.127929688, 454.59616088867));
					elseif tostring(plr["Data"]["Race"]["Value"]) == "Human" then
						_tp(CFrame["new"](29237.294921875, 14889.426757812, -206.94955444336));
					end;
				end;
			end);
		end;
	end);
	local FM = t["Mirage"]:AddToggle("Q", { ["Title"] = "Auto Complete Trial Race", ["Description"] = "", ["Default"] = false });
	FM:OnChanged(function(o)
		_G["Complete_Trials"] = o;
	end);
	GetSeaBeastTrial = function()
			if not workspace["Map"]:FindFirstChild("FishmanTrial") then
				return nil;
			end;
			if workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Trial of Water") then
				FishmanTrial = workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Trial of Water");
			end;
			if FishmanTrial then
				for o, p in next, workspace["SeaBeasts"]:GetChildren() do
					if p:FindFirstChild("HumanoidRootPart") and (p["HumanoidRootPart"]["Position"] - FishmanTrial["Position"])["Magnitude"] <= 1500 then
						if p["Health"]["Value"] > 0 then
							return p;
						end;
					end;
				end;
			end;
		end;
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Complete_Trials"] then
					if tostring(plr["Data"]["Race"]["Value"]) == "Mink" then
						notween(workspace["Map"]["MinkTrial"]["Ceiling"]["CFrame"] * CFrame["new"](0, -20, 0));
					end;
				end;
			end);
		end;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Complete_Trials"] then
					if tostring(plr["Data"]["Race"]["Value"]) == "Fishman" then
						if GetSeaBeastTrial() then
							repeat
								task["wait"]();
								spawn(function()
									_tp(CFrame["new"]((GetSeaBeastTrial())["HumanoidRootPart"]["Position"]["X"], (game:GetService("Workspace"))["Map"]["WaterBase-Plane"]["Position"]["Y"] + 300, (GetSeaBeastTrial())["HumanoidRootPart"]["Position"]["Z"]));
								end);
								MousePos = (GetSeaBeastTrial())["HumanoidRootPart"]["Position"];
								Useskills("Melee", "Z");
								Useskills("Melee", "X");
								Useskills("Melee", "C");
								wait(.1);
								Useskills("Sword", "Z");
								Useskills("Sword", "X");
								wait(.1);
								Useskills("Blox Fruit", "Z");
								Useskills("Blox Fruit", "X");
								Useskills("Blox Fruit", "C");
								wait(.1);
								Useskills("Gun", "Z");
								Useskills("Gun", "X");
							until _G["Complete_Trials"] == false or not GetSeaBeastTrial();
						end;
					end;
				end;
			end);
		end;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Complete_Trials"] then
					if tostring(plr["Data"]["Race"]["Value"]) == "Cyborg" then
						_tp(workspace["Map"]["CyborgTrial"]["Floor"]["CFrame"] * CFrame["new"](0, 500, 0));
					end;
				end;
			end);
		end;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Complete_Trials"] then
					if tostring(plr["Data"]["Race"]["Value"]) == "Skypiea" then
						notween(workspace["Map"]["SkyTrial"]["Model"]["FinishPart"]["CFrame"]);
					end;
				end;
			end);
		end;
	end);
	spawn(function()
		while wait(.1) do
			pcall(function()
				if _G["Complete_Trials"] then
					if tostring(plr["Data"]["Race"]["Value"]) == "Human" or tostring(plr["Data"]["Race"]["Value"]) == "Ghoul" then
						local o = { "Ancient Vampire", "Ancient Zombie" };
						local p = GetConnectionEnemies(o);
						if p then
							repeat
								wait();
								f["Kill"](p, _G["Complete_Trials"]);
							until _G["Complete_Trials"] == false or not p["Parent"] or p["Humanoid"]["Health"] <= 0;
						end;
					end;
				end;
			end);
		end;
	end);
	local cM = t["Mirage"]:AddToggle("Q", { ["Title"] = "Auto Kill Player After Trial", ["Description"] = "turn on for kill player after the race trials", ["Default"] = false });
	cM:OnChanged(function(o)
		_G["Defeating"] = o;
	end);
	spawn(function()
		while task["wait"](Sec) do
			pcall(function()
				if _G["Defeating"] then
					for o, p in pairs(workspace["Characters"]:GetChildren()) do
						if p["Name"] ~= plr["Name"] then
							if p["Humanoid"]["Health"] > 0 and (p:FindFirstChild("HumanoidRootPart") and (p["Parent"] and (Root["Position"] - p["HumanoidRootPart"]["Position"])["Magnitude"] <= 250)) then
								repeat
									task["wait"]();
									EquipWeapon(_G["SelectWeapon"]);
									_tp(p["HumanoidRootPart"]["CFrame"] * CFrame["new"](0, 0, 15));
									sethiddenproperty(plr, "SimulationRadius", math["huge"]);
								until _G["Defeating"] == false or p["Humanoid"]["Health"] <= 0 or not p["Parent"] or not p:FindFirstChild("HumanoidRootPart") or not p:FindFirstChild("Humanoid");
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	t["Drago"]:AddSection("Dojo Quest & Drago Race");
	local uM = t["Drago"]:AddToggle("DojoQ", { ["Title"] = "Auto Dojo Trainer", ["Description"] = "turn on for do dojo belt quest white to black", ["Default"] = false });
	uM:OnChanged(function(o)
		_G["Dojoo"] = o;
	end);
	function printBeltName(o)
		if type(o) == "table" and o["Quest"]["BeltName"] then
			return o["Quest"]["BeltName"];
		end;
	end;
	spawn(function()
		while wait(Sec) do
			if _G["Dojoo"] then
				pcall(function()
					local o = { [1] = { ["NPC"] = "Dojo Trainer", ["Command"] = "RequestQuest" } };
					local p = (replicated["Modules"]["Net"]:FindFirstChild("RF/InteractDragonQuest")):InvokeServer(unpack(o));
					local n = printBeltName(p);
					if debug == false and (not p and not n) then
						_tp(CFrame["new"](5865.0234375, 1208.3154296875, 871.15185546875));
						debug = true;
					elseif debug == true and ((CFrame["new"](5865.0234375, 1208.3154296875, 871.15185546875))["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 50 then
						if n == "White" then
							local o = GetConnectionEnemies("Skull Slayer");
							if o then
								repeat
									task["wait"]();
									f["Kill"](o, _G["Dojoo"]);
								until not p or not _G["Dojoo"] or not f["Alive"](o);
							else
								_tp(CFrame["new"](-16759.58984375, 71.283767700195, 1595.3399658203));
							end;
						elseif n == "Yellow" then
							repeat
								task["wait"]();
								_G["SeaBeast1"] = true;
								_G["TerrorShark"] = true;
								_G["Shark"] = true;
								_G["Piranha"] = true;
								_G["MobCrew"] = true;
								_G["FishBoat"] = true;
								_G["SailBoats"] = true;
							until not _G["Dojoo"] or not p;
							_G["SeaBeast1"] = false;
							_G["TerrorShark"] = false;
							_G["Shark"] = false;
							_G["Piranha"] = false;
							_G["MobCrew"] = false;
							_G["FishBoat"] = false;
							_G["SailBoats"] = false;
						elseif n == "Green" then
							repeat
								task["wait"]();
								_G["SailBoats"] = true;
							until not _G["Dojoo"] or not p;
							_G["SailBoats"] = false;
						elseif n == "Purple" then
							repeat
								task["wait"]();
								_G["FarmEliteHunt"] = true;
							until not _G["Dojoo"] or not p;
							_G["FarmEliteHunt"] = false;
						elseif n == "Red" then
							repeat
								task["wait"]();
								_G["SailBoats"] = true;
								_G["FishBoat"] = true;
							until not _G["Dojoo"] or not p;
							_G["SailBoats"] = false;
							_G["FishBoat"] = false;
						elseif n == "Black" then
							repeat
								task["wait"]();
								if workspace["Map"]:FindFirstChild("PrehistoricIsland") or workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Prehistoric Island") then
									_G["Prehis_Find"] = true;
									if workspace["Map"]["PrehistoricIsland"]["Core"]["ActivationPrompt"]:FindFirstChild("ProximityPrompt", true) then
										_G["Prehis_Skills"] = false;
										_G["Prehis_Find"] = true;
									else
										_G["Prehis_Skills"] = true;
										_G["Prehis_Find"] = false;
									end;
								else
									_G["Prehis_Find"] = true;
									_G["Prehis_Skills"] = false;
								end;
							until not _G["Dojoo"] or not p;
							_G["Prehis_Find"] = false;
							_G["Prehis_Skills"] = false;
						elseif n == "Orange" or n == "Blue" then
							return nil;
						end;
					end;
					if not p then
						debug = false;
						local o = { [1] = { ["NPC"] = "Dojo Trainer", ["Command"] = "ClaimQuest" } };
						(replicated["Modules"]["Net"]:FindFirstChild("RF/InteractDragonQuest")):InvokeServer(unpack(o));
					end;
				end);
			end;
		end;
	end);
	local kM = t["Drago"]:AddToggle("BlazeEM", { ["Title"] = "Auto Dragon Hunter", ["Description"] = "turn on for farm blaze ember + auto collect blaze ember", ["Default"] = false });
	kM:OnChanged(function(o)
		_G["FarmBlazeEM"] = o;
	end);
	checkQuesta = function()
			local o = { [1] = { ["Context"] = "Check" } };
			local p = nil;
			pcall(function()
				local o = { [1] = { ["Context"] = "RequestQuest" } };
				((((game:GetService("ReplicatedStorage")):WaitForChild("Modules")):WaitForChild("Net")):WaitForChild("RF/DragonHunter")):InvokeServer(unpack(o));
			end);
			local n, e = pcall(function()
					p = ((((game:GetService("ReplicatedStorage")):WaitForChild("Modules")):WaitForChild("Net")):WaitForChild("RF/DragonHunter")):InvokeServer(unpack(o));
				end);
			local U = false;
			local g;
			local Z;
			local l;
			if p then
				if p["Text"] then
					U = true;
					local o = p["Text"];
					if string["find"](tostring(o), "Defeat") then
						l = 1;
						g = string["sub"](tostring(o), 8, 9);
						g = tonumber(g);
						local p = { "Hydra Enforcer", "Venomous Assailant" };
						for p, n in pairs(p) do
							if string["find"](o, n) then
								Z = n;
								break;
							end;
						end;
					elseif string["find"](tostring(o), "Destroy") then
						g = 10;
						l = 2;
						Z = nil;
					end;
				end;
			end;
			return U, Z, g, l;
		end;
	BackTODoJo = function()
			for o, p in pairs((game:GetService("Players"))["LocalPlayer"]["PlayerGui"]["Notifications"]:GetChildren()) do
				if p["Name"] == "NotificationTemplate" then
					if string["find"](p["Text"], "Head back to the Dojo to complete more tasks") then
						return true;
					end;
				end;
			end;
			return false;
		end;
	DragonMobClear = function(o, p, n)
			if workspace["Enemies"]:FindFirstChild(p) then
				for n, e in pairs(workspace["Enemies"]:GetChildren()) do
					if e["Name"] == p and f["Alive"](e) then
						if o then
							f["Kill"](e, o);
						end;
					end;
				end;
			else
				_tp(n);
			end;
		end;
	spawn(function()
		while wait() do
			if _G["FarmBlazeEM"] then
				pcall(function()
					local o, p, n, e = checkQuesta();
					if o == true and not BackTODoJo() then
						if e == 1 then
							if p == "Hydra Enforcer" or p == "Venomous Assailant" then
								repeat
									wait();
									DragonMobClear(true, p, CFrame["new"](4620.6157226562, 1002.2954711914, 399.08688354492));
								until not _G["FarmBlazeEM"] or not o or BackTODoJo();
							end;
						elseif e == 2 then
							if workspace["Map"]["Waterfall"]["IslandModel"]:FindFirstChild("Meshes/bambootree", true) then
								repeat
									wait();
									spawn(function()
										_tp((workspace["Map"]["Waterfall"]["IslandModel"]:FindFirstChild("Meshes/bambootree", true))["CFrame"] * CFrame["new"](4, 0, 0));
									end);
									if ((workspace["Map"]["Waterfall"]["IslandModel"]:FindFirstChild("Meshes/bambootree", true))["Position"] - Root["Position"])["Magnitude"] <= 200 then
										MousePos = (workspace["Map"]["Waterfall"]["IslandModel"]:FindFirstChild("Meshes/bambootree", true))["Position"];
										Useskills("Melee", "Z");
										Useskills("Melee", "X");
										Useskills("Melee", "C");
										wait(.5);
										Useskills("Sword", "Z");
										Useskills("Sword", "X");
										wait(.5);
										Useskills("Blox Fruit", "Z");
										Useskills("Blox Fruit", "X");
										Useskills("Blox Fruit", "C");
										wait(.5);
										Useskills("Gun", "Z");
										Useskills("Gun", "X");
									end;
								until not _G["FarmBlazeEM"] or not o or BackTODoJo();
							end;
						end;
					else
						_tp(CFrame["new"](5813, 1208, 884));
						DragonMobClear(false, nil, nil);
					end;
				end);
			end;
		end;
	end);
	spawn(function()
		while wait(.1) do
			if _G["FarmBlazeEM"] then
				pcall(function()
					if workspace["EmberTemplate"]:FindFirstChild("Part") then
						game["Players"]["LocalPlayer"]["Character"]["HumanoidRootPart"]["CFrame"] = workspace["EmberTemplate"]["Part"]["CFrame"];
					end;
				end);
			end;
		end;
	end);
	t["Drago"]:AddSection("Drago Trial");
	GetQuestDracoLevel = function()
			local o = { [1] = { ["NPC"] = "Dragon Wizard", ["Command"] = "Upgrade" } };
			return (replicated["Modules"]["Net"]:FindFirstChild("RF/InteractDragonQuest")):InvokeServer(unpack(o));
		end;
	KM = t["Drago"]:AddToggle("Toggle", { ["Title"] = "Tween To Upgrade Droco Trial", ["Description"] = "", ["Default"] = false });
	KM:OnChanged(function(o)
		_G["UPGDrago"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["UPGDrago"] then
					if GetQuestDracoLevel() == false then
						return nil;
					elseif GetQuestDracoLevel() == true then
						if ((CFrame["new"](5814.4272460938, 1208.3267822266, 884.57855224609))["Position"] - Root["Position"])["Magnitude"] >= 300 then
							_tp(CFrame["new"](5814.4272460938, 1208.3267822266, 884.57855224609));
						else
							_tp(CFrame["new"](5814.4272460938, 1208.3267822266, 884.57855224609));
							local o = { [1] = { ["NPC"] = "Dragon Wizard", ["Command"] = "Upgrade" } };
							(replicated["Modules"]["Net"]:FindFirstChild("RF/InteractDragonQuest")):InvokeServer(unpack(o));
						end;
					end;
				end;
			end);
		end;
	end);
	KM = t["Drago"]:AddToggle("Toggle", { ["Title"] = "Auto Drago (V1)", ["Description"] = "turn on for auto quest1 auto prehistoric event + collect dragon eggs", ["Default"] = false });
	KM:OnChanged(function(o)
		_G["DragoV1"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["DragoV1"] then
					if GetM("Dragon Egg") <= 0 then
						repeat
							wait();
							_G["Prehis_Find"] = true;
							_G["Prehis_Skills"] = true;
							_G["Prehis_DE"] = true;
						until not _G["DragoV1"] or GetM("Dragon Egg") >= 1;
						_G["Prehis_Find"] = false;
						_G["Prehis_Skills"] = false;
						_G["Prehis_DE"] = false;
					end;
				end;
			end);
		end;
	end);
	local yM = t["Drago"]:AddToggle("fireflower", { ["Title"] = "Auto Drago (V2)", ["Description"] = "turn on for auto kill Forest Pirate & Collect fireflower", ["Default"] = false });
	yM:OnChanged(function(o)
		_G["AutoFireFlowers"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["AutoFireFlowers"] then
				local o = workspace:FindFirstChild("FireFlowers");
				local p = GetConnectionEnemies("Forest Pirate");
				if p then
					repeat
						wait();
						f["Kill"](p, _G["AutoFireFlowers"]);
					until not _G["AutoFireFlowers"] or not p["Parent"] or p["Humanoid"]["Health"] <= 0 or o;
				else
					_tp(CFrame["new"](-13206.452148438, 425.89199829102, -7964.5537109375));
				end;
				if o then
					for o, p in pairs(o:GetChildren()) do
						if p:IsA("Model") and p["PrimaryPart"] then
							local o = p["PrimaryPart"]["Position"];
							local n = game["Players"]["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"];
							local e = (o - n)["Magnitude"];
							if e <= 100 then
								vim1:SendKeyEvent(true, "E", false, game);
								wait(1.5);
								vim1:SendKeyEvent(false, "E", false, game);
							else
								_tp(CFrame["new"](o));
							end;
						end;
					end;
				end;
			end;
		end;
	end);
	KM = t["Drago"]:AddToggle("Toggle", { ["Title"] = "Auto Drago (V3)", ["Description"] = "turn on for sea event kill terror shark", ["Default"] = false });
	KM:OnChanged(function(o)
		_G["DragoV3"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["DragoV3"] then
					repeat
						wait();
						_G["DangerSc"] = "Lv Infinite";
						_G["SailBoats"] = true;
						_G["TerrorShark"] = true;
					until not _G["DragoV3"];
					_G["DangerSc"] = "Lv 1";
					_G["SailBoats"] = false;
					_G["TerrorShark"] = false;
				end;
			end);
		end;
	end);
	KM = t["Drago"]:AddToggle("Toggle", { ["Title"] = "Auto Relic Drago Trial [Beta]", ["Description"] = "turn on for auto trial v4 you have to COLLECT RELIC by your self", ["Default"] = false });
	KM:OnChanged(function(o)
		_G["Relic123"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["Relic123"] then
				pcall(function()
					if workspace["Map"]:FindFirstChild("DracoTrial") then
						replicated["Remotes"]["DracoTrial"]:InvokeServer();
						wait(.5);
						repeat
							wait();
							_tp(CFrame["new"](-39934.9765625, 10685.359375, 22999.34375));
						until not _G["Relic123"] or Root["Position"] == (CFrame["new"](-39934.9765625, 10685.359375, 22999.34375))["Position"];
						repeat
							wait();
							_tp(CFrame["new"](-40511.25390625, 9376.4013671875, 23458.37890625));
						until not _G["Relic123"] or Root["Position"] == (CFrame["new"](-40511.25390625, 9376.4013671875, 23458.37890625))["Position"];
						wait(2.5);
						repeat
							wait();
							_tp(CFrame["new"](-39914.65625, 10685.384765625, 23000.177734375));
						until not _G["Relic123"] or Root["Position"] == (CFrame["new"](-39914.65625, 10685.384765625, 23000.177734375))["Position"];
						repeat
							wait();
							_tp(CFrame["new"](-40045.83203125, 9376.3984375, 22791.287109375));
						until not _G["Relic123"] or Root["Position"] == (CFrame["new"](-40045.83203125, 9376.3984375, 22791.287109375))["Position"];
						wait(2.5);
						repeat
							wait();
							_tp(CFrame["new"](-39908.5, 10685.405273438, 22990.04296875));
						until not _G["Relic123"] or Root["Position"] == (CFrame["new"](-39908.5, 10685.405273438, 22990.04296875))["Position"];
						repeat
							wait();
							_tp(CFrame["new"](-39609.5, 9376.400390625, 23472.94335975));
						until not _G["Relic123"] or Root["Position"] == (CFrame["new"](-39609.5, 9376.400390625, 23472.94335975))["Position"];
					else
						local o = workspace["Map"]["PrehistoricIsland"]:FindFirstChild("TrialTeleport");
						if o and o:IsA("Part") then
							_tp(CFrame["new"](o["Position"]));
						end;
					end;
				end);
			end;
		end;
	end);
	KM = t["Drago"]:AddToggle("Toggle", { ["Title"] = "Auto Train Drago v4", ["Description"] = "turn on for training Drago race v4 + auto upgrade tier", ["Default"] = false });
	KM:OnChanged(function(o)
		_G["TrainDrago"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["TrainDrago"] then
					local o = { "Venomous Assailant", "Hydra Enforcer" };
					for p = 1, #o, 1 do
						if (plr["Character"]:FindFirstChild("RaceEnergy"))["Value"] == 1 then
							vim1:SendKeyEvent(true, "Y", false, game);
							replicated["Remotes"]["CommF_"]:InvokeServer("UpgradeRace", "Buy", 2);
							_tp(CFrame["new"](4620.6157226562, 1002.2954711914, 399.08688354492));
						elseif (plr["Character"]:FindFirstChild("RaceTransformed"))["Value"] == false then
							local p = GetConnectionEnemies(o);
							if p then
								repeat
									wait();
									f["Kill"](p, _G["TrainDrago"]);
								until _G["TrainDrago"] == false or p["Humanoid"]["Health"] <= 0 or not p["Parent"];
							else
								_tp(CFrame["new"](4620.6157226562, 1002.2954711914, 399.08688354492));
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	local mM = t["Drago"]:AddToggle("dragoTpVolcano", { ["Title"] = "Tween to Drago Trials", ["Description"] = "", ["Default"] = false });
	mM:OnChanged(function(o)
		_G["TpDrago_Prehis"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["TpDrago_Prehis"] then
				local o = workspace["Map"]["PrehistoricIsland"]:FindFirstChild("TrialTeleport");
				if o and o:IsA("Part") then
					_tp(CFrame["new"](o["Position"]));
				end;
			end;
		end;
	end);
	local xM = t["Drago"]:AddToggle("bdrago", { ["Title"] = "Swap Drago Race", ["Description"] = "", ["Default"] = false });
	xM:OnChanged(function(o)
		_G["BuyDrago"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["BuyDrago"] then
				pcall(function()
					if ((CFrame["new"](5814.4272460938, 1208.3267822266, 884.57855224609))["Position"] - Root["Position"])["Magnitude"] >= 300 then
						_tp(CFrame["new"](5814.4272460938, 1208.3267822266, 884.57855224609));
					else
						_tp(CFrame["new"](5814.4272460938, 1208.3267822266, 884.57855224609));
						local o = { [1] = { ["NPC"] = "Dragon Wizard", ["Command"] = "DragonRace" } };
						(replicated["Modules"]["Net"]:FindFirstChild("RF/InteractDragonQuest")):InvokeServer(unpack(o));
					end;
				end);
			end;
		end;
	end);
	local vM = t["Drago"]:AddToggle("UpTalon", { ["Title"] = "Upgrade Dragon Talon With Uzoth", ["Description"] = "", ["Default"] = false });
	vM:OnChanged(function(o)
		_G["DT_Uzoth"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["DT_Uzoth"] then
				local o = CFrame["new"](5661.89014, 1211.31909, 864.836731, .811413169, -1.36805838e-008, -0.584473014, 4.75227395e-008, 1, 4.25682458e-008, .584473014, -6.23161966e-008, .811413169);
				_tp(o);
				if (o["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 25 then
					local o = { ["NPC"] = "Uzoth", ["Command"] = "Upgrade" };
					replicated["Modules"]["Net"]["RF/InteractDragonQuest"]:InvokeServer(o);
				end;
			end;
		end;
	end);
	t["Prehistoric"]:AddSection("Volcanic Magnet");
	KM = t["Prehistoric"]:AddToggle("Toggle", { ["Title"] = "Auto Craft Volcanic Magnet", ["Description"] = "turn on for auto farm material and craft volcanic magnet & stop when you have 1 volcanic magnet", ["Default"] = false });
	KM:OnChanged(function(o)
		_G["CraftVM"] = o;
	end);
	t["Prehistoric"]:AddButton({ ["Title"] = "Craft Volcanic Magnet", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("CraftItem", "Craft", "Volcanic Magnet");
		end });
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["CraftVM"] then
					if GetM("Volcanic Magnet") < 1 then
						if GetM("Scrap Metal") >= 10 and GetM("Blaze Ember") >= 15 then
							replicated["Remotes"]["CommF_"]:InvokeServer("CraftItem", "Craft", "Volcanic Magnet");
						elseif GetM("Scrap Metal") < 10 then
							local o = GetConnectionEnemies("Forest Pirate");
							if o then
								repeat
									wait();
									f["Kill"](o, _G["CraftVM"]);
								until not _G["CraftVM"] or not o["Parent"] or o["Humanoid"]["Health"] <= 0 or GetM("Scrap Metal") >= 10;
							else
								_tp(CFrame["new"](-13206.452148438, 425.89199829102, -7964.5537109375));
							end;
						elseif GetM("Blaze Ember") < 15 then
							repeat
								wait();
								_G["FarmBlazeEM"] = true;
							until not _G["CraftVM"] or GetM("Blaze Ember") >= 15;
							_G["FarmBlazeEM"] = false;
						end;
					end;
				end;
			end);
		end;
	end);
	t["Prehistoric"]:AddSection("Prehistoric Island");
	local CM = t["Prehistoric"]:AddParagraph({ ["Title"] = " Prehistoric Island Status ", ["Content"] = "" });
	spawn(function()
		while wait(.2) do
			if workspace["Map"]:FindFirstChild("PrehistoricIsland") or workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Prehistoric Island") then
				CM:SetDesc(" Prehistoric Island : True");
			else
				CM:SetDesc(" Prehistoric Island : False");
			end;
		end;
	end);
	Vocan = t["Prehistoric"]:AddToggle("Vocan", { ["Title"] = "Auto Find Prehistoric Island", ["Description"] = "turn on for finding & tween & start prehistoric island", ["Default"] = false });
	Vocan:OnChanged(function(o)
		_G["Prehis_Find"] = o;
	end);
	local SM = nil;
	spawn(function()
		while wait() do
			if _G["Prehis_Find"] then
				pcall(function()
					if not workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Prehistoric Island", true) then
						local o = CheckBoat();
						if not o then
							local o = CFrame["new"](-16927.451, 9.086, 433.864);
							TeleportToTarget(o);
							if (o["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 10 then
								replicated["Remotes"]["CommF_"]:InvokeServer("BuyBoat", _G["SelectedBoat"]);
							end;
						else
							if plr["Character"]["Humanoid"]["Sit"] == false then
								local p = o["VehicleSeat"]["CFrame"] * CFrame["new"](0, 1, 0);
								_tp(p);
							else
								repeat
									wait();
									local o = CFrame["new"](-10000000, 31, 37016.25);
									if CheckEnemiesBoat() or CheckTerrorShark() or CheckPirateGrandBrigade() then
										_tp(CFrame["new"](-10000000, 150, 37016.25));
									else
										_tp(CFrame["new"](-10000000, 31, 37016.25));
									end;
								until not _G["Prehis_Find"] or (o["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 10 or workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Prehistoric Island") or plr["Character"]["Humanoid"]["Sit"] == false;
								plr["Character"]["Humanoid"]["Sit"] = false;
							end;
						end;
					else
						if ((workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Prehistoric Island"))["CFrame"]["Position"] - game["Players"]["LocalPlayer"]["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] >= 2000 then
							_tp((workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Prehistoric Island"))["CFrame"]);
						end;
						if workspace["Map"]:FindFirstChild("PrehistoricIsland", true) or workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Prehistoric Island", true) then
							if workspace["Map"]["PrehistoricIsland"]["Core"]["ActivationPrompt"]:FindFirstChild("ProximityPrompt", true) then
								if plr:DistanceFromCharacter(workspace["Map"]["PrehistoricIsland"]["Core"]["ActivationPrompt"]["CFrame"]["Position"]) <= 150 then
									fireproximityprompt(workspace["Map"]["PrehistoricIsland"]["Core"]["ActivationPrompt"]["ProximityPrompt"], math["huge"]);
									vim1:SendKeyEvent(true, "E", false, game);
									wait(1.5);
									vim1:SendKeyEvent(false, "E", false, game);
								end;
								_tp(workspace["Map"]["PrehistoricIsland"]["Core"]["ActivationPrompt"]["CFrame"]);
							end;
						end;
					end;
				end);
			end;
		end;
	end);
	local VM = t["Prehistoric"]:AddToggle("Vocan", { ["Title"] = "Auto Patch Prehistoric Event", ["Description"] = "turn on for auto patch volcano + kill aura lava golems + auto remove lava", ["Default"] = false });
	VM:OnChanged(function(o)
		_G["Prehis_Skills"] = o;
	end);
	spawn(function()
		while wait() do
			if _G["Prehis_Skills"] then
				local o = game["Workspace"]["Map"]:FindFirstChild("PrehistoricIsland");
				if o then
					for o, p in pairs(o:GetDescendants()) do
						if p:IsA("Part") and (p["Name"]:lower()):find("lava") then
							p:Destroy();
						end;
						if p:IsA("MeshPart") and (p["Name"]:lower()):find("lava") then
							p:Destroy();
						end;
					end;
					local p = game["Workspace"]["Map"]["PrehistoricIsland"]["Core"]:FindFirstChild("InteriorLava");
					if p and p:IsA("Model") then
						p:Destroy();
					end;
					local n = workspace["Map"]:FindFirstChild("PrehistoricIsland");
					if n then
						local o = workspace["Map"]["PrehistoricIsland"]:FindFirstChild("TrialTeleport");
						for p, n in pairs(n:GetDescendants()) do
							if n["Name"] == "TouchInterest" then
								if not (o and n:IsDescendantOf(o)) then
									n["Parent"]:Destroy();
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	end);
	spawn(function()
		while wait() do
			pcall(function()
				if _G["Prehis_Skills"] then
					if workspace["Enemies"]:FindFirstChild("Lava Golem") then
						local o = GetConnectionEnemies("Lava Golem");
						if o then
							repeat
								wait();
								f["Kill"](o, _G["Prehis_Skills"]);
								o["Humanoid"]:ChangeState(15);
							until not _G["Prehis_Skills"] or not o["Parent"] or o["Humanoid"]["Health"] <= 0;
						end;
					end;
					for o, p in pairs(game["Workspace"]["Map"]["PrehistoricIsland"]["Core"]["VolcanoRocks"]:GetChildren()) do
						if p:FindFirstChild("VFXLayer") then
							if (p:FindFirstChild("VFXLayer"))["At0"]["Glow"]["Enabled"] == true or p["VFXLayer"]["At0"]["Glow"]["Enabled"] == true then
								repeat
									wait();
									_tp(p["VFXLayer"]["CFrame"]);
									if p["VFXLayer"]["At0"]["Glow"]["Enabled"] == true and plr:DistanceFromCharacter(p["VFXLayer"]["CFrame"]["Position"]) <= 150 then
										MousePos = p["VFXLayer"]["CFrame"]["Position"];
										Useskills("Melee", "Z");
										wait(.5);
										Useskills("Melee", "X");
										wait(.5);
										Useskills("Melee", "C");
										wait(.5);
										Useskills("Blox Fruit", "Z");
										wait(.5);
										Useskills("Blox Fruit", "X");
										wait(.5);
										Useskills("Blox Fruit", "C");
									end;
								until not _G["Prehis_Skills"] or (p:FindFirstChild("VFXLayer"))["At0"]["Glow"]["Enabled"] == false or p["VFXLayer"]["At0"]["Glow"]["Enabled"] == false;
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	local qM = t["Prehistoric"]:AddToggle("Vocan", { ["Title"] = "Auto Collect Dino Bones", ["Description"] = "", ["Default"] = false });
	qM:OnChanged(function(o)
		_G["Prehis_DB"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Prehis_DB"] then
					if workspace:FindFirstChild("DinoBone") then
						for o, p in pairs(workspace:GetChildren()) do
							if p["Name"] == "DinoBone" then
								_tp(p["CFrame"]);
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	local LM = t["Prehistoric"]:AddToggle("Vocan", { ["Title"] = "Auto Collect Dragon Eggs", ["Description"] = "", ["Default"] = false });
	LM:OnChanged(function(o)
		_G["Prehis_DE"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Prehis_DE"] then
					if workspace["Map"]["PrehistoricIsland"]["Core"]["SpawnedDragonEggs"]:FindFirstChild("DragonEgg") then
						_tp((workspace["Map"]["PrehistoricIsland"]["Core"]["SpawnedDragonEggs"]:FindFirstChild("DragonEgg"))["Molten"]["CFrame"]);
						fireproximityprompt(workspace["Map"]["PrehistoricIsland"]["Core"]["SpawnedDragonEggs"]["DragonEgg"]["Molten"]["ProximityPrompt"], 30);
					end;
				end;
			end);
		end;
	end);
	KM = t["Prehistoric"]:AddToggle("Toggle", { ["Title"] = "Auto Reset When Complete Volcano", ["Description"] = "Reset When Complete Volcano not collect dino bones and else..", ["Default"] = false });
	KM:OnChanged(function(o)
		_G["ResetPH"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["ResetPH"] then
					local o = workspace["Map"]["PrehistoricIsland"]:FindFirstChild("TrialTeleport");
					if o and o:FindFirstChild("TouchInterest") then
						plr["Character"]["Humanoid"]["Health"] = 0;
					else
						if workspace:FindFirstChild("DinoBone") then
							for o, p in pairs(workspace:GetChildren()) do
								if p["Name"] == "DinoBone" then
									_tp(p["CFrame"]);
								end;
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	t["SeaEvent"]:AddSection("Sea Event / Setting Sail");
	local Df = {
			"Guardian",
			"PirateGrandBrigade",
			"MarineGrandBrigade",
			"PirateBrigade",
			"MarineBrigade",
			"PirateSloop",
			"MarineSloop",
			"Beast Hunter",
		};
	local Mf = {
			"Lv 1",
			"Lv 2",
			"Lv 3",
			"Lv 4",
			"Lv 5",
			"Lv 6",
			"Lv Infinite",
		};
	local of = t["SeaEvent"]:AddParagraph({ ["Title"] = " Spy Status ", ["Content"] = "" });
	spawn(function()
		while wait(.2) do
			pcall(function()
				local o = string["match"](replicated["Remotes"]["CommF_"]:InvokeServer("InfoLeviathan", "1"), "%d+");
				if o then
					of:SetDesc(" Spy Leviathan  : " .. tostring(o));
					if tostring(o) == 5 then
						of:SetDesc(" Spy Leviathan : Already Done!!");
					end;
				end;
			end);
		end;
	end);
	t["SeaEvent"]:AddButton({ ["Title"] = "Buy Fracments with Spy", ["Description"] = "Buy the spy for finding leviathan", ["Callback"] = function()
			((replicated:WaitForChild("Remotes")):WaitForChild("CommF_")):InvokeServer("InfoLeviathan", "2");
		end });
	local pf = t["SeaEvent"]:AddParagraph({ ["Title"] = " FlozenDimension Status ", ["Content"] = "" });
	spawn(function()
		pcall(function()
			while wait(.2) do
				if workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Frozen Dimension") then
					pf:SetDesc(" Flozen Dimension : True");
				else
					pf:SetDesc(" Flozen Dimension : False");
				end;
			end;
		end);
	end);
	local nf = t["SeaEvent"]:AddToggle("Q", { ["Title"] = "Auto Teleport Frozen Dimension", ["Description"] = "turn on for teleport to frozen dimension and start the leviathan gate", ["Default"] = false });
	nf:OnChanged(function(o)
		_G["FrozenTP"] = o;
	end);
	spawn(function()
		while wait(.1) do
			if _G["FrozenTP"] then
				pcall(function()
					if workspace["Map"]:FindFirstChild("LeviathanGate") then
						_tp(workspace["Map"]["LeviathanGate"]["CFrame"]);
						((replicated:WaitForChild("Remotes")):WaitForChild("CommF_")):InvokeServer("OpenLeviathanGate");
					end;
				end);
			end;
		end;
	end);
	local ef = t["SeaEvent"]:AddToggle("Q", { ["Title"] = "Auto Drive To Hydra Island", ["Description"] = "", ["Default"] = false });
	ef:OnChanged(function(o)
		_G["SailBoat_Hydra"] = o;
	end);
	spawn(function()
		while wait() do
			if _G["SailBoat_Hydra"] then
				pcall(function()
					local o = CheckBoat();
					if not o then
						local o = CFrame["new"](-16927.451, 9.086, 433.864);
						TeleportToTarget(o);
						if (o["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 10 then
							replicated["Remotes"]["CommF_"]:InvokeServer("BuyBoat", _G["SelectedBoat"]);
						end;
					elseif o then
						if plr["Character"]["Humanoid"]["Sit"] == false then
							local p = o["VehicleSeat"]["CFrame"] * CFrame["new"](0, 1, 0);
							_tp(p);
						else
							repeat
								wait();
								if CheckEnemiesBoat() or CheckPirateGrandBrigade() or CheckTerrorShark() then
									_tp(CFrame["new"](5433, 150, 290));
								else
									_tp(CFrame["new"](5433, 35, 290));
								end;
							until _G["SailBoat_Hydra"] == false or (plr["Character"]:WaitForChild("Humanoid"))["Sit"] == false;
							plr["Character"]["Humanoid"]["Sit"] = false;
						end;
					end;
				end);
			end;
		end;
	end);
	local Uf = t["SeaEvent"]:AddDropdown("Q", {
			["Title"] = "Choose Boats",
			["Values"] = Df,
			["Multi"] = false,
			["Default"] = 1,
		});
	Uf:OnChanged(function(o)
		_G["SelectedBoat"] = o;
	end);
	t["SeaEvent"]:AddButton({ ["Title"] = "Buy Boats", ["Description"] = "Buy the select boats", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyBoat", _G["SelectedBoat"]);
		end });
	local gf = t["SeaEvent"]:AddDropdown("Q", {
			["Title"] = "Choose Sea Level",
			["Values"] = Mf,
			["Multi"] = false,
			["Default"] = 1,
		});
	gf:OnChanged(function(o)
		_G["DangerSc"] = o;
	end);
	local Zf = t["SeaEvent"]:AddToggle("Q", { ["Title"] = "Auto Sail Boat", ["Description"] = "", ["Default"] = false });
	Zf:OnChanged(function(o)
		_G["SailBoats"] = o;
	end);
	spawn(function()
		while wait() do
			if _G["SailBoats"] then
				pcall(function()
					local o = CheckBoat();
					if not o and (not (CheckShark() and _G["Shark"] or CheckTerrorShark() and _G["TerrorShark"] or CheckFishCrew() and _G["MobCrew"] or CheckPiranha() and _G["Piranha"]) and (not (CheckEnemiesBoat() and _G["FishBoat"]) and (not (CheckSeaBeast() and _G["SeaBeast1"]) and (not (_G["PGB"] and CheckPirateGrandBrigade()) and (not (_G["HCM"] and CheckHauntedCrew()) and not (_G["Leviathan1"] and CheckLeviathan())))))) then
						local o = CFrame["new"](-16927.451, 9.086, 433.864);
						TeleportToTarget(o);
						if (o["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 10 then
							replicated["Remotes"]["CommF_"]:InvokeServer("BuyBoat", _G["SelectedBoat"]);
						end;
					elseif o and (not (CheckShark() and _G["Shark"] or CheckTerrorShark() and _G["TerrorShark"] or CheckFishCrew() and _G["MobCrew"] or CheckPiranha() and _G["Piranha"]) and (not (CheckEnemiesBoat() and _G["FishBoat"]) and (not (CheckSeaBeast() and _G["SeaBeast1"]) and (not (_G["PGB"] and CheckPirateGrandBrigade()) and (not (_G["HCM"] and CheckHauntedCrew()) and not (_G["Leviathan1"] and CheckLeviathan())))))) then
						if plr["Character"]["Humanoid"]["Sit"] == false then
							local p = o["VehicleSeat"]["CFrame"] * CFrame["new"](0, 1, 0);
							_tp(p);
						else
							if _G["DangerSc"] == "Lv 1" then
								CFrameSelectedZone = CFrame["new"](-21998.375, 30.0006084, -682.309143);
							elseif _G["DangerSc"] == "Lv 2" then
								CFrameSelectedZone = CFrame["new"](-26779.5215, 30.0005474, -822.858032);
							elseif _G["DangerSc"] == "Lv 3" then
								CFrameSelectedZone = CFrame["new"](-31171.957, 30.0001011, -2256.93774);
							elseif _G["DangerSc"] == "Lv 4" then
								CFrameSelectedZone = CFrame["new"](-34054.6875, 30.2187767, -2560.12012);
							elseif _G["DangerSc"] == "Lv 5" then
								CFrameSelectedZone = CFrame["new"](-38887.5547, 30.0004578, -2162.99023);
							elseif _G["DangerSc"] == "Lv 6" then
								CFrameSelectedZone = CFrame["new"](-44541.7617, 30.0003204, -1244.8584);
							elseif _G["DangerSc"] == "Lv Infinite" then
								CFrameSelectedZone = CFrame["new"](-10000000, 31, 37016.25);
							end;
							repeat
								wait();
								if not _G["FishBoat"] and CheckEnemiesBoat() or not _G["PGB"] and CheckPirateGrandBrigade() or not _G["TerrorShark"] and CheckTerrorShark() then
									_tp(CFrameSelectedZone * CFrame["new"](0, 150, 0));
								else
									_tp(CFrameSelectedZone);
								end;
							until _G["SailBoats"] == false or CheckShark() and _G["Shark"] or CheckTerrorShark() and _G["TerrorShark"] or CheckFishCrew() and _G["MobCrew"] or CheckPiranha() and _G["Piranha"] or CheckSeaBeast() and _G["SeaBeast1"] or CheckEnemiesBoat() and _G["FishBoat"] or _G["Leviathan1"] and CheckLeviathan() or _G["HCM"] and CheckHauntedCrew() or _G["PGB"] and CheckPirateGrandBrigade() or (plr["Character"]:WaitForChild("Humanoid"))["Sit"] == false;
							plr["Character"]["Humanoid"]["Sit"] = false;
						end;
					end;
				end);
			end;
		end;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				for o, p in pairs(workspace["Boats"]:GetChildren()) do
					for o, p in pairs(workspace["Boats"][p["Name"]]:GetDescendants()) do
						if p:IsA("BasePart") then
							if _G["SailBoats"] or _G["Prehis_Find"] or _G["FindMirage"] or _G["SailBoat_Hydra"] or _G["AutofindKitIs"] then
								p["CanCollide"] = false;
							else
								p["CanCollide"] = true;
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	t["SeaEvent"]:AddSection("Entity Sea Event");
	Zf = t["SeaEvent"]:AddToggle("Q", { ["Title"] = "Auto Shark", ["Description"] = "", ["Default"] = false });
	Zf:OnChanged(function(o)
		_G["Shark"] = o;
	end);
	Zf = t["SeaEvent"]:AddToggle("Q", { ["Title"] = "Auto Piranha", ["Description"] = "", ["Default"] = false });
	Zf:OnChanged(function(o)
		_G["Piranha"] = o;
	end);
	Zf = t["SeaEvent"]:AddToggle("Q", { ["Title"] = "Auto Terror Shark", ["Description"] = "", ["Default"] = false });
	Zf:OnChanged(function(o)
		_G["TerrorShark"] = o;
	end);
	Zf = t["SeaEvent"]:AddToggle("Q", { ["Title"] = "Auto Fish Crew Member", ["Description"] = "", ["Default"] = false });
	Zf:OnChanged(function(o)
		_G["MobCrew"] = o;
	end);
	Zf = t["SeaEvent"]:AddToggle("Q", { ["Title"] = "Auto Haunted Crew Member", ["Description"] = "", ["Default"] = false });
	Zf:OnChanged(function(o)
		_G["HCM"] = o;
	end);
	Zf = t["SeaEvent"]:AddToggle("Q", { ["Title"] = "Auto Attack PirateGrandBrigade", ["Description"] = "", ["Default"] = false });
	Zf:OnChanged(function(o)
		_G["PGB"] = o;
	end);
	Zf = t["SeaEvent"]:AddToggle("Q", { ["Title"] = "Auto Attack Fish Boat", ["Description"] = "", ["Default"] = false });
	Zf:OnChanged(function(o)
		_G["FishBoat"] = o;
	end);
	Zf = t["SeaEvent"]:AddToggle("Q", { ["Title"] = "Auto Attack Sea Beast", ["Description"] = "", ["Default"] = false });
	Zf:OnChanged(function(o)
		_G["SeaBeast1"] = o;
	end);
	Zf = t["SeaEvent"]:AddToggle("Q", { ["Title"] = "Auto Attack Leviathan", ["Description"] = "", ["Default"] = false });
	Zf:OnChanged(function(o)
		_G["Leviathan1"] = o;
	end);
	spawn(function()
		while wait() do
			pcall(function()
				if _G["Shark"] then
					local o = { "Shark" };
					if CheckShark() then
						for p, n in pairs(workspace["Enemies"]:GetChildren()) do
							if table["find"](o, n["Name"]) then
								if f["Alive"](n) then
									repeat
										task["wait"]();
										f["Kill"](n, _G["Shark"]);
									until _G["Shark"] == false or not n["Parent"] or n["Humanoid"]["Health"] <= 0;
								end;
							end;
						end;
					end;
				end;
				if _G["TerrorShark"] then
					local o = { "Terrorshark" };
					if CheckTerrorShark() then
						for p, n in pairs(workspace["Enemies"]:GetChildren()) do
							if table["find"](o, n["Name"]) then
								if f["Alive"](n) then
									repeat
										task["wait"]();
										f["KillSea"](n, _G["TerrorShark"]);
									until _G["TerrorShark"] == false or not n["Parent"] or n["Humanoid"]["Health"] <= 0;
								end;
							end;
						end;
					end;
				end;
				if _G["Piranha"] then
					local o = { "Piranha" };
					if CheckPiranha() then
						for p, n in pairs(workspace["Enemies"]:GetChildren()) do
							if table["find"](o, n["Name"]) then
								if f["Alive"](n) then
									repeat
										task["wait"]();
										f["Kill"](n, _G["Piranha"]);
									until _G["Piranha"] == false or not n["Parent"] or n["Humanoid"]["Health"] <= 0;
								end;
							end;
						end;
					end;
				end;
				if _G["MobCrew"] then
					local o = { "Fish Crew Member" };
					if CheckFishCrew() then
						for p, n in pairs(workspace["Enemies"]:GetChildren()) do
							if table["find"](o, n["Name"]) then
								if f["Alive"](n) then
									repeat
										task["wait"]();
										f["Kill"](n, _G["MobCrew"]);
									until _G["MobCrew"] == false or not n["Parent"] or n["Humanoid"]["Health"] <= 0;
								end;
							end;
						end;
					end;
				end;
				if _G["HCM"] then
					local o = { "Haunted Crew Member" };
					if CheckHauntedCrew() then
						for p, n in pairs(workspace["Enemies"]:GetChildren()) do
							if table["find"](o, n["Name"]) then
								if f["Alive"](n) then
									repeat
										task["wait"]();
										f["Kill"](n, _G["HCM"]);
									until _G["HCM"] == false or not n["Parent"] or n["Humanoid"]["Health"] <= 0;
								end;
							end;
						end;
					end;
				end;
				if _G["SeaBeast1"] then
					if workspace["SeaBeasts"]:FindFirstChild("SeaBeast1") then
						for o, p in pairs(workspace["SeaBeasts"]:GetChildren()) do
							if p:FindFirstChild("HumanoidRootPart") and (p:FindFirstChild("Health") and p["Health"]["Value"] > 0) then
								repeat
									task["wait"]();
									spawn(function()
										_tp(CFrame["new"](p["HumanoidRootPart"]["Position"]["X"], (game:GetService("Workspace"))["Map"]["WaterBase-Plane"]["Position"]["Y"] + 200, p["HumanoidRootPart"]["Position"]["Z"]));
									end);
									if plr:DistanceFromCharacter(p["HumanoidRootPart"]["CFrame"]["Position"]) <= 500 then
										AitSeaSkill_Custom = p["HumanoidRootPart"]["CFrame"];
										MousePos = AitSeaSkill_Custom["Position"];
										if CheckF() then
											weaponSc("Blox Fruit");
											Useskills("Blox Fruit", "Z");
											Useskills("Blox Fruit", "X");
											Useskills("Blox Fruit", "C");
										else
											Useskills("Melee", "Z");
											Useskills("Melee", "X");
											Useskills("Melee", "C");
											wait(.1);
											Useskills("Sword", "Z");
											Useskills("Sword", "X");
											wait(.1);
											Useskills("Blox Fruit", "Z");
											Useskills("Blox Fruit", "X");
											Useskills("Blox Fruit", "C");
											wait(.1);
											Useskills("Gun", "Z");
											Useskills("Gun", "X");
										end;
									end;
								until _G["SeaBeast1"] == false or not p:FindFirstChild("HumanoidRootPart") or not p["Parent"] or p["Health"]["Value"] <= 0;
							end;
						end;
					end;
				end;
				if _G["Leviathan1"] then
					if workspace["SeaBeasts"]:FindFirstChild("Leviathan") then
						for o, p in pairs(workspace["SeaBeasts"]:GetChildren()) do
							if p:FindFirstChild("HumanoidRootPart") and (p:FindFirstChild("Leviathan Segment") and (p:FindFirstChild("Health") and p["Health"]["Value"] > 0)) then
								repeat
									task["wait"]();
									spawn(function()
										_tp(CFrame["new"](p["HumanoidRootPart"]["Position"]["X"], (game:GetService("Workspace"))["Map"]["WaterBase-Plane"]["Position"]["Y"] + 200, p["HumanoidRootPart"]["Position"]["Z"]));
									end);
									if plr:DistanceFromCharacter(p["HumanoidRootPart"]["CFrame"]["Position"]) <= 500 then
										MousePos = (p:FindFirstChild("Leviathan Segment"))["Position"];
										if CheckF() then
											weaponSc("Blox Fruit");
											Useskills("Blox Fruit", "Z");
											Useskills("Blox Fruit", "X");
											Useskills("Blox Fruit", "C");
										else
											Useskills("Melee", "Z");
											Useskills("Melee", "X");
											Useskills("Melee", "C");
											wait(.1);
											Useskills("Sword", "Z");
											Useskills("Sword", "X");
											wait(.1);
											Useskills("Blox Fruit", "Z");
											Useskills("Blox Fruit", "X");
											Useskills("Blox Fruit", "C");
											wait(.1);
											Useskills("Gun", "Z");
											Useskills("Gun", "X");
										end;
									end;
								until _G["Leviathan1"] == false or not p:FindFirstChild("HumanoidRootPart") or not p["Parent"] or p["Health"]["Value"] <= 0;
							end;
						end;
					end;
				end;
				if _G["FishBoat"] then
					if CheckEnemiesBoat() then
						for o, p in pairs(workspace["Enemies"]:GetChildren()) do
							if p:FindFirstChild("Health") and (p["Health"]["Value"] > 0 and p:FindFirstChild("VehicleSeat")) then
								repeat
									task["wait"]();
									spawn(function()
										if p["Name"] == "FishBoat" then
											_tp(p["Engine"]["CFrame"] * CFrame["new"](0, -50, -25));
										end;
									end);
									if plr:DistanceFromCharacter(p["Engine"]["CFrame"]["Position"]) <= 150 then
										AitSeaSkill_Custom = p["Engine"]["CFrame"];
										MousePos = AitSeaSkill_Custom["Position"];
										if CheckF() then
											weaponSc("Blox Fruit");
											Useskills("Blox Fruit", "Z");
											Useskills("Blox Fruit", "X");
											Useskills("Blox Fruit", "C");
										else
											Useskills("Melee", "Z");
											Useskills("Melee", "X");
											Useskills("Melee", "C");
											wait(.1);
											Useskills("Sword", "Z");
											Useskills("Sword", "X");
											wait(.1);
											Useskills("Blox Fruit", "Z");
											Useskills("Blox Fruit", "X");
											Useskills("Blox Fruit", "C");
											wait(.1);
											Useskills("Gun", "Z");
											Useskills("Gun", "X");
										end;
									end;
								until _G["FishBoat"] == false or not p:FindFirstChild("VehicleSeat") or p["Health"]["Value"] <= 0;
							end;
						end;
					end;
				end;
				if _G["PGB"] then
					if CheckPirateGrandBrigade() then
						for o, p in pairs(workspace["Enemies"]:GetChildren()) do
							if p:FindFirstChild("Health") and (p["Health"]["Value"] > 0 and p:FindFirstChild("VehicleSeat")) then
								repeat
									task["wait"]();
									spawn(function()
										if p["Name"] == "PirateBrigade" then
											_tp(p["Engine"]["CFrame"] * CFrame["new"](0, -30, -10));
										elseif p["Name"] == "PirateGrandBrigade" then
											_tp(p["Engine"]["CFrame"] * CFrame["new"](0, -50, -50));
										end;
									end);
									if plr:DistanceFromCharacter(p["Engine"]["CFrame"]["Position"]) <= 150 then
										AitSeaSkill_Custom = p["Engine"]["CFrame"];
										MousePos = AitSeaSkill_Custom["Position"];
										if CheckF() then
											weaponSc("Blox Fruit");
											Useskills("Blox Fruit", "Z");
											Useskills("Blox Fruit", "X");
											Useskills("Blox Fruit", "C");
										else
											Useskills("Melee", "Z");
											Useskills("Melee", "X");
											Useskills("Melee", "C");
											wait(.1);
											Useskills("Sword", "Z");
											Useskills("Sword", "X");
											wait(.1);
											Useskills("Blox Fruit", "Z");
											Useskills("Blox Fruit", "X");
											Useskills("Blox Fruit", "C");
											wait(.1);
											Useskills("Gun", "Z");
											Useskills("Gun", "X");
										end;
									end;
								until _G["PGB"] == false or not p:FindFirstChild("VehicleSeat") or p["Health"]["Value"] <= 0;
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	t["SeaEvent"]:AddSection("Kitsune Island / Event");
	local lf = t["SeaEvent"]:AddParagraph({ ["Title"] = " Kitsune Island Status ", ["Content"] = "" });
	spawn(function()
		while wait(.2) do
			if workspace["Map"]:FindFirstChild("KitsuneIsland") or workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Kitsune Island") then
				lf:SetDesc(" Kitsune Island : True");
			else
				lf:SetDesc(" Kitsune Island : False");
			end;
		end;
	end);
	local Wf = t["SeaEvent"]:AddToggle("Q", { ["Title"] = "Auto Find Kitsune Island", ["Description"] = "turn on for finding & tween kitsune island", ["Default"] = false });
	Wf:OnChanged(function(o)
		_G["AutofindKitIs"] = o;
	end);
	spawn(function()
		while wait() do
			if _G["AutofindKitIs"] then
				pcall(function()
					if not workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Kitsune Island", true) then
						local o = CheckBoat();
						if not o then
							local o = CFrame["new"](-16927.451, 9.086, 433.864);
							TeleportToTarget(o);
							if (o["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 10 then
								replicated["Remotes"]["CommF_"]:InvokeServer("BuyBoat", _G["SelectedBoat"]);
							end;
						else
							if plr["Character"]["Humanoid"]["Sit"] == false then
								local p = o["VehicleSeat"]["CFrame"] * CFrame["new"](0, 1, 0);
								_tp(p);
							else
								local o = CFrame["new"](-10000000, 31, 37016.25);
								repeat
									wait();
									if CheckEnemiesBoat() or CheckTerrorShark() or CheckPirateGrandBrigade() then
										_tp(CFrame["new"](-10000000, 150, 37016.25));
									else
										_tp(CFrame["new"](-10000000, 31, 37016.25));
									end;
								until not _G["AutofindKitIs"] or (o["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 10 or workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Kitsune Island") or plr["Character"]["Humanoid"]["Sit"] == false;
								plr["Character"]["Humanoid"]["Sit"] = false;
							end;
						end;
					else
						_tp((workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Kitsune Island"))["CFrame"] * CFrame["new"](0, 500, 0));
					end;
				end);
			end;
		end;
	end);
	local Yf = t["SeaEvent"]:AddToggle("Q", { ["Title"] = "Auto Teleport to Shrine Actived", ["Description"] = "", ["Default"] = false });
	Yf:OnChanged(function(o)
		_G["tweenShrine"] = o;
	end);
	spawn(function()
		while wait(.1) do
			if _G["tweenShrine"] then
				pcall(function()
					local o = workspace["Map"]:FindFirstChild("KitsuneIsland") or game["Workspace"]["_WorldOrigin"]["Locations"]:FindFirstChild("Kitsune Island");
					local p = o:FindFirstChild("ShrineActive");
					if p then
						for p, n in next, p:GetDescendants() do
							if n:IsA("BasePart") and n["Name"]:find("NeonShrinePart") then
								(replicated["Modules"]["Net"]:FindFirstChild("RE/TouchKitsuneStatue")):FireServer();
								repeat
									wait();
									_tp(n["CFrame"] * CFrame["new"](0, 2, 0));
								until _G["tweenShrine"] == false or not o;
							end;
						end;
					else
						_tp((workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Kitsune Island"))["CFrame"] * CFrame["new"](0, 500, 0));
					end;
				end);
			end;
		end;
	end);
	local If = t["SeaEvent"]:AddToggle("Q", { ["Title"] = "Auto Collect Azure Ember", ["Description"] = "", ["Default"] = false });
	If:OnChanged(function(o)
		_G["Collect_Ember"] = o;
	end);
	spawn(function()
		while wait(.1) do
			if _G["Collect_Ember"] then
				pcall(function()
					if workspace:WaitForChild("AttachedAzureEmber") or workspace:WaitForChild("EmberTemplate") then
						notween(((workspace:WaitForChild("EmberTemplate")):FindFirstChild("Part"))["CFrame"]);
					else
						_tp((workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Kitsune Island"))["CFrame"] * CFrame["new"](0, 500, 0));
						replicated["Modules"]["Net"]["RF/KitsuneStatuePray"]:InvokeServer();
					end;
				end);
			end;
		end;
	end);
	local Af = t["SeaEvent"]:AddToggle("Q", { ["Title"] = "Auto Trade Azure Ember", ["Description"] = "", ["Default"] = false });
	Af:OnChanged(function(o)
		_G["Trade_Ember"] = o;
	end);
	spawn(function()
		while wait(.1) do
			if _G["Trade_Ember"] then
				pcall(function()
					if workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Kitsune Island", true) then
						(replicated["Modules"]["Net"]:FindFirstChild("RF/KitsuneStatuePray")):InvokeServer();
					end;
				end);
			end;
		end;
	end);
	t["SeaEvent"]:AddButton({ ["Title"] = "Trade Items Azure", ["Description"] = "", ["Callback"] = function()
			(replicated["Modules"]["Net"]:FindFirstChild("RF/KitsuneStatuePray")):InvokeServer();
		end });
	t["SeaEvent"]:AddButton({ ["Title"] = "Talk with kitsune statue", ["Description"] = "", ["Callback"] = function()
			(replicated["Modules"]["Net"]:FindFirstChild("RE/TouchKitsuneStatue")):FireServer();
		end });
	t["Raids"]:AddSection("Dungeon Event / Raiding");
	local ff = t["Raids"]:AddParagraph({ ["Title"] = " Raiding Status ", ["Content"] = "" });
	spawn(function()
		while wait(.2) do
			pcall(function()
				if plr["PlayerGui"]["Main"]["Timer"]["Visible"] == true then
					ff:SetDesc(" Raiding Statud : True");
				else
					ff:SetDesc(" Raiding Statud : False");
				end;
			end);
		end;
	end);
	o = {
			"Flame",
			"Ice",
			"Quake",
			"Light",
			"Dark",
			"String",
			"Rumble",
			"Magma",
			"Human: Buddha",
			"Sand",
			"Bird: Phoenix",
			"Dough",
		};
	local zf = t["Raids"]:AddDropdown("Q", {
			["Title"] = "Select Chip",
			["Values"] = o,
			["Multi"] = false,
			["Default"] = 1,
		});
	zf:OnChanged(function(o)
		_G["SelectChip"] = o;
	end);
	local Nf = t["Raids"]:AddToggle("Q", { ["Title"] = "Auto Select Dungeon Chip", ["Description"] = "", ["Default"] = false });
	Nf:OnChanged(function(o)
		_G["AutoSelectDungeon"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["AutoSelectDungeon"] then
				pcall(function()
					if GetBP("Flame-Flame") then
						_G["SelectChip"] = "Flame";
					elseif GetBP("Ice-Ice") then
						_G["SelectChip"] = "Ice";
					elseif GetBP("Quake-Quake") then
						_G["SelectChip"] = "Quake";
					elseif GetBP("Light-Light") then
						_G["SelectChip"] = "Light";
					elseif GetBP("Dark-Dark") then
						_G["SelectChip"] = "Dark";
					elseif GetBP("String-String") then
						_G["SelectChip"] = "String";
					elseif GetBP("Rumble-Rumble") then
						_G["SelectChip"] = "Rumble";
					elseif GetBP("Magma-Magma") then
						_G["SelectChip"] = "Magma";
					elseif GetBP("Human-Human: Buddha Fruit") then
						_G["SelectChip"] = "Human: Buddha";
					elseif GetBP("Dough-Dough") then
						_G["SelectChip"] = "Dough";
					elseif GetBP("Sand-Sand") then
						_G["SelectChip"] = "Sand";
					elseif GetBP("Bird-Bird: Phoenix") then
						_G["SelectChip"] = "Bird: Phoenix";
					else
						_G["SelectChip"] = "Ice";
					end;
				end);
			end;
		end;
	end);
	t["Raids"]:AddButton({ ["Title"] = "Buy Dungeon Chips [Beli]", ["Description"] = "", ["Callback"] = function()
			if not GetBP("Special Microchip") then
				replicated["Remotes"]["CommF_"]:InvokeServer("RaidsNpc", "Select", _G["SelectChip"]);
			end;
		end });
	t["Raids"]:AddButton({ ["Title"] = "Buy Dungeon Chips [Devil Fruit]", ["Description"] = "Use your lowest fruit in your bag", ["Callback"] = function()
			if GetBP("Special Microchip") then
				return;
			end;
			local p = {};
			local n = {};
			for o, n in next, (replicated:WaitForChild("Remotes"))["CommF_"]:InvokeServer("GetFruits") do
				if n["Price"] <= 490000 then
					table["insert"](p, n["Name"]);
				end;
			end;
			for p, n in pairs(p) do
				for o, p in pairs(o) do
					if not GetBP("Special Microchip") then
						replicated["Remotes"]["CommF_"]:InvokeServer("LoadFruit", tostring(n));
						replicated["Remotes"]["CommF_"]:InvokeServer("RaidsNpc", "Select", _G["SelectChip"]);
					end;
				end;
			end;
		end });
	t["Raids"]:AddSection("Raiding Menu");
	local Ef = t["Raids"]:AddToggle("Q", { ["Title"] = "Auto Start Raid", ["Description"] = "", ["Default"] = false });
	Ef:OnChanged(function(o)
		_G["Auto_StartRaid"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Auto_StartRaid"] then
					if plr["PlayerGui"]["Main"]["TopHUDList"]["RaidTimer"]["Visible"] == false then
						if GetBP("Special Microchip") then
							if World2 then
								_tp(CFrame["new"](-6438.73535, 250.645355, -4501.50684));
								fireclickdetector(workspace["Map"]["CircleIsland"]["RaidSummon2"]["Button"]["Main"]["ClickDetector"]);
							elseif World3 then
								replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](-5097.93164, 316.447021, -3142.66602, -0.405007899, -4.31682743e-008, .914313197, -1.90943332e-008, 1, 3.8755779e-008, -0.914313197, -1.76180437e-009, -0.405007899));
								fireclickdetector(workspace["Map"]["Boat Castle"]["RaidSummon2"]["Button"]["Main"]["ClickDetector"]);
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	local Qf = t["Raids"]:AddToggle("Q", { ["Title"] = "Teleport To Lab", ["Description"] = "", ["Default"] = false });
	Qf:OnChanged(function(o)
		_G["TpLab"] = o;
		while _G["TpLab"] do
			wait(Sec);
			if _G["TpLab"] then
				if World2 and _G["TpLab"] then
					_tp(CFrame["new"](-6438.73535, 250.645355, -4501.50684));
				elseif World3 and _G["TpLab"] then
					_tp(CFrame["new"](-5017.40869, 314.844055, -2823.0127, -0.925743818, 4.48217499e-008, -0.378151238, 4.55503146e-009, 1, 1.07377559e-007, .378151238, 9.7681621e-008, -0.925743818));
				end;
			end;
		end;
	end);
	Qf = t["Raids"]:AddToggle("Q", { ["Title"] = "Auto Complete Raid [Safety]", ["Description"] = "", ["Default"] = false });
	Qf:OnChanged(function(o)
		_G["Raiding"] = o;
	end);
	spawn(function()
		pcall(function()
			while wait(Sec) do
				if _G["Raiding"] then
					if plr["PlayerGui"]["Main"]["TopHUDList"]["RaidTimer"]["Visible"] == true then
						local o = {
								"Island5",
								"Island 4",
								"Island 3",
								"Island 2",
								"Island 1",
							};
						for o, p in ipairs(o) do
							local n = (game:GetService("Workspace"))["_WorldOrigin"]["Locations"]:FindFirstChild(p);
							if n then
								for o, p in pairs(workspace["Enemies"]:GetChildren()) do
									if p:FindFirstChild("Humanoid") or p:FindFirstChild("HumanoidRootPart") then
										if p["Humanoid"]["Health"] > 0 then
											repeat
												wait();
												f["Kill"](p, _G["Raiding"]);
												NextIs = false;
											until not _G["Raiding"] or not p["Parent"] or p["Humanoid"]["Health"] <= 0;
											NextIs = true;
										end;
									end;
								end;
							end;
						end;
					else
						NextIs = false;
					end;
				else
					NextIs = false;
				end;
			end;
		end);
	end);
	local sf = t["Raids"]:AddToggle("Q", { ["Title"] = "Kill Aura", ["Description"] = "", ["Default"] = false });
	sf:OnChanged(function(o)
		_G["KillH"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["KillH"] then
				for o, p in pairs(workspace["Enemies"]:GetChildren()) do
					if f["Alive"](p) then
						pcall(function()
							repeat
								wait(Sec);
								sethiddenproperty(plr, "SimulationRadius", math["huge"]);
								p:BreakJoints();
								p["Humanoid"]["Health"] = 0;
								p["HumanoidRootPart"]["CanCollide"] = false;
							until not _G["KillH"] or not p["Parent"] or p["Humanoid"]["Health"] <= 0;
						end);
					end;
				end;
			end;
		end;
	end);
	local Jf = t["Raids"]:AddToggle("Q", { ["Title"] = "Auto Next Island", ["Description"] = "", ["Default"] = false });
	Jf:OnChanged(function(D)
		NextIs = D;
	end);
	spawn(function()
		while wait(Sec) do
			if NextIs then
				if plr["PlayerGui"]["Main"]["TopHUDList"]["RaidTimer"]["Visible"] == true then
					if workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Island 5") then
						_tp((workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Island 5"))["CFrame"] * CFrame["new"](0, 50, 100));
					elseif workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Island 4") then
						_tp((workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Island 4"))["CFrame"] * CFrame["new"](0, 50, 100));
					elseif workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Island 3") then
						_tp((workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Island 3"))["CFrame"] * CFrame["new"](0, 50, 100));
					elseif workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Island 2") then
						_tp((workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Island 2"))["CFrame"] * CFrame["new"](0, 50, 100));
					elseif workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Island 1") then
						_tp((workspace["_WorldOrigin"]["Locations"]:FindFirstChild("Island 1"))["CFrame"] * CFrame["new"](0, 50, 100));
					end;
				end;
			end;
		end;
	end);
	local tf = t["Raids"]:AddToggle("Q", { ["Title"] = "Auto Awakening", ["Description"] = "", ["Default"] = false });
	tf:OnChanged(function(o)
		_G["Auto_Awakener"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Auto_Awakener"] then
					replicated["Remotes"]["CommF_"]:InvokeServer("Awakener", "Check");
					replicated["Remotes"]["CommF_"]:InvokeServer("Awakener", "Awaken");
				end;
			end);
		end;
	end);
	t["Combat"]:AddSection("Combat / Aimbot");
	__indexPlayer = t["Combat"]:AddParagraph({ ["Title"] = "All Players On Server :", ["Content"] = "" });
	spawn(function()
		while wait(Sec) do
			pcall(function()
				for o, p in pairs((game:GetService("Players")):GetPlayers()) do
					if o == 12 then
						__indexPlayer:SetDesc("All Players :" .. (" " .. (o .. " / 12 [Max]")));
					elseif o == 1 then
						__indexPlayer:SetDesc("All Players  :" .. (" " .. (o .. " / 12")));
					else
						__indexPlayer:SetDesc("All Players  :" .. (" " .. (o .. " / 12")));
					end;
				end;
			end);
		end;
	end);
	__AimBotTurn = t["Combat"]:AddParagraph({ ["Title"] = "Aimbot Status :", ["Content"] = "" });
	local Bf = { "AimBots Skill", "Auto Aimbots" };
	Checking_AimStatus = function()
			if _G["AimCam"] then
				return "Aimbot Camera";
			else
				return "";
			end;
			if _G["AimbotGun"] then
				return "Aimbot Guns";
			else
				return "";
			end;
		end;
	spawn(function()
		while wait(.2) do
			pcall(function()
				if _G["AimMethod"] then
					__AimBotTurn:SetDesc("Aimbot - Skills : True");
				elseif (_G["AimCam"] or _G["AimbotGun"]) and _G["AimMethod"] then
					__AimBotTurn:SetDesc("Aimbot - Skills |" .. (Checking_AimStatus() .. " :True"));
				else
					__AimBotTurn:SetDesc("Aimbot - Skills : False");
				end;
			end);
		end;
	end);
	local Kf = {};
	for o, p in pairs((game:GetService("Players")):GetChildren()) do
		table["insert"](Kf, p["Name"]);
	end;
	local af = t["Combat"]:AddDropdown("SelectedPly", {
			["Title"] = "Choose Players",
			["Values"] = Kf,
			["Multi"] = false,
			["Default"] = 1,
		});
	af:OnChanged(function(o)
		_G["PlayersList"] = o;
	end);
	tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Teleport to choose players", ["Description"] = "", ["Default"] = false });
	tf:OnChanged(function(o)
		_G["TpPly"] = o;
		pcall(function()
			if _G["TpPly"] then
				repeat
					wait();
					_tp((game:GetService("Players"))[_G["PlayersList"]]["Character"]["HumanoidRootPart"]["CFrame"]);
				until not _G["TpPly"];
			end;
		end);
	end);
	tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Spectate Choose Players", ["Description"] = "", ["Default"] = false });
	tf:OnChanged(function(o)
		SpectatePlys = o;
		repeat
			task["wait"](.1);
			workspace["Camera"]["CameraSubject"] = ((game:GetService("Players")):FindFirstChild(_G["PlayersList"]))["Character"]["Humanoid"];
		until SpectatePlys == false;
		workspace["Camera"]["CameraSubject"] = plr["Character"]["Humanoid"];
	end);
	tf = t["Combat"]:AddDropdown("Q", {
			["Title"] = "Choose Aim Method",
			["Values"] = Bf,
			["Multi"] = false,
			["Default"] = 1,
		});
	tf:OnChanged(function(D)
		ABmethod = D;
	end);
	tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Aimbot Method Skills", ["Description"] = "", ["Default"] = false });
	tf:OnChanged(function(o)
		_G["AimMethod"] = o;
	end);
	task["spawn"](function()
		while task["wait"]() do
			pcall(function()
				if _G["AimMethod"] and ABmethod == "AimBots Skill" then
					for o, p in pairs((game:GetService("Players")):GetPlayers()) do
						if p["Name"] == _G["PlayersList"] and p["Team"] ~= game["Players"]["LocalPlayer"]["Team"] then
							MousePos = (p["Character"]:FindFirstChild("HumanoidRootPart"))["Position"];
						end;
					end;
				end;
			end);
		end;
	end);
	task["spawn"](function()
		while task["wait"]() do
			pcall(function()
				if _G["AimMethod"] and ABmethod == "Auto Aimbots" then
					local o = math["huge"];
					for p, n in pairs((game:GetService("Players")):GetPlayers()) do
						if n["Name"] ~= plr["Name"] and n["Team"] ~= game["Players"]["LocalPlayer"]["Team"] then
							local p = n:DistanceFromCharacter(plr["Character"]["HumanoidRootPart"]["Position"]);
							if p < o then
								o = p;
								MousePos = (n["Character"]:FindFirstChild("HumanoidRootPart"))["Position"];
							end;
						end;
					end;
				end;
			end);
		end;
	end);
	tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Aimbot Camera Closet Players", ["Description"] = "", ["Default"] = false });
	tf:OnChanged(function(o)
		_G["AimCam"] = o;
	end);
	task["spawn"](function()
		while task["wait"](Sec) do
			pcall(function()
				if _G["AimCam"] then
					local o = workspace["CurrentCamera"];
					closestplayer = function()
							local o = math["huge"];
							local p = nil;
							for n, e in next, ply:GetPlayers() do
								if e ~= plr then
									if e["Character"] and (e["Character"]:FindFirstChild("Head") and (_G["AimCam"] and e["Character"]["Humanoid"]["Health"] > 0)) then
										local n = (e["Character"]["Head"]["Position"] - plr["Character"]["Head"]["Position"])["Magnitude"];
										if n < o then
											o = n;
											p = e;
										end;
									end;
								end;
							end;
							return p;
						end;
					repeat
						task["wait"]();
						o["CFrame"] = CFrame["new"](o["CFrame"]["Position"], (closestplayer())["Character"]["HumanoidRootPart"]["Position"]);
					until _G["AimCam"] == false or Mag > dist;
				end;
			end);
		end;
	end);
	t["Combat"]:AddSection("LocalPlayer Settings / Misc");
	tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Instance Mink V3 [ INF ]", ["Description"] = "turn on for make mink v3 infinity", ["Default"] = false });
	tf:OnChanged(function(D)
		InfAblities = D;
	end);
	spawn(function()
		while wait(.2) do
			pcall(function()
				if InfAblities then
					if not plr["Character"]["HumanoidRootPart"]:FindFirstChild("Agility") then
						local o = replicated["FX"]["Agility"]:Clone();
						o["Name"] = "Agility";
						o["Parent"] = plr["Character"]["HumanoidRootPart"];
					end;
				else
					plr["Character"]["HumanoidRootPart"]["Agility"]:Destroy();
				end;
			end);
		end;
	end);
	tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Instance Energy [ INF ]", ["Description"] = "turn on for make energy infinity", ["Default"] = false });
	tf:OnChanged(function(o)
		infEnergy = o;
		if o then
			getInfinity_Ability("Energy", infEnergy);
		end;
	end);
	tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Instance Soru [ INF ]", ["Description"] = "turn on for make soru infinity", ["Default"] = false });
	tf:OnChanged(function(o)
		_G["InfSoru"] = o;
		if o then
			getInfinity_Ability("Soru", _G["InfSoru"]);
		end;
	end);
	tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Instance Observation Range [ INF ]", ["Description"] = "turn on for make observation range infinity", ["Default"] = false });
	tf:OnChanged(function(o)
		_G["InfiniteObRange"] = o;
		if o then
			getInfinity_Ability("Observation", _G["InfiniteObRange"]);
		end;
	end);
	t["Combat"]:AddSection("Settings Combat / Aimbot Settings");
	tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Ignore Same Teams", ["Description"] = "turn on for ignore not aimbot same team", ["Default"] = false });
	tf:OnChanged(function(o)
		_G["NoAimTeam"] = o;
	end);
	tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Accept Allies", ["Description"] = "turn on for auto accept ally", ["Default"] = false });
	tf:OnChanged(function(o)
		_G["AcceptAlly"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["AcceptAlly"] then
				pcall(function()
					for o, p in pairs(ply:GetChildren()) do
						if p["Name"] ~= plr["Name"] and (p:FindFirstChild("Humanoid") and p:FindFirstChild("HumanoidRootPart")) then
							((replicated:WaitForChild("Remotes")):WaitForChild("CommF_")):InvokeServer("AcceptAlly", p["Name"]);
						end;
					end;
				end);
			end;
		end;
	end);
	t["Combat"]:AddSection("Esp Items / Entity / Island");
	function isnil(D)
		return D == nil;
	end;
	local function hf(o)
		return math["floor"](tonumber(o) + .5);
	end;
	Number = math["random"](1, 1000000);
	EspPly = function()
			for o, p in next, game["Players"]:GetChildren() do
				pcall(function()
					if not isnil(p["Character"]) then
						if PlayerEsp then
							if not isnil(p["Character"]["Head"]) and not p["Character"]["Head"]:FindFirstChild("NameEsp" .. Number) then
								local o = Instance["new"]("BillboardGui", p["Character"]["Head"]);
								o["Name"] = "NameEsp" .. Number;
								o["ExtentsOffset"] = Vector3["new"](0, 1, 0);
								o["Size"] = UDim2["new"](1, 200, 1, 30);
								o["Adornee"] = p["Character"]["Head"];
								o["AlwaysOnTop"] = true;
								local n = Instance["new"]("TextLabel", o);
								n["Font"] = Enum["Font"]["Code"];
								n["FontSize"] = "Size14";
								n["TextWrapped"] = true;
								n["Text"] = p["Name"] .. (" \n" .. (hf(((game:GetService("Players"))["LocalPlayer"]["Character"]["Head"]["Position"] - p["Character"]["Head"]["Position"])["Magnitude"] / 3) .. " M"));
								n["Size"] = UDim2["new"](1, 0, 1, 0);
								n["TextYAlignment"] = "Top";
								n["BackgroundTransparency"] = 1;
								n["TextStrokeTransparency"] = .5;
								if p["Team"] == TeamSelf then
									n["TextColor3"] = Color3["new"](0, 0, 254);
								else
									n["TextColor3"] = Color3["new"](255, 0, 0);
								end;
							else
								p["Character"]["Head"]["NameEsp" .. Number]["TextLabel"]["Text"] = p["Data"]["Level"]["Value"] .. (" | " .. (p["Name"] .. (" | " .. (hf(((game:GetService("Players"))["LocalPlayer"]["Character"]["Head"]["Position"] - p["Character"]["Head"]["Position"])["Magnitude"] / 3) .. (" M\nHealth : " .. (hf((p["Character"]["Humanoid"]["Health"] * 100) / p["Character"]["Humanoid"]["MaxHealth"]) .. "%"))))));
							end;
						else
							if p["Character"]["Head"]:FindFirstChild("NameEsp" .. Number) then
								(p["Character"]["Head"]:FindFirstChild("NameEsp" .. Number)):Destroy();
							end;
						end;
					end;
				end);
			end;
		end;
	LocationEsp = function()
			for o, p in next, workspace["_WorldOrigin"]["Locations"]:GetChildren() do
				pcall(function()
					if IslandESP then
						if p["Name"] ~= "Sea" then
							if not p:FindFirstChild("NameEsp") then
								local o = Instance["new"]("BillboardGui", p);
								o["Name"] = "NameEsp";
								o["ExtentsOffset"] = Vector3["new"](0, 1, 0);
								o["Size"] = UDim2["new"](1, 200, 1, 30);
								o["Adornee"] = p;
								o["AlwaysOnTop"] = true;
								local n = Instance["new"]("TextLabel", o);
								n["Font"] = Enum["Font"]["Code"];
								n["FontSize"] = "Size14";
								n["TextWrapped"] = true;
								n["Size"] = UDim2["new"](1, 0, 1, 0);
								n["TextYAlignment"] = "Top";
								n["BackgroundTransparency"] = 1;
								n["TextStrokeTransparency"] = .5;
								n["TextColor3"] = Color3["fromRGB"](98, 252, 252);
							else
								p["NameEsp"]["TextLabel"]["Text"] = p["Name"] .. ("   \n" .. (hf(((game:GetService("Players"))["LocalPlayer"]["Character"]["Head"]["Position"] - p["Position"])["Magnitude"] / 3) .. " M"));
							end;
						end;
					else
						if p:FindFirstChild("NameEsp") then
							(p:FindFirstChild("NameEsp")):Destroy();
						end;
					end;
				end);
			end;
		end;
	DevEsp = function()
			for o, p in next, workspace:GetChildren() do
				pcall(function()
					if DevilFruitESP then
						if string["find"](p["Name"], "Fruit") then
							if not p["Handle"]:FindFirstChild("NameEsp" .. Number) then
								local o = Instance["new"]("BillboardGui", p["Handle"]);
								o["Name"] = "NameEsp" .. Number;
								o["ExtentsOffset"] = Vector3["new"](0, 1, 0);
								o["Size"] = UDim2["new"](1, 200, 1, 30);
								o["Adornee"] = p["Handle"];
								o["AlwaysOnTop"] = true;
								local n = Instance["new"]("TextLabel", o);
								n["Font"] = Enum["Font"]["Code"];
								n["FontSize"] = "Size14";
								n["TextWrapped"] = true;
								n["Size"] = UDim2["new"](1, 0, 1, 0);
								n["TextYAlignment"] = "Top";
								n["BackgroundTransparency"] = 1;
								n["TextStrokeTransparency"] = .5;
								n["TextColor3"] = Color3["fromRGB"](255, 255, 255);
								n["Text"] = p["Name"] .. (" \n" .. (hf(((game:GetService("Players"))["LocalPlayer"]["Character"]["Head"]["Position"] - p["Handle"]["Position"])["Magnitude"] / 3) .. " M"));
							else
								p["Handle"]["NameEsp" .. Number]["TextLabel"]["Text"] = "[" .. (p["Name"] .. ("]" .. ("   \n" .. (hf(((game:GetService("Players"))["LocalPlayer"]["Character"]["Head"]["Position"] - p["Handle"]["Position"])["Magnitude"] / 3) .. " M"))));
							end;
						end;
					else
						if p["Handle"]:FindFirstChild("NameEsp" .. Number) then
							(p["Handle"]:FindFirstChild("NameEsp" .. Number)):Destroy();
						end;
					end;
				end);
			end;
		end;
	flowerEsp = function()
			for o, p in pairs(workspace:GetChildren()) do
				pcall(function()
					if p["Name"] == "Flower2" or p["Name"] == "Flower1" then
						if FlowerESP then
							if not p:FindFirstChild("NameEsp" .. Number) then
								local o = Instance["new"]("BillboardGui", p);
								o["Name"] = "NameEsp" .. Number;
								o["ExtentsOffset"] = Vector3["new"](0, 1, 0);
								o["Size"] = UDim2["new"](1, 200, 1, 30);
								o["Adornee"] = p;
								o["AlwaysOnTop"] = true;
								local n = Instance["new"]("TextLabel", o);
								n["Font"] = Enum["Font"]["Code"];
								n["FontSize"] = "Size14";
								n["TextWrapped"] = true;
								n["Size"] = UDim2["new"](1, 0, 1, 0);
								n["TextYAlignment"] = "Top";
								n["BackgroundTransparency"] = 1;
								n["TextStrokeTransparency"] = .5;
								n["TextColor3"] = Color3["fromRGB"](88, 214, 252);
								if p["Name"] == "Flower1" then
									n["Text"] = "Blue Flower" .. (" \n" .. (hf(((game:GetService("Players"))["LocalPlayer"]["Character"]["Head"]["Position"] - p["Position"])["Magnitude"] / 3) .. " M"));
									n["TextColor3"] = Color3["fromRGB"](88, 214, 252);
								end;
								if p["Name"] == "Flower2" then
									n["Text"] = "Red Flower" .. (" \n" .. (hf(((game:GetService("Players"))["LocalPlayer"]["Character"]["Head"]["Position"] - p["Position"])["Magnitude"] / 3) .. " M"));
									n["TextColor3"] = Color3["fromRGB"](88, 214, 252);
								end;
							else
								p["NameEsp" .. Number]["TextLabel"]["Text"] = p["Name"] .. ("   \n" .. (hf(((game:GetService("Players"))["LocalPlayer"]["Character"]["Head"]["Position"] - p["Position"])["Magnitude"] / 3) .. " M"));
							end;
						else
							if p:FindFirstChild("NameEsp" .. Number) then
								(p:FindFirstChild("NameEsp" .. Number)):Destroy();
							end;
						end;
					end;
				end);
			end;
		end;
	EventIslandEsp = function()
			for o, p in pairs(workspace["_WorldOrigin"]["Locations"]:GetChildren()) do
				pcall(function()
					if EspEventIsland then
						if p["Name"] == "Mirage Island" or p["Name"] == "Prehistoric Island" or p["Name"] == "Kitsune Island" then
							if not p:FindFirstChild("NameEsp") then
								local o = Instance["new"]("BillboardGui", p);
								o["Name"] = "NameEsp";
								o["ExtentsOffset"] = Vector3["new"](0, 1, 0);
								o["Size"] = UDim2["new"](1, 200, 1, 30);
								o["Adornee"] = p;
								o["AlwaysOnTop"] = true;
								local n = Instance["new"]("TextLabel", o);
								n["Font"] = "Code";
								n["FontSize"] = "Size14";
								n["TextWrapped"] = true;
								n["Size"] = UDim2["new"](1, 0, 1, 0);
								n["TextYAlignment"] = "Top";
								n["BackgroundTransparency"] = 1;
								n["TextStrokeTransparency"] = .5;
								n["TextColor3"] = Color3["fromRGB"](80, 245, 245);
							else
								p["NameEsp"]["TextLabel"]["Text"] = p["Name"] .. ("   \n" .. (hf((plr["Character"]["Head"]["Position"] - p["Position"])["Magnitude"] / 3) .. " M"));
							end;
						end;
					elseif p:FindFirstChild("NameEsp") then
						(p:FindFirstChild("NameEsp")):Destroy();
					end;
				end);
			end;
		end;
	gearEsp = function()
			for o, p in pairs(workspace["Map"]["MysticIsland"]:GetDescendants()) do
				pcall(function()
					if ESPGear then
						if p["Name"] == "Part" and p["Material"] == Enum["Material"]["Neon"] then
							if not p:FindFirstChild("NameEsp") then
								local o = Instance["new"]("BillboardGui", p);
								o["Name"] = "NameEsp";
								o["ExtentsOffset"] = Vector3["new"](0, 1, 0);
								o["Size"] = UDim2["new"](1, 200, 1, 30);
								o["Adornee"] = p;
								o["AlwaysOnTop"] = true;
								local n = Instance["new"]("TextLabel", o);
								n["Font"] = "Code";
								n["FontSize"] = "Size14";
								n["TextWrapped"] = true;
								n["Size"] = UDim2["new"](1, 0, 1, 0);
								n["TextYAlignment"] = "Top";
								n["BackgroundTransparency"] = 1;
								n["TextStrokeTransparency"] = .5;
								n["TextColor3"] = Color3["fromRGB"](80, 245, 245);
							else
								p["NameEsp"]["TextLabel"]["Text"] = "Gear" .. ("   \n" .. (hf((plr["Character"]["Head"]["Position"] - p["Position"])["Magnitude"] / 3) .. " M"));
							end;
						end;
					else
						if p:FindFirstChild("NameEsp") then
							(p:FindFirstChild("NameEsp")):Destroy();
						end;
					end;
				end);
			end;
		end;
	AdvanFruitEsp = function()
			if advanEsp == true then
				for o, p in pairs(replicated["NPCs"]:GetChildren()) do
					if p["Name"] == "Advanced Fruit Dealer" then
						if not workspace:FindFirstChild("Adv") then
							Adv = Instance["new"]("Part");
							Adv["Name"] = "Adv";
							Adv["Transparency"] = 1;
							Adv["Size"] = Vector3["new"](1, 1, 1);
							Adv["Anchored"] = true;
							Adv["CanCollide"] = false;
							Adv["Parent"] = workspace;
							Adv["CFrame"] = p["HumanoidRootPart"]["CFrame"];
						elseif workspace:FindFirstChild("Adv") then
							if not Adv:FindFirstChild("NameEsp") then
								local o = Instance["new"]("BillboardGui", Adv);
								o["Name"] = "NameEsp";
								o["ExtentsOffset"] = Vector3["new"](0, 1, 0);
								o["Size"] = UDim2["new"](1, 200, 1, 30);
								o["Adornee"] = Adv;
								o["AlwaysOnTop"] = true;
								local p = Instance["new"]("TextLabel", o);
								p["Font"] = "Code";
								p["FontSize"] = "Size14";
								p["TextWrapped"] = true;
								p["Size"] = UDim2["new"](1, 0, 1, 0);
								p["TextYAlignment"] = "Top";
								p["BackgroundTransparency"] = 1;
								p["TextStrokeTransparency"] = .5;
								p["TextColor3"] = Color3["fromRGB"](80, 245, 245);
							else
								Adv["NameEsp"]["TextLabel"]["Text"] = p["Name"] .. ("   \n" .. (hf((plr["Character"]["Head"]["Position"] - p["HumanoidRootPart"]["Position"])["Magnitude"] / 3) .. " M"));
							end;
						end;
					end;
				end;
			else
				if workspace:FindFirstChild("Adv") then
					(workspace:FindFirstChild("Adv")):Destroy();
				end;
			end;
		end;
	HakiClorEsp = function()
			if ColorEsp == true then
				for o, p in pairs(replicated["NPCs"]:GetChildren()) do
					if p["Name"] == "Barista Cousin" then
						if not workspace:FindFirstChild("Gay") then
							Gay = Instance["new"]("Part");
							Gay["Name"] = "Gay";
							Gay["Transparency"] = 1;
							Gay["Size"] = Vector3["new"](1, 1, 1);
							Gay["Anchored"] = true;
							Gay["CanCollide"] = false;
							Gay["Parent"] = workspace;
							Gay["CFrame"] = p["HumanoidRootPart"]["CFrame"];
						elseif workspace:FindFirstChild("Gay") then
							if not Gay:FindFirstChild("NameEsp") then
								local o = Instance["new"]("BillboardGui", Gay);
								o["Name"] = "NameEsp";
								o["ExtentsOffset"] = Vector3["new"](0, 1, 0);
								o["Size"] = UDim2["new"](1, 200, 1, 30);
								o["Adornee"] = Gay;
								o["AlwaysOnTop"] = true;
								local p = Instance["new"]("TextLabel", o);
								p["Font"] = "Code";
								p["FontSize"] = "Size14";
								p["TextWrapped"] = true;
								p["Size"] = UDim2["new"](1, 0, 1, 0);
								p["TextYAlignment"] = "Top";
								p["BackgroundTransparency"] = 1;
								p["TextStrokeTransparency"] = .5;
								p["TextColor3"] = Color3["fromRGB"](80, 245, 245);
							else
								Gay["NameEsp"]["TextLabel"]["Text"] = p["Name"] .. ("   \n" .. (hf((plr["Character"]["Head"]["Position"] - p["HumanoidRootPart"]["Position"])["Magnitude"] / 3) .. " M"));
							end;
						end;
					end;
				end;
			else
				if workspace:FindFirstChild("Gay") then
					(workspace:FindFirstChild("Gay")):Destroy();
				end;
			end;
		end;
	LegenSword = function()
			if LegenS == true then
				for o, p in pairs(replicated["NPCs"]:GetChildren()) do
					if p["Name"] == "Legendary Sword Dealer " then
						if not workspace:FindFirstChild("Lgd") then
							Lgd = Instance["new"]("Part");
							Lgd["Name"] = "Lgd";
							Lgd["Transparency"] = 1;
							Lgd["Size"] = Vector3["new"](1, 1, 1);
							Lgd["Anchored"] = true;
							Lgd["CanCollide"] = false;
							Lgd["Parent"] = workspace;
							Lgd["CFrame"] = p["HumanoidRootPart"]["CFrame"];
						elseif workspace:FindFirstChild("Lgd") then
							if not Lgd:FindFirstChild("NameEsp") then
								local o = Instance["new"]("BillboardGui", Lgd);
								o["Name"] = "NameEsp";
								o["ExtentsOffset"] = Vector3["new"](0, 1, 0);
								o["Size"] = UDim2["new"](1, 200, 1, 30);
								o["Adornee"] = Lgd;
								o["AlwaysOnTop"] = true;
								local p = Instance["new"]("TextLabel", o);
								p["Font"] = "Code";
								p["FontSize"] = "Size14";
								p["TextWrapped"] = true;
								p["Size"] = UDim2["new"](1, 0, 1, 0);
								p["TextYAlignment"] = "Top";
								p["BackgroundTransparency"] = 1;
								p["TextStrokeTransparency"] = .5;
								p["TextColor3"] = Color3["fromRGB"](80, 245, 245);
							else
								Lgd["NameEsp"]["TextLabel"]["Text"] = p["Name"] .. ("   \n" .. (hf((plr["Character"]["Head"]["Position"] - p["HumanoidRootPart"]["Position"])["Magnitude"] / 3) .. " M"));
							end;
						end;
					end;
				end;
			else
				if workspace:FindFirstChild("Lgd") then
					(workspace:FindFirstChild("Lgd")):Destroy();
				end;
			end;
		end;
	ChestEsp = function()
			if ChestESP then
				local o = game:GetService("CollectionService");
				local p = game:GetService("Players");
				local n = p["LocalPlayer"];
				local e = n["Character"] or n["CharacterAdded"]:Wait();
				local U = (e:GetPivot())["Position"];
				local g = o:GetTagged("_ChestTagged");
				for o, p in ipairs(g) do
					local n = false;
					repeat
						if not SelectedIsland or p:IsDescendantOf(SelectedIsland) then
							if not p:GetAttribute("IsDisabled") then
								local o;
								local e, g = pcall(function()
										return (p:GetPivot())["Position"];
									end);
								if e then
									o = g;
								elseif p:IsA("BasePart") then
									o = p["Position"];
								else
									n = true;
									break;
								end;
								local Z = (o - U)["Magnitude"];
								local l = (p:GetFullName()):gsub("[^%w_]", "_");
								local W = p:FindFirstChild("ChestEspAttachment");
								if not W then
									local o = Instance["new"]("Attachment");
									o["Name"] = "ChestEspAttachment";
									o["Parent"] = p;
									o["Position"] = Vector3["new"](0, 3, 0);
									local n = Instance["new"]("BillboardGui");
									n["Name"] = "NameEsp";
									n["Size"] = UDim2["new"](0, 200, 0, 30);
									n["Adornee"] = o;
									n["ExtentsOffset"] = Vector3["new"](0, 1, 0);
									n["AlwaysOnTop"] = true;
									n["Parent"] = o;
									local e = Instance["new"]("TextLabel");
									e["Font"] = Enum["Font"]["Code"];
									e["TextSize"] = 14;
									e["TextWrapped"] = true;
									e["Size"] = UDim2["new"](1, 0, 1, 0);
									e["TextYAlignment"] = Enum["TextYAlignment"]["Top"];
									e["BackgroundTransparency"] = 1;
									e["TextStrokeTransparency"] = .5;
									e["TextColor3"] = Color3["fromRGB"](80, 245, 245);
									e["Parent"] = n;
								end;
								local Y = W and W:FindFirstChild("NameEsp");
								if Y then
									local o = math["floor"](Z / 3);
									local n = p["Name"]:gsub("Label", "");
									Y["TextLabel"]["Text"] = string["format"]("[%s] %d M", n, o);
								end;
								if _G_AutoFarmChest and Z <= 20 then
									if W then
										W:Destroy();
									end;
								end;
							end;
						end;
						n = true;
					until true;
					if not n then
						break;
					end;
				end;
			else
				for o, p in ipairs((game:GetService("CollectionService")):GetTagged("_ChestTagged")) do
					local n = p:FindFirstChild("ChestEspAttachment");
					if n then
						n:Destroy();
					end;
				end;
			end;
		end;
	berriesEsp = function()
			if BerryEsp then
				local o = game:GetService("CollectionService");
				local p = game:GetService("Players");
				local n = p["LocalPlayer"];
				local e = o:GetTagged("BerryBush");
				for o, p in ipairs(e) do
					local e = (p["Parent"]:GetPivot())["Position"];
					for o, p in pairs(p:GetAttributes()) do
						if p and (not BerryArray or table["find"](BerryArray, p)) then
							local o = "BerryEspPart_" .. (p .. ("_" .. tostring(e)));
							local U = workspace:FindFirstChild(o);
							if not U then
								U = Instance["new"]("Part");
								U["Name"] = o;
								U["Transparency"] = 1;
								U["Size"] = Vector3["new"](1, 1, 1);
								U["Anchored"] = true;
								U["CanCollide"] = false;
								U["Parent"] = workspace;
								U["CFrame"] = CFrame["new"](e);
							end;
							if not U:FindFirstChild("NameEsp") then
								local o = Instance["new"]("BillboardGui", U);
								o["Name"] = "NameEsp";
								o["ExtentsOffset"] = Vector3["new"](0, 1, 0);
								o["Size"] = UDim2["new"](0, 200, 0, 30);
								o["Adornee"] = U;
								o["AlwaysOnTop"] = true;
								local p = Instance["new"]("TextLabel", o);
								p["Font"] = Enum["Font"]["Code"];
								p["TextSize"] = 14;
								p["TextWrapped"] = true;
								p["Size"] = UDim2["new"](1, 0, 1, 0);
								p["TextYAlignment"] = Enum["TextYAlignment"]["Top"];
								p["BackgroundTransparency"] = 1;
								p["TextStrokeTransparency"] = .5;
								p["TextColor3"] = Color3["fromRGB"](80, 245, 245);
								p["Parent"] = o;
							end;
							local g = U:FindFirstChild("NameEsp");
							local Z = (n["Character"]["Head"]["Position"] - e)["Magnitude"] / 3;
							g["TextLabel"]["Text"] = "[" .. (p .. ("]" .. (" " .. (math["round"](Z) .. " M"))));
							if _G["AutoBerry"] and math["round"](Z) <= 20 then
								U:Destroy();
							end;
						end;
					end;
				end;
			else
				for o, p in ipairs(workspace:GetChildren()) do
					if p:IsA("Part") and p["Name"]:match("BerryEspPart_.*") then
						p:Destroy();
					end;
				end;
			end;
		end;
	tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Esp Berries", ["Description"] = "", ["Default"] = false });
	tf:OnChanged(function(D)
		BerryEsp = D;
		while BerryEsp do
			wait();
			berriesEsp();
		end;
	end);
	tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Esp Players", ["Description"] = "", ["Default"] = false });
	tf:OnChanged(function(D)
		PlayerEsp = D;
		while PlayerEsp do
			wait();
			EspPly();
		end;
	end);
	tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Esp Chests", ["Description"] = "", ["Default"] = false });
	tf:OnChanged(function(D)
		ChestESP = D;
		while ChestESP do
			wait();
			ChestEsp();
		end;
	end);
	tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Esp Fruits", ["Description"] = "", ["Default"] = false });
	tf:OnChanged(function(D)
		DevilFruitESP = D;
		while DevilFruitESP do
			wait();
			DevEsp();
		end;
	end);
	tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Esp Island Location", ["Description"] = "", ["Default"] = false });
	tf:OnChanged(function(D)
		IslandESP = D;
		while IslandESP do
			wait();
			LocationEsp();
		end;
	end);
	if World2 then
		tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Esp Flower", ["Description"] = "", ["Default"] = false });
		tf:OnChanged(function(D)
			FlowerESP = D;
			while FlowerESP do
				wait();
				flowerEsp();
			end;
		end);
		tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Esp Legendary Sword", ["Description"] = "", ["Default"] = false });
		tf:OnChanged(function(D)
			LegenS = D;
			while LegenS do
				wait();
				LegenSword();
			end;
		end);
	end;
	if World2 or World3 then
		tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Esp Aura Colour Dealers", ["Description"] = "", ["Default"] = false });
		tf:OnChanged(function(D)
			ColorEsp = D;
			while ColorEsp do
				wait();
				HakiClorEsp();
			end;
		end);
	end;
	if World3 then
		tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Esp Gears", ["Description"] = "", ["Default"] = false });
		tf:OnChanged(function(D)
			ESPGear = D;
			while ESPGear do
				wait();
				gearEsp();
			end;
		end);
		tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Esp SeaEvent Island", ["Description"] = "", ["Default"] = false });
		tf:OnChanged(function(D)
			EspEventIsland = D;
			while EspEventIsland do
				wait();
				EventIslandEsp();
			end;
		end);
		tf = t["Combat"]:AddToggle("Q", { ["Title"] = "Esp Advanced Fruits Dealer", ["Description"] = "", ["Default"] = false });
		tf:OnChanged(function(D)
			advanEsp = D;
			while advanEsp do
				wait();
				AdvanFruitEsp();
			end;
		end);
	end;
	t["Travel"]:AddSection("Travel - Worlds");
	t["Travel"]:AddButton({ ["Title"] = "Travel East Blue (World 1)", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("TravelMain");
		end });
	t["Travel"]:AddButton({ ["Title"] = "Travel Dressrosa (World 2)", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("TravelDressrosa");
		end });
	t["Travel"]:AddButton({ ["Title"] = "Travel Zou (World 3)", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("TravelZou");
		end });
	t["Travel"]:AddSection("Travel - Island");
	Location = {};
	for o, p in pairs(workspace["_WorldOrigin"]["Locations"]:GetChildren()) do
		table["insert"](Location, p["Name"]);
	end;
	Travelllll = t["Travel"]:AddDropdown("Travelllll", {
			["Title"] = "Select Travelling",
			["Values"] = Location,
			["Multi"] = false,
			["Default"] = 1,
		});
	Travelllll:OnChanged(function(o)
		_G["Island"] = o;
	end);
	GoIsland = t["Travel"]:AddToggle("GoIsland", { ["Title"] = "Auto Travel", ["Description"] = "Automatic teleport to pos island", ["Default"] = false });
	GoIsland:OnChanged(function(o)
		_G["Teleport"] = o;
		if o then
			for o, p in pairs(workspace["_WorldOrigin"]["Locations"]:GetChildren()) do
				if p["Name"] == _G["Island"] then
					repeat
						wait();
						_tp(p["CFrame"] * CFrame["new"](0, 30, 0));
					until not _G["Teleport"] or Root["CFrame"] == p["CFrame"];
				end;
			end;
		end;
	end);
	t["Travel"]:AddSection("Travel - Portal");
	if World1 then
		Location_Portal = { "Sky", "UnderWater" };
	elseif World2 then
		Location_Portal = { "SwanRoom", "Cursed Ship" };
	elseif World3 then
		Location_Portal = {
				"Castle On The Sea",
				"Mansion Cafe",
				"Hydra Teleport",
				"Canvendish Room",
				"Temple of Time",
			};
	end;
	PortalTP = t["Travel"]:AddDropdown("PortalTP", {
			["Title"] = "Select Portal",
			["Values"] = Location_Portal,
			["Multi"] = false,
			["Default"] = 1,
		});
	PortalTP:OnChanged(function(o)
		_G["Island_PT"] = o;
	end);
	t["Travel"]:AddButton({ ["Title"] = "requestEntrance", ["Description"] = "", ["Callback"] = function()
			if _G["Island_PT"] == "Sky" then
				replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](-7894, 5547, -380));
			elseif _G["Island_PT"] == "UnderWater" then
				replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](61163, 11, 1819));
			elseif _G["Island_PT"] == "SwanRoom" then
				replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](2285, 15, 905));
			elseif _G["Island_PT"] == "Cursed Ship" then
				replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](923, 126, 32852));
			elseif _G["Island_PT"] == "Castle On The Sea" then
				replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](-5097.93164, 316.447021, -3142.66602, -0.405007899, -4.31682743e-008, .914313197, -1.90943332e-008, 1, 3.8755779e-008, -0.914313197, -1.76180437e-009, -0.405007899));
			elseif _G["Island_PT"] == "Mansion Cafe" then
				replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](-12471.169921875, 374.94024658203, -7551.677734375));
			elseif _G["Island_PT"] == "Hydra Teleport" then
				replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](5643.4526367188, 1013.0858154297, -340.51025390625));
			elseif _G["Island_PT"] == "Canvendish Room" then
				replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](5314.5463867188, 22.562219619751, -127.06755065918));
			elseif _G["Island_PT"] == "Temple of Time" then
				replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](28310.0234, 14895.1123, 109.456741, -0.469690144, -2.85620132e-008, -0.882831335, -3.23509219e-008, 1, -1.51411736e-008, .882831335, 2.14487486e-008, -0.469690144));
			end;
		end });
	t["Travel"]:AddSection("Travel - NPCs");
	for o, p in pairs(replicated["NPCs"]:GetChildren()) do
		table["insert"](NPCList, p["Name"]);
	end;
	NPCsPos = t["Travel"]:AddDropdown("NPCsPos", {
			["Title"] = "Select NPCs",
			["Values"] = NPCList,
			["Multi"] = false,
			["Default"] = 1,
		});
	NPCsPos:OnChanged(function(D)
		NPClist = D;
	end);
	GoNPCs = t["Travel"]:AddToggle("GoNPCs", { ["Title"] = "Auto Tween to NPCs", ["Description"] = "Automatic teleport to pos Npcs", ["Default"] = false });
	GoNPCs:OnChanged(function(o)
		_G["TPNpc"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["TPNpc"] then
				pcall(function()
					for o, p in pairs(replicated["NPCs"]:GetChildren()) do
						if p["Name"] == NPClist then
							_tp(p["HumanoidRootPart"]["CFrame"]);
						end;
					end;
				end);
			end;
		end;
	end);
	t["Fruit"]:AddSection("Fruits Options");
	local Xf = {};
	local function df(o)
		local p = tostring(o);
		while true do
			p, k = p:gsub("^(-?%d+)(%d%d%d)", "%1,%2");
			if k == 0 then
				break;
			end;
		end;
		return p;
	end;
	for o, p in pairs(replicated["Remotes"]["CommF_"]:InvokeServer("GetFruits", true)) do
		if p["OnSale"] == true then
			local o = df(p["Price"]);
			local n = p["Name"];
			table["insert"](Xf, n);
		end;
	end;
	local Hf = {};
	for o, p in pairs(replicated["Remotes"]["CommF_"]:InvokeServer("GetFruits", false)) do
		if p["OnSale"] == true then
			local o = df(p["Price"]);
			local n = p["Name"];
			table["insert"](Hf, n);
		end;
	end;
	Sel_NFruit = t["Fruit"]:AddDropdown("Sel_NFruit", {
			["Title"] = "Select Fruit Stock",
			["Values"] = Hf,
			["Multi"] = false,
			["Default"] = 1,
		});
	Sel_NFruit:OnChanged(function(o)
		_G["SelectFruit"] = o;
	end);
	t["Fruit"]:AddButton({ ["Title"] = "Buy Basic Stock", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("PurchaseRawFruit", _G["SelectFruit"]);
		end });
	Sel_MFruit = t["Fruit"]:AddDropdown("Sel_MFruit", {
			["Title"] = "Select Mirage Fruit",
			["Values"] = Xf,
			["Multi"] = false,
			["Default"] = 1,
		});
	Sel_MFruit:OnChanged(function(D)
		SelectF_Adv = D;
	end);
	local Rf = {};
	for o, p in pairs(replicated["Remotes"]["CommF_"]:InvokeServer("GetFruits", false)) do
		if p["OnSale"] == true then
			local o = df(p["Price"]);
			local n = p["Name"];
			table["insert"](Rf, n);
		end;
	end;
	t["Fruit"]:AddButton({ ["Title"] = "Buy Mirage Stock", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("PurchaseRawFruit", SelectF_Adv);
		end });
	RandomFF = t["Fruit"]:AddToggle("RandomFF", { ["Title"] = "Auto Random Fruit", ["Description"] = "Automatic random devil fruit", ["Default"] = false });
	RandomFF:OnChanged(function(o)
		_G["Random_Auto"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["Random_Auto"] then
					replicated["Remotes"]["CommF_"]:InvokeServer("Cousin", "Buy");
				end;
			end);
		end;
	end);
	DropF = t["Fruit"]:AddToggle("DropF", { ["Title"] = "Auto Drop Fruit", ["Description"] = "Automatic drop devil fruit", ["Default"] = false });
	DropF:OnChanged(function(o)
		_G["DropFruit"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["DropFruit"] then
				pcall(function()
					DropFruits();
				end);
			end;
		end;
	end);
	StoredF = t["Fruit"]:AddToggle("StoredF", { ["Title"] = "Auto Store Fruit", ["Description"] = "Automatic store devil fruit", ["Default"] = false });
	StoredF:OnChanged(function(o)
		_G["StoreF"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["StoreF"] then
				pcall(function()
					UpdStFruit();
				end);
			end;
		end;
	end);
	TwF = t["Fruit"]:AddToggle("TwF", { ["Title"] = "Auto Tween to Fruit", ["Description"] = "Automatic tween to get devil fruit", ["Default"] = false });
	TwF:OnChanged(function(o)
		_G["TwFruits"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["TwFruits"] then
				pcall(function()
					for o, p in pairs(workspace:GetChildren()) do
						if string["find"](p["Name"], "Fruit") then
							_tp(p["Handle"]["CFrame"]);
						end;
					end;
				end);
			end;
		end;
	end);
	BringF = t["Fruit"]:AddToggle("BringF", { ["Title"] = "Auto Collect Fruit", ["Description"] = "Automatic bring devil fruit", ["Default"] = false });
	BringF:OnChanged(function(o)
		_G["InstanceF"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			if _G["InstanceF"] then
				pcall(function()
					collectFruits(_G["InstanceF"]);
				end);
			end;
		end;
	end);
	t["Shop"]:AddSection("Shop Options");
	t["Shop"]:AddButton({ ["Title"] = "Buy Buso", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyHaki", "Buso");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Geppo", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyHaki", "Geppo");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Soru", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyHaki", "Soru");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Ken", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("KenTalk", "Buy");
		end });
	t["Shop"]:AddSection("Fighting - Style");
	t["Shop"]:AddButton({ ["Title"] = "Buy Black Leg", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyBlackLeg");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Electro", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyElectro");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Fishman Karate", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyFishmanKarate");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy DragonClaw", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BlackbeardReward", "DragonClaw", "2");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Superhuman", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuySuperhuman");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Death Step", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyDeathStep");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Sharkman Karate", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuySharkmanKarate");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy ElectricClaw", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyElectricClaw");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy DragonTalon", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyDragonTalon");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Godhuman", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyGodhuman");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy SanguineArt", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuySanguineArt");
		end });
	t["Shop"]:AddSection("Accessory");
	t["Shop"]:AddButton({ ["Title"] = "Buy Tomoe Ring", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyItem", "Tomoe Ring");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Black Cape", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyItem", "Black Cape");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Swordsman Hat", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyItem", "Swordsman Hat");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Bizarre Rifle", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("Ectoplasm", "Buy", 1);
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Ghoul Mask", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("Ectoplasm", "Buy", 2);
		end });
	t["Shop"]:AddSection("Accessory SeaEvent");
	t["Shop"]:AddButton({ ["Title"] = "Craft Dragonheart", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("CraftItem", "Craft", "Dragonheart");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Craft Dragonstorm", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("CraftItem", "Craft", "Dragonstorm");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Craft DinoHood", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("CraftItem", "Craft", "DinoHood");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Craft SharkTooth", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("CraftItem", "Craft", "SharkTooth");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Craft TerrorJaw", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("CraftItem", "Craft", "TerrorJaw");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Craft SharkAnchor", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("CraftItem", "Craft", "SharkAnchor");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Craft LeviathanCrown", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("CraftItem", "Craft", "LeviathanCrown");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Craft LeviathanShield", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("CraftItem", "Craft", "LeviathanShield");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Craft LeviathanBoat", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("CraftItem", "Craft", "LeviathanBoat");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Craft LegendaryScroll", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("CraftItem", "Craft", "LegendaryScroll");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Craft MythicalScroll", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("CraftItem", "Craft", "MythicalScroll");
		end });
	t["Shop"]:AddSection("Weapon World1");
	t["Shop"]:AddButton({ ["Title"] = "Buy Cutlass", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyItem", "Cutlass");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Katana", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyItem", "Katana");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Iron Mace", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyItem", "Iron Mace");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Duel Katana", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyItem", "Duel Katana");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Triple Katana", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyItem", "Triple Katana");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Pipe", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyItem", "Pipe");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Dual-Headed Blade", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyItem", "Dual-Headed Blade");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Bisento", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyItem", "Bisento");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Soul Cane", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyItem", "Soul Cane");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Slingshot", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyItem", "Slingshot");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Musket", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyItem", "Musket");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Dual Flintlock", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyItem", "Dual Flintlock");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Flintlock", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyItem", "Flintlock");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Refined Flintlock", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyItem", "Refined Flintlock");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Cannon", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BuyItem", "Cannon");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Kabucha", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BlackbeardReward", "Slingshot", "2");
		end });
	t["Shop"]:AddSection("Fragments shop");
	t["Shop"]:AddButton({ ["Title"] = "Buy Refund Stats", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BlackbeardReward", "Refund", "2");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Reroll Race", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("BlackbeardReward", "Reroll", "2");
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Ghoul Race (2.5k)", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("Ectoplasm", " Change", 4);
		end });
	t["Shop"]:AddButton({ ["Title"] = "Buy Cyborg Race (2.5k)", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("CyborgTrainer", " Buy");
		end });
	t["Misc"]:AddSection("Server - Function");
	t["Misc"]:AddButton({ ["Title"] = "Rejoin Server", ["Description"] = "", ["Callback"] = function()
			(game:GetService("TeleportService")):Teleport(game["PlaceId"], game["Players"]["LocalPlayer"]);
		end });
	t["Misc"]:AddButton({ ["Title"] = "Hop Server", ["Description"] = "", ["Callback"] = function()
			Hop();
		end });
	t["Misc"]:AddButton({ ["Title"] = "Hop to Lowest Players", ["Description"] = "", ["Callback"] = function()
			local o = game:GetService("HttpService");
			local p = game:GetService("TeleportService");
			local n = "https://games.roblox.com/v1/games/";
			local e = game["PlaceId"];
			local U = n .. (e .. "/servers/Public?sortOrder=Asc&limit=100");
			function ListServers(p)
				local n = game:HttpGet(U .. (p and "&cursor=" .. p or ""));
				return o:JSONDecode(n);
			end;
			local g, Z;
			repeat
				local o = ListServers(Z);
				g = o["data"][1];
				Z = o["nextPageCursor"];
			until g;
			p:TeleportToPlaceInstance(e, g["id"], plr);
		end });
	t["Misc"]:AddButton({ ["Title"] = "Hop to Lowest Pings Server", ["Description"] = "", ["Callback"] = function()
			local o = game:GetService("HttpService");
			local p = game:GetService("TeleportService");
			local n = game:GetService("Stats");
			local function e(p, n)
				local e = string["format"]("https://games.roblox.com/v1/games/%d/servers/Public?limit=%d", p, n);
				local U, g = pcall(function()
						return o:JSONDecode(game:HttpGet(e));
					end);
				if U and (g and g["data"]) then
					return g["data"];
				end;
				return nil;
			end;
			local U = game["PlaceId"];
			local g = 100;
			local Z = e(U, g);
			if not Z then
				return;
			end;
			local l = Z[1];
			for o, p in pairs(Z) do
				if p["ping"] < l["ping"] and p["maxPlayers"] > p["playing"] then
					l = p;
				end;
			end;
			local W = .5;
			task["wait"](W);
			local Y = 100;
			local I = n["Network"]["ServerStatsItem"];
			local A = I["Data Ping"]:GetValueString();
			local f = tonumber(A:match("(%d+)"));
			if f >= Y then
				p:TeleportToPlaceInstance(U, l["id"]);
			else
 
			end;
		end });
	local Pf = t["Misc"]:AddInput("JobID", {
			["Title"] = "JobID",
			["Default"] = "",
			["Placeholder"] = "",
			["Numeric"] = false,
			["Finished"] = false,
			["Callback"] = function(o)
				_G["JobId"] = o;
			end,
		});
	spawn(function()
		while wait(Sec) do
			if _G["JobId"] then
				pcall(function()
					local o;
					o = plr["OnTeleport"]:Connect(function(p)
							if p == Enum["TeleportState"]["Failed"] then
								o:Disconnect();
								if workspace:FindFirstChild("Message") then
									workspace["Message"]:Destroy();
								end;
							end;
						end);
				end);
			end;
		end;
	end);
	t["Misc"]:AddButton({ ["Title"] = "Teleport [Job ID]", ["Description"] = "", ["Callback"] = function()
			replicated["__ServerBrowser"]:InvokeServer("teleport", _G["JobId"]);
		end });
	t["Misc"]:AddButton({ ["Title"] = "Copy JobID", ["Description"] = "", ["Callback"] = function()
			setclipboard(tostring(game["JobId"]));
		end });
	t["Misc"]:AddSection("Player Gui / Others");
	t["Misc"]:AddButton({ ["Title"] = "Open Awakenings Expert", ["Description"] = "", ["Callback"] = function()
			plr["PlayerGui"]["Main"]["AwakeningToggler"]["Visible"] = true;
		end });
	t["Misc"]:AddButton({ ["Title"] = "Open Title Selection", ["Description"] = "", ["Callback"] = function()
			replicated["Remotes"]["CommF_"]:InvokeServer("getTitles", true);
			plr["PlayerGui"]["Main"]["Titles"]["Visible"] = true;
		end });
	DisbleChat = t["Misc"]:AddToggle("DisbleChat", { ["Title"] = "Disable Chat GUI", ["Description"] = "", ["Default"] = false });
	DisbleChat:OnChanged(function(o)
		_G["Rechat"] = o;
		if _G["Rechat"] == true then
			local o = game:GetService("StarterGui");
			o:SetCoreGuiEnabled(Enum["CoreGuiType"]["Chat"], false);
		elseif _G["chat"] == false then
			local o = game:GetService("StarterGui");
			o:SetCoreGuiEnabled(Enum["CoreGuiType"]["Chat"], true);
		end;
	end);
	DisbleLeaderB = t["Misc"]:AddToggle("DisbleLeaderB", { ["Title"] = "Disable Leader Board GUI", ["Description"] = "", ["Default"] = false });
	DisbleLeaderB:OnChanged(function(o)
		ReLeader = o;
		if ReLeader == true then
			local o = game:GetService("StarterGui");
			o:SetCoreGuiEnabled(Enum["CoreGuiType"]["PlayerList"], false);
		elseif ReLeader == false then
			local o = game:GetService("StarterGui");
			o:SetCoreGuiEnabled(Enum["CoreGuiType"]["PlayerList"], true);
		end;
	end);
	t["Misc"]:AddButton({ ["Title"] = "Set Pirate Team", ["Description"] = "", ["Callback"] = function()
			Pirates();
		end });
	t["Misc"]:AddButton({ ["Title"] = "Set Marine Team", ["Description"] = "", ["Callback"] = function()
			Marines();
		end });
	UnPortal = t["Misc"]:AddToggle("UnPortal", { ["Title"] = "Unlock All Portals", ["Description"] = "unlocked portal for who doesn't defeat rip_indra", ["Default"] = false });
	UnPortal:OnChanged(function(o)
		_G["PortalUnLock"] = o;
	end);
	spawn(function()
		while wait(Sec) do
			pcall(function()
				if _G["PortalUnLock"] then
					if f["Pos"](CstlePos_Miti, 8) then
						replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](-12471.169921875, 374.94024658203, -7551.677734375));
					elseif f["Pos"](Man3Pos_Miti, 8) then
						replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](-5072.08984375, 314.5412902832, -3151.1098632812));
					elseif f["Pos"](HydraPos_Miti, 8) then
						replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](5748.7587890625, 610.44982910156, -267.81704711914));
					elseif f["Pos"](HydratoCastle, 8) then
						replicated["Remotes"]["CommF_"]:InvokeServer("requestEntrance", Vector3["new"](-5072.08984375, 314.5412902832, -3151.1098632812));
					end;
				end;
			end);
		end;
	end);
	t["Misc"]:AddSection("Graphics / Haki Stats");
	HakiSt = {
			"State 0",
			"State 1",
			"State 2",
			"State 3",
			"State 4",
			"State 5",
		};
	HakiStat = t["Misc"]:AddDropdown("HakiStat", {
			["Title"] = "Select Haki States",
			["Values"] = HakiSt,
			["Multi"] = false,
			["Default"] = 1,
		});
	HakiStat:OnChanged(function(o)
		_G["SelectStateHaki"] = o;
	end);
	t["Misc"]:AddButton({ ["Title"] = "ChangeBusoStage", ["Description"] = "", ["Callback"] = function()
			if _G["SelectStateHaki"] == "State 0" then
				replicated["Remotes"]["CommF_"]:InvokeServer("ChangeBusoStage", 0);
			elseif _G["SelectStateHaki"] == "State 1" then
				replicated["Remotes"]["CommF_"]:InvokeServer("ChangeBusoStage", 1);
			elseif _G["SelectStateHaki"] == "State 2" then
				replicated["Remotes"]["CommF_"]:InvokeServer("ChangeBusoStage", 2);
			elseif _G["SelectStateHaki"] == "State 3" then
				replicated["Remotes"]["CommF_"]:InvokeServer("ChangeBusoStage", 3);
			elseif _G["SelectStateHaki"] == "State 4" then
				replicated["Remotes"]["CommF_"]:InvokeServer("ChangeBusoStage", 4);
			elseif _G["SelectStateHaki"] == "State 5" then
				replicated["Remotes"]["CommF_"]:InvokeServer("ChangeBusoStage", 5);
			end;
		end });
	rtxM = t["Misc"]:AddToggle("rtxM", { ["Title"] = "Turn on RTX Mode", ["Description"] = "", ["Default"] = false });
	rtxM:OnChanged(function(o)
		_G["RTXMode"] = o;
		local p = game["Lighting"];
		local n = Instance["new"]("ColorCorrectionEffect", p);
		local e = Instance["new"]("ColorCorrectionEffect", p);
		OldAmbient = p["Ambient"];
		OldBrightness = p["Brightness"];
		OldColorShift_Top = p["ColorShift_Top"];
		OldBrightnessc = n["Brightness"];
		OldContrastc = n["Contrast"];
		OldTintColorc = n["TintColor"];
		OldTintColore = e["TintColor"];
		if not _G["RTXMode"] then
			return;
		end;
		while _G["RTXMode"] do
			wait();
			p["Ambient"] = Color3["fromRGB"](33, 33, 33);
			p["Brightness"] = .3;
			n["Brightness"] = .176;
			n["Contrast"] = .39;
			n["TintColor"] = Color3["fromRGB"](217, 145, 57);
			game["Lighting"]["FogEnd"] = 999;
			if not plr["Character"]["HumanoidRootPart"]:FindFirstChild("PointLight") then
				local o = Instance["new"]("PointLight");
				o["Parent"] = plr["Character"]["HumanoidRootPart"];
				o["Range"] = 15;
				o["Color"] = Color3["fromRGB"](217, 145, 57);
			end;
			if not _G["RTXMode"] then
				p["Ambient"] = OldAmbient;
				p["Brightness"] = OldBrightness;
				p["ColorShift_Top"] = OldColorShift_Top;
				n["Contrast"] = OldContrastc;
				n["Brightness"] = OldBrightnessc;
				n["TintColor"] = OldTintColorc;
				e["TintColor"] = OldTintColore;
				game["Lighting"]["FogEnd"] = 2500;
				(plr["Character"]["HumanoidRootPart"]:FindFirstChild("PointLight")):Destroy();
			end;
		end;
	end);
	t["Misc"]:AddButton({ ["Title"] = "Turn on Fast Mode", ["Description"] = "", ["Callback"] = function()
			for o, p in next, workspace:GetDescendants() do
				if table["find"](e, p["ClassName"]) then
					p["Material"] = "Plastic";
				end;
			end;
		end });
	t["Misc"]:AddButton({ ["Title"] = "Turn on Low CPU", ["Description"] = "", ["Callback"] = function()
			LowCpu();
		end });
	t["Misc"]:AddButton({ ["Title"] = "Turn on increase Boats", ["Description"] = "", ["Callback"] = function()
			for o, p in pairs(workspace["Boats"]:GetDescendants()) do
				if table["find"](Df, p["Name"]) and tostring(p["Owner"]["Value"]) == tostring(plr["Name"]) then
					p["VehicleSeat"]["MaxSpeed"] = 350;
					p["VehicleSeat"]["Torque"] = .2;
					p["VehicleSeat"]["TurnSpeed"] = 5;
					p["VehicleSeat"]["HeadsUpDisplay"] = true;
				end;
			end;
		end });
	t["Misc"]:AddButton({ ["Title"] = "Remove Sky Fog", ["Description"] = "", ["Callback"] = function()
			if Lighting:FindFirstChild("LightingLayers") then
				Lighting["LightingLayers"]:Destroy();
			end;
			if Lighting:FindFirstChild("SeaTerrorCC") then
				Lighting["SeaTerrorCC"]:Destroy();
			end;
			if Lighting:FindFirstChild("FantasySky") then
				Lighting["FantasySky"]:Destroy();
			end;
		end });
	t["Misc"]:AddSection("Configure - God");
	t["Misc"]:AddButton({ ["Title"] = "Rain Fruits (Client)", ["Description"] = "", ["Callback"] = function()
			for o, p in pairs((game:GetObjects("rbxassetid://14759368201"))[1]:GetChildren()) do
				p["Parent"] = game["Workspace"]["Map"];
				p:MoveTo(plr["Character"]["PrimaryPart"]["Position"] + Vector3["new"](math["random"](-50, 50), 100, math["random"](-50, 50)));
				if p["Fruit"]:FindFirstChild("AnimationController") then
					((p["Fruit"]:FindFirstChild("AnimationController")):LoadAnimation(p["Fruit"]:FindFirstChild("Idle"))):Play();
				end;
				p["Handle"]["Touched"]:Connect(function(o)
					if o["Parent"] == plr["Character"] then
						p["Parent"] = plr["Backpack"];
						plr["Character"]["Humanoid"]:EquipTool(p);
					end;
				end);
			end;
		end });
	briggt1 = t["Misc"]:AddToggle("briggt1", { ["Title"] = "Turn on Full Bright", ["Description"] = "", ["Default"] = false });
	briggt1:OnChanged(function(o)
		bright = o;
		if o == true then
			Lighting["Ambient"] = Color3["new"](1, 1, 1);
			Lighting["ColorShift_Bottom"] = Color3["new"](1, 1, 1);
			Lighting["ColorShift_Top"] = Color3["new"](1, 1, 1);
		else
			Lighting["Ambient"] = Color3["new"](0, 0, 0);
			Lighting["ColorShift_Bottom"] = Color3["new"](0, 0, 0);
			Lighting["ColorShift_Top"] = Color3["new"](0, 0, 0);
		end;
	end);
	Cheat_DayNight = { "Day", "Night" };
	DayN = t["Misc"]:AddDropdown("DayN", {
			["Title"] = "Select Time",
			["Values"] = Cheat_DayNight,
			["Multi"] = false,
			["Default"] = 1,
		});
	DayN:OnChanged(function(o)
		_G["SelectDN"] = o;
	end);
	dayornight = t["Misc"]:AddToggle("dayornight", { ["Title"] = "Turn on Time", ["Description"] = "", ["Default"] = false });
	dayornight:OnChanged(function(o)
		_G["daylightN"] = o;
	end);
	task["spawn"](function()
		while task["wait"]() do
			if _G["daylightN"] then
				if _G["SelectDN"] == "Day" then
					Lighting["ClockTime"] = 12;
				elseif _G["SelectDN"] == "Night" then
					Lighting["ClockTime"] = 0;
				end;
			end;
		end;
	end);
	walkWater = t["Misc"]:AddToggle("walkWater", { ["Title"] = "Turn on Walk on Water", ["Description"] = "walk on water", ["Default"] = true });
	walkWater:OnChanged(function(o)
		_G["WalkWater_Part"] = o;
		if _G["WalkWater_Part"] then
			(game:GetService("Workspace"))["Map"]["WaterBase-Plane"]["Size"] = Vector3["new"](1000, 112, 1000);
		else
			(game:GetService("Workspace"))["Map"]["WaterBase-Plane"]["Size"] = Vector3["new"](1000, 80, 1000);
		end;
	end);
	iceWalk = t["Misc"]:AddToggle("iceWalk", { ["Title"] = "Turn on Ice Walk", ["Description"] = "Ice walk just like walk on water but have ice effect", ["Default"] = false });
	iceWalk:OnChanged(function(o)
		_G["WalkWater"] = o;
	end);
	spawn(function()
		while task["wait"]() do
			if _G["WalkWater"] then
				pcall(function()
					if plr["Character"] and plr["Character"]:FindFirstChild("LeftFoot") then
						local o = replicated["Assets"]["Models"]["IceSpikes4"]:Clone();
						o["Parent"] = workspace;
						o["Size"] = Vector3["new"](3 + math["random"](10, 12), 1.7, 3 + math["random"](10, 12));
						o["Color"] = Color3["fromRGB"](128, 187, 219);
						o["CFrame"] = CFrame["new"](plr["Character"]["Head"]["Position"]["X"], -3.8, plr["Character"]["Head"]["Position"]["Z"]) * CFrame["Angles"]((math["random"]() - .5) * .06, math["random"]() * 7, (math["random"]() - .5) * .07);
						local p = {};
						p["Size"] = Vector3["new"](0, .3, 0);
						local n = TW:Create(o, TweenInfo["new"](2, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["In"]), p);
						n["Completed"]:Connect(function()
							o:Destroy();
						end);
						n:Play();
					end;
				end);
			end;
		end;
	end);
	local bf = game["Players"]["LocalPlayer"];
	local function Of(o)
		if not o then
			return false;
		end;
		local p = o:FindFirstChild("Humanoid");
		return p and p["Health"] > 0;
	end;
	local function jf(o, p)
		local n = (game:GetService("Workspace"))["Enemies"]:GetChildren();
		local e = (game:GetService("Players")):GetPlayers();
		local U = {};
		local g = (o:GetPivot())["Position"];
		for o, n in ipairs(n) do
			local e = n:FindFirstChild("HumanoidRootPart");
			if e and Of(n) then
				local o = (e["Position"] - g)["Magnitude"];
				if o <= p then
					table["insert"](U, n);
				end;
			end;
		end;
		for o, n in ipairs(e) do
			if n ~= bf and n["Character"] then
				local o = n["Character"]:FindFirstChild("HumanoidRootPart");
				if o and Of(n["Character"]) then
					local e = (o["Position"] - g)["Magnitude"];
					if e <= p then
						table["insert"](U, n["Character"]);
					end;
				end;
			end;
		end;
		return U;
	end;
	function AttackNoCoolDown()
		local o = (game:GetService("Players"))["LocalPlayer"];
		local p = o["Character"];
		if not p then
			return;
		end;
		local n = nil;
		for o, p in ipairs(p:GetChildren()) do
			if p:IsA("Tool") then
				n = p;
				break;
			end;
		end;
		if not n then
			return;
		end;
		local e = jf(p, 60);
		if #e == 0 then
			return;
		end;
		local U = game:GetService("ReplicatedStorage");
		local g = U:FindFirstChild("Modules");
		if not g then
			return;
		end;
		local Z = ((U:WaitForChild("Modules")):WaitForChild("Net")):WaitForChild("RE/RegisterAttack");
		local l = ((U:WaitForChild("Modules")):WaitForChild("Net")):WaitForChild("RE/RegisterHit");
		if not Z or not l then
			return;
		end;
		local W, Y = {}, nil;
		for o, p in ipairs(e) do
			if not p:GetAttribute("IsBoat") then
				local o = {
						"RightLowerArm",
						"RightUpperArm",
						"LeftLowerArm",
						"LeftUpperArm",
						"RightHand",
						"LeftHand",
					};
				local n = p:FindFirstChild(o[math["random"](#o)]) or p["PrimaryPart"];
				if n then
					table["insert"](W, { p, n });
					Y = n;
				end;
			end;
		end;
		if not Y then
			return;
		end;
		Z:FireServer(0);
		local I = o:FindFirstChild("PlayerScripts");
		if not I then
			return;
		end;
		local A = I:FindFirstChildOfClass("LocalScript");
		while not A do
			I["ChildAdded"]:Wait();
			A = I:FindFirstChildOfClass("LocalScript");
		end;
		local f;
		if getsenv then
			local o, p = pcall(getsenv, A);
			if o and p then
				f = p["_G"]["SendHitsToServer"];
			end;
		end;
		local z, N = pcall(function()
				return (require(g["Flags"]))["COMBAT_REMOTE_THREAD"] or false;
			end);
		if z and (N and f) then
			f(Y, W);
		elseif z and not N then
			l:FireServer(Y, W);
		end;
	end;
	CameraShakerR = require(game["ReplicatedStorage"]["Util"]["CameraShaker"]);
	CameraShakerR:Stop();
	get_Monster = function()
			for o, p in pairs(workspace["Enemies"]:GetChildren()) do
				local n = p:FindFirstChild("UpperTorso") or p:FindFirstChild("Head");
				if p:FindFirstChild("HumanoidRootPart", true) and n then
					if (p["Head"]["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 50 then
						return true, n["Position"];
					end;
				end;
			end;
			for o, p in pairs(workspace["SeaBeasts"]:GetChildren()) do
				if p:FindFirstChild("HumanoidRootPart") and (p:FindFirstChild("Health") and p["Health"]["Value"] > 0) then
					return true, p["HumanoidRootPart"]["Position"];
				end;
			end;
			for o, p in pairs(workspace["Enemies"]:GetChildren()) do
				if p:FindFirstChild("Health") and (p["Health"]["Value"] > 0 and p:FindFirstChild("VehicleSeat")) then
					return true, p["Engine"]["Position"];
				end;
			end;
		end;
	Actived = function()
			local o = game["Players"]["LocalPlayer"]["Character"]:FindFirstChildOfClass("Tool");
			for o, p in next, getconnections(o["Activated"]) do
				if typeof(p["Function"]) == "function" then
					getupvalues(p["Function"]);
				end;
			end;
		end;
	task["spawn"](function()
		RunSer["Heartbeat"]:Connect(function()
			pcall(function()
				if not _G["Seriality"] then
					return;
				end;
				AttackNoCoolDown();
				local o = game["Players"]["LocalPlayer"]["Character"]:FindFirstChildOfClass("Tool");
				local p = o["ToolTip"];
				local n, e = get_Monster();
				if p == "Blox Fruit" then
					if n then
						local p = o:FindFirstChild("LeftClickRemote");
						if p then
							Actived();
							p:FireServer(Vector3["new"](.01, -500, .01), 1, true);
							p:FireServer(false);
						end;
					end;
				end;
			end);
		end);
	end);
	local wf = game:GetService("UserInputService");
	local Gf = game:GetService("UserInputService");
	local Tf = Instance["new"]("ScreenGui");
	Tf["Name"] = "ControlGUI";
	Tf["Parent"] = game["CoreGui"];
	local rf = Instance["new"]("ImageButton");
	rf["Size"] = UDim2["new"](0, 55, 0, 55);
	rf["Position"] = UDim2["new"](.15, 0, .15, 0);
	rf["Image"] = "rbxassetid://125868498014025";
	rf["ScaleType"] = Enum["ScaleType"]["Fit"];
	rf["BackgroundColor3"] = Color3["fromRGB"](25, 25, 25);
	rf["BorderSizePixel"] = 0;
	rf["Parent"] = Tf;
	local Ff = Instance["new"]("UICorner");
	Ff["CornerRadius"] = UDim["new"](1, 0);
	Ff["Parent"] = rf;
	local cf = false;
	local uf, kf;
	local yf;
	local function mf(o)
		local p = o["Position"] - uf;
		rf["Position"] = UDim2["new"](kf["X"]["Scale"], kf["X"]["Offset"] + p["X"], kf["Y"]["Scale"], kf["Y"]["Offset"] + p["Y"]);
	end;
	rf["InputBegan"]:Connect(function(o)
		if o["UserInputType"] == Enum["UserInputType"]["MouseButton1"] or o["UserInputType"] == Enum["UserInputType"]["Touch"] then
			cf = true;
			uf = o["Position"];
			kf = rf["Position"];
			yf = Gf["InputChanged"]:Connect(function(o)
					if (o["UserInputType"] == Enum["UserInputType"]["MouseMovement"] or o["UserInputType"] == Enum["UserInputType"]["Touch"]) and cf then
						mf(o);
					end;
				end);
			o["Changed"]:Connect(function()
				if o["UserInputState"] == Enum["UserInputState"]["End"] then
					cf = false;
					if yf then
						yf:Disconnect();
						yf = nil;
					end;
				end;
			end);
		end;
	end);
	local xf = false;
	rf["MouseButton1Click"]:Connect(function()
		xf = not xf;
		if J then
			if xf then
				J:Minimize(false);
			else
				J:Minimize(true);
			end;
		end;
	end);
end)(...);
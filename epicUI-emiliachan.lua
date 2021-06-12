local colorvar = "hpapcolor"
local rainbowvar
Menu.Separator()
Menu.Text("epicUI by emilia-chan")
Menu.Spacing()
Menu.Spacing()
Menu.Text("Dont reload the lua or it will crash!")
Menu.Text("Unload and load instead!")
Menu.Spacing()
Menu.Spacing()
Menu.Checkbox("UI enable","b_Enabledui", true)
Menu.Spacing()
Menu.Checkbox("Disable Default GameUI", "cToggleDefault", true)
Menu.Spacing()
Menu.Checkbox("Enable Profile Picture","b_enableprofilepic", true)
Menu.Spacing()
if Menu.GetBool("b_enableprofilepic") then
    Menu.InputText("Profile picture url: ", "s_url", "https://cdn.discordapp.com/attachments/301017663159664640/730310414096924732/background.png")
    Menu.Spacing()
    Menu.Checkbox("Get/Update Profile Picture", "b_pfp", false)
    Menu.Spacing()
end
Menu.Checkbox("Perfect Bhop Indicator", "b_bhopind", true)
Menu.Text("Indicator Size")
Menu.InputInt("Size", "i_indsize", 25)
Menu.Spacing()
Menu.ColorPicker("Indicator color", "c_indcolor", 0, 255, 0, 255)
Menu.Spacing()
Menu.Spacing()
Menu.SliderFloat("Money Display Height", "f_moneyheight", 0, 1,"%.05f", 0.4)
Menu.Spacing()
Menu.Checkbox("High score warning", "b_scorewarning", true)
Menu.Spacing()
Menu.InputInt("Warning if > x", "i_scoretrigger", 85)
Menu.Spacing()
Menu.Spacing()
Menu.Spacing()
Menu.Spacing()
Menu.Checkbox("Speed Counter", "b_counterenable", false)
Menu.Spacing()
Menu.SliderFloat("Counter posX", "f_counterx", 0, 1,"%.05f", 0.5)
Menu.SliderFloat("Counter posY", "f_countery", 0, 1,"%.05f", 0.8)
Menu.Spacing()
Menu.Spacing()
Menu.Text("Color Picker")
Menu.Combo("Items","com_items", {"HP and AP","Score Warning", "Weapon and Ammo", "Armor bar", "Background bar","Pfp background","Pfp border and name", "Money", "Player stats", "Ping and FPS", "Player counter", "Dead HUD", "Speed counter"}, 0)
Menu.ColorPicker("Color", "c_color", 255,255,255,255)
Menu.Checkbox("Rainbow", "b_rainbow", false)
Menu.Spacing()
Menu.Spacing()
Menu.Spacing()
Menu.Spacing()
Menu.Checkbox("Gay mode", "b_gaymode", false)
Menu.Spacing()
Menu.Spacing()
Menu.Separator()
Menu.Spacing()
Menu.Spacing()
--default one
--https://cdn.discordapp.com/attachments/673200501659009037/708824024641437826/image0.jpg

--zBumper pfp
--https://cdn.discordapp.com/attachments/709311463872921700/709312208546431006/930f1b6dcc487d87fe5c2b7a7ea527ab7db4abcd_full.jpg
local iHealthOffset = Hack.GetOffset("DT_BasePlayer", "m_iHealth")
local iArmorOffset = Hack.GetOffset("DT_CSPlayer", "m_ArmorValue")
local iClip1Offset = Hack.GetOffset("DT_BaseCombatWeapon", "m_iClip1")
local iBackupAmmo = Hack.GetOffset("DT_BaseCombatWeapon", "m_iPrimaryReserveAmmoCount")
local vVelOffset = Hack.GetOffset("DT_BasePlayer", "m_vecVelocity[0]")
local fFlags_Offset = Hack.GetOffset("DT_BasePlayer", "m_fFlags")
local iAccountOffset = Hack.GetOffset("DT_CSPlayer", "m_iAccount")
local bHasDefuserOffset = Hack.GetOffset("DT_CSPlayer", "m_bHasDefuser")
local bIsDefusingOffset = Hack.GetOffset("DT_CSPlayer", "m_bIsDefusing")
local iKillsOffset = Hack.GetOffset("DT_PlayerResource", "m_iKills")
local iDeathsOffset = Hack.GetOffset("DT_PlayerResource", "m_iDeaths")
local iAssistsOffset = Hack.GetOffset("DT_PlayerResource", "m_iAssists")
local iScoreOffset = Hack.GetOffset("DT_CSPlayerResource", "m_iScore")
local iTeamNumOffset = Hack.GetOffset("DT_BaseEntity", "m_iTeamNum")
local hObsTargetOffset = Hack.GetOffset("DT_BasePlayer", "m_hObserverTarget")

local healthbg
local armorbg = Color.new(200, 200, 200, 255)
local colorbg = Color.new(0, 0, 0, 255)

local colors = {
  Color.new(255,255,255,255), --hp
  Color.new(255,0,0,255), -- score warning
  Color.new(255,255,255,255), -- weapon and ammo
  Color.new(200,200,200,255), -- armor bar
  Color.new(0,0,0,255), -- background bar
  Color.new(0,0,0,0), -- pfp background
  Color.new(255,255,255,255), -- pfp border
  Color.new(0,200,0,255), -- money
  Color.new(255,0,255,255), -- player stats
  Color.new(255,0,255,255), -- ping and fps
  Color.new(255,0,255,255), -- player counter
  Color.new(255,0,255,255), -- dead hud
  Color.new(255,255,255,255) -- speed counter
}

local rainbows = {
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
}

local Playerinfo = CPlayerInfo.new()



FileSys.CreateDirectory(GetAppData() .. "\\INTERIUM\\CSGO\\FilesForLUA\\")
FileSys.CreateDirectory(GetAppData() .. "\\INTERIUM\\CSGO\\FilesForLUA\\ui-emiliachan\\")
URLDownloadToFile(Menu.GetString("s_url"), GetAppData() .. "\\INTERIUM\\CSGO\\FilesForLUA\\ui-emiliachan\\pfp.png")
URLDownloadToFile("https://cdn.discordapp.com/attachments/702957570440298727/707592415535562762/Linebeam.ttf", GetAppData() .. "\\INTERIUM\\CSGO\\FilesForLUA\\ui-emiliachan\\frostbite.ttf")
Render.LoadImage("profilepicture", GetAppData() .. "\\INTERIUM\\CSGO\\FilesForLUA\\ui-emiliachan\\pfp.png")
Render.LoadFont("font1", GetAppData() .. "\\INTERIUM\\CSGO\\FilesForLUA\\ui-emiliachan\\frostbite.ttf", 20)



local time
local Rainbow = 0
local Strong = 5
local fps = 0
local ongroundspeed = 0


function Clamp (input, min, max)
    local output
    if input > max then
        output = max
    elseif input < min then
        output = min
    else
        output = input
    end
    return output
end

function Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function hsv2rgb(h, s, v, a)
    local r, g, b
  
    local i = math.floor(h * 6);
    local f = h * 6 - i;
    local p = v * (1 - s);
    local q = v * (1 - f * s);
    local t = v * (1 - (1 - f) * s);
  
    i = i % 6
  
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
  
    return r * 255, g * 255, b * 255, a * 255
end

local function drawui()

    colors[Menu.GetInt("com_items") + 1] = Menu.GetColor("c_color")
    rainbows[Menu.GetInt("com_items") + 1] = Menu.GetBool("b_rainbow")


    if Menu.GetBool("b_Enabledui") == false then
        return
    end
   
    if (not Utils.IsLocalAlive()) then
		return
	end
    
    local pLocal = IEntityList.GetPlayer(IEngine.GetLocalPlayer())
    if (not pLocal) then
        return
    end

    -- getting playerdata
    

    local x = Globals.ScreenWidth()
    local y = Globals.ScreenHeight()

    local disname


    pLocal:GetPlayerInfo(Playerinfo)
    if (not Playerinfo) then return end

    local pResource = pLocal:GetPlayerResource()
    if (not pResource) then return end

    local weapon = pLocal:GetActiveWeapon()
    if (not weapon) then return end

    local weapondata = weapon:GetWeaponData()
    if (not weapondata) then return end

    local netinfo = IEngine.GetNetChannelInfo()
    if (not netinfo) then return end

    local ihealth = pLocal:GetPropInt(iHealthOffset)
    local health = Clamp(ihealth,0,100)
    if not health then return end

    local armor = pLocal:GetPropInt(iArmorOffset)
    if not armor then return end

    local money = pLocal:GetPropInt(iAccountOffset)
    if not money then return end

    local hasDefuser = pLocal:GetPropBool(bHasDefuserOffset)
    if (hasDefuser == nil) then return end

    local vecVelocity = pLocal:GetPropVector(vVelOffset)
    if not vecVelocity then return end

    local vel2d = math.sqrt(vecVelocity.x * vecVelocity.x + vecVelocity.y * vecVelocity.y)

    local flags = pLocal:GetPropInt(fFlags_Offset)
    if not flags then return end

    local primammo = weapon:GetPropInt(iClip1Offset)
    if not primammo then return end

    local weapname = weapondata.consoleName
    if not weapname then return end

    local weaptype = weapondata.iWeaponType
    if not weaptype then return end

    local maxmag = weapondata.iMaxClip1
    if not maxmag then return end

    local backclip = weapon:GetPropInt(iBackupAmmo)
    if not backclip then return end

    local kills = pResource:GetPropInt(iKillsOffset)
    if not kills then return end

    local deaths = pResource:GetPropInt(iDeathsOffset)
    if not deaths then return end

    local assists = pResource:GetPropInt(iAssistsOffset)
    if not assists then return end

    local score = pResource:GetPropInt(iScoreOffset)
    if not score then return end

    local isDefusing = pLocal:GetPropBool(bIsDefusingOffset)
    if (isDefusing == nil) then return end

    if not Render.IsFont("font1") then return end

    local playername = Playerinfo.szName

    local userid = Playerinfo.userId
    
    --weapon names

    if weapname == "weapon_usp_silencer" then
        disname = "USP-S"
    elseif weapname == "weapon_deagle" then
        disname = "Desert Eagle"
    elseif weapname == "weapon_elite" then
        disname = "Dual Berettas"
    elseif weapname == "weapon_fiveseven" then
        disname = "Five-SeveN"
    elseif weapname == "weapon_glock" then
        disname = "Glock-18"
    elseif weapname == "weapon_hkp2000" then
        disname = "P2000"
    elseif weapname == "weapon_p250" then
        disname = "P250"
    elseif weapname == "weapon_tec9" then
        disname = "Tec-9"
    elseif weapname == "weapon_cz75a" then
        disname = "CZ75-Auto"
    elseif weapname == "weapon_revolver" then
        disname = "R8 Revolver"
    elseif weapname == "weapon_flashbang" then
        disname = "Flashbang"
    elseif weapname == "weapon_decoy" then
        disname = "Decoy"
    elseif weapname == "weapon_hegrenade" then
        disname = "HE Grenade"
    elseif weapname == "weapon_incgrenade" then
        disname = "Incendiary Grenade"
    elseif weapname == "weapon_molotov" then
        disname = "Molotov"
    elseif weapname == "weapon_smokegrenade" then
        disname = "Smoke Grenade"
    elseif weapname == "weapon_tagrenade" then
        disname = "TA Grenade"
    elseif weapname == "weapon_healthshot" then
        disname = "Medi-Shot"
    elseif weapname == "weapon_c4" then
        disname = "Bomb"
    elseif weapname == "weapon_taser" then
        disname = "Zeus X-27"
    elseif weapname == "item_heavyassaultsuit" then
        disname = "Assault Suit"
    elseif weapname == "chicken" then
        disname = "Chicken"
    elseif weapname == "weapon_breachcharge" then
        disname = "Breach Charge"
    elseif weapname == "weapon_snowball" then
        disname = "Snowball"
    elseif weapname == "weapon_axe" then
        disname = "Axe"
    elseif weapname == "weapon_hammer" then
        disname = "Hammer"
    elseif weapname == "weapon_spanner" then
        disname = "Spanner"
    elseif weapname == "weapon_tablet" then
        disname = "Tablet"
    elseif weapname == "item_cash" then
        disname = "Cash"
    elseif weapname == "weapon_bumpmine" then
        disname = "Bump Mine"
    elseif weapname == "weapon_shield" then
        disname = "Shield"
    elseif weapname == "weapon_m249" then
        disname = "M249"
    elseif weapname == "weapon_mag7" then
        disname = "Mag-7"
    elseif weapname == "weapon_negev" then
        disname = "Negev"
    elseif weapname == "weapon_nova" then
        disname = "Nova"
    elseif weapname == "weapon_sawedoff" then
        disname = "Sawed-off"
    elseif weapname == "weapon_xm1014" then
        disname = "XM-1014"
    elseif weapname == "weapon_bizon" then
        disname = "PP-Bizon"
    elseif weapname == "weapon_mac10" then
        disname = "Mac-10"
    elseif weapname == "weapon_mp7" then
        disname = "MP7"
    elseif weapname == "weapon_mp9" then
        disname = "MP9"
    elseif weapname == "weapon_p90" then
        disname = "P90"
    elseif weapname == "weapon_ump45" then
        disname = "UMP-45"
    elseif weapname == "weapon_mp5sd" then
        disname = "MP5-SD"
    elseif weapname == "weapon_m4a1" then
        disname = "M4A4"
    elseif weapname == "weapon_m4a1_silencer" then
        disname = "M4A1-S"
    elseif weapname == "weapon_ak47" then
        disname = "AK-47"
    elseif weapname == "weapon_aug" then
        disname = "AUG"
    elseif weapname == "weapon_famas" then
        disname = "Famas"
    elseif weapname == "weapon_gs3sg1" then
        disname = "GS3SG1"
    elseif weapname == "weapon_galilar" then
        disname = "Galil"
    elseif weapname == "weapon_scar20" then
        disname = "SCAR-20"
    elseif weapname == "weapon_sg556" then
        disname = "SG-556"
    elseif weapname == "weapon_ssg08" then
        disname = "SSG-08"
    elseif weapname == "weapon_awp" then
        disname = "AWP"
    else
        disname = "unindentified/knife"
    end                                            
    
    
    
    ------------------color manager

    Rainbow = Rainbow + (IGlobalVars.frametime * (Strong/10))
    if Rainbow > 1.0 then Rainbow = 0.0 end

    if Menu.GetBool("b_gaymode") then
        for l = 1, 13 do
            rainbows[l] = true
        end
    end
    
    for i = 0, 13 do
        if rainbows[i] == true then
            colors[i] = Color.new(hsv2rgb(Rainbow, 1, 1, 1))
        end
    end
 
    -------------------actual features

    --health, armor, defuser shit
    if ihealth ~= 69 or ihealth ~= 1 then
        Render.Text("HP: " .. tostring(ihealth), 10, (y/8 * 7) + 5, 30, colors[1], false, true, "font1")
    else
        Render.Text("HP: " .. tostring(ihealth), 10, (y/8 * 7) + 5, 30,Color.new(hsv2rgb(Rainbow, 1, 1, 1)), false, true, "font1")
    end

    Render.Text("AP: " .. tostring(armor), 10, (y/8 * 7) + 35, 30, colors[1], false, true, "font1")
    if hasDefuser then
        Render.Text("Has Defuser", 10, (y/8 * 7) + 65, 30, colors[1], false, true, "font1")
    end

    local warntrigger = Menu.GetInt("i_scoretrigger")

    if Menu.GetBool("b_scorewarning") then
        local warningtextsize = Render.CalcTextSize("Score over " .. tostring(warntrigger) .. "!",30, "font1")
        if score > warntrigger then
            Render.Text("Score over " .. tostring(warntrigger) .. "!", x - warningtextsize.x - 10, (y/8 * 7.5), 30, colors[2], false, true, "font1")
        end
    end
    --weapon info text render
    local curweaponsize = Render.CalcTextSize(disname, 30, 0)
    if not (weaptype == 0) then
        if not (weaptype == 9) then
            if not (weapname == "weapon_c4") then
                Render.Text(tostring(primammo) .. "/" .. tostring(backclip), x - curweaponsize.x - x/11, (y/8 * 6.5) + 35, 30, colors[3], false, true, "font1")
            end
        end
        Render.Text(disname, x - curweaponsize.x - x/11, (y/8 * 6.5) + 5, 30, colors[3], false, true, "font1")
    end
    
    --backdrop for health and armor
    if  not (armor == 0) then
        Render.AddPoly(0, 36, 6.5*y/8 - 4)
        Render.AddPoly(1,  70 + health * 3.5 - 10, 6.5*y/8 - 4)
        Render.AddPoly(2,  40 + health * 3.5 - 10, 7*y/8)
        Render.AddPoly(3, 5, 7*y/8)
    else
        Render.AddPoly(0, 36, 6.5*y/8 - 4)
        Render.AddPoly(1,  40 + health * 3.5 - 10, 6.5*y/8 - 4)
        Render.AddPoly(2,  10 + health * 3.5 - 10, 7*y/8)
        Render.AddPoly(3, 5, 7*y/8)
    end
    Render.PolyFilled(4,colors[5])

    
    --healthbar color
    if health < 21 then
        healthbg = Color.new(200,0,0,255)
    else
        healthbg = Color.new(0,200,0,255)
    end

    --healthquad
    if not (health == 0) then
        Render.AddPoly(0, 40, 6.5*y/8)
        Render.AddPoly(1, 40 + health * 3.5, 6.5*y/8)
        Render.AddPoly(2, 10 + health * 3.5,  y/8 * 7)
        Render.AddPoly(3, 10, y/8 * 7)
        Render.PolyFilled(4, healthbg)
    end
    --armorquad
    if not (armor == 0) then
        Render.AddPoly(0, (40 + health * 3.5) - ((30/100) * (100 - armor)) , 7*y/8 - ((y/16) / 100) * armor)
        Render.AddPoly(1, 70 + health * 3.5, 7*y/8 - (((y/16) / 100) * armor))
        Render.AddPoly(2, 40 + health * 3.5, 7*y/8, 10 + health * 3.5)
        Render.AddPoly(3, 10 + health * 3.5, 7*y/8)
        Render.PolyFilled(4,colors[4])
    end

    
    local id64 = Playerinfo.steamID64

    --reload picture
    while Menu.GetBool("b_pfp") do
        if (URLDownloadToFile(Menu.GetString("s_url"), GetAppData() .. "\\INTERIUM\\CSGO\\FilesForLUA\\ui-emiliachan\\pfp.png") == true) then
            Render.LoadImage("profilepicture", GetAppData() .. "\\INTERIUM\\CSGO\\FilesForLUA\\ui-emiliachan\\pfp.png")
            Menu.SetBool("b_pfp", false)
            break
        end
    end
  
    

    --p profile picture handler
    if Menu.GetBool("b_enableprofilepic") then
        if Render.IsImage("profilepicture") then
            Render.RectFilled(36, 6.5*y/8 - 98, 36 + 88, 6.5*y/8 - 10, colors[6], 0)
            Render.Image("profilepicture", 36, 6.5*y/8 - 98, 36 + 88, 6.5*y/8 -10, Color.new(255,255,255,255), 0,0,1,1)
            Render.Rect(36, 6.5*y/8 - 98, 36 + 88, 6.5*y/8 - 10, colors[7], 0, 3)
            Render.Text(playername, 36 + 98, 6.5*y/8 - 30, 20, colors[7], false, true, "font1")
        end
    end

    
  
    --money display
    local moneysz = Render.CalcTextSize("$ " .. tostring(money), 30 , "font1")
    Render.RectFilled(10, y*Menu.GetFloat("f_moneyheight"), moneysz.x + 15, moneysz.y + y*Menu.GetFloat("f_moneyheight"), Color.new(0, 0, 0, 50), 4)
    Render.Text("$ " .. tostring(money), 10, y*Menu.GetFloat("f_moneyheight"), 30, colors[8], false, true, "font1")

    --kills and deaths
    local kdr
    if deaths == 0 then
        kdr = kills
    else
        kdr = Round(kills/deaths,1)
    end
    local szkdr = Render.CalcTextSize("KDR: " .. kdr, 25, "font1")
    local szepic = Render.CalcTextSize("Assists: " .. assists, 25, "font1")
    Render.Text("Kills: " .. kills, x - szepic.x * 2, 0, 25, colors[9], false, true, "font1")
    Render.Text("Deaths: " .. deaths, x - szepic.x * 2, 25, 25, colors[9], false, true, "font1")
    Render.Text("Assists: " .. assists, x - szepic.x - 5, 0, 25, colors[9], false, true, "font1")
    Render.Text("KDR: " .. kdr, x - szkdr.x - 5, 25, 25, colors[9], false, true, "font1")

    -- fps and ping
    
    fps = Utils.GetFps()


    Render.Text("FPS: " .. fps, 6*x/10, y - szkdr.y - 10, 25, colors[10], true, true, "font1")
    Render.Text("Ping: " .. tostring(Clamp((math.floor((netinfo:GetLatency(0) - netinfo:GetLatency(1)) * 1000)), 0, 9999)), 4*x/10, y - szkdr.y - 10, 25, colors[10], true, true, "font1")

    --ct and t
    local cts = 0
    local ts = 0

    for i = 1, IEngine.GetMaxClients() do
        local entplayer = IEntityList.GetPlayer(i)
        if not entplayer then goto skip end

        local team = entplayer:GetPropInt(iTeamNumOffset)

        if entplayer:IsAlive() or entplayer:IsDormant() then
            if team == 2 then
                ts = ts + 1
            elseif team == 3 then
                cts = cts + 1
            end
        end
        ::skip::
    end

    Render.Text("CTs Alive: " .. cts, 3*x/10, 0, 25, colors[11], true, true, "font1")
    Render.Text("Ts Alive: " .. ts, 7*x/10, 0, 25, colors[11], true, true, "font1")

    --speed counter
    if Menu.GetBool("b_counterenable") then
        if IsBit(flags, 0) then
            ongroundspeed = vel2d
            Render.Text(math.floor(vel2d), x * Menu.GetFloat("f_counterx"), y * Menu.GetFloat("f_countery") , 25, colors[13], true, true, "font1")
        else
            Render.Text(math.floor(vel2d) .. " (" .. math.floor(ongroundspeed) .. ")", x * Menu.GetFloat("f_counterx"), y * Menu.GetFloat("f_countery") , 25, colors[13], true, true, "font1")
        end
    end

    --defuseshow

    if isDefusing then
        if hasDefuser then
            Render.Text("Defusing... With Defuser!", x/2, y/6*2, 30, Color.new(100,100,255,255), true, true, "font1")
        else
            Render.Text("Defusing... No Defuser!", x/2, y/6*2, 30, Color.new(100,100,255,255), true, true, "font1")
        end

    end

    -- bhop indicator
    local ic = Menu.GetColor("c_indcolor")
    local indsize = Menu.GetInt("i_indsize")

    if IsBit(flags, 0) then
        if vel2d > 286 then
            time = IGlobalVars.curtime
        end
    end

    if Menu.GetBool("b_bhopind") then
        if time > IGlobalVars.curtime - 0.25 then
            for  i = 0, indsize do
                Render.Line(0, y - i, x, y - i, Color.new(ic.r,ic.g,ic.b, Clamp((255  - (255/indsize) * i), 0, 255)), 1)
            end
        end
    end
end


local function deathui()
    if not (Menu.GetBool("b_Enabledui")) then
        return
    end

    local pLocal = IEntityList.GetPlayer(IEngine.GetLocalPlayer())
    if not pLocal then return end

    if pLocal:IsAlive() then return end

    local obstargetint = pLocal:GetPropInt(hObsTargetOffset)
    if (obstargetint <= 0) then return end

    local entitytarget = IEntityList.GetClientEntityFromHandleA(obstargetint)

    local Target = IEntityList.ToPlayer(entitytarget)
    if (not Target or Target:GetClassId() ~= 40 or not Target:IsAlive() or Target:IsDormant()) then return end

    local player = IEntityList.GetPlayer(Target:GetIndex())
    local playerinfo = CPlayerInfo.new()
    if not player then return end

    player:GetPlayerInfo(playerinfo)

    local x = Globals.ScreenWidth()
    local y = Globals.ScreenHeight()

    Render.Text("Spectating " .. playerinfo.szName, x/2, 0, 30, colors[10], true, true, "font1")
    Render.Text("HP: " .. player:GetPropInt(iHealthOffset), x/2, 3.5*y/4, 30, colors[12], true, true, "font1")

end


local function uidisable()

    local pLocal = IEntityList.GetPlayer(IEngine.GetLocalPlayer())
    if not pLocal then return end

    local Message = "\x01[\x09epicUI\x01] \x01default UI \x06enabled"
    local cvar = ICvar.FindVar("cl_draw_only_deathnotices")

    if(cvar:GetInt() == 0 and Menu.GetBool("cToggleDefault")) then
        IEngine.ExecuteClientCmd("cl_draw_only_deathnotices 1")
    elseif(cvar:GetInt() == 1 and not Menu.GetBool("cToggleDefault")) then
        IEngine.ExecuteClientCmd("cl_draw_only_deathnotices 0")
        IChatElement.ChatPrintf(0, 0, Message)
    end


end


Hack.RegisterCallback("PaintTraverse", drawui)
Hack.RegisterCallback("PaintTraverse", deathui)
Hack.RegisterCallback("CreateMove", uidisable)
--made by emilia-chan#6609

Menu.Text("cool gui")
Menu.Spacing()
Menu.Spacing()
Menu.Spacing()
Menu.SliderInt("x position", "xpos", 0, Globals.ScreenWidth(), "%1.f", Globals.ScreenWidth() / 8)

FileSys.CreateDirectory(GetAppData() .. "\\INTERIUM\\CSGO\\Fonts\\")
URLDownloadToFile("https://cdn.discordapp.com/attachments/756567318594846762/767746381569851422/modern_dos_8x8.ttf", GetAppData() .. "\\INTERIUM\\CSGO\\Fonts\\modern_dos_8x8.ttf")
Render.LoadFont(69,GetAppData() .. "\\INTERIUM\\CSGO\\Fonts\\modern_dos_8x8.ttf", 16)



--make life easier
Colors = {
    white = Color.new(255,255,255,255),
    yellow = Color.new(255,255,0,255),
    red = Color.new(255,0,0,255),
    blue = Color.new(0,0,255,255),
    green = Color.new(255,0,255,255),
    pink = Color.new(255,0,255,255),
}

local pitchtable = {"None", "Emotion", "Down", "Up", "Zero"}
local yawtable = {"None", "Backwards", "Spinbot", "Lowerbody", "Freestanding"}
local chamsmattable = {"None", "Flat", "Texture", "Velvet", "Metallic", "Wireframe", "Glass", "Plastic Glass", "Gradient", "Evaporation"}
local desynctypetable = {"None", "Static", "Balance"}
local desyncswaptypetable = {"Auto", "Manual"}
local edgebugtable = {"Short", "Standard"}
local jumpbugtable = {"Simple", "Scan", "Hybrid"}
local scantable = {"Very Low", "Low", "Normal", "High", "Very High"}
-- easier
local homekey = 0x24
local opened = true
local espvisible
local desyncend


--make life easier
local function drawtext (text, y ,color)
    Render.Text(text, Menu.GetInt("xpos"), y, 10, color, false, true, 69)
end
--look better
local function to_string_bool(bool)
    if bool then
        return "On"
    else
        return "Off"
    end
end

function Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function getespvisibility()
    if GetBool(Vars.esp_visible_only) then
        espvisible = ", Only visible"
    else
        espvisible = ""
    end

end

local function getdesync()
    if GetInt(Vars.antiaim_desync_type) ~= 0 then
        if GetBool(Vars.antiaim_desync_antishake) then
            desyncend = ", " ..  desyncswaptypetable[GetInt(Vars.antiaim_desync_swap_type) + 1] .. ", Antishake"
        else
            desyncend = ", " ..  desyncswaptypetable[GetInt(Vars.antiaim_desync_swap_type) + 1]
        end
    else
        desyncend = ""
    end
end

local function drawfovchanger()
    if GetBool(Vars.misc_customFov) then
        return "On, " .. tostring(GetInt(Vars.misc_overridefov)) .. ", " .. tostring(GetInt(Vars.misc_viewmodelfov))
    else
        return "Off"
    end
end


--actual shit
function DrawGui()
    if InputSys.IsKeyPress(homekey) then
        opened =  not opened
    end

    if opened then
        drawtext("Hello " .. Hack.GetUserName() .. " :)", 4, Colors.yellow)
        if GetBool(Vars.legit_enable) then
            drawtext("Legitbot:   " .. to_string_bool(GetBool(Vars.legit_enable)), 14,Colors.yellow)
        else
            drawtext("Legitbot:   " .. to_string_bool(GetBool(Vars.legit_enable)), 14,Colors.white)
        end
        drawtext("Bunnyhop:   " .. to_string_bool(GetBool(Vars.misc_bhop)), 24,Colors.white)
        if GetBool(Vars.chams_player_enabled) then
            if GetBool(Vars.chams_player_ignore_team) then
                drawtext("Chams:      Enemy, " .. chamsmattable[GetInt(Vars.chams_player_material_visible) + 1] .. " / " .. chamsmattable[GetInt(Vars.chams_player_material_invisible) +1], 34, Colors.white)
            else
                drawtext("Chams:      All, " .. chamsmattable[GetInt(Vars.chams_player_material_visible) + 1] .. " / " .. chamsmattable[GetInt(Vars.chams_player_material_invisible) +1], 34, Colors.white)
            end
        
        else
            drawtext("Chams:      Off", 34, Colors.white)
        end

        if GetBool(Vars.esp_enabled) then
            getespvisibility()
            if GetBool(Vars.esp_ignore_team) then
                drawtext("Esp:        Enemy" .. espvisible, 44, Colors.white)
            else
                drawtext("Esp:        All" .. espvisible, 44, Colors.white)
            end

        else
            drawtext("Esp:        Off", 44, Colors.white)
        end
        drawtext("RankEsp:    " .. to_string_bool(GetBool(Vars.misc_showrank)), 54, Colors.white)
        drawtext("AA Pitch:   " .. pitchtable[GetInt(Vars.ragebot_antiaim_pitch) + 1], 64, Colors.white)
        drawtext("AA Yaw:     " .. yawtable[GetInt(Vars.ragebot_antiaim_yaw) + 1], 74, Colors.white)
        getdesync()
        if GetInt(Vars.antiaim_desync_type) ~= 0 then
            drawtext("Desync:     " .. desynctypetable[GetInt(Vars.antiaim_desync_type) + 1] .. desyncend, 84, Colors.yellow)
        else
            drawtext("Desync:     " .. desynctypetable[1] .. desyncend, 84, Colors.white)
        end
        drawtext("Clantag:    " .. to_string_bool(GetBool(Vars.misc_clantag)), 94, Colors.white)
        drawtext("FovChanger: " ..  drawfovchanger(), 104, Colors.white)
        if GetBool(Vars.ragebot_enabled) then
            drawtext("Ragebot:    On", 114, Colors.red)
        else
            drawtext("Ragebot:    Off", 114, Colors.white)
        end
        drawtext("3rdperson:  " .. to_string_bool(GetBool(Vars.visuals_thirdperson)), 124, Colors.white)
        if GetBool(Vars.legit_backtrack) then
            drawtext("Backtrack:  " .. to_string_bool(GetBool(Vars.legit_backtrack)) .. ", " .. Round(GetFloat(Vars.legit_backtrack_time), 3) .. "s",134 ,Colors.white)
        else
            drawtext("Backtrack:  Off",134 ,Colors.white)
        end
        if GetBool(Vars.misc_jumpbug) then
            if GetInt(Vars.misc_jumpbug_type) == 1 or GetInt(Vars.misc_jumpbug_type) == 2 then
            drawtext("Jumpbug:    " ..  to_string_bool(GetBool(Vars.misc_jumpbug)) .. ", " .. jumpbugtable[GetInt(Vars.misc_jumpbug_type) + 1] .. ", " .. scantable[GetInt(Vars.misc_jumpbug_scan_type) + 1], 144, Colors.white)
            else
                drawtext("Jumpbug:    " ..  to_string_bool(GetBool(Vars.misc_jumpbug)) .. ", " .. jumpbugtable[GetInt(Vars.misc_jumpbug_type) + 1], 144, Colors.white)
            end
        else
            drawtext("Jumpbug:    Off", 144, Colors.white)

        end
        if GetBool(Vars.misc_edgebug) then
            drawtext("Edgebug:    " .. to_string_bool(GetBool(Vars.misc_edgebug)) .. ", " .. edgebugtable[GetInt(Vars.misc_edgebug_type) + 1], 154, Colors.white)
        else
            drawtext("Edgebug:    Off", 154, Colors.white)
        end
        drawtext("Crouchbug:  " .. to_string_bool(GetBool(Vars.misc_crouchbug)), 164, Colors.white)

    end


end


Hack.RegisterCallback("PaintTraverse", DrawGui)
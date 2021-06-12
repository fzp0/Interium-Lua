Menu.Separator()
Menu.Text("3D hitmarkers by emilia-chan v1.2")
Menu.Checkbox("Enabled", "b_3dhitenable", true)
Menu.Checkbox("Damage text", "b_3dhitdmgtext", true)
Menu.ColorPicker("Hitmarker color", "c_3dhitcolor", 255, 255, 255, 255)
Menu.Checkbox("drawRainbow", "hitrainbow", false)
Menu.Checkbox("textRainbow", "textrainbow", false)
Menu.ColorPicker("Text color", "c_3dtextcolor", 255, 255, 255, 255)
Menu.Combo("Shapes", "i_chooseshape", {"Normal", "Circle", "Image", "Spinning Triangle", "Spinning Square"}, 0)
Menu.SliderInt("Fade time", "i_fadelength", 5, 200, "frames: %.1f", 50)
Menu.SliderFloat("Draw time", "f_drawtime", 0.2, 10.0, "%.3f s", 2.0)
Menu.SliderInt("Hitmarker Size", "i_3dhitsize", 1, 40, "%.1f", 8)
Menu.SliderInt("Dmg text Y offset", "i_dmgtextY", -100, 100, "%.1f", -20)
Menu.SliderInt("Rotation speed", "i_rotationangle", 0, 360, "Angle per frame: %.1f", 4)
Menu.InputText("Image name", "s_imagename", "image.jpg")
Menu.Checkbox("Load image", "b_loadimage", false)

function table.empty (self)
    for _, _ in pairs(self) do
        return false
    end
    return true
end

local function getplayer(uid)

    return IEntityList.GetEntity(IEngine.GetPlayerForUserID(uid))

end

local function timeinms()

    return IGlobalVars.realtime * 1000

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




local impacts = {}
local hitmarkers = {}

local Rainbow = 0
local Strong = 5

--image
FileSys.CreateDirectory(GetAppData() .. "\\INTERIUM\\CSGO\\FilesForLUA\\")
FileSys.CreateDirectory(GetAppData() .. "\\INTERIUM\\CSGO\\FilesForLUA\\3dhit-emiliachan\\")


local impact_info =
{
    x = 0,
    y = 0,
    z = 0,
    time = 0
}

local hitmarker_info =
{
    impact = impact_info,
    dmg = 0,
    alpha = 0
}

local rotated = 0

--cx, cy vector points relative to px, py; returns vec2d


local function hit3dDraw()

    if not Menu.GetBool("b_3dhitenable") then return end

    local pLocal = IEntityList.GetEntity(IEngine.GetLocalPlayer())

    if Menu.GetBool("b_loadimage") then
        Render.LoadImage("img_loadedimage", GetAppData() .. "\\INTERIUM\\CSGO\\FilesForLUA\\3dhit-emiliachan\\" .. Menu.GetString("s_imagename"))
        Menu.SetBool("b_loadimage", false)
    end

    if (not pLocal) or (not IEngine.IsConnected()) or (not IEngine.IsInGame()) then 
        if(not table.empty(impacts)) then impacts = {} end
        if(not table.empty(hitmarkers)) then hitmarkers = {} end
        return
    end

    Rainbow = Rainbow + IGlobalVars.frametime * Strong / 10
    if Rainbow > 1.0 then Rainbow = 0.0 end

    local time = timeinms()

    local linelength = Menu.GetInt("i_3dhitsize") -- length of the hitmarker cross line

    local delay = Menu.GetFloat("f_drawtime") * 1000
    local framestofade = Menu.GetInt("i_fadelength")
    local textYoffset = Menu.GetInt("i_dmgtextY")

   
    for i, iter in ipairs(hitmarkers) do
        local b_expired = time > iter.impact.time + delay
        local i_alpha_interval = 255/framestofade
        if b_expired then iter.alpha = iter.alpha - i_alpha_interval end
        if b_expired and iter.alpha <= 0 then
            table.remove(hitmarkers, i)
            goto continue
        end

        local vec_pos3D = Vector.new(iter.impact.x, iter.impact.y, iter.impact.z)
        local vec_pos2D = Vector.new()

        if not Math.WorldToScreen(vec_pos3D, vec_pos2D) then
            goto continue
        end

        local drawcolor = Color.new(Menu.GetColor("c_3dhitcolor").r,Menu.GetColor("c_3dhitcolor").g, Menu.GetColor("c_3dhitcolor").b, iter.alpha)
        local textcolor = Color.new(Menu.GetColor("c_3dtextcolor").r,Menu.GetColor("c_3dtextcolor").g, Menu.GetColor("c_3dtextcolor").b, iter.alpha)

        if Menu.GetBool("hitrainbow") then
            drawcolor = Color.new(hsv2rgb(Rainbow, 1, 1, 1))
        end
    
        if Menu.GetBool("textrainbow") then
            textcolor = Color.new(hsv2rgb(Rainbow, 1, 1, 1))
        end

        if Menu.GetInt("i_chooseshape") == 0 then
            Render.Line(vec_pos2D.x - linelength, vec_pos2D.y - linelength, vec_pos2D.x - (linelength / 4), vec_pos2D.y - (linelength / 4), drawcolor, 1)
            Render.Line(vec_pos2D.x - linelength, vec_pos2D.y + linelength, vec_pos2D.x - (linelength / 4), vec_pos2D.y + (linelength / 4), drawcolor, 1)   
            Render.Line(vec_pos2D.x + linelength, vec_pos2D.y - linelength, vec_pos2D.x + (linelength / 4), vec_pos2D.y - (linelength / 4), drawcolor, 1)
            Render.Line(vec_pos2D.x + linelength, vec_pos2D.y + linelength, vec_pos2D.x + (linelength / 4), vec_pos2D.y + (linelength / 4), drawcolor, 1)
            
        elseif Menu.GetInt("i_chooseshape") == 1 then
            --draw a circle
            local radius = linelength
            radius = radius * (iter.alpha / 255)
            Render.CircleFilled(vec_pos2D.x, vec_pos2D.y, radius, drawcolor, 420)
            

        elseif Menu.GetInt("i_chooseshape") == 2 then
            if Render.IsImage("img_loadedimage") then
               Render.Image("img_loadedimage", vec_pos2D.x - linelength, vec_pos2D.y - linelength, vec_pos2D.x + linelength, vec_pos2D.y + linelength, drawcolor, 0, 0, 1, 1)
            end

        elseif Menu.GetInt("i_chooseshape") == 3 then

            local radius = linelength
            radius = radius * (iter.alpha / 255)

            local x = math.cos(math.rad(rotated)) + math.sin(math.rad(rotated))
            local y = math.sin(math.rad(rotated)) - math.cos(math.rad(rotated))

            rotated = rotated + 120
            if rotated > 359 then rotated = rotated - 360 end

            local x120 = math.cos(math.rad(rotated)) + math.sin(math.rad(rotated))
            local y120 = math.sin(math.rad(rotated)) - math.cos(math.rad(rotated))

            rotated = rotated + 120
            if rotated > 359 then rotated = rotated - 360 end

            local x240 = math.cos(math.rad(rotated)) + math.sin(math.rad(rotated))
            local y240 = math.sin(math.rad(rotated)) - math.cos(math.rad(rotated))

            Render.TriangleFilled(x * radius + vec_pos2D.x, y * radius + vec_pos2D.y, x120 * radius + vec_pos2D.x, y120 * radius + vec_pos2D.y, x240 * radius + vec_pos2D.x, y240 * radius + vec_pos2D.y, drawcolor)

        elseif Menu.GetInt("i_chooseshape") == 4 then
            local radius = linelength
            radius = radius * (iter.alpha / 255)

            local x = math.cos(math.rad(rotated)) + math.sin(math.rad(rotated))
            local y = math.sin(math.rad(rotated)) - math.cos(math.rad(rotated))

            rotated = rotated + 90
            if rotated > 359 then rotated = rotated - 360 end

            local x90 = math.cos(math.rad(rotated)) + math.sin(math.rad(rotated))
            local y90 = math.sin(math.rad(rotated)) - math.cos(math.rad(rotated))

            rotated = rotated + 90
            if rotated > 359 then rotated = rotated - 360 end

            local x180 = math.cos(math.rad(rotated)) + math.sin(math.rad(rotated))
            local y180 = math.sin(math.rad(rotated)) - math.cos(math.rad(rotated))

            rotated = rotated + 90
            if rotated > 359 then rotated = rotated - 360 end

            local x270 = math.cos(math.rad(rotated)) + math.sin(math.rad(rotated))
            local y270 = math.sin(math.rad(rotated)) - math.cos(math.rad(rotated))

            Render.AddPoly(0, x * radius + vec_pos2D.x, y * radius + vec_pos2D.y)
            Render.AddPoly(1, x90 * radius + vec_pos2D.x, y90 * radius + vec_pos2D.y)
            Render.AddPoly(2, x180 * radius + vec_pos2D.x, y180 * radius + vec_pos2D.y)
            Render.AddPoly(3, x270 * radius + vec_pos2D.x, y270 * radius + vec_pos2D.y)
            Render.PolyFilled(4, drawcolor)

        end

        if Menu.GetBool("b_3dhitdmgtext") then Render.Text_1(tostring(iter.dmg), vec_pos2D.x, vec_pos2D.y + textYoffset, 12, textcolor, true, false) end

        ::continue::
    end

    rotated = rotated + Menu.GetInt("i_rotationangle")
    if rotated > 360 then rotated = 0 end

end

local function Hit3dPlayerHurt(event)
    
    if not Menu.GetBool("b_3dhitenable") then return end

    local pLocal = IEntityList.GetEntity(IEngine.GetLocalPlayer())

    if (not event) or (not pLocal) then return end

    if(event:GetName() ~= "player_hurt") then return end

    local attacker = getplayer(event:GetInt("attacker"))
    local victim = getplayer(event:GetInt("userid"))

    if (not attacker) or (not victim) or (attacker ~= pLocal) then return end

    local vec_enemyposition = victim:GetAbsOrigin()

    local best_impact
    local best_impact_distance = -1
    local time = timeinms()

    for i, iter in ipairs(impacts) do
        
        if time > (iter.time + 25) then
            table.remove(impacts, i)
            goto continue
        end

        local vec_position = Vector.new(iter.x, iter.y, iter.z)
        local distance = Math.VectorDistance(vec_position, vec_enemyposition)

        if distance < best_impact_distance or best_impact_distance == -1 then
            
            best_impact_distance = distance
            best_impact = iter

        end

        ::continue::
    end

    if (best_impact_distance == -1) then return end

    local info = {
        impact = best_impact,
        dmg = event:GetInt("dmg_health"),
        alpha = 255
    }

    table.insert(hitmarkers, info)

end

local function Hit3dBulletImpact(event)
    if not Menu.GetBool("b_3dhitenable") then return end

    local pLocal = IEntityList.GetEntity(IEngine.GetLocalPlayer())

    if (not event) or (not pLocal) then return end

    if(event:GetName() ~= "bullet_impact") then return end

    local shooter = getplayer(event:GetInt("userid"))

    if (not shooter) or (shooter ~= pLocal) then return end

    local info = {
        x = event:GetFloat("x"),
        y = event:GetFloat("y"),
        z = event:GetFloat("z"),
        time = timeinms()
    }

    table.insert(impacts, info)
end


Hack.RegisterCallback("PaintTraverse", hit3dDraw)
Hack.RegisterCallback("FireEventClientSideThink", Hit3dBulletImpact)
Hack.RegisterCallback("FireEventClientSideThink", Hit3dPlayerHurt)



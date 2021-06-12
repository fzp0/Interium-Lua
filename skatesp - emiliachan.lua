Menu.Text("SkateEsp")
Menu.Checkbox("Enabled", "b_skateenabled", true)
Menu.SliderFloat("Scale", "f_skatescale", 0,2,"%001f", 0.15)
FileSys.CreateDirectory(GetAppData() .. "\\INTERIUM\\CSGO\\FilesForLUA\\")
FileSys.CreateDirectory(GetAppData() .. "\\INTERIUM\\CSGO\\FilesForLUA\\skate-emiliachan\\")
URLDownloadToFile("https://cdn.discordapp.com/attachments/706147810768322612/722804683386781746/skate.png", GetAppData() .. "\\INTERIUM\\CSGO\\FilesForLUA\\skate-emiliachan\\skate.png")
URLDownloadToFile("https://cdn.discordapp.com/attachments/706147810768322612/722816330268672090/skatejump.png", GetAppData() .. "\\INTERIUM\\CSGO\\FilesForLUA\\skate-emiliachan\\skatejump.png") 
Render.LoadImage("skate", GetAppData() .. "\\INTERIUM\\CSGO\\FilesForLUA\\skate-emiliachan\\skate.png")
Render.LoadImage("skatejump", GetAppData() .. "\\INTERIUM\\CSGO\\FilesForLUA\\skate-emiliachan\\skatejump.png")


local fFlags_Offset = Hack.GetOffset("DT_BasePlayer", "m_fFlags")

local function render()
    if not Menu.GetBool("b_skateenabled") then return end

    local pLocal = IEntityList.GetPlayer(IEngine.GetLocalPlayer())
	if (not pLocal) then 
        return
    end
    
    for i = 1, IEngine.GetMaxClients() do
        local player = IEntityList.GetPlayer(i)
        if not player then goto skip end

        if player:IsDormant() then goto skip end

        if not player:IsAlive() then goto skip end

        local flags = player:GetPropInt(fFlags_Offset)
        if not flags then goto skip end

        local playerpos = player:GetAbsOrigin()
        if not playerpos then goto skip end
        --vec3d

        local screenpos = Vector2D.new()
        --vec2D

        Math.WorldToScreen(playerpos, screenpos)
        if not screenpos then goto skip end

        --if IsBit(flags, 0) then
        --    Render.Text_1("sex", 200, 200, 12, Color.new(255,255,255,255), false, true)
        --    if Render.IsImage("skate") then
        --        Render.Image("skate", screenpos.x - (543/2 * Menu.GetFloat("f_skatescale")), screenpos.y ,screenpos.x + (543/2 * Menu.GetFloat("f_skatescale")), screenpos.y + (159 * Menu.GetFloat("f_skatescale")), Color.new(255,255,255,255), 0,0,1,1)  
        --    end
        --end

        if not IsBit(flags, 0) then
            if Render.IsImage("skatejump") then
                Render.Image("skatejump", screenpos.x - (543/2 * Menu.GetFloat("f_skatescale")), screenpos.y ,screenpos.x + (543/2 * Menu.GetFloat("f_skatescale")), screenpos.y + (159 * Menu.GetFloat("f_skatescale")), Color.new(255,255,255,255), 0,0,1,1)
            end
        else
            if Render.IsImage("skate") then
                Render.Text_1("sex", 200, 200, 12, Color.new(255,255,255,255), false, true)
                Render.Image("skate", screenpos.x - (543/2 * Menu.GetFloat("f_skatescale")), screenpos.y ,screenpos.x + (543/2 * Menu.GetFloat("f_skatescale")), screenpos.y + (159 * Menu.GetFloat("f_skatescale")), Color.new(255,255,255,255), 0,0,1,1)  
            end
        end

        ::skip::
    end



end



Hack.RegisterCallback("PaintTraverse", render)
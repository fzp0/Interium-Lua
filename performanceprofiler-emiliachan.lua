Menu.Separator()
Menu.Text("Performance profiler by emilia-chan")
Menu.Spacing()
Menu.Spacing()
Menu.Spacing()
Menu.SliderFloat("Position X", "f_posx", 0, 1,"%.05f", 0.065)
Menu.SliderFloat("Position Y", "f_posy", 0, 1,"%.05f", 0.3)
Menu.SliderInt("Graph width", "i_size", 30, 200, "%1.f", 40)
Menu.SliderInt("Graph height offset","i_offset", 0, 1000, "%1.f", 0)
Menu.SliderFloat("speed", "f_speed", 0.001, 2, "%.05f", 0.05)
Menu.SliderInt("Max Fps clamp", "i_fpsclamp", 0, 1000, "%1.f", 350)
Menu.SliderInt("Max Ping clamp", "i_pingclamp", 0, 1000, "%1.f", 300)
Menu.SliderInt("Opacity", "i_opacity", 0 ,255, "%1.f", 120)
Menu.Separator()

local ping = {}
local fps = {}
local time = IGlobalVars.realtime

local iPingOffset = Hack.GetOffset("DT_PlayerResource", "m_iPing")

local fcolor = Color.new(255,255,255,255)
local pcolor = Color.new(255,255,255,255)

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

function Draw()
    local pLocal = IEntityList.GetPlayer(IEngine.GetLocalPlayer())
    local size = Menu.GetInt("i_size")
    local offset = Menu.GetInt("i_offset")
    local x = Globals.ScreenWidth() * Menu.GetFloat("f_posx")
    local y = Globals.ScreenHeight() * Menu.GetFloat("f_posy")
    local netinfo = IEngine.GetNetChannelInfo()

    if IGlobalVars.realtime > time then

        if not pLocal then
            table.insert(ping, 1, 0)
            table.insert(fps,1,Utils.GetFps())
            time = IGlobalVars.realtime + Menu.GetFloat("f_speed")
        else
            local pResource = pLocal:GetPlayerResource()
            if (not pResource) then return end 
            table.insert(ping,1,(math.floor((netinfo:GetLatency(0) - netinfo:GetLatency(1)) * 1000)))
            table.insert(fps,1,Utils.GetFps())
            time = IGlobalVars.realtime + Menu.GetFloat("f_speed")
        end
    end
   
    if #fps > size then
        table.remove(fps)
    end

    if #ping > size then
        table.remove(ping)
    end

    if #fps < 3 then
        return
    end
    if #ping < 3 then
        return
    end
    
    Render.RectFilled(x + 80 - size * 5,  y - 300*100/320, x + 105 ,y + offset + 150,Color.new(0,0,0,Menu.GetInt("i_opacity")), 5)
    Render.Text_1("Fps: " .. fps[1], x + 100 - size * 5, y - 300*100/320 + 20, 20, Color.new(255,255,255,255), false, true)
    Render.Text_1("Ping: " .. ping[1], x + 20, y - 300*100/320 + 20, 20, Color.new(255,255,255,255), false, true)

    for i = 1, #fps, 1 do
        local cur = fps[i]
        local next = fps[i + 1]
        local pcur = ping[i]
        local pnext = ping[i+1]
        if cur < 30 then
            fcolor = Color.new(255,0,0,255)
        else
            fcolor = Color.new(255,255,255,255)
        end

        if pcur > 200 then
            pcolor = Color.new(255,0,0,255)
        else
            pcolor = Color.new(255,255,255,255)
        end
        --fps
        Render.Line(x + 90 - (i -1) * 5, y + offset + 130 - Clamp(cur,0,Menu.GetInt("i_fpsclamp")) * 75 / 320, x + 90 - i * 5, y + offset + 130 - Clamp(next,0,Menu.GetInt("i_fpsclamp")) * 75 / 320, fcolor, 1)
        --ping
        Render.Line(x + 90  - (i -1) * 5, y + (offset/2) + 20 - Clamp(pcur,0,Menu.GetInt("i_pingclamp")) * 75 / 320, x + 90 - i * 5, y + (offset/2) + 20 - Clamp(pnext,0,Menu.GetInt("i_pingclamp")) * 75 / 320, pcolor, 1)
    end
end

Hack.RegisterCallback("PaintTraverse", Draw)
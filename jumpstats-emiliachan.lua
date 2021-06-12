-- init menu
Menu.Text("jumpstats by emilia-chan")
Menu.Checkbox("Longjump indicator", "b_ljon", true)
Menu.SliderInt("Longjump minimum distance", "i_ljmindis", 0,300, "%1.f", 200)

-- vars
local startPos
local endPos
local lj
local height = 0
local lastlj = 0

local jumping = false

local drawingLJ = false
local ljVisible = false
local curAlpha = 0

local test = false

--offsets
local hObsTargetOffset = Hack.GetOffset("DT_BasePlayer", "m_hObserverTarget")
local fFlags_Offset = Hack.GetOffset("DT_BasePlayer", "m_fFlags")
local vOrigin_Offset = Hack.GetOffset("DT_BaseEntity", "m_vecOrigin")

-- help functions

local function color(dist)
    if dist >= 235 then
        return {255, 137, 34}
    elseif dist >= 230 then
        return {255, 33, 33}
    elseif dist >= 227 then
        return {57, 204, 96}
    elseif dist >= 225 then
        return {91, 225, 225}
    else
        return {170,170,170}
    end
end

local function round(number, decimals)
	local power = 10^decimals
	return math.floor(number * power) / power
end

function Lerp(val1, val2, time)
	return val1 * (1 - time) + val2 * time
end


-- actual functions

local function setupcommand()

    if not Menu.GetBool("b_ljon") then
        return
    end

    

    local pLocal = IEntityList.GetPlayer(IEngine.GetLocalPlayer())
    if not pLocal then return end
    
    local flags = pLocal:GetPropInt(fFlags_Offset)
    if not flags then return end
    
    

    if ljVisible and (IGlobalVars.realtime - lastlj > 4) then
        ljVisible = false
    end
    --starting lj

    if not IsBit(flags, 0) and (not jumping) then
        jumping = true
        startPos = pLocal:GetPropVector(vOrigin_Offset)
        if (not startPos) then return end
		endPos = nil
	end

    if (jumping) and (IsBit(flags, 0)) then
        
        endPos = pLocal:GetPropVector(vOrigin_Offset)
        if not endPos then return end
        

		local distX = math.abs(endPos.x - startPos.x)
		local distY = math.abs(endPos.y - startPos.y)
        local distZ = endPos.z - startPos.z -- up/down
        
        jumping = false

        local distance = (math.sqrt(distX*distX + distY*distY)) + 32
		if distance > Menu.GetInt("i_ljmindis") and distance < 300 then
			lj = distance
			height = distZ

			drawingLJ = true
			ljVisible = true
			lastlj = IGlobalVars.realtime
		end
	end
end

local function draw()
    if not Menu.GetBool("b_ljon") then return end
    
	local pLocal = IEntityList.GetPlayer(IEngine.GetLocalPlayer())
    if not pLocal then return end

    if drawingLJ and lj then
        
        local x = Globals.ScreenWidth() / 2
        local y = Globals.ScreenHeight() / 1.2 + 30
        local colour = color(lj)
        
        --fade in
        if ljVisible and curAlpha < 255 then
            curAlpha = Lerp(curAlpha, 255, 17 * IGlobalVars.frametime)
            if curAlpha > 254 then
				curAlpha = 255
			end
        end

        --fade out
        if not ljVisible then
        	curAlpha = Lerp(curAlpha, 0, 8 * IGlobalVars.frametime)
			if curAlpha < 1 then
				curAlpha = 0
				drawingLJ = false
			end
        end
        
        --render text
        local text = round(lj, 2) .. " units"
		if math.abs(height) > 7 then
			curAlpha = math.min(curAlpha, 100)
			text = text .. " [" .. round(height, 1) .." vert]"
        end
        
        Render.Text_1(text,x,y,25,Color.new(colour[1], colour[2], colour[3], curAlpha), true, true)
    end
end


Hack.RegisterCallback("PaintTraverse", draw)
Hack.RegisterCallback("CreateMove", setupcommand)







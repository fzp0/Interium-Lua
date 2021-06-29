Menu.Spacing()
Menu.Spacing()
Menu.Separator()
Menu.Text("Checkpoint lua by emilia-chan")
Menu.Spacing()
Menu.Checkbox("Enabled","b_velenabled",true)
Menu.Spacing()
Menu.Checkbox("Velocity cancellation", "b_velcancel", true)
Menu.Spacing()
Menu.Checkbox("Sounds", "b_velsounds", false)
Menu.Spacing()
Menu.Button("sv_cheats 1","svcheat1")
Menu.Spacing()
Menu.KeyBind("Checkpoint Key","k_GetPos",0)
Menu.Spacing()
Menu.KeyBind("Teleport Key","k_SetPos",0)
Menu.Spacing()
Menu.KeyBind("Prev Position Key","k_PrevPos",0)
Menu.Spacing()
Menu.KeyBind("Next Position Key","k_NextPos",0)
Menu.Spacing()
Menu.Separator()
--Menu.Spacing()
--Menu.KeyBind("Undo Position Key", "k_UndoPos", 0)

local fFlags_Offset = Hack.GetOffset("DT_BasePlayer", "m_fFlags")
local vVelocity_Offset = Hack.GetOffset("DT_BasePlayer", "m_vecVelocity[0]")

g_fLastUndo = 0
CurrentCP = -1
CounterCP = 0
OverallCP = 0
OverallTP = 0
CpLimit = 10

posx = {}
viewangx = {}

posy = {}
viewangy = {}

posz = {}

hAng = QAngle.new(0,0,0)
hPos = Vector.new(0,0,0)
--current angles
undoang = Vector.new(0,0,0)
undopos = Vector.new(0,0,0)
--previous angles

colon = Color.new(255, 225, 225, 200)
coloff = Color.new(255, 210, 35, 125)

onground = 0
MoveType_LADDER = 9

invalidundoground = false

Hotkey_status = {
get = false,
set = false,
prev = false,
nex = false,
undo = false,
}


--viewangles for velcancellation
local viewangles = QAngle.new(0,0,0)
local unmove = false


local function doteleport(pos)
	if Menu.GetBool("b_velenabled") == false then
		return
	end

	local pLocal = IEntityList.GetPlayer(IEngine.GetLocalPlayer())
	if (not pLocal) then 
        return
	end
	
	if (not Utils.IsLocalAlive()) then
		return
	end
	local Flags = pLocal:GetPropInt(fFlags_Offset)
	local iMoveType = pLocal:GetMoveType()

	local current = CurrentCP
	local counter = CounterCP

	local toplay = Menu.GetBool("b_velsounds")

	if OverallCP > CpLimit then
		
		if(current == CpLimit - 1 and pos == 1) then
			CurrentCP = -1
			current = -1
		end

		if(current == 0 and pos == -1) then
			CurrentCP = CpLimit
			current = CpLimit
		end

	else
		if(current == CounterCP - 1 and pos == 1) then
			CurrentCP = -1
			current = -1
		end

		if(current == 0 and pos == -1) then
			CurrentCP = counter
			current = counter
		end	
	end

	local actual = current + pos

	if(actual < 0 or actual > OverallCP) then
		IChatElement.ChatPrintf(0, 0, "[Checkpoint] No Checkpoints Found!")
	else

		
		OverallTP = OverallTP + 1
		--set vel vector to 0 here later
		undopos = pLocal:GetAbsOrigin()
		IEngine.GetViewAngles(undoang)

		if(iMoveType == MoveType_LADDER) then
			invalidundoground = false
		else
			invalidundoground = false
		end

		IEngine.ExecuteClientCmd("setpos_exact " .. tostring(posx[actual]) .. " " .. tostring(posy[actual]) .. " " .. tostring(posz[actual]))
		IEngine.ExecuteClientCmd("setang_exact " .. tostring(viewangx[actual]) .. " " .. tostring(viewangy[actual]))
		CurrentCP = CurrentCP + pos
		if toplay then IEngine.ExecuteClientCmd("playvol buttons\\blip1 1") end
	end
end


local cancellation = false

local function teleport(cmd)
	if Menu.GetBool("b_velenabled") == false then
		return
	end

	local pLocal = IEntityList.GetPlayer(IEngine.GetLocalPlayer())
	if (not pLocal) then 
        return
	end
	
	if (not Utils.IsLocalAlive()) then
		return
	end

	local Flags = pLocal:GetPropInt(fFlags_Offset)
	IEngine.GetViewAngles(viewangles)
	local vecvelocity = pLocal:GetPropVector(vVelocity_Offset)
	
	if Menu.GetBool("svcheat1") then
		IEngine.ExecuteClientCmd("sv_cheats 1")
	end
	
	if InputSys.IsKeyDown(Menu.GetInt("k_GetPos")) == Hotkey_status.get and InputSys.IsKeyDown(Menu.GetInt("k_SetPos")) == Hotkey_status.set and InputSys.IsKeyDown(Menu.GetInt("k_NextPos")) == Hotkey_status.nex and InputSys.IsKeyDown(Menu.GetInt("k_PrevPos")) == Hotkey_status.prev then
		return
	end
	
	Hotkey_status.get = InputSys.IsKeyDown(Menu.GetInt("k_GetPos"))
	Hotkey_status.set = InputSys.IsKeyDown(Menu.GetInt("k_SetPos"))
	Hotkey_status.nex = InputSys.IsKeyDown(Menu.GetInt("k_NextPos"))
	Hotkey_status.prev = InputSys.IsKeyDown(Menu.GetInt("k_PrevPos"))
	Hotkey_status.undo = InputSys.IsKeyDown(Menu.GetInt("k_UndoPos"))
	-- button status managment
	

	--if Hotkey_status.undo then
	--
	--	local fLastUndo = pLocal:curtime()  - g_fLastUndo
	--	local Flags = pLocal:GetPropInt(fFlags_Offset)
	--
	--	if(Utils.IsLocalAlive() and (not invalidundoground) and fLastUndo > 1) then
	--		if(undopos.x == 0 and undopos.y == 0 and undopos.z == 0) then
	--			return
	--		end
	--		
	--		if IsBit(Flags,onground) then
	--			g_fLastUndo = pLocal:curtime()
	--			IEngine.ExecuteClientCmd("setpos_exact " .. tostring(undopos.x) .. " " .. tostring(undopos.y) .. " " .. tostring(undopos.z))
	--			IEngine.ExecuteClientCmd("setang_exact " .. tostring(undoang.pitch) .. " " .. tostring(undoang.yaw))
	--
	--		else
	--			IEngine.ExecuteClientCmd("playvol buttons\\button10 1")	
	--			IChatElement.ChatPrintf(0, 0, "[Checkpoint] Undo in air!")
	--		end
	--	else
	--		if invalidundoground then
	--			IEngine.ExecuteClientCmd("playvol buttons\\button10 1")	
	--			IChatElement.ChatPrintf(0, 0, "[Checkpoint] Undo on ladder!")
	--		end
	--	end
	--	return
	--end
	

	
	local toplay = Menu.GetBool("b_velsounds")

	if Hotkey_status.prev then
		if CurrentCP == -1 then
			if toplay then IEngine.ExecuteClientCmd("playvol buttons\\button10 1") end
			IChatElement.ChatPrintf(0, 0, "[Checkpoint] No Checkpoints Found!")
			return
		end
		doteleport(-1)
		return
	end	

	
	if Hotkey_status.nex then
		if CurrentCP == -1 then
			if toplay then IEngine.ExecuteClientCmd("playvol buttons\\button10 1") end
			IChatElement.ChatPrintf(0, 0, "[Checkpoint] No Checkpoints Found!")
			return
		end	
		doteleport(1)
		return
	end
	

	-- make string arrays and then at the teleport compile them back into vectors / qangles

	if Hotkey_status.get then
		
		if (IsBit(Flags,onground)) then
			if (CpLimit == CounterCP) then
				CurrentCP = -1
				CounterCP = 0
			end
			hPos = pLocal:GetAbsOrigin()
			IEngine.GetViewAngles(hAng)

			posx[CounterCP] = hPos.x
			posy[CounterCP] = hPos.y
			posz[CounterCP] = hPos.z
			viewangx[CounterCP] = hAng.pitch
			viewangy[CounterCP] = hAng.yaw

			CurrentCP = CounterCP
			CounterCP = CounterCP + 1
			OverallCP = OverallCP + 1
			IChatElement.ChatPrintf(0, 0, "[Checkpoint] Saved Checkpoint!")
			if toplay then IEngine.ExecuteClientCmd("playvol buttons\\blip1 1") end
		else
			IChatElement.ChatPrintf(0, 0, "[Checkpoint] Not on ground!")
			if toplay then IEngine.ExecuteClientCmd("playvol buttons\\button10 1") end
		end	
		
	end


	if Hotkey_status.set then

		cancellation = true
		doteleport(0)
	end

	if cancellation == true then
		if math.sqrt(vecvelocity.x * vecvelocity.x + vecvelocity.y * vecvelocity.y) < 15 then
			cancellation = false
			return
		end
		
		if Menu.GetBool("b_velcancel") then

			if ~(IsBit(cmd.buttons, 8)  or IsBit(cmd.buttons, 9) or IsBit(cmd.buttons, 2) or IsBit(cmd.buttons, 3)) then
				local vec_direction = QAngle.new()
				Math.VectorAngles(vecvelocity, vec_direction)

				vec_direction.yaw = cmd.viewangles.yaw - vec_direction.yaw
				local forward = Vector.new()
				Math.AngleVectors(vec_direction, forward)

				local vec_negated_direction = forward * math.sqrt(vecvelocity.x * vecvelocity.x + vecvelocity.y * vecvelocity.y);

				cmd.forwardmove = vec_negated_direction.x
				cmd.sidemove = vec_negated_direction.y
			end
			
		end
	end

end
	
local function ui()

	if Menu.GetBool("b_velenabled") == false then
		return
	end
	
	if (not Utils.IsLocalAlive()) then return end
	
	local pLocal = IEntityList.GetPlayer(IEngine.GetLocalPlayer())
	if (not pLocal) then
        return
    end

	--Render.Text_1(pos[CounterCP], 400, Globals.ScreenHeight() / 2 - 80, 25, colon, false, true)
	
	if Hotkey_status.get then
		Render.Text_1("1. Checkpoint", 3, Globals.ScreenHeight() / 2 - 80, 25, colon, false, true)
	else
		Render.Text_1("1. Checkpoint", 3, Globals.ScreenHeight() / 2 - 80, 25, coloff, false, true)
	end

	if Hotkey_status.set then
		Render.Text_1("2. Teleport", 3, Globals.ScreenHeight() / 2 - 55, 25, colon, false, true)
	else
		Render.Text_1("2. Teleport", 3, Globals.ScreenHeight() / 2 - 55, 25, coloff, false, true)
	end
	
	if Hotkey_status.prev then
		Render.Text_1("3. Prev Pos", 3, Globals.ScreenHeight() / 2 - 30, 25, colon, false, true)
	else
		Render.Text_1("3. Prev Pos", 3, Globals.ScreenHeight() / 2 - 30, 25, coloff, false, true)
	end

	if Hotkey_status.nex then
		Render.Text_1("4. Next Pos", 3, Globals.ScreenHeight() / 2 - 5, 25, colon, false, true)
	else
		Render.Text_1("4. Next Pos", 3, Globals.ScreenHeight() / 2 - 5, 25, coloff, false, true)
	end
	
	


	
	--if Hotkey_status.undo then
	--	Render.Text_1("5. Undo Pos", 3, Globals.ScreenHeight() / 2 + 20, 25, colon, false, true)
	--else
	--	Render.Text_1("5. Undo Pos", 3, Globals.ScreenHeight() / 2 + 20, 25, coloff, false, true)
	--end
	
end

Hack.RegisterCallback("CreateMove", teleport)
Hack.RegisterCallback("PaintTraverse", ui)
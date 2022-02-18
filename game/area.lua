-- The equivalents of this file in n64decomp/sm64 are 'src/game/area.c' and 'src/game/area.h'
-- The equivalent of this file in sm64js is 'src/game/Area.js'

local function Area()
	return {
		index = -0x00,
		flags = -0x00, -- Only has 1 flag: 0x01 = Is this the active area?
		terrainType = 0x0000, -- default terrain of the level (set from level script cmd 0x31)
		unk04 = nil, -- geometry layout data
		terrainData = nil, -- collision data (set from level script cmd 0x2E)
		surfaceRooms = nil, -- (set from level script cmd 0x2F)
		macroObjects = nil, -- Macro Objects Ptr (set from level script cmd 0x39)
		warpNodes = nil,
		paintingWarpNodes = nil,
		instantWarps = nil,
		objectSpawnInfos = nil,
		camera = nil,
		unused = nil, -- Filled by level script 0x3A, but is unused.
		whirlpools = {nil, nil}, -- Level start dialog number (set by level script cmd 0x30)
		dialog = {0x00, 0x00},
		musicParam = 0x0000,
		musicParam2 = 0x0000,
	}
end

-- All the transition data to be used in screen_transition
local function WarpTransitionData()
	return {
		red = 0x00,
		green = 0x00,
		blue = 0x00,
		
		startTexRadius = -0x0000,
		endTexRadius = -0x0000,
		startTexX = -0x0000,
		startTexY = -0x0000,
		endTexX = -0x0000,
		endTexY = -0x0000,
		
		texTimer = -0x0000, -- always 0, does seems to affect transition when disabled
	}
end

local function WarpTransition()
	return {
		isActive = false, -- Is the transition active. (either true or false)
		type = 0x00, -- Determines the type of transition to use (circle, star, etc.)
		time = 0x00, -- Amount of time to complete the transition (in frames)
		pauseRendering = false, -- Should the game stop rendering. (either true or false)
		data = WarpTransitionData(),
	}
end

local gAreaData = {}
for i=1, 8 do
	gAreaData[i] = Area()
end

local gWarpTransition = WarpTransition()

gAreas = gAreaData
gCurrentArea = nil
local D_8032CE74 = nil
local D_8032CE78 = nil
local gWarpTransDelay = 0
local gWarpTransFBSetColor = Color(0, 0, 0, 0)
local gWarpTransRed = 0
local gWarpTransGreen = 0
local gWarpTransBlue = 0

local gNoControllerMsg = "NO CONTROLLER"
if VERSION_EU then
	gNoControllerMsg = {
		gNoControllerMsg,
		"MANETTE DEBRANCHEE",
		"CONTROLLER FEHLT"
	}
end

local function set_warp_transition_rgb(red, green, blue)
	gWarpTransFBSetColor = Color(red, green, blue)
	gWarpTransRed = red
	gWarpTransGreen = green
	gWarpTransBlue = blue
end

function clear_areas()
	gCurrentArea = nil
	--gWarpTransition.isActive = false
	--gWarpTransition.pauseRendering = false
	--gMarioSpawnInfo.areaIndex = -1
	
	for i=1, 8 do
		local area = gAreaData[i]
		area.index = i
		area.flags = 0x00
		area.terrainType = 0x0000
		area.unk04 = nil
		area.terrainData = nil
		area.surfaceRooms = nil
		area.macroObjects = nil
		area.warpNodes = nil
		area.paintingWarpNodes = nil
		area.instantWarps = nil
		area.objectSpawnInfos = nil
		area.camera = nil
		area.unused = nil
		area.whirlpools[1] = nil
		area.whirlpools[2] = nil
		area.dialog[1] = DIALOG_NONE or 0x00 -- TODO: Remove 0x00 fallback for DIALOG_NONE
		area.dialog[2] = DIALOG_NONE or 0x00
		area.musicParam = 0
		area.musicParam2 = 0
	end
end

function load_area(index)
	if not gCurrentArea and gAreaData[index].unk04 then
		gCurrentArea = gAreaData[index]
		gCurrAreaIndex = gCurrentArea.index
		
		if gCurrentArea.terrainData then
			-- TODO: Handle terrainData in load_area
		end
		
		if gCurrentArea.objectSpawnInfos then
			-- TODO: Handle objectSpawnInfos in load_area
		end
		
		--load_obj_warp_nodes()
		--geo_call_global_function_nodes(gCurrentArea.unk04.node, GEO_CONTEXT_AREA_LOAD)
	end
end

function unload_area()
	if gCurrentArea then
		--unload_objects_from_area(0, gCurrentArea.index)
		--geo_call_global_function_nodes(gCurrentArea.unk04.node, GEO_CONTEXT_AREA_UNLOAD)
		
		gCurrentArea = nil
		gWarpTransition.isActive = false
	end
end

function play_transition(transType, time, red, green, blue)
	printf("[play_transition] transType: %d, time: 0x%02x, red: 0x%02x, green: 0x%02x, blue: 0x%02x\n", transType or -1, time or -1, red or -1, green or -1, blue or -1)
	gWarpTransition.isActive = true
	gWarpTransition.type = transType
	gWarpTransition.time = time
	gWarpTransition.pauseRendering = false
	
	-- The lowest bit of transType determines if the transition is fading in or out.
	if bit.band(transType, 1) ~= 0 then
		set_warp_transition_rgb(red, green, blue)
	else
		red, green, blue = gWarpTransRed, gWarpTransGreen, gWarpTransBlue
	end
	
	if transType < 8 then -- if transition is RGB
		gWarpTransition.data.red = red
		gWarpTransition.data.green = green
		gWarpTransition.data.blue = blue
	else -- if transition is textured
		errorf("transType %d not implemented", transType)
	end
end

function render_game()
	render.setRGBA(255, 0, 0, 255)
	render.drawRect(0, 0, 512, 16)
	if gCurrentArea and not gWarpTransition.pauseRendering then
		render.enableScissorRect(0, BORDER_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-BORDER_HEIGHT)
		--render_hud()
		
		render.enableScissorRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
		--render_text_labels()
		--do_cutscene_handler()
		--print_displaying_credits_entry()
		
		render.enableScissorRect(0, BORDER_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-BORDER_HEIGHT)
		--render_menus_and_dialogs()
		
		if D_8032CE78 then
			make_viewport_clip_rect(D_8032CE78)
		else
			render.enableScissorRect(0, BORDER_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-BORDER_HEIGHT)
		end
		
		if gWarpTransition.isActive then
			osdprintf("gWarpTransDelay: %d\n", gWarpTransDelay)
			if gWarpTransDelay == 0 then
				gWarpTransition.isActive = not render_screen_transition(1, gWarpTransition.type, gWarpTransition.time, gWarpTransition.data)
				if not gWarpTransition.isActive then
					if bit.band(gWarpTransition.type, 1) ~= 0 then
						gWarpTransition.pauseRendering = true
					else
						set_warp_transition_rgb(0, 0, 0)
					end
				end
			else
				gWarpTransDelay = gWarpTransDelay-1
			end
		end
	else
		--render_text_labels()
		if D_8032CE78 then
			clear_viewport(D_8032CE78, gWarpTransFBSetColor)
		else
			clear_framebuffer(gWarpTransFBSetColor)
		end
	end
	
	D_8032CE74 = nil
	D_8032CE78 = nil
end

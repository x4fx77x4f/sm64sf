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

WARP_TRANSITION_FADE_FROM_COLOR = 0x00
WARP_TRANSITION_FADE_INTO_COLOR = 0x01
WARP_TRANSITION_FADE_FROM_STAR = 0x08
WARP_TRANSITION_FADE_INTO_STAR = 0x09
WARP_TRANSITION_FADE_FROM_CIRCLE = 0x0A
WARP_TRANSITION_FADE_INTO_CIRCLE = 0x0B
WARP_TRANSITION_FADE_FROM_MARIO = 0x10
WARP_TRANSITION_FADE_INTO_MARIO = 0x11
WARP_TRANSITION_FADE_FROM_BOWSER = 0x12
WARP_TRANSITION_FADE_INTO_BOWSER = 0x13

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

function render_game() end

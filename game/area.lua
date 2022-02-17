-- The equivalents of this file in n64decomp/sm64 are 'src/game/area.c' and 'src/game/area.h'
-- The equivalent of this file in sm64js is 'src/game/Area.js'

local function Area()
	return {
		index = 0x00,
		flags = 0x00,
		terrainType = 0x0000,
		unk04 = nil,
		terrainData = nil,
		surfaceRooms = nil,
		macroObjects = nil,
		warpNodes = nil,
		paintingWarpNodes = nil,
		instantWarps = nil,
		objectSpawnInfos = nil,
		camera = nil,
		unused = nil,
		whirlpools = {nil, nil},
		dialog = {0x00, 0x00},
		musicParam = 0x0000,
		musicParam2 = 0x0000,
	}
end

local gAreaData = {}
for i=1, 8 do
	gAreaData[i] = Area()
end

gAreas = gAreaData
gCurrentArea = nil

local gNoControllerMsg = "NO CONTROLLER"
if VERSION_EU then
	gNoControllerMsg = {
		gNoControllerMsg,
		"MANETTE DEBRANCHEE",
		"CONTROLLER FEHLT"
	}
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

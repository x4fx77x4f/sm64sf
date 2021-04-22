local gPlayerSpawnInfos = {{}}
local D_8033A160 = {}
for i=1, 0x100 do
	D_8033A160[i] = {}
end
local gAreaData = {{}, {}, {}, {}, {}, {}, {}, {}}

local gWarpTransition = {data={}}

local gCurrCourseNum
local gCurrActNum
local gCurrAreaIndex
local gSavedCourseNum
local gPauseScreenMode
local gSaveOptSelectIndex

local gMarioSpawnInfo = gPlayerSpawnInfos[1] -- This won't work. Fucking pointer bullshit.
local gLoadedGraphNodes = D_8033A160
gAreas = gAreaData
local gCurrentArea = nil
local gCurrCreditsEntry = nil
local D_8032CE74 = nil
local D_8032CE78 = nil
local gWarpTransDelay = 0
local gFBSetColor = 0
local gWarpTransFBSetColor = 0
local gWarpTransRed = 0
local gWarpTransGreen = 0
local gWarpTransBlue = 0
local gCurrSaveFileNum = 1
local gCurrLevelNum = LEVEL_MIN

function print_intro_text()
	if bit.band(gGlobalTimer, 0x1F) < 20 then
		if gControllerBits == 0 then
			print_text_centered(SCREEN_WIDTH / 2, 20, "NO CONTROLLER")
		else
			print_text_centered(60, 38, "PRESS")
			print_text_centered(60, 20, "START")
		end
	end
end

function clear_areas()
	
end

function load_area(index)
	if gCurrentArea == nil and gAreaData[index].unk04 ~= nil then
		gCurrentArea = gAreaData[index]
		gCurrAreaIndex = gCurrentArea.index
		
		if gCurrentArea.terrainData ~= nil then
			load_area_terrain(index, gCurrentArea.terrainData, gCurrentArea.surfaceRooms, gCurrentArea.macroObjects)
		end
		
		if gCurrentArea.objectSpawnInfos ~= nil then
			spawn_objects_from_info(0, gCurrentArea.objectSpawnInfos)
		end
		
		--load_obj_warp_nodes()
		--geo_call_global_function_nodes(gCurrentArea.unk04.node, GEO_CONTEXT_AREA_LOAD)
	end
end

function unload_area()
	if gCurrentArea ~= nil then
		--unload_objects_from_area(0, gCurrentArea.index)
		--geo_call_global_function_nodes(gCurrentArea.unk04.node, GEO_CONTEXT_AREA_UNLOAD)
		
		gCurrentArea.flags = 0 -- redundant?
		gCurrentArea = nil
		gWarpTransition.isActive = false
	end
end

function render_game()
	if gCurrentArea ~= nil and not gWarpTransition.pauseRendering then
		--gDPSetScissor()
		--render_hud()
		
		--gDPSetScissor()
		--render_text_labels()
		--do_cutscene_handler()
		--print_displaying_credits_entry()
		--gDPSetScissor()
		--gPauseScreenMode = render_menus_and_dialogs
	else
		--render_text_labels()
		if D_8032CE78 ~= nil then
			clear_viewport(D_8032CE78, gWarpTransFBSetColor)
		else
			clear_frame_buffer(gWarpTransFBSetColor)
		end
	end
	
	D_8032CE74 = nil
	D_8032CE78 = nil
end

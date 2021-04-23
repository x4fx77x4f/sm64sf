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
gCurrentArea = nil
local gCurrCreditsEntry = nil
local D_8032CE74 = nil
local D_8032CE78 = nil
local gWarpTransDelay = 0
local gFBSetColor = 0
local gWarpTransFBSetColor = Color(0, 0, 0)
local gWarpTransRed = 0
local gWarpTransGreen = 0
local gWarpTransBlue = 0
local gCurrSaveFileNum = 1
local gCurrLevelNum = LEVEL_MIN

function set_warp_transition_rgb(red, green, blue)
	gWarpTransFBSetColor = Color(red, green, blue)
	gWarpTransRed = red
	gWarpTransGreen = green
	gWarpTransBlue = blue
end

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

-- Sets up the information needed to play a warp transition, including the
-- transition type, time in frames, and the RGB color that will fill the screen.
function play_transition(transType, time, red, green, blue)
	gWarpTransition.isActive = true
	gWarpTransition.type = transType
	gWarpTransition.time = time
	gWarpTransition.pauseRendering = false
	
	-- The lowest bit of transType determines if the transition is fading in or out.
	if bit.band(transType, 1) ~= 0 then
		set_warp_transition_rgb(red, green, blue)
	else
		red = gWarpTransRed
		green = gWarpTransGreen
		blue = gWarpTransBlue
	end
	
	if transType < 8 then -- if transition is RGB
		gWarpTransition.data.red = red
		gWarpTransition.data.green = green
		gWarpTransition.data.blue = blue
	else -- if transition is textured
		gWarpTransition.data.red = red
		gWarpTransition.data.green = green
		gWarpTransition.data.blue = blue
		
		-- TODO: add texture support to play_transition
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
		
		if gWarpTransition.isActive then
			if gWarpTransDelay == 0 then
				gWarpTransition.isActive = not render_screen_transition(
					0,
					gWarpTransition.type,
					gWarpTransition.time,
					gWarpTransition.data
				)
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
		if D_8032CE78 ~= nil then
			clear_viewport(D_8032CE78, gWarpTransFBSetColor)
		else
			clear_frame_buffer(gWarpTransFBSetColor)
		end
	end
	
	D_8032CE74 = nil
	D_8032CE78 = nil
end

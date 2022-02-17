-- The equivalents of this file in n64decomp/sm64 are 'include/level_commands.h' and 'src/engine/level_script.c'
-- The equivalent of this file in sm64js is 'src/engine/LevelCommands.js'

OP_AND = 0
OP_NAND = 1
OP_EQ = 2
OP_NEQ = 3
OP_LT = 4
OP_LEQ = 5
OP_GT = 6
OP_GEQ = 7

OP_SET = 0
OP_GET = 1

VAR_CURR_SAVE_FILE_NUM = 0
VAR_CURR_COURSE_NUM = 1
VAR_CURR_ACT_NUM = 2
VAR_CURR_LEVEL_NUM = 3
VAR_CURR_AREA_INDEX = 4

WARP_CHECKPOINT = 0x80
WARP_NO_CHECKPOINT = 0x00

WHIRLPOOL_COND_ALWAYS = 0
WHIRLPOOL_COND_BOWSER2_BEATEN = 2
WHIRLPOOL_COND_AT_LEAST_SECOND_STAR = 3

-- Head defines
REGULAR_FACE = 0x0002
DIZZY_FACE = 0x0003

local SCRIPT_RUNNING = 1
local SCRIPT_PAUSED = 0
local SCRIPT_PAUSED2 = -1 

local sStack = {}

local sLevelPool = {}

local sDelayFrames = 0
local sDelayFrames2 = 0

local sCurrAreaIndex = -1

local sScriptStatus
local sRegister
local sCurrentCmd
local sCurrentIndex

local function wrap(i, macro_name, func)
	func = func or function()
		errorf("level command '%s' not implemented", macro_name)
	end
	_G[macro_name] = function(...)
		return {i, func, {...}}
	end
end

local function level_cmd_load_and_execute(args)
	-- The first three parameters are only relevant on real hardware, so they can be ignored.
	table.insert(sStack, sCurrentCmd)
	table.insert(sStack, sCurrentIndex)
	sCurrentCmd = assertf(args[4], "tried to EXECUTE non-existent script from %d", sCurrentIndex)
	return 1
end

local function level_cmd_exit_and_execute(args)
	-- The first three parameters are only relevant on real hardware, so they can be ignored.
	sCurrentCmd = assertf(args[4], "tried to EXIT_AND_EXECUTE non-existent script from %d", sCurrentIndex)
	return 1
end

local function level_cmd_sleep(args)
	sScriptStatus = SCRIPT_PAUSED
	if sDelayFrames == 0 then
		sDelayFrames = args[1]
		return sCurrentIndex
	else
		sDelayFrames = sDelayFrames-1
		if sDelayFrames == 0 then
			sScriptStatus = SCRIPT_RUNNING
		else
			return sCurrentIndex
		end
	end
end

local function level_cmd_sleep2(args)
	sScriptStatus = SCRIPT_PAUSED
	if sDelayFrames == 0 then
		sDelayFrames2 = args[1]
		return sCurrentIndex
	else
		sDelayFrames2 = sDelayFrames2-1
		if sDelayFrames2 == 0 then
			sScriptStatus = SCRIPT_RUNNING
		else
			return sCurrentIndex
		end
	end
end

local function level_cmd_jump(args)
	sCurrentCmd = args[1]
	return 1
end

local function level_cmd_call(args)
	local func = args[2]
	assertf(func, "tried to CALL non-existent function from %d", sCurrentIndex)
	sRegister = func(args[1], sRegister)
end

local function level_cmd_set_register(args)
	sRegister = args[1]
end

local function level_cmd_load_to_fixed_address(args) end

local function level_cmd_load_raw(args) end

local function level_cmd_load_mio0(args) end

local function level_cmd_init_level(args)
	--init_graph_node_start(nil, gObjParentGraphNode)
	--clear_objects()
	clear_areas()
	--main_pool_push_state()
end

local function level_cmd_clear_level(args)
	--clear_objects()
	--clear_area_graph_nodes()
	clear_areas()
	--main_pool_pop_state()
end

local function level_cmd_alloc_level_pool(args) end

local function level_cmd_free_level_pool(args) end

local function level_cmd_begin_area(args)
	local areaIndex = args[1]
	local geoLayout = args[2]
	
	if areaIndex < 8 then
		local screenArea = process_geo_layout(sLevelPool, geoLayout)
		local node = nil and screenArea.views[0] -- TODO: Don't forget to undo this hack once geo_layout is implemented
		
		sCurrAreaIndex = areaIndex
		screenArea.areaIndex = areaIndex
		gAreas[areaIndex].unk04 = screenArea
		
		gAreas[areaIndex].camera = node and node.config.camera or nil
	end
end

local function level_cmd_end_area(args)
	sCurrAreaIndex = -1
end

local function level_cmd_set_transition(args)
	if gCurrentArea then
		play_transition(args[1], args[2], args[3], args[4], args[5])
	end
end

local function level_cmd_set_blackout(args)
	-- TODO: Unstub BLACKOUT
end

local function level_cmd_load_area(args)
	local areaIndex = args[1]
	
	--stop_sounds_in_continuous_banks()
	load_area(areaIndex)
end

local function level_cmd_unload_area(args)
	unload_area()
end

wrap(0x00, 'EXECUTE', level_cmd_load_and_execute)
wrap(0x01, 'EXIT_AND_EXECUTE', level_cmd_exit_and_execute)
wrap(0x02, 'EXIT', level_cmd_exit)
wrap(0x03, 'SLEEP', level_cmd_sleep)
wrap(0x04, 'SLEEP_BEFORE_EXIT', level_cmd_sleep2)
wrap(0x05, 'JUMP', level_cmd_jump)
wrap(0x06, 'JUMP_LINK', level_cmd_jump_and_link)
wrap(0x07, 'RETURN', level_cmd_return)
wrap(0x08, 'JUMP_LINK_PUSH_ARG', level_cmd_jump_and_link_push_arg)
wrap(0x09, 'JUMP_N_TIMES', level_cmd_jump_repeat)
wrap(0x0A, 'LOOP_BEGIN', level_cmd_loop_begin)
wrap(0x0B, 'LOOP_UNTIL', level_cmd_loop_until)
wrap(0x0C, 'JUMP_IF', level_cmd_jump_if)
wrap(0x0D, 'JUMP_LINK_IF', level_cmd_jump_and_link_if)
wrap(0x0E, 'SKIP_IF', level_cmd_skip_if)
wrap(0x0F, 'SKIP', level_cmd_skip)
wrap(0x10, 'SKIP_NOP', level_cmd_skippable_nop)
wrap(0x11, 'CALL', level_cmd_call)
wrap(0x12, 'CALL_LOOP', level_cmd_call_loop)
wrap(0x13, 'SET_REG', level_cmd_set_register)
wrap(0x14, 'PUSH_POOL', level_cmd_push_pool_state)
wrap(0x15, 'POP_POOL', level_cmd_pop_pool_state)
wrap(0x16, 'FIXED_LOAD', level_cmd_load_to_fixed_address)
wrap(0x17, 'LOAD_RAW', level_cmd_load_raw)
wrap(0x18, 'LOAD_MIO0', level_cmd_load_mio0)
wrap(0x19, 'LOAD_MARIO_HEAD', level_cmd_load_mario_head)
wrap(0x1A, 'LOAD_MIO0_TEXTURE', level_cmd_load_mio0_texture)
wrap(0x1B, 'INIT_LEVEL', level_cmd_init_level)
wrap(0x1C, 'CLEAR_LEVEL', level_cmd_clear_level)
wrap(0x1D, 'ALLOC_LEVEL_POOL', level_cmd_alloc_level_pool)
wrap(0x1E, 'FREE_LEVEL_POOL', level_cmd_free_level_pool)
wrap(0x1F, 'AREA', level_cmd_begin_area)
wrap(0x20, 'END_AREA', level_cmd_end_area)
wrap(0x21, 'LOAD_MODEL_FROM_DL', level_cmd_load_model_from_dl)
wrap(0x22, 'LOAD_MODEL_FROM_GEO', level_cmd_load_model_from_geo)
wrap(0x23, 'CMD23', level_cmd_23)
wrap(0x24, 'OBJECT_WITH_ACTS', level_cmd_place_object)
function OBJECT(model, posX, posY, posZ, angleX, angleY, angleZ, behParam, beh)
	return OBJECT_WITH_ACTS(model, posX, posY, posZ, angleX, angleY, angleZ, behParam, beh, 0x1F)
end
wrap(0x25, 'MARIO', level_cmd_init_mario)
wrap(0x26, 'WARP_NODE', level_cmd_create_warp_node)
wrap(0x27, 'PAINTING_WARP_NODE', level_cmd_create_painting_warp_node)
wrap(0x28, 'INSTANT_WARP', level_cmd_create_instant_warp)
wrap(0x29, 'LOAD_AREA', level_cmd_load_area)
wrap(0x2A, 'CMD2A', level_cmd_unload_area)
wrap(0x2B, 'MARIO_POS', level_cmd_set_mario_start_pos)
wrap(0x2C, 'CMD2C', level_cmd_2C)
wrap(0x2D, 'CMD2D', level_cmd_2D)
wrap(0x2E, 'TERRAIN', level_cmd_set_terrain_data)
wrap(0x2F, 'ROOMS', level_cmd_set_rooms)
wrap(0x30, 'SHOW_DIALOG', level_cmd_show_dialog)
wrap(0x31, 'TERRAIN_TYPE', level_cmd_set_terrain_type)
wrap(0x32, 'NOP', level_cmd_nop)
wrap(0x33, 'TRANSITION', level_cmd_set_transition)
wrap(0x34, 'BLACKOUT', level_cmd_set_blackout)
wrap(0x35, 'GAMMA', level_cmd_set_gamma)
wrap(0x36, 'SET_BACKGROUND_MUSIC', level_cmd_set_music)
wrap(0x37, 'SET_MENU_MUSIC', level_cmd_set_menu_music)
wrap(0x38, 'STOP_MUSIC', level_cmd_38)
wrap(0x39, 'MACRO_OBJECTS', level_cmd_set_macro_objects)
wrap(0x3A, 'CMD3A', level_cmd_3A)
wrap(0x3B, 'WHIRLPOOL', level_cmd_create_whirlpool)
wrap(0x3C, 'GET_OR_SET', level_cmd_get_or_set_var)

function level_script_execute(cmd, index)
	sScriptStatus = SCRIPT_RUNNING
	sCurrentCmd = cmd
	sCurrentIndex = index
	
	while sScriptStatus == SCRIPT_RUNNING do
		local cmd = sCurrentCmd[sCurrentIndex]
		local new_index = cmd[2](cmd[3])
		sCurrentIndex = new_index or sCurrentIndex+1
	end
	osdprintf("sScriptStatus: %2i\nsCurrentCmd: 0x%02x\n", sScriptStatus, sCurrentCmd[sCurrentIndex][1])
	
	render_game()
	
	return sCurrentCmd, sCurrentIndex
end

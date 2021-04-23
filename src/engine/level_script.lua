local SCRIPT_RUNNING = 1
local SCRIPT_PAUSED = 0
local SCRIPT_PAUSED2 = -1

local sStack = {}

local sLevelPool = nil

local sDelayFrames = 0
local sDelayFrames2 = 0

local sCurrAreaIndex = -1

local sStackTop = sStack
local sStackBase = nil

--sScriptStatus
local sRegister
--sCurrentCmds
sCurrentCmdOffset = 1
--sCurrentCmd

local function CMD_NEXT()
	sCurrentCmdOffset = sCurrentCmdOffset+1
	sCurrentCmd = sCurrentCmds[sCurrentCmdOffset]
end

local function level_cmd_load_and_execute(entry)
	assertf(entry, "tried to execute null level script from %s at %d", _GR[sCurrentCmds], sCurrentCmdOffset)
	
	sStackTop = sStackTop
	
	sCurrentCmds = entry
	sCurrentCmdOffset = 1
	sCurrentCmd = sCurrentCmds[sCurrentCmdOffset]
end

local function level_cmd_exit_and_execute(entry)
	assertf(entry, "tried to execute null level script from %s at %d", _GR[sCurrentCmds], sCurrentCmdOffset)
	
	local targetAddr = entry
	
	sStackTop = sStackBase
	sCurrentCmds = targetAddr
	sCurrentCmdOffset = 1
	sCurrentCmd = sCurrentCmds[sCurrentCmdOffset]
end

local function level_cmd_sleep(frames)
	sScriptStatus = SCRIPT_PAUSED
	
	if sDelayFrames == 0 then
		sDelayFrames = frames
	else
		sDelayFrames = sDelayFrames-1
		if sDelayFrames == 0 then
			sScriptStatus = SCRIPT_RUNNING
			return CMD_NEXT()
		end
	end
end

local function level_cmd_sleep2(frames)
	sScriptStatus = SCRIPT_PAUSED2
	
	if sDelayFrames == 0 then
		sDelayFrames = frames
	else
		sDelayFrames = sDelayFrames-1
		if sDelayFrames == 0 then
			sScriptStatus = SCRIPT_RUNNING
			return CMD_NEXT()
		end
	end
end

level_cmd_skippable_nop = CMD_NEXT

local function level_cmd_call(arg, func)
	sRegister = func(arg, sRegister)
	
	if sRegister == 0 then
		sScriptStatus = SCRIPT_PAUSED
	else
		sScriptStatus = SCRIPT_RUNNING
		return CMD_NEXT()
	end
end

local function level_cmd_set_register(value)
	sRegister = value
	return CMD_NEXT()
end

local function level_cmd_load_to_fixed_address(loadAddr, romStart, romEnd)
	-- TODO: implement FIXED_LOAD
	return CMD_NEXT()
end

local function level_cmd_load_raw(loadAddr, romStart, romEnd)
	-- TODO: implement LOAD_RAW
	return CMD_NEXT()
end

local function level_cmd_load_mio0(loadAddr, romStart, romEnd)
	-- TODO: implement LOAD_MIO0
	return CMD_NEXT()
end

local function level_cmd_load_mario_head(loadAddr, romStart, romEnd)
	-- TODO: implement LOAD_MARIO_HEAD
	return CMD_NEXT()
end

local function level_cmd_init_level()
	clear_objects()
	clear_areas()
	return CMD_NEXT()
end

local function level_cmd_clear_level()
	clear_objects()
	--clear_area_graph_nodes()
	clear_areas()
	
	return CMD_NEXT()
end

local function level_cmd_alloc_level_pool()
	return CMD_NEXT()
end

local function level_cmd_free_level_pool()
	return CMD_NEXT()
end

local function level_cmd_begin_area(index, geo)
	local areaIndex = index
	local geoLayoutAddr = geo
	
	if areaIndex < 8 then
		local screenArea = process_geo_layout(sLevelPool, geoLayoutAddr)
		local node = screenArea.views[1]
		
		sCurrAreaIndex = areaIndex
		screenArea.areaIndex = areaIndex
		gAreas[areaIndex].unk04 = screenArea
		
		if node ~= nil then
			gAreas[areaIndex].camera = node.config.camera
		else
			gAreas[areaIndex].camera = nil
		end
	end
	
	return CMD_NEXT()
end

local function level_cmd_end_area()
	sCurrAreaIndex = -1
	return CMD_NEXT()
end

local function level_cmd_create_instant_warp(index, destArea, displaceX, displaceY, displaceZ)
	local warp
	
	if sCurrAreaIndex ~= -1 then
		if gAreas[sCurrAreaIndex].instantWarps == nil then
			gAreas[sCurrAreaIndex].instantWarps = {{}, {}, {}, {}}
			
			for i=INSTANCE_WARP_INDEX_START, INSTANT_WARP_INDEX_STOP do
				gAreas[sCurrAreaIndex].instantWarps[i].id = 0
			end
		end
		
		warp = gAreas[sCurrAreaIndex].instantWarps
		
		warp[1].id = 1
		warp[1].area = destArea
		
		warp[1].displacement[1] = displaceX
		warp[1].displacement[2] = displaceY
		warp[1].displacement[3] = displaceZ
	end
	
	return CMD_NEXT()
end

local function level_cmd_set_blackout(active)
	--osViBlack(active)
	return CMD_NEXT()
end

local function level_cmd_load_area(area)
	local areaIndex = area
	
	--stop_sounds_in_continuous_banks()
	load_area(areaIndex)
	
	return CMD_NEXT()
end

local function level_cmd_unload_area()
	unload_area()
	return CMD_NEXT()
end

local function level_cmd_set_transition(transType, time, colorR, colorG, colorB)
	if gCurrentArea ~= nil then
		play_transition(transType, time, colorR, colorG, colorB)
	end
	return CMD_NEXT()
end

level_cmd_nop = CMD_NEXT

local LevelScriptJumpTable = {
	[0x00] = level_cmd_load_and_execute,
	[0x01] = level_cmd_exit_and_execute,
	[0x02] = level_cmd_exit,
	[0x03] = level_cmd_sleep,
	[0x04] = level_cmd_sleep2,
	[0x05] = level_cmd_jump,
	[0x06] = level_cmd_jump_and_link,
	[0x07] = level_cmd_return,
	[0x08] = level_cmd_jump_and_link_push_arg,
	[0x09] = level_cmd_jump_repeat,
	[0x0A] = level_cmd_loop_begin,
	[0x0B] = level_cmd_loop_until,
	[0x0C] = level_cmd_jump_if,
	[0x0D] = level_cmd_jump_and_link_if,
	[0x0E] = level_cmd_skip_if,
	[0x0F] = level_cmd_skip,
	[0x10] = level_cmd_skippable_nop,
	[0x11] = level_cmd_call,
	[0x12] = level_cmd_call_loop,
	[0x13] = level_cmd_set_register,
	[0x14] = level_cmd_push_pool_state,
	[0x15] = level_cmd_pop_pool_state,
	[0x16] = level_cmd_load_to_fixed_address,
	[0x17] = level_cmd_load_raw,
	[0x18] = level_cmd_load_mio0,
	[0x19] = level_cmd_load_mario_head,
	[0x1A] = level_cmd_load_mio0_texture,
	[0x1B] = level_cmd_init_level,
	[0x1C] = level_cmd_clear_level,
	[0x1D] = level_cmd_alloc_level_pool,
	[0x1E] = level_cmd_free_level_pool,
	[0x1F] = level_cmd_begin_area,
	[0x20] = level_cmd_end_area,
	[0x21] = level_cmd_load_model_from_dl,
	[0x22] = level_cmd_load_model_from_geo,
	[0x23] = level_cmd_23,
	[0x24] = level_cmd_place_object,
	[0x25] = level_cmd_init_mario,
	[0x26] = level_cmd_create_warp_node,
	[0x27] = level_cmd_create_painting_warp_node,
	[0x28] = level_cmd_create_instant_warp,
	[0x29] = level_cmd_load_area,
	[0x2A] = level_cmd_unload_area,
	[0x2B] = level_cmd_set_mario_start_pos,
	[0x2C] = level_cmd_2C,
	[0x2D] = level_cmd_2D,
	[0x2E] = level_cmd_set_terrain_data,
	[0x2F] = level_cmd_set_rooms,
	[0x30] = level_cmd_show_dialog,
	[0x31] = level_cmd_set_terrain_type,
	[0x32] = level_cmd_nop,
	[0x33] = level_cmd_set_transition,
	[0x34] = level_cmd_set_blackout,
	[0x35] = level_cmd_set_gamma,
	[0x36] = level_cmd_set_music,
	[0x37] = level_cmd_set_menu_music,
	[0x38] = level_cmd_38,
	[0x39] = level_cmd_set_macro_objects,
	[0x3A] = level_cmd_3A,
	[0x3B] = level_cmd_create_whirlpool,
	[0x3C] = level_cmd_get_or_set_var,
}

function level_script_execute(cmds)
	sScriptStatus = SCRIPT_RUNNING
	sCurrentCmds = cmds
	--sCurrentCmdOffset = 1
	sCurrentCmd = sCurrentCmds[sCurrentCmdOffset]
	assertf(sCurrentCmd, "failed to find sCurrentCmd at offset %d in %q", sCurrentCmdOffset, tostring(sCurrentCmds))
	
	while sScriptStatus == SCRIPT_RUNNING do
		--LevelScriptJumpTable[sCurrentCmd.type](unpack(sCurrentCmd))
		-- [[
		assertf(
			LevelScriptJumpTable[sCurrentCmd.type],
			"no such level command 0x%02X at %d in %s", sCurrentCmd.type, sCurrentCmdOffset, _GR[sCurrentCmds]
		)(unpack(sCurrentCmd))
		--]]
		coroutine.yield()
	end
	
	init_render_image()
	render_game()
	
	return sCurrentCmds
end

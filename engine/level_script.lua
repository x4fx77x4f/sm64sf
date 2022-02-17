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
		return {[-1]=i, [0]=func, ...}
	end
end

local function level_cmd_load_and_execute(entry)
	assertf(entry, "tried to EXECUTE non-existent script from %d", sCurrentIndex)
	table.insert(sStack, sCurrentScript)
	table.insert(sStack, sCurrentIndex)
	sCurrentCmd = entry
	return 1
end
wrap(0x00, 'EXECUTE', level_cmd_load_and_execute)

local function level_cmd_sleep(frames)
	sScriptStatus = SCRIPT_PAUSED
	if sDelayFrames == 0 then
		sDelayFrames = frames
		return sCurrentIndex
	else
		sDelayFrames = sDelayFrames-1
		if sDelayFrames == 0 then
			sScriptStatus = SCRIPT_RUNNING
		end
	end
end
wrap(0x03, 'SLEEP', level_cmd_sleep)

local function level_cmd_jump(target)
	sCurrentScript = target
	return 1
end
wrap(0x05, 'JUMP', level_cmd_jump)

local function level_cmd_set_register(value)
	sRegister = value
end
wrap(0x13, 'SET_REG', level_cmd_set_register)

local function level_cmd_init_level()
	-- TODO: Unstub INIT_LEVEL
end
wrap(0x1b, 'INIT_LEVEL', level_cmd_init_level)

local function level_cmd_set_blackout(active)
	-- TODO: Unstub BLACKOUT
end
wrap(0x34, 'BLACKOUT', level_cmd_set_blackout)

function level_script_execute(cmd, index)
	sScriptStatus = SCRIPT_RUNNING
	sCurrentCmd = cmd
	sCurrentIndex = index
	
	while sScriptStatus == SCRIPT_RUNNING do
		local cmd = sCurrentCmd[sCurrentIndex]
		local new_index = cmd[0](unpack(cmd))
		sCurrentIndex = new_index or sCurrentIndex+1
	end
	
	osdprintf("sScriptStatus: %2i\nsCurrentCmd: 0x%02x\n", sScriptStatus, sCurrentCmd[sCurrentIndex][-1])
	return sCurrentCmd, sCurrentIndex
end

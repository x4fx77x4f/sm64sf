-- https://hack64.net/wiki/doku.php?id=super_mario_64:level_commands

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

REGULAR_FACE = 0x0002
DIZZY_FACE = 0x0003

local DEGREES = math.deg -- may have to change...

local SCRIPT_RUNNING = 1
local SCRIPT_PAUSED = 0
local SCRIPT_PAUSED2 = -1

local LevelCommands = {}
LevelCommands.__index = LevelCommands

function LevelCommands.new()
	local self = setmetatable({}, LevelCommands)
	
	self.sScriptStatus = SCRIPT_PAUSED
	self.sDelayFrames = 0
	self.sDelayFrames2 = 0
	
	self.sCurrentScript = {}
	self.sRegister = nil
	
	self.sStackTop = {}
	self.sStackBaseIndex = 0
	
	return self
end

function LevelCommands:next()
	self.sCurrentScript.index = self.sCurrentScript.index+1
end

function LevelCommands:load_mio0()
	self:next()
end

function LevelCommands:load_raw()
	self:next()
end

function LevelCommands:init_level()
	--GeoLayout.gObjParentGraphNode = init_graph_node_start(nil, GeoLayout.gObjParentGraphNode)
	--ObjectListProcessor:clear_objects()
	Area:clear_areas()
	self:next()
end

function LevelCommands:init_mario(model, bharg, bhscript)
	table.assign(Area.gMarioSpawnInfo, {
		startPos = Vector(0, 0, 0),
		startAngle = Vector(0, 0, 0),
		areaIndex = 0,
		behaviorArg = bharg,
		behaviorScript = bhscript,
		unk18 = Area.gLoadedGraphNodes[model]
	})
	
	self:next()
end

function LevelCommands:load_model_from_geo(model, geo)
	if type(geo) == 'function' then
		geo = geo()
	end
	
	Area.gLoadedGraphNodes[model] = GeoLayout:process_geo_layout(geo)
	
	self:next()
end

function LevelCommands:load_model_from_dl(model, dl, layer)
	if model < 256 then
		Area.gLoadedGraphNodes[model] = GeoLayout:init_graph_node_display_list(layer, dl)
	else
		error("invalid gLoadedGraphNodes index - load model from dl")
	end
	
	self:next()
end

function LevelCommands:set_mario_pos(area, yaw, x, y, z)
	yaw = DEGREES(yaw)
	
	table.assign(Area.gMarioSpawnInfo, {
		areaIndex = area,
		startPos = Vector(x, y, z),
		startAngle = Angle(0, yaw, 0)
	})
	
	self:next()
end

function LevelCommands:load_mario_head(id)
	GoddardRenderer:gdm_setup()
	GoddardRenderer:gdm_maketestdl(id)
	self:next()
end

function LevelCommands:exit()
	table.remove(self.sStackTop)
	table.remove(self.sStackTop)
	self.sStackBaseIndex = table.remove(self.sStackTop)
	self.sCurrentScript = table.remove(self.sStackTop)
end

function LevelCommands:exit_and_execute(script, label)
	table.remove(self.sStackTop)
	table.remove(self.sStackTop)
	self:start_new_script(script, label)
end

function LevelCommands:sleep(delay)
	self.sScriptStatus = SCRIPT_PAUSED
	
	if self.sDelayFrames == 0 then
		self.sDelayFrames = delay
	else
		self.sDelayFrames = self.sDelayFrames-1
		if self.sDelayFrames == 0 then
			self:next()
			self.sScriptStatus = SCRIPT_RUNNING
		end
	end
end

function LevelCommands:sleep2(delay)
	self.sScriptStatus = SCRIPT_PAUSED2
	
	if self.sDelayFrames2 == 0 then
		self.sDelayFrames2 = delay
	else
		self.sDelayFrames2 = self.sDelayFrames2-1
		if self.sDelayFrames2 == 0 then
			self:next()
			self.sScriptStatus = SCRIPT_RUNNING
		end
	end
end

function LevelCommands:blackout(bool)
	self:next()
end

function LevelCommands:set_register(value)
	if type(value) == 'function' then
		value = value()
	end
	self.sRegister = value
	self:next()
end

function LevelCommands:eval_script_op(op, arg)
	if op == OP_AND then
		return bit.band(self.sRegister, arg) and 1 or 0
	elseif op == OP_NAND then
		return bit.band(self.sRegister, arg) and 0 or 1
	elseif op == OP_EQ then
		return self.sRegister == arg and 0 or 1
	elseif op == OP_NEQ then
		return self.sRegister ~= arg and 0 or 1
	elseif op == OP_LT then
		return self.sRegister < arg and 0 or 1
	elseif op == OP_LEQ then
		return self.sRegister <= arg and 0 or 1
	elseif op == OP_GT then
		return self.sRegister > arg and 0 or 1
	elseif op == OP_GEQ then
		return self.sRegister >= arg and 0 or 1
	end
	return 0
end

function LevelCommands:get_func(func, funcClass)
	-- allow deferred linking:
	-- CALL_LOOP(1, 'LevelUpdate.lvl_init_or_update')
	if type(func) == 'string' then
		local f
		local parts = string.split(func, '.')
		if #parts == 1 then
			f = gLinker[func]
			funcClass = nil
		else
			funcClass = gLinker[parts[1]]
			f = funcClass[parts[2]]
		end
		assertf(f, "deferred level commands func not found: %s", func)
		func = f
	end
	
	return func, funcClass
end

function LevelCommands:call(arg, func, funcClass)
	func, funcClass = self:get_func(func, funcClass)
	self.sRegister = func(funcClass, arg, self.sRegister)
	self:next()
end

function LevelCommands:call_loop(arg, func, funcClass)
	func, funcClass = self:get_func(func, funcClass)
	self.sRegister = func(funcClass, arg, self.sRegister)
	
	if self.sRegister == 0 then
		self.sScriptStatus = SCRIPT_PAUSED
	else
		self.sScriptStatus = SCRIPT_RUNNING
		self:next()
	end
end

function LevelCommands:alloc_level_pool()
	self:next()
end

function LevelCommands:free_level_pool()
	self:next()
end

function LevelCommands:get_area(what)
	self.sRegister = Area[what]
	self:next()
end

function LevelCommands:set_area(what, value)
	Area[what] = self.sRegister
	self:next()
end

function LevelCommands:load_area(areaIndex)
	Area:load_area(areaIndex)
	self:next()
end

function LevelCommands:unload_area(what, value)
	Area:clear_areas()
	-- clear_area_graph_nodes -- call all node functions with init and clear command
	self:next()
end

function LevelCommands:begin_area(areaIndex, geoLayout)
	if areaIndex < 8 then
		local screnArea = GeoLayout:process_geo_layout(geoLayout) -- sic?
		
		self.sCurrAreaIndex = areaIndex
		screnArea.areaIndex = areaIndex
		Area.gAreas[areaIndex].geometryLayoutData = screnArea
		
		if screnArea.views[1] then
			Area.gAreas[areaIndex].camera = screnArea.views[1].config.camera
		else
			Area.gAreas[areaIndex].camera = nil
		end
	end
	
	self:next()
end

function LevelCommands:place_object(model, x, y, z, pitch, yaw, rot, bharg, bhscript, act)
	local val7 = bit.lshift(1, Area.gCurrActNum - 1)
	act = bit.bor(act, 0x1F)
	
	if self.sCurrAreaIndex ~= -1 and (bit.band(act, val7) ~= 0 or act == 0x1F) then
		local spawnInfo = {
			startPos = Vector(x, y, z),
			startAngle = Angle(DEGREES(pitch), DEGREES(yaw), DEGREES(rot)),
			areaIndex = self.sCurrAreaIndex,
			activeAreaIndex = self.sCurrAreaIndex,
			behaviorArg = bharg,
			behaviorScript = bhscript,
			unk18 = Area.gLoadedGraphNodes[model],
			next = Area.gAreas[self.sCurrAreaIndex].objectSpawnInfos
		}
		
		Area.gAreas[self.sCurrAreaIndex].objectSpawnInfos = spawnInfo
	end
	
	self:next()
end

function LevelCommands:macro_objects(data)
	if self.sCurrAreaIndex ~= -1 then
		Area.gAreas[self.sCurrAreaIndex].macroObjects = data
	end
	
	self:next()
end

function LevelCommands:rooms(rms)
	if self.sCurrAreaIndex ~= -1 then
		Area.gAreas[self.sCurrAreaIndex].surfaceRooms = rms
	end
	
	self:next()
end

function LevelCommands:terrain(data)
	if self.sCurrAreaIndex ~= -1 then
		Area.gAreas[self.sCurrAreaIndex].terrainData = data
	end
	
	self:next()
end

function LevelCommands:terrain_type(data)
	if self.sCurrAreaIndex ~= -1 then
		Area.gAreas[self.sCurrAreaIndex].terrainType = data
	end
	
	self:next()
end

function LevelCommands:end_area(data)
	self.sCurrAreaIndex = -1
	self:next()
end

function LevelCommands:transition(transType, time, red, green, blue)
	if Area.gCurrentArea then
		Area:play_transition(transType, time, red, green, blue)
	end
	
	self:next()
end

function LevelCommands:cleardemoptr()
	Game.gCurrDemoInput = nil
	self:next()
end

function LevelCommands:execute(script)
	assertf(script, "tried to execute non-existent level script from %d in %q", self.sCurrentScript.index, _GR[self.sCurrentScript.commands])
	table.insert(self.sStackTop, {
		commands = self.sCurrentScript.commands,
		index = self.sCurrentScript.index + 1
	})
	table.insert(self.sStackTop, self.sStackBaseIndex)
	self.sStackBaseIndex = #self.sStackTop
	self:start_new_script(script)
end

function LevelCommands:jump_link(script)
	assertf(script, "tried to jump_link non-existent level script from %d in %q", self.sCurrentScript.index, _GR[self.sCurrentScript.commands])
	self:next()
	table.insert(self.sStackTop, {
		commands = self.sCurrentScript.commands,
		index = self.sCurrentScript.index
	})
	self:start_new_script(script)
end

function LevelCommands:jump_if(op, arg, script, label)
	if self:eval_script_op(op, arg) ~= 0 then
		self:start_new_script(script, label)
	else
		self:next()
	end
end

-- Renamed from 'return' because that is a reserved keyword.
function LevelCommands:pop()
	self.sCurrentScript = table.remove(self.sStackTop)
end

function LevelCommands:loop_begin()
	table.insert(self.sStackTop, {
		commands = self.sCurrentScript.commands,
		index = self.sCurrentScript.index + 1
	})
	self:next()
end

function LevelCommands:loop_until(op, arg)
	if self:eval_script_op(op, arg) ~= 0 then
		table.remove(self.sStackTop)
		self:next()
	else
		self.sCurrentScript = self.sStackTop[#self.sStackTop]
	end
end

function LevelCommands:warp(id, destLevel, destArea, destNode, flags)
	if self.sCurrAreaIndex ~= -1 then
		local warpNode = {
			id = id,
			destLevel = destLevel,
			destArea = destArea,
			destNode = destNode,
			object = false
		}
		
		Area.gAreas[self.sCurrAreaIndex].warpNodes[warpNode.id] = warpNode
	end
	
	self:next()
end

function LevelCommands:instant_warp(index, destArea, displaceX, displaceY, displaceZ)
	if self.sCurrAreaIndex ~= -1 then
		local warpNode = {
			id = 1, -- !
			area = destArea,
			displacement = {displaceX, displaceY, displaceZ}
		}
		
		Area.gAreas[self.sCurrAreaIndex].instantWarps[index] = warpNode
	end
	
	self:next()
end

function LevelCommands:painting_warp_node(id, destLevel, destArea, destNode, flags)
	if self.sCurrAreaIndex ~= -1 then
		local warpNode = {
			id = 1, -- !
			destLevel = destLevel,
			destArea = destArea,
			destNode = destNode,
		}
		
		Area.gAreas[self.sCurrAreaIndex].paintingWarpNodes[id] = warpNode
	end
	
	self:next()
end

function LevelCommands:clear_level()
	ObjectListProcessor:clear_objects()
	Area:clear_area_graph_nodes()
	Area:clear_areas()
	
	self:next()
end

function LevelCommands:start_new_script(level_script, label)
	if level_script then
		if type(level_script) == 'string' then
			level_script = assertf(_G[level_script], "tried to start nonexistent level script '%s' with label '%s'", level_script, label or "nil")
		elseif type(level_script) == 'function' then
			level_script = assertf(level_script(), "level script function '%s' returned nil", _GR[level_script] or "[UNKNOWN]")
		end
		assertf(level_script, "tried to start nonexistent level script with label '%s'", label or "nil")
		self.sCurrentScript.commands = level_script
	end
	self.sCurrentScript.index = 0
end

function LevelCommands:level_script_execute()
	self.sScriptStatus = SCRIPT_RUNNING
	
	while self.sScriptStatus == SCRIPT_RUNNING do
		assertf(type(self.sCurrentScript.commands) == 'table', "level script doesn't exist")
		local cmd = self.sCurrentScript.commands[self.sCurrentScript.index]
		assertf(cmd, "level script out of bounds at %d in %q", self.sCurrentScript.index, _GR[self.sCurrentScript.commands])
		cmd.command(self, unpack(cmd.args or {}))
	end
	
	Game:init_render_image()
	Area:render_game()
	Game:end_master_display_list()
end

_G.LevelCommands = LevelCommands.new()

local function wrap(dst, src)
	src = src or LevelCommands[string.lower(dst)]
	assertf(src, "failed to wrap %q for LevelCommands", dst)
	_GR[src] = dst
	_G[dst] = function(...)
		return {command=src, args={...}}
	end
end
wrap('ALLOC_LEVEL_POOL')
wrap('AREA', LevelCommands.begin_area)
wrap('BLACKOUT')
wrap('CALL')
wrap('CALL_LOOP')
wrap('CLEAR_LEVEL')
wrap('CLEARDEMOPTR')
wrap('END_AREA')
wrap('EXECUTE')
wrap('EXIT')
wrap('EXIT_AND_EXECUTE')
wrap('FIXED_LOAD', LevelCommands.next)
wrap('FREE_LEVEL_POOL')
wrap('GET_AREA')
wrap('INIT_LEVEL')
wrap('INSTANT_WARP')
wrap('JUMP', LevelCommands.start_new_script)
wrap('JUMP_IF')
wrap('JUMP_LINK')
wrap('LABEL', LevelCommands.next)
wrap('LOAD_AREA')
wrap('LOAD_MARIO_HEAD')
wrap('LOAD_MIO0')
wrap('LOAD_MODEL_FROM_GEO')
wrap('LOAD_RAW')
wrap('LOAD_MODEL_FROM_DL')
wrap('LOOP_BEGIN')
wrap('LOOP_UNTIL')
wrap('MARIO', LevelCommands.init_mario)
wrap('MARIO_POS', LevelCommands.set_mario_pos)
wrap('MACRO_OBJECTS')
wrap('OBJECT', LevelCommands.place_object)
wrap('OBJECT_WITH_ACTS', LevelCommands.place_object)
wrap('PAINTING_WARP_NODE')
wrap('RETURN', LevelCommands.pop)
wrap('ROOMS')
wrap('SET_BACKGROUND_MUSIC', LevelCommands.next)
wrap('SET_REG', LevelCommands.set_register)
wrap('SHOW_DIALOG', LevelCommands.next)
wrap('SLEEP')
wrap('SLEEP_BEFORE_EXIT', LevelCommands.sleep2)
wrap('TERRAIN')
wrap('TERRAIN_TYPE')
wrap('TRANSITION')
wrap('UNLOAD_AREA')
wrap('WARP_NODE', LevelCommands.warp)
-- non-sm64js
wrap('CMD2A', LevelCommands.unload_area)
wrap('SET_MENU_MUSIC', LevelCommands.next)
wrap('STOP_MUSIC', LevelCommands.next)

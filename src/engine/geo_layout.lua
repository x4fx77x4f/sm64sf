-- https://hack64.net/wiki/doku.php?id=super_mario_64:geometry_layout_commands

-- Layers
LAYER_FORCE = 0
LAYER_OPAQUE = 1
LAYER_OPAQUE_DECAL = 2
LAYER_OPAQUE_INTER = 3
LAYER_ALPHA = 4
LAYER_TRANSPARENT = 5
LAYER_TRANSPARENT_DECAL = 6
LAYER_TRANSPARENT_INTER = 7

-- sky background params
BACKGROUND_OCEAN_SKY = 0
BACKGROUND_FLAMING_SKY = 1
BACKGROUND_UNDERWATER_CITY = 2
BACKGROUND_BELOW_CLOUDS = 3
BACKGROUND_SNOW_MOUNTAINS = 4
BACKGROUND_DESERT = 5
BACKGROUND_HAUNTED = 6
BACKGROUND_GREEN_SKY = 7
BACKGROUND_ABOVE_CLOUDS = 8
BACKGROUND_PURPLE_SKY = 9

function PAINTING_ID(id, grp)
	return bit.bor(id, bit.lshift(grp, 8))
end

local function copy3argsToObject(pos, argIndex, args)
	for i = argIndex, i < argIndex + 3 do
		table.insert(pos, args[i])
	end
	return 3
end

GeoLayout = {}
GeoLayout.__index = GeoLayout

function GeoLayout.new()
	local self = setmetatable({}, GeoLayout)
	
	self.sCurrentLayout = {}
	self.gGeoLayoutStack = {}
	
	return self
end

function GeoLayout:next()
	self.sCurrentLayout.index = self.sCurrentLayout.index+1
end

function GeoLayout:branch_and_link(args)
	-- I'm assuming it's meant to be 'this.gGeoLayoutStack.push(this.sCurrentLayout)'
	-- and not 'this.gGeoLayoutStack.push = this.sCurrentLayout'????
	-- sm64js only uses GEO_BRANCH_AND_LINK in red_flame_shadow_geo,
	-- which is not referenced anywhere, and while the code makes no
	-- sense, it's not a syntax error so that's prob why it's not fixed.
	table.insert(self.gGeoLayoutStack, self.sCurrentLayout)
	table.insert(self.gGeoLayoutStack, self.sCurGraphNodeIndex)
	self.gGeoLayoutReturnIndex = self.gGeoLayoutStackIndex
	self:start_new_layout(args[1])
end

function GeoLayout:branch(args)
	if args[1] == 1 then
		self:next()
		table.insert(self.gGeoLayoutStack, self.sCurrentLayout)
	end
	
	self:start_new_layout(args[2])
end

-- renamed from 'return'
function GeoLayout:pop(args)
	self.sCurrentLayout = table.remove(self.gGeoLayoutStack)
end

function GeoLayout:node_screen_area(args) -- node_root
	do return self:next() end -- TODO: unstub all of GeoLayout
	
	local _, x, y, width, height = unpack(args)
	local i = 0
	
	self.gGeoNumViews = args[1] + 2
	
	local graphNode = GraphNode:init_graph_node_root(nil, nil, 0, x, y, width, height)
	
	--self.gGeoViews = {}
	
	grapgNode.numViews = self.gGeoNumViews
	
	self.gGeoViews = Array(self.gGeoNumViews):fill(false):destroy() -- TODO: is this necessary?
	graphNode.views = self.gGeoViews
	
	GraphNode:register_scene_graph_Node(self, graphNode)
	
	self:next()
end

function GeoLayout:open_node(args)
	table.insert(self.gCurGraphNodeList, self.gCurGraphNodeList[self.gCurGraphNodeIndex] or false)
	self.gCurGraphNodeIndex = self.gCurGraphNodeIndex+1
	self:next()
end

function GeoLayout:close_node(args)
	self.gCurGraphNodeIndex = self.gCurGraphNodeIndex-1
	self:next()
end

function GeoLayout:node_master_list(args) -- zbuffer?
	local graphNode = GraphNode:init_graph_node_master_list(nil, nil, args[1])
	GraphNode:register_scene_graph_node(self, graphNode)
	self:next()
end

function GeoLayout:display_list(args)
	local drawingLayer = args[1]
	local displaylist = args[2]
	
	local graphNode = GraphNode:init_graph_node_display_list(drawingLayer, displaylist)
	
	GraphNode:register_scene_graph_node(self, graphNode)
	
	self:next()
end

function GeoLayout:node_render_object_parent(args)
	local graphNode = GraphNode:init_graph_node_object_parent(self.gObjParentGraphNode)
	
	GraphNode:register_scene_graph_node(self, graphNode)
	
	self:next()
end

function GeoLayout:node_animated_part(args)
	local drawingLayer = args[1]
	local translation = Vector(args[2], args[3], args[4])
	local displayList = args[5]
	
	local graphNode = GraphNode:init_graph_node_animated_part(drawingLayer, displayList, translation)
	GraphNode:register_scene_graph_node(self, graphNode)
	self:next()
end

function GeoLayout:node_ortho(args)
	local scale = args[1] / 100.0
	
	local graphNode = GraphNode:init_graph_node_ortho(nil, nil, scale)
	GraphNode:register_scene_graph_node(self, graphNode)
	self:next()
end

function GeoLayout:node_perspective(args)
	--if args[4] then -- optional 4th function argument
	--end
	local graphNode = GraphNode:init_graph_node_perspective(nil, nil, args[1], args[2], args[3], args[4], 0)
	GraphNode:register_scene_graph_node(self, graphNode)
	self:next()
end

function GeoLayout:node_camera(args)
	local cameraType = args[1]
	local func = args[8]
	local argIndex = 1
	local pos, focus = {}, {}
	
	argIndex = argIndex+copy3argsToObject(pos, argIndex, args)
	argIndex = argIndex+copy3argsToObject(focus, argIndex, args)
	
	local graphNode = GraphNode:init_graph_node_camera(nil, nil, pos, focus, func, cameraType)
	GraphNode:register_scene_graph_node(self, graphNode)
	self.gGeoViews[1] = graphNode
	self:next()
end

function GeoLayout:node_generated(args)
	local param, theFunc, funcClass = unpack(args)
	
	-- allow deferred linking:
	-- GEO_ASM(0, 'MarioMisc.geo_mario_head_rotation')
	if type(theFunc) == 'string' then
		local func
		local parts = string.explode('.', theFunc)
		if #parts == 1 then
			func = gLinker[theFunc]
			funcClass = nil
		else
			funcClass = gLinker[parts[1]]
			func = funcClass[parts[2]]
		end
		if not func then
			errorf("deferred node_generated function not found: %s", theFunc)
		end
		theFunc = func
	end
	if not theFunc then
		printf("node_generated: skipping\n")
	end
	
	local graphNode = GraphNode:init_graph_node_generated(nil, nil, theFunc, param, funcClass)
	GraphNode:register_scene_graph_node(self, graphNode)
	self:next()
end

function GeoLayout:node_background(args)
	local graphNode = GraphNode:init_graph_node_background(nil, nil, args[1], arg[2], 0)
	GraphNode:register_scene_graph_node(self, graphNode)
	self:next()
end

function GeoLayout:node_switch_case(args)
	local graphNode = GraphNode:init_graph_node_switch_case(args[1], nil, args[2], arg[3])
	GraphNode:register_scene_graph_node(self, graphNode)
	self:next()
end

function GeoLayout:node_culling_radius(args)
	local graphNode = GraphNode:init_graph_node_culling_radius(args[1])
	GraphNode:register_scene_graph_node(self, graphNode)
	self:next()
end

function GeoLayout:node_render_range(args)
	local graphNode = GraphNode:init_graph_Node_render_range(args[1], arg[2])
	GraphNode:register_scene_graph_node(self, graphNode)
	self:next()
end

function GeoLayout:node_shadow(args)
	local shadowType = args[1]
	local shadowSolidity = args[2]
	local shadowScale = args[3]
	
	local graphNode = GraphNode:init_graph_node_shadow(shadowScale, shadowSolidity, shadowType)
	GraphNode:register_scene_graph_node(self, graphNode)
	self:next()
end

function GeoLayout:node_billboard(args)
	local drawingLayer = 0
	local params
	local translation
	local displaylist
	
	if args and #args > 0 then
		params = args[1]
		translation = Vector(args[2], args[3], args[4])
	else
		params = 0
		translation = Vector(0, 0, 0)
	end
	
	if bit.band(params, 0x80) ~= 0 then
		error("more implementation needed in geo node billboard")
	end
	
	local graphNode = GraphNode:init_graph_node_billboard(drawingLayer, displaylist, translation)
	GraphNode:register_scene_graph_node(self, graphNode)
	self:next()
end

function GeoLayout:node_scale(args)
	local drawingLayer = 0
	local params = args[1]
	local scale = args[2] / 65536.0
	local displaylist
	
	if bit.band(params, 0x80) ~= 0 then
		error("more implementation needed in geo scale")
	end
	
	local graphNode = GraphNode:init_graph_node_scale(drawingLayer, displaylist, scale)
	GraphNode:register_scene_graph_node(self, graphNode)
	self:next()
end

-- layer, rx, ry, rz <, dl>
function GeoLayout:node_rotation(args)
	local drawingLayer = args[1]
	local rot = Angle(args[2], args[3], args[4])
	local displayList = args[5]
	
	--if bit.band(params, 0x80) ~= 0 then
	--	error("unimplemented feature in node rotation")
	--end
	
	local graphNode = GraphNode:init_graph_node_rotation(drawingLayer, displayList, rot)
	GraphNode:register_scene_graph_node(self, graphNode)
	self:next()
end

-- layer, tx, ty, tz <, dl>
function GeoLayout:node_translate(args)
	local drawingLayer = args[1]
	local trans = Vector(args[2], args[3], args[4])
	local displayList = args[5]
	
	--if bit.band(params, 0x80) ~= 0 then
	--	error("unimplemented feature in node translate")
	--end
	
	local graphNode = GraphNode:init_graph_node_translation(drawingLayer, displayList, trans)
	GraphNode:register_scene_graph_node(self, graphNode)
	self:next()
end

-- layer, tx, ty, tz <, dl>
function GeoLayout:node_translate_rotate(args)
	local drawingLayer = args[1]
	local trans = Vector(args[2], args[3], args[4])
	local rot = Angle(args[5], args[6], args[7])
	local displayList = args[8]
	
	--if bit.band(params, 0x80) ~= 0 then
	--	error("unimplemented feature in node translate")
	--end
	
	local graphNode = GraphNode:init_graph_node_translation_rotation(drawingLayer, displayList, trans, rot)
	GraphNode:register_scene_graph_node(self, graphNode)
	self:next()
end

function GeoLayout:node_start(args)
	local graphNode = GraphNode:init_graph_node_start()
	GraphNode:register_scene_graph_node(self, graphNode)
	self:next()
end

function GeoLayout:node_end(args)
	self.gGeoLayoutStackIndex = self.gGeoLayoutReturnIndex
	self.gGeoLayoutStackIndex = self.gGeoLayoutStackIndex-1
	self.gGeoLayoutReturnIndex = self.gGeoLayoutStack[self.gGeoLayoutStackIndex] -- ??
	self.gCurGraphNodeIndex = self.gGeoLayoutStack[self.gGeoLayoutStackIndex] -- ?
	self.gGeoLayoutStackIndex = self.gGeoLayoutStackIndex-1
	self.gGeoLayoutCommand = self.gGeoLayoutStack[self.gGeoLayoutStackIndex]
	self:next()
end

-- param, ux, uy, uz, nodeFunc
function GeoLayout:node_held_object(args)
	local offset = Vector(args[2], args[3], args[4])
	local nodeFunc = args[5]
	
	local graphNode = GraphNode:init_graph_node_held_oject(nil, nil, offset, nodeFunc)
	GraphNode:register_scene_graph_node(self, graphNode)
	self:next()
end

function GeoLayout:start_new_layout(layout)
	if type(layout) == 'function' then
		layout = layout()
	end
	self.sCurrentLayout = {
		layout = layout,
		index = 0
	}
end

function GeoLayout:process_geo_layout(geoLayout)
	self:start_new_layout(geoLayout)
	
	-- set a bunch of other initial globals
	self.gCurRootGraphNode = nil
	self.gGeoNumViews = 0
	
	self.gCurGraphNodeList = {0}
	self.gCurGraphNodeIndex = 1
	
	self.gGeoLayoutStackIndex = 2
	self.gGeoLayoutReturnIndex = 2 -- stack index is often copied here?
	
	self.gGeoLayoutStack = {0, 0}
	
	--print("processing geo layout")
	
	while self.sCurrentLayout.index < #self.sCurrentLayout.layout+(self.sCurrentLayout.layout[0] and 1 or 0) do
		local cmd = self.sCurrentLayout.layout[self.sCurrentLayout.index]
		if not cmd then
			errorf("geo layout out of bounds at %d in %q", self.sCurrentLayout.index, _GR[self.sCurrentLayout.commands])
		elseif cmd[0] then
			self[cmd[0]](self, unpack(cmd))
		else
			cmd.command(self, cmd.args)
		end
	end
	
	--print("finished processing geo layout")
	--printTable(self.gCurRootGraphNode)
	return self.gCurRootGraphNode
end

local function wrap(dst, src)
	src = src or GeoLayout['node_'..string.lower(dst)]
	assertf(src, "failed to wrap %q for GeoLayout", dst)
	dst = 'GEO_'..dst
	_GR[src] = dst
	_G[dst] = function(...)
		return {command=src, args={...}}
	end
end
wrap('ANIMATED_PART')
wrap('ASM', GeoLayout.node_generated)
wrap('BACKGROUND')
wrap('BACKGROUND_COLOR', GeoLayout.node_background)
wrap('BILLBOARD')
wrap('BRANCH', GeoLayout.branch)
wrap('BRANCH_AND_LINK', GeoLayout.branch_and_link)
wrap('CAMERA')
wrap('CAMERA_FRUSTUM', GeoLayout.node_perspective)
wrap('CAMERA_FRUSTRUM_WITH_FUNC', GeoLayout.node_perspective)
wrap('CLOSE_NODE', GeoLayout.close_node)
wrap('CULLING_RADIUS')
wrap('DISPLAY_LIST', GeoLayout.display_list)
wrap('END')
wrap('HELD_OBJECT')
wrap('NODE_SCREEN_AREA', GeoLayout.node_screen_area)
wrap('NODE_ORTHO', GeoLayout.node_ortho)
wrap('NODE_START', GeoLayout.node_start)
wrap('OPEN_NODE', GeoLayout.open_node)
wrap('RENDER_OBJ', GeoLayout.node_render_object_parent)
wrap('RENDER_RANGE')
wrap('RETURN', GeoLayout.pop)
wrap('ROTATION_NODE', GeoLayout.node_rotation)
wrap('SCALE')
wrap('SHADOW')
wrap('SWITCH_CASE')
wrap('TRANSLATE_NODE', GeoLayout.node_translate)
wrap('TRANSLATE_NODE_WITH_DL', GeoLayout.node_translate)
wrap('TRANSLATE_ROTATE')
wrap('ZBUFFER', GeoLayout.node_master_list)

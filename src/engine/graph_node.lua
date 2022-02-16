GRAPH_RENDER_ACTIVE = bit.lshift(1, 0)
GRAPH_RENDER_CHILDREN_FIRST = bit.lshift(1, 1)
GRAPH_RENDER_BILLBOARD = bit.lshift(1, 2)
GRAPH_RENDER_Z_BUFFER = bit.lshift(1, 3)
GRAPH_RENDER_INVISIBLE = bit.lshift(1, 4)
GRAPH_RENDER_HAS_ANIMATION = bit.lshift(1, 5)
GRAPH_RENDER_CYLBOARD = bit.lshift(1, 6)

-- Whether the node type has a function pointer of type GraphNodeFunc
GRAPH_NODE_TYPE_FUNCTIONAL = 0x100

-- Type used for Bowser and an unused geo function in obj_behaviors.c
GRAPH_NODE_TYPE_400 = 0x400

-- The discriminant for different types of geo nodes
GRAPH_NODE_TYPE_ROOT = 0x001
GRAPH_NODE_TYPE_ORTHO_PROJECTION = 0x002
GRAPH_NODE_TYPE_PERSPECTIVE = bit.bor(0x003, GRAPH_NODE_TYPE_FUNCTIONAL)
GRAPH_NODE_TYPE_MASTER_LIST = 0x004
GRAPH_NODE_TYPE_START = 0x00A
GRAPH_NODE_TYPE_LEVEL_OF_DETAIL = 0x00B
GRAPH_NODE_TYPE_CAMERA = bit.bor(0x014, GRAPH_NODE_TYPE_FUNCTIONAL)
GRAPH_NODE_TYPE_TRANSLATION_ROTATION = 0x015
GRAPH_NODE_TYPE_TRANSLATION = 0x016
GRAPH_NODE_TYPE_ROTATION = 0x017
GRAPH_NODE_TYPE_OBJECT = 0x018
GRAPH_NODE_TYPE_ANIMATED_PART = 0x019
GRAPH_NODE_TYPE_BILLBOARD = 0x01A
GRAPH_NODE_TYPE_DISPLAY_LIST = 0x01B
GRAPH_NODE_TYPE_SCALE = 0x01C
GRAPH_NODE_TYPE_SHADOW = 0x028
GRAPH_NODE_TYPE_OBJECT_PARENT = 0x029
GRAPH_NODE_TYPE_GENERATED_LIST = bit.bor(0x02A, GRAPH_NODE_TYPE_FUNCTIONAL)
GRAPH_NODE_TYPE_BACKGROUND = bit.bor(0x02C, GRAPH_NODE_TYPE_FUNCTIONAL)
GRAPH_NODE_TYPE_HELD_OBJ = bit.bor(0x02E, GRAPH_NODE_TYPE_FUNCTIONAL)
GRAPH_NODE_TYPE_CULLING_RADIUS = 0x02F
GRAPH_NODE_TYPE_SWITCH_CASE = bit.bor(0x00C, GRAPH_NODE_TYPE_FUNCTIONAL)

GFX_NUM_MASTER_LISTS = 8

GEO_CONTEXT_CREATE = 0 -- called when node is created from a geo command
GEO_CONTEXT_RENDER = 1 -- called from rendering_graph_node.c
GEO_CONTEXT_AREA_UNLOAD = 2 -- called when unloading an area
GEO_CONTEXT_AREA_LOAD = 3 -- called when loading an area
GEO_CONTEXT_AREA_INIT = 4 -- called when initializing the 8 areas
GEO_CONTEXT_HELD_OBJ = 5 -- called when processing a GraphNodeHeldObj

gVec3fZero = {0.0, 0.0, 0.0}
gVec3sZero = gVec3fZero
gVec3fOne = {1.0, 1.0, 1.0}

GraphNode = {}

function GraphNode:init_graph_node_object(graphNode, sharedChild, pos, angle, scale)
	graphNode = {
		--node = -1,
		pos = table.copy(pos),
		angle = table.copy(angle),
		scale = table.copy(scale),
		sharedChild,
		unk38 = {
			animID = 0,
			animFrame = 0,
			animFrameAccelAssist = 0,
			animAccel = 0x10000,
			animTimer = 0
		}
	}
end

function GraphNode:geo_obj_init_spawninfo(graphNode, spawn)
	graphNode.scale = {1, 1, 1}
	graphNode.angle = table.copy(spawn.startAngle)
	graphNode.pos = table.copy(spawn.startPos)
	
	graphNode.areaIndex = spawn.areaIndex
	graphNode.activeAreaIndex = spawn.activeAreaIndex
	graphNode.sharedChild = spawn.unk18
	graphNode.unk4C = spawn
	graphNode.throwMatrix = nil
	graphNode.unk38 = {
		curAnim = 0
	}
	
	graphNode.flags = bit.bor(graphNode.flags, GRAPH_RENDER_ACTIVE)
	graphNode.flags = bit.band(graphNode.flags, bit.bnot(GRAPH_RENDER_INVISIBLE))
	graphNode.flags = bit.bor(graphNode.flags, GRAPH_RENDER_HAS_ANIMATION)
	graphNode.flags = bit.band(graphNode.flags, bit.bnot(GRAPH_RENDER_BILLBOARD))
end

--function GraphNode:geo_obj_init_animation(graphNode, anim) end
--function GraphNode:geo_obj_init_animation_accel(graphNode, anim, animAccel) end
--function GraphNode:geo_reset_object_node(graphNode) end
--function GraphNode:geo_make_first_child(newFirstChild) end
--function GraphNode:geo_call_global_function_nodes_helper(children, callContext) end
--function GraphNode:geo_call_global_function_nodes(graphNodeRoot, callContext) end

local function get_func(func, funcClass)
	-- allow deferred linking:
	-- GEO_ASM(0, 'MarioMisc.geo_mario_head_rotation')
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
		assertf(f, "deferred graph node func not found: %s", func)
		func = f
	end
	
	return func, funcClass
end

--function GraphNode:init_graph_node_held_object(graphNode, objNode, translation, func) end

function GraphNode:geo_add_child(parent, graphNode)
	local firstChild, parentLastChild
	
	graphNode.parent = parent
	firstChild = parent.children[1]
	
	if not firstChild then
		graphNode.prev = graphNode
		graphNode.next = graphNode
	else
		graphNode.prev = firstChild.prev
		graphNode.next = firstChild
		firstChild.prev.next = graphNode
		firstChild.prev = graphNode
	end
	
	table.insert(parent.children, graphNode) -- also store in children array
	
	return graphNode
end

--function GraphNode:geo_remove_child(graphNode) end

-- there's no way bitops's insistence on signing won't break this
local function getTopBits(number)
	number = bit.rshift(number, 16) -- '>>>' not '>>'!
	return number > 32767 and number - 65536 or number
end

local function setTopBits(number32, number16)
	return bit.bor(bit.lshift(number16, 16), bit.band(number32, 0xFFFF))
end

--function GraphNode:retrieve_animation_index(curFrame, attributes) end
--function GraphNode:geo_update_animation_frame(obj, accelAssist) end

local gGraphNodeNextID = 1

function GraphNode:init_graph_node(graphNode, type)
	graphNode.type = type
	graphNode.flags = 0
	graphNode.prev = nil
	graphNode.next = nil
	graphNode.parent = nil
	graphNode.children = {}
	
	--[[
	graphNode.debug = {}
	gGraphNodeNextID = gGraphNodeNextID+1
	graphNode.debug.id = gGraphNodeNextID
	graphNode.debug.type = gGraphNodeTypeNames[type]
	graphNode.wrapper = graphNode
	--]]
end

function GraphNode:init_scene_graph_node_links(graphNode, type)
	self:init_graph_node(graphNode, type)
	graphNode.flags = GRAPH_RENDER_ACTIVE
	graphNode.prev = graphNode
	graphNode.next = graphNode
end

--function GraphNode:init_graph_node_start(pool, graphNode) end
--function GraphNode:init_graph_node_root(pool, graphNode, areaIndex, x, y, width, height) end
--function GraphNode:init_graph_node_culling_radius(radius) end
--function GraphNode:init_graph_node_render_range(minDistance, maxDistance) end
--function GraphNode:init_graph_node_switch_case(numCases, selectedCase, func, funcClass) end
--function GraphNode:init_graph_node_perspective(pool, graphNode, fov, near, far, func) end
--function GraphNode:init_graph_node_generated(pool, graphNode, gfxFunc, parameter, funcClass) end
--function GraphNode:init_graph_node_object_parent(sharedChild) end
--function GraphNode:init_graph_node_animated_part(drawingLayer, displayList, translation) end
--function GraphNode:init_graph_node_billboard(drawingLayer, displayList, translation) end
--function GraphNode:init_graph_node_camera(pool, graphNode, pos, focus, func, mode) end
--function GraphNode:init_graph_node_display_list(drawingLayer, displayList) end
--function GraphNode:init_graph_node_background(pool, graphNode, background, backgroundFunc, zero) end
--function GraphNode:init_graph_node_shadow(shadowScale, shadowSolidity, shadowType) end
--function GraphNode:init_graph_node_scale(drawingLayer, displayList, scale) end
--function GraphNode:init_graph_node_rotation(drawingLayer, displayList, rotation) end
--function GraphNode:init_graph_node_translation(drawingLayer, displayList, translation) end
--function GraphNode:init_graph_node_translation_rotation(drawingLayer, displayList, translation, rotation) end

function GraphNode:init_graph_node_ortho(pool, graphNode, scale)
	graphNode = {
		node = -1,
		scale = scale
	}
	
	self_init_scene_graph_node_links(graphNode, GRAPH_NODE_TYPE_ORTHO_PROJECTION)
	return graphNode
end

function GraphNode:init_graph_node_master_list(pool, graphNode, on)
	graphNode = {
		node = -1,
		listHeads = {},
	}
	self:init_scene_graph_node_links(graphNode, GRAPH_NODE_TYPE_MASTER_LIST)
	
	if on then
		graphNode.flags = bit.bor(graphNode.flags, GRAPH_RENDER_Z_BUFFER)
	end
	
	return graphNode
end

function GraphNode:register_scene_graph_node(g, graphNode)
	if graphNode then
		g.gCurGraphNodeList[g.gCurGraphNodeIndex] = graphNode
		
		if g.gCurGraphNodeIndex == 1 then
			if not g.gCurRootGraphNode then
				g.gCurRootGraphNode = graphNode
			end
		else
			printTable(g.gCurGraphNodeList)
			if g.gCurGraphNodeList[g.gCurGraphNodeIndex - 1].type == GRAPH_NODE_TYPE_OBJECT_PARENT then
				g.gCurGraphNodeList[g.gCurGraphNodeIndex - 1].sharedChild = graphNode
			else
				self:geo_add_child(g.gCurGraphNodeList[g.gCurGraphNodeIndex - 1], graphNode)
			end
		end
	end
end

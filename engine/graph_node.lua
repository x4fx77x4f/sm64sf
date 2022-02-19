-- The equivalents of this file in n64decomp/sm64 are 'src/engine/graph_node_manager.c', 'src/engine/graph_node.c', 'src/engine/graph_node.h' and 'include/types.h'
-- The equivalent of this file in sm64js is 'src/engine/graph_node.js'

GRAPH_RENDER_ACTIVE = bit.lshift(1, 0)
GRAPH_RENDER_CHILDREN_FIRST = bit.lshift(1, 1)
GRAPH_RENDER_BILLBOARD = bit.lshift(1, 2)
GRAPH_RENDER_Z_BUFFER = bit.lshift(1, 3)
GRAPH_RENDER_INVISIBLE = bit.lshift(1, 4)
GRAPH_RENDER_HAS_ANIMATION = bit.lshift(1, 5)

-- Whether the node type has a function pointer of type GraphNodeFunc
GRAPH_NODE_TYPE_FUNCTIONAL = 0x100

-- Type used for Bowser and an unused geo function in obj_behaviors
GRAPH_NODE_TYPE_400 = 0x400

-- The discriminant for different types of geo nodes
GRAPH_NODE_TYPE_ROOT = 0x001
GRAPH_NODE_TYPE_ORTHO_PROJECTION = 0x002
GRAPH_NODE_TYPE_PERSPECTIVE = bit.bor(0x003, GRAPH_NODE_TYPE_FUNCTIONAL)
GRAPH_NODE_TYPE_MASTER_LIST = 0x004
GRAPH_NODE_TYPE_START = 0x00A
GRAPH_NODE_TYPE_LEVEL_OF_DETAIL = 0x00B
GRAPH_NODE_TYPE_SWITCH_CASE = bit.bor(0x00C, GRAPH_NODE_TYPE_FUNCTIONAL)
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

-- The number of master lists. A master list determines the order and render
-- mode with which display lists are drawn.
GFX_NUM_MASTER_LISTS = 8

-- Passed as first argument to a GraphNodeFunc to give information about in
-- which context it was called and what it is expected to do.
GEO_CONTEXT_CREATE = 0 -- called when node is created from a geo command
GEO_CONTEXT_RENDER = 1 -- called from rendering_graph_node
GEO_CONTEXT_AREA_UNLOAD = 2 -- called when unloading an area
GEO_CONTEXT_AREA_LOAD = 3 -- called when loading an area
GEO_CONTEXT_AREA_INIT = 4 -- called when initializing the 8 areas
GEO_CONTEXT_HELD_OBJ = 5 -- called when processing a GraphNodeHeldObj

-- Initialize a geo node with a given type. Sets all links such that there are no siblings, parent or children for this node.
local function init_scene_graph_node_links(graphNode, type)
	graphNode.type = type
	graphNode.flags = GRAPH_RENDER_ACTIVE
	graphNode.prev = graphNode
	graphNode.next = graphNode
	graphNode.parent = nil
	graphNode.children = nil
end

local function GraphNode()
	return {
		type = -0x0000,
		flags = -0x0000,
		prev = nil,
		next = nil,
		parent = nil,
		children = nil,
	}
end

-- An extension of a graph node that includes a function.
-- Many graph node types have an update function that gets called when they are processed.
local function FnGraphNode()
	local obj = {
		node = GraphNode(),
		func = nil,
	}
	obj.node.extension = obj -- Hack
	return obj
end

-- The very root of the geo tree. Specifies the viewport.
local function GraphNodeRoot()
	local obj = {
		node = GraphNode(),
		areaIndex = 0x00,
		x = -0x0000,
		y = -0x0000,
		width = -0x0000,
		height = -0x0000,
		numViews = -0x0000,
		views = nil,
	}
	obj.node.extension = obj -- Hack
	return obj
end
function init_graph_node_root(graphNode, areaIndex, x, y, width, height)
	graphNode = graphNode or GraphNodeRoot()
	init_scene_graph_node_links(graphNode.node, GRAPH_NODE_TYPE_ROOT)
	graphNode.areaIndex = areaIndex
	graphNode.x = x
	graphNode.y = y
	graphNode.width = width
	graphNode.height = height
	graphNode.views = nil
	graphNode.numViews = 0
	return graphNode
end

-- A node that sets up an orthographic projection based on the global
-- root node. Used to draw the skybox image.
local function GraphNodeOrthoProjection()
	local obj = {
		node = GraphNode(),
		scale = 0.0, -- float
	}
	obj.node.extension = obj -- Hack
	return obj
end
function init_graph_node_ortho_projection(graphNode, scale)
	graphNode = graphNode or GraphNodeOrthoProjection()
	init_scene_graph_node_links(graphNode.node, GRAPH_NODE_TYPE_ORTHO_PROJECTION)
	graphNode.scale = scale
	return graphNode
end

local function GraphNodePerspective()
	local obj = {
		fnNode = FnGraphNode(),
		fov = 0.0, -- float; horizontal field of view in degrees
		near = -0x0000, -- near clipping plane
		far = -0x0000, -- near clipping plane
	}
	obj.fnNode.extension = obj -- Hack
	return obj
end
function init_graph_node_perspective(graphNode, fov, near, far, nodeFunc)
	graphNode = graphNode or GraphNodePerspective()
	init_scene_graph_node_links(graphNode.fnNode.node, GRAPH_NODE_TYPE_PERSPECTIVE)
	graphNode.fov = fov
	graphNode.near = near
	graphNode.far = far
	graphNode.fnNode.func = nodeFunc
	if nodeFunc then
		nodeFunc(GEO_CONTEXT_CREATE, graphNode.fnNode.node)
	end
	return graphNode
end

-- GraphNode that specifies the location and aim of the camera.
-- When the roll is 0, the up vector is (0, 1, 0).
local function GraphNodeCamera()
	local obj = {
		fnNode = FnGraphNode(),
		config = {
			-- When the node is created, a mode is assigned to the node.
			-- Later in geo_camera_main a Camera is allocated, the mode is passed to the struct, and the field is overridden by a pointer to the struct. Gotta save those 4 bytes.
			mode = -0x00000000,
			camera = nil,
		},
		pos = Vector(),
		focus = Vector(),
		matrixPtr = nil, -- pointer to look-at matrix of this camera as a Mat4
		roll = -0x0000, -- roll in look at matrix. Doesn't account for light direction unlike rollScreen.
		rollScreen = -0x0000, -- rolls screen while keeping the light direction consistent
	}
	obj.fnNode.extension = obj -- Hack
	return obj
end
function init_graph_node_camera(graphNode, pos, focus, func, mode)
	graphNode = graphNode or GraphNodeCamera()
	init_scene_graph_node_links(graphNode.fnNode.node, GRAPH_NODE_TYPE_CAMERA)
	graphNode.pos = pos -- TODO: Make sure this copy by reference (as opposed to copy by value originally) is safe to do
	graphNode.focus = focus
	graphNode.fnNode.func = func
	graphNode.config.mode = mode
	graphNode.roll = 0
	graphNode.rollScreen = 0
	if func then
		func(GEO_CONTEXT_CREATE, graphNode.fnNode.node)
	end
	return graphNode
end

-- GraphNode that manages the 8 top-level display lists that will be drawn.
-- Each list has its own render mode, so for example water is drawn in a different master list than opaque objects.
-- It also sets the z-buffer on before rendering and off after.
local function GraphNodeMasterList()
	local obj = {
		node = GraphNode(),
		listHeads = {},
		listTails = {},
	}
	obj.node.extension = obj -- Hack
	return obj
end
function init_graph_node_master_list(graphNode, on)
	graphNode = graphNode or GraphNodeMasterList()
	init_scene_graph_node_links(graphNode.node, GRAPH_NODE_TYPE_MASTER_LIST)
	if on and on ~= 0 then
		graphNode.node.flags = bit.bor(graphNode.node.flags, GRAPH_RENDER_Z_BUFFER)
	end
	return graphNode
end

local function GraphNodeGenerated()
	local obj = {
		fnNode = FnGraphNode(),
		parameter = 0x00000000, -- extra context for the function
	}
	obj.fnNode.extension = obj -- Hack
	return obj
end
function init_graph_node_generated(graphNode, gfxFunc, parameter)
	graphNode = graphNode or GraphNodeGenerated()
	init_scene_graph_node_links(graphNode.fnNode.node, GRAPH_NODE_TYPE_GENERATED_LIST)
	graphNode.fnNode.func = gfxFunc
	graphNode.parameter = parameter
	if gfxFunc then
		gfxFunc(GEO_CONTEXT_CREATE, graphNode.fnNode.node)
	end
	return graphNode
end

function GraphNodeBackground()
	local obj = {
		fnNode = FnGraphNode(),
		background = -0x00000000, -- background ID, or rgba5551 color if fnNode.func is null
	}
	obj.fnNode.extension = obj -- Hack
	return obj
end
function init_graph_node_background(graphNode, background, backgroundFunc)
	graphNode = graphNode or GraphNodeBackground()
	init_scene_graph_node_links(graphNode.fnNode.node, GRAPH_NODE_TYPE_BACKGROUND)
	graphNode.background = bit.bor(bit.lshift(background, 16), background)
	graphNode.fnNode.func = backgroundFunc
	if backgroundFunc then
		backgroundFunc(GEO_CONTEXT_CREATE, graphNode.fnNode.node)
	end
	return graphNode
end

-- Adds 'childNode' to the end of the list children from 'parent'
function geo_add_child(parent, childNode)
	if childNode then
		childNode.parent = parent
		local parentFirstChild = parent.children
		if not parentFirstChild then
			parent.children = childNode
			childNode.prev = childNode
			childNode.next = childNode
		else
			local parentLastChild = parentFirstChild.prev
			childNode.prev = parentLastChild
			childNode.next = parentFirstChild
			parentFirstChild.prev = childNode
			parentLastChild.next = childNode
		end
	end
	return childNode
end

function register_scene_graph_node(graphNode)
	if graphNode then
		gCurGraphNodeList[gCurGraphNodeIndex] = graphNode
		
		if gCurGraphNodeIndex == 1 then
			gCurRootGraphNode = gCurRootGraphNode or graphNode
		elseif gCurGraphNodeList[gCurGraphNodeIndex - 1].type == GRAPH_NODE_TYPE_OBJECT_PARENT then
			gCurGraphNodeList[gCurGraphNodeIndex - 1].sharedChild = graphNode
		else
			geo_add_child(gCurGraphNodeList[gCurGraphNodeIndex - 1], graphNode)
		end
	end
end

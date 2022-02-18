-- The equivalents of this file in n64decomp/sm64 are 'src/engine/geo_layout.c', 'include/geo_commands.h', and 'include/sm64.h'
-- The equivalent of this file in sm64js is 'src/engine/GeoLayout.js'

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

gCurRootGraphNode = nil

local gGeoViews = {}
local gGeoNumViews

local gGeoLayoutStack = {} --[16]
gCurGraphNodeList = {} --[32]
gCurGraphNodeIndex = nil
local gGeoLayoutStackIndex -- similar to SP register in MIPS
local gGeoLayoutReturnIndex -- similar to RA register in MIPS
local gGeoLayoutCommand
local gGeoLayoutIndex -- specific to sm64sf2

-- 0x01: Terminate geo layout
local function geo_layout_cmd_end(args)
	-- TODO: Implement stack
	gGeoLayoutCommand = nil
end

-- 0x04: Open node
local function geo_layout_cmd_open_node(args)
	gCurGraphNodeList[gCurGraphNodeIndex + 1] = gCurGraphNodeList[gCurGraphNodeIndex]
	gCurGraphNodeIndex = gCurGraphNodeIndex+1
end

-- 0x05: Close node
local function geo_layout_cmd_close_node(args)
	gCurGraphNodeIndex = gCurGraphNodeIndex-1
end

-- 0x08: Create a scene graph root node that specifies the viewport
local function geo_layout_cmd_node_root(args)
	local x = args[2]
	local y = args[3]
	local width = args[4]
	local height = args[5]
	
	-- number of entries to allocate for gGeoViews array
	-- at least 2 are allocated by default
	-- cmd+0x02 = 0x00: Mario face, 0x0A: all other levels
	gGeoNumViews = args[1]+2
	
	local graphNode = init_graph_node_root(nil, 0, x, y, width, height)
	
	gGeoViews = {}
	
	graphNode.views = gGeoViews
	graphNode.numViews = gGeoNumViews
	
	for i=1, gGeoNumViews do
		gGeoViews[i] = nil
	end
	
	register_scene_graph_node(graphNode.node)
end

-- 0x09: Create orthographic projection scene graph node
local function geo_layout_cmd_node_ortho_projection(args)
	local scale = args[1] / 100.0
	local graphNode = init_graph_node_ortho_projection(nil, scale)
	register_scene_graph_node(graphNode.node)
end

-- 0x0a: Create camera frustum scene graph node
local function geo_layout_cmd_node_perspective(args)
	local frustumFunc
	local fov = args[2]
	local near = args[3]
	local far = args[4]
	if args[1] ~= 0 then
		-- optional asm function
		frustumFunc = args[5]
	end
	local graphNode = init_graph_node_perspective(nil, fov, near, far, frustumFunc)
	register_scene_graph_node(graphNode.node)
end

-- 0x0c: Create z-buffer-toggling scene graph node
local function geo_layout_cmd_node_master_list(args)
	local graphNode = init_graph_node_master_list(nil, args[1])
	register_scene_graph_node(graphNode.node)
end

-- 0x0f: Create a camera scene graph node (GraphNodeCamera). The focus sets the Camera's areaCen position.
local function geo_layout_cmd_node_camera(args)
	-- TODO: Verify that this simulation of a short to float conversion is accurate
	local pos = Vector((args[2]+0x8000)%0xffff-0x8000, (args[3]+0x8000)%0xffff-0x8000, (args[4]+0x8000)%0xffff-0x8000)
	local focus = Vector((args[5]+0x8000)%0xffff-0x8000, (args[6]+0x8000)%0xffff-0x8000, (args[7]+0x8000)%0xffff-0x8000)
	local func = args[8]
	if func == 0 then
		func = nil
	end
	local graphNode = init_graph_node_camera(nil, pos, focus, func, args[1])
	register_scene_graph_node(graphNode.fnNode.node)
	gGeoViews[1] = graphNode.fnNode.node
end

-- 0x18: Create dynamically generated displaylist scene graph node
local function geo_layout_cmd_node_generated(args)
	local graphNode = init_graph_node_generated(
		nil,
		args[2], -- asm function
		args[1] -- parameter
	)
	register_scene_graph_node(graphNode.fnNode.node)
end

-- 0x19: Create background scene graph node
local function geo_layout_cmd_node_background(args)
	local graphNode = init_graph_node_background(
		nil,
		args[1], -- background ID, or RGBA5551 color if asm function is nil
		args[2] -- asm function
	)
	register_scene_graph_node(graphNode.node)
end

function process_geo_layout(pool, geoLayout)
	-- set by register_scene_graph_node when gCurGraphNodeIndex is 0 and gCurRootGraphNode is nil
	gCurRootGraphNode = nil
	
	gGeoNumViews = 0
	
	gCurGraphNodeList[1] = 0
	gCurGraphNodeIndex = 1 -- incremented by cmd_open_node, decremented by cmd_close_node
	
	gGeoLayoutStackIndex = 2
	gGeoLayoutReturnIndex = 2 -- stack index is often copied here?
	
	gGeoLayoutCommand = geoLayout
	gGeoLayoutIndex = 1
	
	gGraphNodePool = pool
	
	gGeoLayoutStack[1] = 0
	gGeoLayoutStack[2] = 0
	
	while gGeoLayoutCommand do
		local cmd = gGeoLayoutCommand[gGeoLayoutIndex]
		if not cmd then
			break
		end
		local new_index = cmd[2](cmd[3])
		gGeoLayoutIndex = new_index or gGeoLayoutIndex+1
		yield()
	end
	
	return gCurRootGraphNode
end

local function wrap(i, macro_name, func)
	func = func or function()
		errorf("geo command '%s' not implemented", macro_name)
	end
	_G[macro_name] = function(...)
		return {i, func, {...}}
	end
end
wrap(0x00, 'GEO_BRANCH_AND_LINK', geo_layout_cmd_branch_and_link)
wrap(0x01, 'GEO_END', geo_layout_cmd_end)
wrap(0x02, 'GEO_BRANCH', geo_layout_cmd_branch)
wrap(0x03, 'GEO_RETURN', geo_layout_cmd_return)
wrap(0x04, 'GEO_OPEN_NODE', geo_layout_cmd_open_node)
wrap(0x05, 'GEO_CLOSE_NODE', geo_layout_cmd_close_node)
wrap(0x06, 'GEO_ASSIGN_AS_VIEW', geo_layout_cmd_assign_as_view)
wrap(0x07, 'GEO_UPDATE_NODE_FLAGS', geo_layout_cmd_update_node_flags)
wrap(0x08, 'GEO_NODE_SCREEN_AREA', geo_layout_cmd_node_root)
wrap(0x09, 'GEO_NODE_ORTHO', geo_layout_cmd_node_ortho_projection)
wrap(0x0a, 'GEO_CAMERA_FRUSTUM', geo_layout_cmd_node_perspective)
wrap(0x0a, 'GEO_CAMERA_FRUSTUM_WITH_FUNC', geo_layout_cmd_node_perspective)
wrap(0x0b, 'GEO_NODE_START', geo_layout_cmd_node_start)
wrap(0x0c, 'GEO_ZBUFFER', geo_layout_cmd_node_master_list)
wrap(0x0d, 'GEO_RENDER_RANGE', geo_layout_cmd_node_level_of_detail)
wrap(0x0e, 'GEO_SWITCH_CASE', geo_layout_cmd_node_switch_case)
wrap(0x0f, 'GEO_CAMERA', geo_layout_cmd_node_camera)
wrap(0x10, 'GEO_TRANSLATE_ROTATE', geo_layout_cmd_node_translation_rotation)
function GEO_TRANSLATE_ROTATE_WITH_DL(layer, tx, ty, tz, rx, ry, rz, displayList)
	return GEO_TRANSLATE_ROTATE(bit.bor(layer, 0x80), tx, ty, tz, rx, ry, rz, displayList)
end
function GEO_TRANSLATE(layer, tx, ty, tz)
	return GEO_TRANSLATE_ROTATE(bit.bor(layer, 0x10), tx, ty, tz, nil, nil, nil)
end
function GEO_TRANSLATE_WITH_DL(layer, tx, ty, tz, displayList)
	return GEO_TRANSLATE_ROTATE(bit.bor(layer, 0x10, 0x80), tx, ty, tz, nil, nil, nil, displayList)
end
function GEO_ROTATE(layer, rx, ry, rz)
	return GEO_TRANSLATE_ROTATE(bit.bor(layer, 0x20), nil, nil, nil, rx, ry, rz)
end
function GEO_ROTATE_WITH_DL(layer, rx, ry, rz, displayList)
	return GEO_TRANSLATE_ROTATE(bit.bor(layer, 0x20, 0x80), nil, nil, nil, rx, ry, rz, displayList)
end
function GEO_ROTATE_Y(layer, ry)
	return GEO_TRANSLATE_ROTATE(bit.bor(layer, 0x30), nil, nil, nil, nil, ry, nil)
end
function GEO_ROTATE_Y_WITH_DL(layer, ry, displayList)
	return GEO_TRANSLATE_ROTATE(bit.bor(layer, 0x30, 0x80), nil, nil, nil, nil, ry, nil, displayList)
end
wrap(0x11, 'GEO_TRANSLATE_NODE', geo_layout_cmd_node_translation)
function GEO_TRANSLATE_NODE_WITH_DL(layer, ux, uy, uz, displayList)
	return GEO_TRANSLATE_NODE(bit.bor(layer, 0x80), ux, uy, uz, displayList)
end
wrap(0x12, 'GEO_ROTATION_NODE', geo_layout_cmd_node_rotation)
function GEO_ROTATE_NODE_WITH_DL(layer, ux, uy, uz, displayList)
	return GEO_ROTATE_NODE(bit.bor(layer, 0x80), ux, uy, uz, displayList)
end
wrap(0x13, 'GEO_ANIMATED_PART', geo_layout_cmd_node_animated_part)
wrap(0x14, 'GEO_BILLBOARD_WITH_PARAMS', geo_layout_cmd_node_billboard)
function GEO_BILLBOARD_WITH_PARAMS_AND_DL(layer, tx, ty, tz, displayList)
	return GEO_TRANSLATE_NODE(bit.bor(layer, 0x80), tx, ty, tz, displayList)
end
function GEO_BILLBOARD()
	return GEO_BILLBOARD_WITH_PARAMS(0, 0, 0, 0)
end
wrap(0x15, 'GEO_DISPLAY_LIST', geo_layout_cmd_node_display_list)
wrap(0x16, 'GEO_SHADOW', geo_layout_cmd_node_shadow)
wrap(0x17, 'GEO_RENDER_OBJ', geo_layout_cmd_node_object_parent)
wrap(0x18, 'GEO_ASM', geo_layout_cmd_node_generated)
wrap(0x19, 'GEO_BACKGROUND', geo_layout_cmd_node_background)
wrap(0x19, 'GEO_BACKGROUND_COLOR', geo_layout_cmd_node_background)
wrap(0x1a, 'GEO_NOP_1A', geo_layout_cmd_nop)
wrap(0x1b, 'GEO_COPY_VIEW', geo_layout_cmd_copy_view)
wrap(0x1c, 'GEO_HELD_OBJECT', geo_layout_cmd_node_held_obj)
wrap(0x1d, 'GEO_SCALE', geo_layout_cmd_node_scale)
function GEO_SCALE_WITH_DL(layer, scale, displayList)
	return GEO_SCALE(bit.bor(layer, 0x80), scale, displayList)
end
wrap(0x1e, 'GEO_NOP_1E', geo_layout_cmd_nop2)
wrap(0x1f, 'GEO_NOP_1F', geo_layout_cmd_nop3)
wrap(0x20, 'GEO_CULLING_RADIUS', geo_layout_cmd_node_culling_radius)

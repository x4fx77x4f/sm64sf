local gObjParentGraphNode
local gGraphNodePool
local gCurRootGraphNode

local gGeoViews
local gGeoNumViews -- length of gGeoViews array

local gGeoLayoutStack = {[0]=0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
local gCurGraphNodeList = {}
local gCurGraphNodeIndex
local gGeoLayoutStackIndex -- similar to SP register in MIPS
local gGeoLayoutReturnIndex -- similar to RA register in MIPS
--gGeoLayoutCommands
gGeoLayoutCommandOffset = 1
--gGeoLayoutCommand

local function CMD_NEXT()
	gGeoLayoutCommandOffset = gGeoLayoutCommandOffset+1
	gGeoLayoutCommand = gGeoLayoutCommands[gGeoLayoutCommandOffset]
end

-- 0x01: Terminate geo layout
local function geo_layout_cmd_end()
	gGeoLayoutStackIndex = gGeoLayoutReturnIndex
	gGeoLayoutStackIndex = gGeoLayoutStackIndex-1
	gGeoLayoutReturnIndex = bit.band(gGeoLayoutStack[gGeoLayoutStackIndex], 0xFFFF)
	gGeoLayoutStackIndex = gGeoLayoutStackIndex-1
	gCurGraphNodeIndex = bit.rshift(gGeoLayoutStack[gGeoLayoutStackIndex], 16)
	return CMD_NEXT()
end

-- 0x04: Open node
local function geo_layout_cmd_open_node()
	gCurGraphNodeList[gCurGraphNodeIndex + 1] = gCurGraphNodeList[gCurGraphNodeIndex]
	gCurGraphNodeIndex = gCurGraphNodeIndex+1
	return CMD_NEXT()
end

-- 0x05: Close node
local function geo_layout_cmd_close_node()
	gCurGraphNodeIndex = gCurGraphNodeIndex-1
	return CMD_NEXT()
end

-- 0x08: Create a scene graph root node that specifies the viewport
local function geo_layout_cmd_node_root(numEntries, x, y, width, height)
	local graphNode
	
	-- number of entries to allocate for gGeoViews array
	-- at least 2 are allocated by default
	-- numEntries = 0x00: Mario face, 0x0A: all other levels
	gGeoNumViews = numEntries + 2
	
	--graphNode = init_graph_node_root(gGraphNodePool, nil, 0, x, y, width, height)
	graphNode, gGraphNodePool = {}, {}
	
	-- TODO: check type
	gGeoViews = gGraphNodePool -- I'm hoping I can just ignore C memory management.
	
	graphNode.views = gGeoViews
	graphNode.numViews = gGeoNumViews
	
	for i = 0, gGeoNumViews do
		gGeoViews[i] = nil
	end
	
	--register_scene_graph_node(graphNode.node)
	
	return CMD_NEXT()
end

-- 0x09: Create orthographic projection scene graph node
local function geo_layout_cmd_node_ortho_projection(scale)
	local graphNode
	scale = scale / 100.0
	
	--graphNode = init_graph_node_ortho_projection(gGraphNodePool, nil, scale)
	
	--register_scene_graph_node(graphNode.node)
	
	return CMD_NEXT()
end

-- 0x0A: Create camera frustum scene graph node
local function geo_layout_cmd_node_perspective(fov, near, far, func)
	local graphNode
	local frustumFunc = func
	
	--graphNode = init_graph_node_perspective(gGraphNodePool, nil, fov, near, far, frustumFunc, 0)
	
	--register_scene_graph_node(graphNode.fnNode.node)
	
	return CMD_NEXT()
end

-- 0x0C: Create zbuffer-toggling scene graph node
local function geo_layout_cmd_node_master_list(enable)
	local graphNode
	
	--graphNode = init_graph_node_master_list(gGraphNodePool, nil, enable)
	
	--register_scene_graph_node(graphNode.node)
	
	return CMD_NEXT()
end

-- 0x0F: Create a camera scene graph node (GraphNodeCamera). The focus sets the Camera's areaCen position.
local function geo_layout_cmd_node_camera(type, x1, y1, z1, x2, y2, z2, func)
	local graphNode
	
	local pos, focus
	
	pos = Vector(x1, y1, z1)
	focus = Vector(x2, y2, z2)
	
	--[[graphNode = init_graph_node_camera(
		gGraphNodePool, nil, pos, focus,
		func, type
	)
	
	register_scene_graph_node(graphNode.fnNode.node)
	
	gGeoViews[1] = graphNode.fnNode.node]]
	
	return CMD_NEXT()
end

-- 0x18: Create dynamically generated displaylist scene graph node
local function geo_layout_cmd_node_generated(param, func)
	local graphNode
	
	--[[graphNode = init_graph_node_generated(
		gGraphNodePool, nil,
		func, -- asm function
		param -- parameter
	)
	
	register_scene_graph_node(graphNode.fnNode.node)]]
	
	return CMD_NEXT()
end

-- 0x19: Create background scene graph node
local function geo_layout_cmd_node_background(background, func)
	local graphNode
	
	--[[
	graphNode = init_graph_node_background(
		gGraphNodePool, nil,
		background, -- background ID, or RGBA5551 color if asm function is null
		func, -- asm function
		0
	)
	
	register_scene_graph_node(graphNode.fnNode.node)]]
	
	return CMD_NEXT()
end

local GeoLayoutJumpTable = {
	[0x00] = geo_layout_cmd_branch_and_link,
	[0x01] = geo_layout_cmd_end,
	[0x02] = geo_layout_cmd_branch,
	[0x03] = geo_layout_cmd_return,
	[0x04] = geo_layout_cmd_open_node,
	[0x05] = geo_layout_cmd_close_node,
	[0x06] = geo_layout_cmd_assign_as_view,
	[0x07] = geo_layout_cmd_update_node_flags,
	[0x08] = geo_layout_cmd_node_root,
	[0x09] = geo_layout_cmd_node_ortho_projection,
	[0x0A] = geo_layout_cmd_node_perspective,
	[0x0B] = geo_layout_cmd_node_start,
	[0x0C] = geo_layout_cmd_node_master_list,
	[0x0D] = geo_layout_cmd_node_level_of_detail,
	[0x0E] = geo_layout_cmd_node_switch_case,
	[0x0F] = geo_layout_cmd_node_camera,
	[0x10] = geo_layout_cmd_node_translation_rotation,
	[0x11] = geo_layout_cmd_node_translation,
	[0x12] = geo_layout_cmd_node_rotation,
	[0x13] = geo_layout_cmd_node_animated_part,
	[0x14] = geo_layout_cmd_node_billboard,
	[0x15] = geo_layout_cmd_node_display_list,
	[0x16] = geo_layout_cmd_node_shadow,
	[0x17] = geo_layout_cmd_node_object_parent,
	[0x18] = geo_layout_cmd_node_generated,
	[0x19] = geo_layout_cmd_node_background,
	[0x1A] = geo_layout_cmd_nop,
	[0x1B] = geo_layout_cmd_copy_view,
	[0x1C] = geo_layout_cmd_node_held_obj,
	[0x1D] = geo_layout_cmd_node_scale,
	[0x1E] = geo_layout_cmd_nop2,
	[0x1F] = geo_layout_cmd_nop3,
	[0x20] = geo_layout_cmd_node_culling_radius,
}

function process_geo_layout(pool, segptr)
	-- set by register_scene_graph_node when gCurGraphNodeIndex is 0
	-- and gCurRootGraphNode is NULL
	gCurRootGraphNode = nil
	
	gGeoNumViews = 0
	
	gCurGraphNodeList[1] = 0
	gCurGraphNodeIndex = 0 -- incremented by cmd_open_node, decremented by cmd_close_node
	
	gGeoLayoutStackIndex = 2
	gGeoLayoutReturnIndex = 2 -- stack index is often copied here?
	
	gGeoLayoutCommands = segptr
	gGeoLayoutCommand = gGeoLayoutCommands[gGeoLayoutCommandOffset]
	assertf(gGeoLayoutCommand, "failed to find gGeoLayoutCommand at offset %d in %q", gGeoLayoutCommandOffset, tostring(gGeoLayoutCommands))
	
	gGraphNodePool = pool
	
	gGeoLayoutStack[1] = 0
	gGeoLayoutStack[2] = 0
	
	while gGeoLayoutCommand ~= nil do
		--GeoLayoutJumpTable[gGeoLayoutCommand[0x00]](unpack(gGeoLayoutCommand))
		-- [[
		assertf(
			GeoLayoutJumpTable[gGeoLayoutCommand[0x00]],
			"no such geo command 0x%02X at %d in %s", gGeoLayoutCommand[0x00], gGeoLayoutCommandOffset, _GR[gGeoLayoutCommands]
		)(unpack(gGeoLayoutCommand))
		--]]
		coroutine.yield()
	end
	
	gCurRootGraphNode = gCurRootGraphNode or {views={}}
	return gCurRootGraphNode
end

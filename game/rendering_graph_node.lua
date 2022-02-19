-- The equivalent of this file in n64decomp/sm64 is 'src/game/rendering_graph_node.c'
-- The equivalent of this file in sm64js is 'src/engine/GeoRenderer.js'

--[[
	This file contains the code that processes the scene graph for rendering.
	The scene graph is responsible for drawing everything except the HUD / text boxes.
	First the root of the scene graph is processed when geo_process_root
	is called from level_script.c. The rest of the tree is traversed recursively
	using the function geo_process_node_and_siblings, which switches over all
	geo node types and calls a specialized function accordingly.
	
	The scene graph typically looks like:
	- Root (viewport)
	 - Master list
	  - Ortho projection
	   - Background (skybox)
	 - Master list
	  - Perspective
	   - Camera
	    - <area-specific display lists>
	    - Object parent
	     - <group with 240 object nodes>
	 - Master list
	  - Script node (Cannon overlay)
]]

local gMatStackIndex = -0x0000
local gMatStack = {} --[32]
local gMatStackFixed = {} --[32]

local function geo_process_ortho_projection(node)
	if not node.scale then
		errorf("node '%s' needs to be GraphNodeOrthoProjection not GraphNode", tostring(node))
	end
	-- TODO: Unstub geo_process_ortho_projection
	if node.node.children then
		geo_process_node_and_siblings(node.node.children)
	end
end

local function geo_process_perspective(node)
	-- TODO: Unstub geo_process_perspective
	if node.fnNode.func then
		node.fnNode.func(GEO_CONTEXT_RENDER, node.fnNode.node, gMatStack[gMatStackIndex])
	end
	if node.fnNode.node.children then
		geo_process_node_and_siblings(node.node.children)
	end
end

local function geo_process_generated_list(node)
	node = node.extension -- Hack
	if not node.parameter then
		printTable(node)
		errorf("node '%s' needs to be GraphNodeGenerated not GraphNode", tostring(node))
	end
	if node.fnNode.func then
		node.fnNode.func(GEO_CONTEXT_RENDER, node.fnNode.node, gMatStack[gMatStackIndex])
	end
	if node.fnNode.node.children then
		geo_process_node_and_siblings(node.node.children)
	end
end

-- Process a generic geo node and its siblings.
-- The first argument is the start node, and all its siblings will be iterated over.
local geo_try_process_children
local lookup = {
	[GRAPH_NODE_TYPE_ORTHO_PROJECTION] = geo_process_ortho_projection,
	[GRAPH_NODE_TYPE_PERSPECTIVE] = geo_process_perspective,
	[GRAPH_NODE_TYPE_MASTER_LIST] = geo_process_master_list,
	[GRAPH_NODE_TYPE_LEVEL_OF_DETAIL] = geo_process_level_of_detail,
	[GRAPH_NODE_TYPE_SWITCH_CASE] = geo_process_switch,
	[GRAPH_NODE_TYPE_CAMERA] = geo_process_camera,
	[GRAPH_NODE_TYPE_TRANSLATION_ROTATION] = geo_process_translation_rotation,
	[GRAPH_NODE_TYPE_TRANSLATION] = geo_process_translation,
	[GRAPH_NODE_TYPE_ROTATION] = geo_process_rotation,
	[GRAPH_NODE_TYPE_OBJECT] = geo_process_object,
	[GRAPH_NODE_TYPE_ANIMATED_PART] = geo_process_animated_part,
	[GRAPH_NODE_TYPE_BILLBOARD] = geo_process_billboard,
	[GRAPH_NODE_TYPE_DISPLAY_LIST] = geo_process_display_list,
	[GRAPH_NODE_TYPE_SCALE] = geo_process_scale,
	[GRAPH_NODE_TYPE_SHADOW] = geo_process_shadow,
	[GRAPH_NODE_TYPE_OBJECT_PARENT] = geo_process_object_parent,
	[GRAPH_NODE_TYPE_GENERATED_LIST] = geo_process_generated_list,
	[GRAPH_NODE_TYPE_BACKGROUND] = geo_process_background,
	[GRAPH_NODE_TYPE_HELD_OBJ] = geo_process_held_object,
}
local function geo_process_node_and_siblings(firstNode)
	local iterateChildren = true
	local curGraphNode = firstNode
	local parent = curGraphNode.parent
	
	-- In the case of a switch node, exactly one of the children of the node is processed instead of all children like usual
	if parent then
		iterateChildren = parent.type ~= GRAPH_NODE_TYPE_SWITCH_CASE
	end
	
	while iterateChildren do
		if bit.band(curGraphNode.flags, GRAPH_RENDER_ACTIVE) ~= 0 then
			if bit.band(curGraphNode.flags, GRAPH_RENDER_CHILDREN_FIRST) ~= 0 then
				geo_try_process_children(curGraphNode)
			else
				-- cast to various?
				local func = lookup[curGraphNode.type]
				if func then
					func(curGraphNode.extension)
				else
					--printf("[geo_process_node_and_siblings] WARNING: No function for type 0x%03x\n", curGraphNode.type)
					geo_try_process_children(curGraphNode)
				end
			end
		elseif curGraphNode.type == GRAPH_NODE_TYPE_OBJECT then
			-- cast to GraphNodeObject?
			curGraphNode.throwMatrix = nil
		end
		osdprintf("curGraphNode.flags: 0x%03x\n", curGraphNode.type)
		curGraphNode = curGraphNode.next
		if curGraphNode == firstNode then
			break
		end
		yield()
	end
end

-- Processes the children of the given GraphNode if it has any
function geo_try_process_children(node)
	if node.children then
		geo_process_node_and_siblings(node.children)
	end
end

-- Process a root node. This is the entry point for processing the scene graph.
-- The root node itself sets up the viewport, then all its children are processed to set up the projection and draw display lists.
function geo_process_root(node, b, c, clearColor)
	if not node.node then
		printTable(node)
		errorf("node '%s' needs to be GraphNodeRoot not GraphNode", tostring(node))
	end
	if bit.band(node.node.flags, GRAPH_RENDER_ACTIVE) ~= 0 then
		local viewport = Vp()
		gMatStackIndex = 0
		viewport.vp.vtrans:setX(node.x*4):setY(node.y*4):setZ(511)
		viewport.vp.vscale:setX(node.width*4):setY(node.height*4):setZ(511)
		if b then
			clear_framebuffer(clearColor)
			make_viewport_clip_rect(b)
			viewport = b
		elseif c then
			clear_framebuffer(clearColor)
			make_viewport_clip_rect(c)
		end
		
		gCurGraphNodeRoot = node
		if node.node.children then
			geo_process_node_and_siblings(node.node.children)
		end
		gCurGraphNodeRoot = nil
	end
end

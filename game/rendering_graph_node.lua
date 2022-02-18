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

function geo_process_root(node, b, c, clearColor)
	if not node.node then
		printTable(node)
		errorf("node '%s' needs to be GraphNodeRoot not GraphNode", tostring(node))
	end
	if bit.band(node.node.flags, GRAPH_RENDER_ACTIVE) ~= 0 then
		local viewport = Vp()
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

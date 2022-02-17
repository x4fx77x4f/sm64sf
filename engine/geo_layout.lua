-- The equivalent of this file in n64decomp/sm64 is 'src/engine/geo_layout.c'
-- The equivalent of this file in sm64js is 'src/engine/GeoLayout.js'

local gCurRootGraphNode

function process_geo_layout()
	-- TODO: Unstub process_geo_layout.
	-- This is supposed to be set to NULL. As a temporary measure, I'm making it a table. This is because what's supposed to happen is for VM code to call 'register_scene_graph_node', which will define gCurRootGraphNode. Since this is stubbed, I need to do that here rather than there.
	gCurRootGraphNode = {}
	
	return gCurRootGraphNode
end

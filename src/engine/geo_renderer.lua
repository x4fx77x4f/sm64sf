GeoRenderer = {}
GeoRenderer.__index = GeoRenderer

local renderModeTable = {
	{
		Gbi.G_RM_OPA_SURF_SURF2,
		Gbi.G_RM_AA_OPA_SURF_SURF2,
		Gbi.G_RM_AA_OPA_SURF_SURF2,
		Gbi.G_RM_AA_OPA_SURF_SURF2,
		false,
		Gbi.G_RM_AA_XLU_SURF_SURF2,
		Gbi.G_RM_AA_XLU_SURF_SURF2,
		Gbi.G_RM_AA_XLU_SURF_SURF2
	},
	{
		Gbi.G_RM_ZB_OPA_SURF_SURF2,
		Gbi.G_RM_AA_ZB_OPA_SURF_SURF2,
		Gbi.G_RM_AA_ZB_OPA_DECAL_DECAL2,
		Gbi.G_RM_AA_ZB_OPA_INTER_NOOP2,
		Gbi.G_RM_AA_ZB_TEX_EDGE_NOOP2,
		Gbi.G_RM_AA_ZB_XLU_SURF_SURF2,
		Gbi.G_RM_AA_ZB_XLU_DECAL_DECAL2,
		Gbi.G_RM_AA_ZB_XLU_INTER_INTER2
	}
}

function GeoRenderer.new()
	local self = setmetatable({}, GeoRenderer)
	
	self.gMatStack = Array(32):fill(0):map(Mat4):destroy()
	self.gMatStackIndex = 0
	self.gAreaUpdateCounter = 0
	
	self.gCurGraphNodeRoot = null
	self.gCurGraphNodeMasterList = null
	self.gCurGraphNodeCamFrustum = null
	self.gCurGraphNodeCamera = null
	self.gCurGraphNodeObject = null
	self.gCurGraphNodeHeldObject = null
	
	self.ANIM_TYPE_NONE = 0
	
	-- Not all parts have full animation: to save space, some animations only
	-- have xz, y, or no translation at all. All animations have rotations though
	self.ANIM_TYPE_TRANSLATION = 1
	self.ANIM_TYPE_VERTICAL_TRANSLATION = 2
	self.ANIM_TYPE_LATERAL_TRANSLATION = 3
	self.ANIM_TYPE_NO_TRANSLATION = 4
	
	-- Every animation includes rotation, after processing any of the above
	-- translation types the type is set to self
	self.ANIM_TYPE_ROTATION = 5
	
	return self
end

function GeoRenderer:geo_process_master_lib_sub(node)
	local enableZBuffer = bit.band(node.flags, GRAPH_RENDER_Z_BUFFER) ~= 0
	local modeList = renderModeTable[enableZBuffer and 1 or 0]
	
	if enableZBuffer then
		Gbi.gSPSetGeometryMode(Game.gDisplayList, Gbi.G_ZBUFFER)
	end
	
	for i=0, GFX_NUM_MASTER_LISTS do
		if node.listHeads[i] then
			if not modeList[i] then
				errorf("need to add render mode for i %d", i)
			end
			Gbi.gDPSetRenderMode(Game.gDisplayList, modeList[i])
			for displayNode in ipairs(node.listHeads[i]) do
				Gbi.gSPMatrix(Game.gDisplayList, displayNode.transform, SF_BOR(Gbi.G_MTX_MODELVIEW, Gbi.G_MTX_LOAD, G_MTX_NOPUSH))
				Gbi.gSPDisplayList(Game.gDisplayList, displayNode.displayList)
			end
		end
	end
	
	if enableZBuffer then
		Gbi.gSPClearGeometryMode(Game.gDisplayList, Gbi.G_ZBUFFER)
	end
end

function GeoRenderer:geo_process_master_list(node)
	if not self.gCurGraphNodeMasterList and node.children[1] then
		self.gCurGraphNodeMasterList = node
		for k, v in pairs(node.listHeads) do
			-- probably equivalent to .fill(null)?
			node.listHeads[k] = nil
		end
		self:geo_process_node_and_siblings(node.children)
		self:geo_process_master_list_sub(node)
		self.gCurGraphNodeMasterList = nil
	end
end

function GeoRenderer:geo_process_ortho_projection(node)
	if node.children[1] then -- ughhh indexing will be a problem
		local mtx = Mat4()
		local left = (self.gCurGraphNodeRoot.x - self.gCurGraphNodeRoot.width) / 2.0 * node.scale
		local right = (self.gCurGraphNodeRoot.x + self.gCurGraphNodeRoot.width) / 2.0 * node.scale
		local top = (self.gCurGraphNodeRoot.y - self.gCurGraphNodeRoot.height) / 2.0 * node.scale
		local bottom = (self.gCurGraphNodeRoot.y + self.gCurGraphNodeRoot.height) / 2.0 * node.scale
		
		guOrtho(mtx, left, right, bottom, top, -2.0, 2.0, 1.0)
		--Gbi.gSPPerspNormalize(Game.gDisplayList, 0xFFFF)
		Gbi.gSPMatrix(Game.gDisplayList, mtx, SF_BOR(Gbi.G_MTX_PROJECTION, Gbi.G_MTX_LOAD, Gbi.G_MTX_NOPUSH))
		
		self:geo_process_node_and_siblings(node.children)
	end
end

function GeoRenderer:geo_process_perspective(node)
	local f = node.func
	if f.func then
		if f.func ~= Camera.geo_camera_ov then
			error("geo process perspective")
		end
		f.func(Camera, GEO_CONTEXT_RENDER, node)
	end
	
	if node.children[1] then
		local aspect = SCREEN_WIDTH / SCREEN_HEIGHT
		local mtx = Mat4()
		local perspNorm = {}
		
		guPerspective(mtx, perspNorm, node.fov, aspect, node.near, node.far, 1.0)
		
		--Gbi.gSPPerspNormalize(Game.gDisplayList, perspNorm.value)
		Gbi.gSPMatrix(Game.gDisplayList, mtx, SF_BOR(Gbi.G_MTX_PROJECTION, Gbi.G_MTX_LOAD, Gbi.G_MTX_NOPUSH))
		
		self.gCurGraphNodeCamFrustum = node
		self:geo_process_node_and_siblings(node.children)
		self.gCurGraphNodeCamFrustum = nil
	end
end

--function GeoRenderer:geo_process_camera(node) end
--function GeoRenderer:geo_process_translation_rotation(node) end
--function GeoRenderer:geo_process_translation(node) end
--function GeoRenderer:geo_process_rotation(node) end

function GeoRenderer:geo_process_background(node)
	local list
	if node.backgroundFunc then
		list = node.backgroundFunc(GEO_CONTEXT_RENDER, node)
	end
	
	if list then
		self:geo_append_display_list(list, bit.rshift(node.flags, 8))
	elseif self.gCurGraphNodeMasterList then
		local gfx = {}
		Gbi.gDPSetCycleType(gfx, Gbi.G_CYC_FILL)
		Gbi.gDPSetFillColor(gfx, node.background)
		Gbi.gDPFillRectangle(gfx, 0, 0, SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1)
		Gbi.gDPSetCycleType(gfx, Gbi.G_CYC_1CYCLE)
		Gbi.gSPEndDisplayList(gfx)
		self:geo_append_display_list(gfx, 0)
	end
	self:geo_process_node_siblings(node.children)
end

--function GeoRenderer:geo_process_generated_list(node) end
--function GeoRenderer:geo_process_scale(node) end
--function GeoRenderer:read_next_anim_value() end
--function GeoRenderer:geo_process_animated_part(node) end
--function GeoRenderer:geo_set_animation_globals(node, hasAnimation) end
--function GeoRenderer:obj_is_in_view(node, matrix) end
--function GeoRenderer:geo_process_object(node) end
--function GeoRenderer:geo_process_object_parent(node) end
--function GeoRenderer:geo_process_display_list(node) end

function GeoRenderer:geo_append_display_list(displayList, layer)
	local gMatStackCopy = Mat4()
	mtxf_to_mtx(gMatStackCopy, self.gMatStack[self.gMatStackIndex])
	
	if self.gCurGraphNodeMasterList then
		local listNode = {
			transform = gMatStackCopy,
			displayList = displayList
		}
		
		if self.gCurGraphNodeMasterList.listHeads[layer] then
			table.insert(self.gCurGraphNodeMasterList.listHeads[layer], listNode)
		else
			self.gCurGraphNodeMasterList.listHeads[layer] = {listNode}
		end
	end
end

--function GeoRenderer:geo_process_level_of_detail(node) end
--function GeoRenderer:geo_process_billboard(node) end
--function GeoRenderer:geo_process_shadow(node) end
--function GeoRenderer:geo_process_held_object(node) end
--function GeoRenderer:geo_process_switch_case(node) end

GeoRenderer.geo_process_single_node_switch = {
	[GRAPH_NODE_TYPE_ANIMATED_PART] = GeoRenderer.geo_process_animated_part,
	[GRAPH_NODE_TYPE_BACKGROUND] = GeoRenderer.geo_process_background,
	[GRAPH_NODE_TYPE_BILLBOARD] = GeoRenderer.geo_process_billboard,
	[GRAPH_NODE_TYPE_CAMERA] = GeoRenderer.geo_process_camera,
	[GRAPH_NODE_TYPE_DISPLAY_LIST] = GeoRenderer.geo_process_display_list,
	[GRAPH_NODE_TYPE_GENERATED_LIST] = GeoRenderer.geo_process_generated_list,
	[GRAPH_NODE_TYPE_HELD_OBJ] = GeoRenderer.geo_process_held_object,
	[GRAPH_NODE_TYPE_LEVEL_OF_DETAIL] = GeoRenderer.geo_process_level_of_detail,
	[GRAPH_NODE_TYPE_MASTER_LIST] = GeoRenderer.geo_process_master_list,
	[GRAPH_NODE_TYPE_OBJECT] = GeoRenderer.geo_process_object,
	[GRAPH_NODE_TYPE_OBJECT_PARENT] = GeoRenderer.geo_process_object_parent,
	[GRAPH_NODE_TYPE_ORTHO_PROJECTION] = GeoRenderer.geo_process_ortho_projection,
	[GRAPH_NODE_TYPE_PERSPECTIVE] = GeoRenderer.geo_process_perspective,
	[GRAPH_NODE_TYPE_ROTATION] = GeoRenderer.geo_process_rotation,
	[GRAPH_NODE_TYPE_SCALE] = GeoRenderer.geo_process_scale,
	[GRAPH_NODE_TYPE_SHADOW] = GeoRenderer.geo_process_shadow,
	[GRAPH_NODE_TYPE_SWITCH_CASE] = GeoRenderer.geo_process_switch_case,
	[GRAPH_NODE_TYPE_TRANSLATION] = GeoRenderer.geo_process_translation,
	[GRAPH_NODE_TYPE_TRANSLATION_ROTATION] = GeoRenderer.geo_process_translation_rotation,
}

function GeoRenderer:geo_process_single_node(node)
	local func = self.geo_process_single_node_switch[node.type]
	if func then
		func(self, node)
	else
		-- remove this check once all types have been added
		if node.type ~= GRAPH_NODE_TYPE_CULLING_RADIUS and node.type ~= GRAPH_NODE_TYPE_START then
			printTable(node)
			error("unimplemented type in geo renderer")
		end
		self:geo_process_node_and_siblings(node.children)
	end
end

function GeoRenderer:geo_process_node_and_siblings(children)
	for child in ipairs(children) do
		if bit.band(child.flags, GRAPH_RENDER_ACTIVE) ~= 0 then
			self:geo_process_single_node(child)
		elseif child.type == GRAPH_NODE_TYPE_OBJECT then
			child.throwMatrix = nil
		end
	end
end

function GeoRenderer:geo_process_root(root, b, c, clearColor)
	--print("processing root node to render")
	if bit.band(root.flags, GRAPH_RENDER_ACTIVE) ~= 0 then
		mtxf_identity(self.gMatStack[self.gMatStackIndex])
		self.gCurGraphNodeRoot = root
		self:geo_process_node_and_siblings(root.children)
		self.gCurGraphNodeRoot = nil
	end
end

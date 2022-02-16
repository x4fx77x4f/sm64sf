WARP_TRANSITION_FADE_FROM_COLOR = 0x00
WARP_TRANSITION_FADE_INTO_COLOR = 0x01
WARP_TRANSITION_FADE_FROM_STAR = 0x08
WARP_TRANSITION_FADE_INTO_STAR = 0x09
WARP_TRANSITION_FADE_FROM_CIRCLE = 0x0A
WARP_TRANSITION_FADE_INTO_CIRCLE = 0x0B
WARP_TRANSITION_FADE_FROM_MARIO = 0x10
WARP_TRANSITION_FADE_INTO_MARIO = 0x11
WARP_TRANSITION_FADE_FROM_BOWSER = 0x12
WARP_TRANSITION_FADE_INTO_BOWSER = 0x13

local D_8032CF00 = { -- default view port?
	vscale = {640, 480, 511, 0},
	vtrans = {640, 480, 511, 0}
}

Area = {}

function Area:area_get_warp_node(id)
	return self.gCurrentArea.warpNodes[id]
end

function Area:area_get_warp_node_from_params(o)
	local warp_id = bit.rshift(bit.band(o.rawData[oBehParams], 0x00FF0000), 16)
	return self:area_get_warp_node(warp_id)
end

function Area:load_obj_warp_nodes()
	do return end
	for node in ipairs(GeoLayout.gObjParentGraphNode.children) do
		local object = node.wrapperObjectNode.wrapperObject
		
		if object.activeFlags ~= ACTIVE_FLAG_DEACTIVATED and LevelUpdate:get_mario_spawn_type(object) ~= 0 then
			local warp_node = self:area_get_warp_node_from_params(object)
			if warp_node then
				warp_node.object = object
			end
		end
	end
end

function Area:load_area(index)
	if not self.gCurrentArea and self.gAreas[index] then
		self.gCurrentArea = self.gAreas[index]
		self.gCurAreaIndex = self.gCurrentArea.index
		
		if self.gCurrentArea.terrainData then
			-- WTF is gLinker?
			--gLinker.SurfaceLoad.load_area_terrain(index, this.gCurrentArea.terrainData, this.gCurrentArea.surfaceRooms, this.gCurrentArea.macroObjects)
		end
		
		if self.gCurrentArea.objectSpawnInfos then
			--gLinker.ObjectListProcessor.spawn_objects_from_info(this.gCurrentArea.objectSpawnInfos)
		end
		
		self:load_obj_warp_nodes()
		--geo_call_global_function_nodes(self.gCurrentArea.geometryLayoutData, GEO_CONTEXT_AREA_LOAD)
	end
end

function Area:unload_area()
	if self.gCurrentArea then
		ObjectListProcessor:unload_objects_from_area(0, self.gCurrentArea.index)
		geo_call_global_function_nodes(self.gCurrentArea.geometryLayoutData, GEO_CONTEXT_AREA_UNLOAD)
		
		self.gCurrentArea.flags = 0
		self.gCurrentArea = nil
		self.gWarpTransition.isActive = 0
	end
end

function Area:load_mario_area()
	self:load_area(self.gMarioSpawnInfo.areaIndex)
	
	if self.gCurrentArea.index == self.gMarioSpawnInfo.areaIndex then
		self.gCurrentArea.flags = bit.bor(self.gCurrentArea.flags, 0x01)
		--ObjectListProcessor:spawn_objects_from_info(self.gMarioSpawnInfo)
		--[[
		local marioCloneSpawnInfo = self.gMarioSpawnInfo
		marioCloneSpawnInfo.startPos[1] = marioCloneSpawnInfo.startPos[1]-500
		ObjectListProcessor:spawn_objects_from_info(self.marioCloneSpawnInfo)
		--]]
	end
end

function Area:unload_mario_area()
	if self.gCurrentArea and bit.band(self.gCurrentArea.flags, 0x01) ~= 0 then
		ObjectListProcessor:unload_objects_from_area(0, self.gMarioSpawnInfo.activeAreaIndex)
		
		self.gCurrentArea.flags = bit.band(self.gCurrentArea.flags, bit.bnot(0x01))
		if self.gCurrentArea.flags == 0 then
			self:unload_area()
		end
	end
end

function Area:area_update_objects()
	--GeoRenderer.gAreaUpdateCounter = GeoRenderer.gAreaUpdateCounter+1
	--ObjectListProcessor:update_objects(0)
end

function Area:override_viewport_and_clip(a, b, c, d, e)
	local sp6 = SF_BOR(bit.lshift(bit.rshift(c, 3), 11), bit.lshift(bit.rshift(d, 3), 6), bit.lshift(bit.rshift(e, 3), 1), 1)
	
	self.gFBSetColor = bit.bor(bit.lshift(sp6, 16), sp6)
	self.D_8032CE74 = a
	self.D_8032CE78 = a
end

function Area:set_warp_transition_rgb(red, green, blue)
	local warpTransitionRGBA16 = SF_BOR(bit.lshift(bit.rshift(red, 3), 11), bit.lshift(bit.rshift(green, 3), 6), bit.lshift(bit.rshift(blue, 3), 1), 1)
	self.gWarpTransFBSetColor = bit.bor(bit.lshift(warpTransitionRGBA16, 16), warpTransitionRGBA16)
	self.gWarpTransRed = red
	self.gWarpTransGreen = green
	self.gWarpTransBlue = blue
end

function Area:play_transition(transType, time, red, green, blue)
	self.gWarpTransition.isActive = 1
	self.gWarpTransition.type = transType
	self.gWarpTransition.time = time
	self.gWarpTransition.pauseRendering = false
	
	-- The lowest bit of transType determines if the transition is fading in or out.
	if bit.band(transType, 1) ~= 0 then
		self:set_warp_transition_rgb(red, green, blue)
	else
		red = self.gWarpTransRed
		green = self.gWarpTransGreen
		blue = self.gWarpTransBlue
	end
	
	self.gWarpTransition.data.red = red
	self.gWarpTransition.data.green = green
	self.gWarpTransition.data.blue = blue
	if transType >= 8 then -- if transition is not RGB
		-- Both the start and end textured transition are always located in the middle of the screen.
		-- If you really wanted to, you could place the start at one corner and the end at
		-- the opposite corner. This will make the transition image look like it is moving
		-- across the screen.
		self.gWarpTransition.data.startTexX = SCREEN_WIDTH / 2 / 2
		self.gWarpTransition.data.startTexY = SCREEN_HEIGHT / 2 / 2
		self.gWarpTransition.data.endTexX = SCREEN_WIDTH / 2 / 2
		self.gWarpTransition.data.endTexY = SCREEN_HEIGHT / 2 / 2
		
		self.gWarpTransition.data.texTimer = 0
		
		if bit.band(transType, 1) ~= 0 then -- fading in
			self.gWarpTransition.data.startTexRadius = SCREEN_WIDTH / 2
			if transType >= 0x0F then
				self.gWarpTransition.data.endTexRadius = 16
			else
				self.gWarpTransition.data.endTexRadius = 0
			end
		else -- fading out
			if transType >= 0x0E then
				self.gWarpTransition.data.startTexRadius = 16
			else
				self.gWarpTransition.data.startTexRadius = 0
			end
			self.gWarpTransition.data.endTexRadius = SCREEN_WIDTH / 2
		end
	end
end

function Area:clear_areas()
	self.gCurrentArea = nil
	self.gWarpTransition.isActive = 0
	self.gWarpTransition.pauseRendering = 0
	self.gMarioSpawnInfo.areaIndex = -1
	
	for i, areaData in pairs(self.gAreas) do
		table.assign(areaData, {
			index = i,
			flags = 0,
			terrainType = 0,
			geometryLayoutData = nil,
			terrainData = nil,
			surfaceRooms = nil,
			macroObjects = nil,
			warpNodes = {},
			paintingWarpNodes = {},
			instantWarps = {},
			objectSpawnInfos = nil,
			camera = nil,
			unused28 = nil,
			whirlpools = {nil, nil},
			dialog = {nil, nil},
			musicParam = 0,
			musicParam2 = 0
		})
	end
end

function Area:clear_area_graph_nodes()
	if self.gCurrentArea then
		geo_call_global_function_nodes(self.gCurrentArea.geometryLayoutData, GEO_CONTEXT_AREA_UNLOAD)
		self.gCurrentArea = nil
		self.gWarpTransition.isActive = 0
	end
	
	for i, areaData in pairs(self.gAreas) do
		if areaData.geometryLayoutData then
			geo_call_global_function_nodes(areaData.geometryLayoutData, GEO_CONTEXT_AREA_INIT)
			areaData.geometryLayoutData = nil
		end
	end
end

function Area:render_game()
	if self.gCurrentArea and not self.gWarpTransition.pauseRendering then
		GeoRenderer:geo_process_root(self.gCurrentArea.geometryLayoutData, self.D_8032CE74, self.D_8032CE78, self.gFBSetColor)
		
		Gbi.gSPViewport(Game.gDisplayList, D_8032CF00)
		
		--Hud:render_hud()
		--Print:render_text_labels()
		--do_cutscene_handler()
		--print_displaying_credits_entry()
		
		--gPauseScreenMode = render_menus_and_dialogs()
		
		--[[
		if gPauseScreenMode ~= 0 then
			gSaveOptSelectIndex = gPauseScreenMode
		end
		
		if D_8032CE78 ~= nil then
			make_viewport_clip_rect(D_8032CE78)
		else
			gDisplayListHead = gDisplayListHead+1
			gDPSetScissor(gDisplayListHead, G_SC_NON_INTERLACE, 0, BORDER_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - BORDER_HEIGHT)
		end
		]]
		
		if self.gWarpTransition.isActive then
			if self.gWarpTransDelay == 0 then
				self.gWarpTransition.isActive = not render_screen_transition(0, self.gWarpTransition.type, self.gWarpTransition.time, self.gWarpTransition.data)
				
				if not self.gWarpTransition.isActive then
					if bit.band(self.gWarpTransition.type, 1) ~= 0 then
						self.gWarpTransition.pauseRendering = true
					else
						self:set_warp_transition_rgb(0, 0, 0)
					end
				end
			else
				self.gWarpTransDelay = self.gWarpTransDelay-1
			end
		end
	else
		--Print:render_text_labels()
		if self.D_8032CE78 then
			Game:clear_viewport(self.D_8032CE78, self.gWarpTransFBSetColor)
		else
			Game:clear_frame_buffer(self.gWarpTransFBSetColor)
		end
	end
	
	self.D_8032CE74 = nil
	self.D_8032CE78 = nil
end

function Area:print_intro_text()
	if bit.band(gGlobalTimer, 0x1F) < 20 then
		local noController = false -- gControllerBits == 0
		
		if noController then
			--Print:print_text_centered(SCREEN_WIDTH / 2, 20, "NO CONTROLLER")
		else
			--Print:print_text_centered(60, 38, "PRESS")
			--Print:print_text_centered(60, 20, "START")
		end
	end
end

Area.gCurrentArea = nil
Area.gAreas = Array(8):fill(0):map(function() return { index = 0 } end):destroy()
Area.gCurAreaIndex = 0
Area.gCurrLevelNum = 0
Area.gLoadedGraphNodes = {}

Area.D_8032CE74 = nil
Area.D_8032CE78 = nil

Area.gMarioSpawnInfo = {
	startPos = Vector(0, 0, 0),
	startAngle = Angle(0, 0, 0),
	areaIndex = 0, activeAreaIndex = 0,
	behaviorArg = 0, behaviorScript = nil,
	unk18 = nil,
	next = nil
}

Area.gWarpTransition = {
	data = {}
}
Area.gWarpTransDelay = 0
Area.gFBSetColor = 0
Area.gWarpTransFBSetColor = 0
Area.gWarpTransRed = 0
Area.gWarpTransGreen = 0
Area.gWarpTransBlue = 0

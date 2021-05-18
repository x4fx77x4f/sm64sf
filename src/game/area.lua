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
	end
end

function Area:load_mario_area()
	self:load_area(self.gMarioSpawnInfo.areaIndex)
	
	if self.gCurrentArea.index == self.gMarioSpawnInfo.areaIndex then
		self.gCurrentArea.flags = bit.bor(self.gCurrentArea.flags, 0x01)
		--gLinker.ObjectListProcessor.spawn_objects_from_info(this.gMarioSpawnInfo)
		--[[
		local marioCloneSpawnInfo = self.gMarioSpawnInfo
		marioCloneSpawnInfo.startPos[1] = marioCloneSpawnInfo.startPos[1]-500
		gLinker.ObjectListProcessor.spawn_objects_from_info(this.marioCloneSpawnInfo)
		--]]
	end
end

function Area:area_update_objects()
	--GeoRenderer.gAreaUpdateCounter = GeoRenderer.gAreaUpdateCounter+1
	--gLinker.ObjectListProcessor.update_objects(0)
end

function Area:set_warp_transition_rgb(red, green, blue)
	local warpTransitionRGBA16 = SF_BOR(bit.lshift(bit.rshift(red, 3), 11), bit.lshift(bit.rshift(green, 3), 6), bit.lshift(bit.rshift(blue, 3), 1), 1)
	self.gWarpTransFBSetColor = bit.bor(bit.lshift(warpTransitionRGBA16, 16), warpTransitionRGBA16)
	self.gWarpTransRed = red
	self.gWarpTransGreen = green
	self.gWarpTransBlue = blue
end

function Area:play_transition(transType, time, red, green, blue)
	self.gWarpTransition.isActive = true
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
			warpNodes = nil,
			paintingWarpNodes = nil,
			instantWarps = nil,
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

function Area:render_game()
	if self.gCurrentArea then
		--GeoRenderer:geo_process_root(self.gCurrentArea.geometryLayoutData, nil, nil, nil)
		
		Gbi.gSPViewport(Game.gDisplayList, D_8032CF00)
		--Hud:render_hud()
		--Print:render_text_labels()
		
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
	end
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

Area.gMarioSpawnInfo = {
	startPos = Vector(0, 0, 0),
	startAngle = Angle(0, 0, 0),
	areaIndex = 0, activeAreaIndex = 0,
	behaviorArg = 0, behaviorScript = nil,
	unk18 = nil, next = nil
}

Area.gWarpTransition = {
	data = {}
}
Area.gWarpTransDelay = 0
Area.gWarpTransRed = 0
Area.gWarpTransGreen = 0
Area.gWarpTransBlue = 0

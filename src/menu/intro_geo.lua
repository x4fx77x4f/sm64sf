-- frame counts for the zoom in, hold, and zoom out of title model
local INTRO_STEPS_ZOOM_IN = 20
local INTRO_STEPS_HOLD_1 = 75
local INTRO_STEPS_ZOOM_OUT = 91

sIntroFrameCounter = nil
sTmCopyrightAlpha = nil

-- Geo callback to render the "Super Mario 64" logo on the title screen
-- sm64js equivalent: geo_title_screen(param, graphNode, unused)
function geo_intro_super_mario_64_logo(self, state, node, context)
	dbgprintf("[geo_intro_super_mario_64_logo] state: %q, node: %q\n", tostring(state), tostring(node))
	local graphNode = node
	local dl = nil
	local dlIter = nil
	local scaleMat = Matrix()
	local scaleTable1 = intro_seg7_table_0700C790
	local scaleTable2 = intro_seg7_table_0700C880
	local scaleX
	local scaleY
	local scaleZ
	
	if state ~= 1 then
		sIntroFrameCounter = 0
	else
		scaleMat = Matrix()
		
		-- determine scale based on the frame counter
		if sIntroFrameCounter >= 0 and sIntroFrameCounter < INTRO_STEPS_ZOOM_IN then
			-- zooming in
			scaleX = scaleTable1[sIntroFrameCounter * 3]
			scaleY = scaleTable1[sIntroFrameCounter * 3 + 1]
			scaleZ = scaleTable1[sIntroFrameCounter * 3 + 2]
		elseif sIntroFrameCounter >= INTRO_STEPS_ZOOM_IN and sIntroFrameCounter < INTRO_STEPS_HOLD_1 then
			-- holding
			scaleX = 1
			scaleY = 1
			scaleZ = 1
		elseif sIntroFrameCounter >= INTRO_STEPS_HOLD_1 and sIntroFrameCounter < INTRO_STEPS_ZOOM_OUT then
			-- zooming out
			scaleX = scaleTable2[(sIntroFrameCounter - INTRO_STEPS_HOLD_1) * 3]
			scaleY = scaleTable2[(sIntroFrameCounter - INTRO_STEPS_HOLD_1) * 3 + 1]
			scaleZ = scaleTable2[(sIntroFrameCounter - INTRO_STEPS_HOLD_1) * 3 + 2]
		else
			-- disappeared
			scaleX = 0
			scaleY = 0
			scaleZ = 0
		end
		--guScale(scaleMat, scaleX, scaleY, scaleZ)
		
		--gSPMatrix(scaleMat, bit.bor(bit.bor(G_MTX_MODELVIEW, G_MTX_MUL), G_MTX_PUSH))
		--gSPDisplayList(intro_seg7_dl_0700B3A0) -- draw model
		--gSPPopMatrix(G_MTX_MODELVIEW)
		--gSPEndDisplayList()
		
		render.setRGBA(255, 255, 255, 255)
		render.setFont('DermaLarge')
		render.drawSimpleText(20, 20, "geo_intro_super_mario_64_logo")
		render.drawLine(0, 0, 1024, 1024)
		
		sIntroFrameCounter = sIntroFrameCounter+1
	end
	return dl
end

-- Geo callback to render TM and Copyright on the title screen
-- sm64js equvalent: geo_fade_transition(param, graphNode, unused)
function geo_intro_tm_copyright(self, state)
	if state ~= 1 then -- reset
		sTmCopyrightAlpha = 0
	else -- draw
		render.setRGBA(255, 255, 255, sTmCopyrightAlpha)
		intro_seg7_dl_0700C6A0() -- draw model
		
		-- Once the "Super Mario 64" logo has just about zoomed fully, fade in the "TM" and copyright text
		if sIntroFrameCounter >= 19 then
			sTmCopyrightAlpha = sTmCopyrightAlpha+26
			if sTmCopyrightAlpha > 255 then
				sTmCopyrightAlpha = 255
			end
		end
	end
end

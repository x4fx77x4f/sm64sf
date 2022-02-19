-- The equivalents of this file in n64decomp/sm64 are 'src/menu/intro_geo.c'
-- The equivalent of this file in sm64js is 'src/levels/intro/gfx.js'

-- frame counts for the zoom in, hold, and zoom out of title model
INTRO_STEPS_ZOOM_IN = 20
INTRO_STEPS_HOLD_1 = 75
INTRO_STEPS_ZOOM_OUT = 91

-- background types
INTRO_BACKGROUND_SUPER_MARIO = 0
INTRO_BACKGROUND_GAME_OVER = 1

-- intro geo bss
local sGameOverFrameCounter = -0x00000000
local sGameOverTableIndex = -0x00000000
local sIntroFrameCounter = -0x0000
local sTmCopyrightAlpha = -0x00000000

-- Geo callback to render the "Super Mario 64" logo on the title screen
function geo_intro_super_mario_64_logo(state, node, context)
	if state ~= GEO_CONTEXT_RENDER then
		sIntroFrameCounter = 0
	else
		node.flags = bit.bor(bit.band(node.flags, 0xff), bit.lshift(LAYER_OPAQUE, 8))
		local scaleTable1 = intro_seg7_table_0700C790
		local scaleTable2 = intro_seg7_table_0700C880
		local scale
		
		-- determine scale based on the frame counter
		if sIntroFrameCounter >= 0 and sIntroFrameCounter < INTRO_STEPS_ZOOM_IN then
			-- zooming in
			scale = Vector(
				scaleTable1[sIntroFrameCounter * 3 + 1],
				scaleTable1[sIntroFrameCounter * 3 + 2],
				scaleTable1[sIntroFrameCounter * 3 + 3]
			)
		elseif sIntroFrameCounter >= INTRO_STEPS_ZOOM_IN and sIntroFrameCounter < INTRO_STEPS_HOLD_1 then
			-- holding
			scale = Vector(
				1.0,
				1.0,
				1.0
			)
		elseif sIntroFrameCounter >= INTRO_STEPS_HOLD_1 and sIntroFrameCounter < INTRO_STEPS_ZOOM_OUT then
			-- zooming out
			scale = Vector(
				scaleTable2[(sIntroFrameCounter - INTRO_STEPS_HOLD_1) * 3 + 1],
				scaleTable2[(sIntroFrameCounter - INTRO_STEPS_HOLD_1) * 3 + 2],
				scaleTable2[(sIntroFrameCounter - INTRO_STEPS_HOLD_1) * 3 + 3]
			)
		else
			-- disappeared
			scale = Vector(
				0.0,
				0.0,
				0.0
			)
		end
		local mtx = Matrix()
		mtx:setScale(scale)
		
		render.pushMatrix(mtx)
			-- TODO: Draw the actual logo
			render.setRGBA(127, 255, 127, 255)
			render.setFont('DermaDefault')
			render.drawText(SCREEN_WIDTH, 0, "geo_intro_super_mario_64_logo", TEXT_ALIGN.RIGHT)
		render.popMatrix()
		
		sIntroFrameCounter = sIntroFrameCounter+1
	end
end

-- Geo callback to render TM and Copyright on the title screen
function geo_intro_tm_copyright(state, node, context)
	if state ~= GEO_CONTEXT_RENDER then
		sIntroFrameCounter = 0
	else
		render.setRGBA(255, 255, 255, sTmCopyrightAlpha)
		if sTmCopyrightAlpha == 255 then -- opaque
			node.flags = bit.bor(bit.band(node.flags, 0xff), bit.lshift(LAYER_OPAQUE, 8))
		else -- blend
			node.flags = bit.bor(bit.band(node.flags, 0xff), bit.lshift(LAYER_TRANSPARENT, 8))
		end
		render.setFont('DermaDefault')
		render.drawText(SCREEN_WIDTH, 20, "geo_intro_tm_copyright", TEXT_ALIGN.RIGHT)
		
		-- Once the "Super Mario 64" logo has just about zoomed fully, fade in the "TM" and copyright text
		if sIntroFrameCounter >= 19 then
			sTmCopyrightAlpha = sTmCopyrightAlpha+26
			if sTmCopyrightAlpha > 255 then
				sTmCopyrightAlpha = 255
			end
		end
	end
end

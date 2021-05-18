TEX_TRANS_STAR = 0
TEX_TRANS_CIRCLE = 1
TEX_TRANS_MARIO = 2
TEX_TRANS_BOWSER = 3

TRANS_TYPE_MIRROR = 0
TRANS_TYPE_CLAMP = 1

local sTransitionColorFadeCount = {[0]=0, 0, 0, 0}
local sTransitionTextureFadeCount = {[0]=0, 0}

local sTextureTransitionID = {[0]=
	texture_transition_star_half
}

local function set_and_reset_transition_fade_timer(fadeTimer, transTime)
	local reset = false
	
	sTransitionColorFadeCount[fadeTimer] = sTransitionColorFadeCount[fadeTimer]+1
	
	if sTransitionColorFadeCount[fadeTimer] == transTime then
		sTransitionColorFadeCount[fadeTimer] = 0
		sTransitionTextureFadeCount[fadeTimer] = 0
		reset = true
	end
	
	return reset
end

local function set_transition_color_fade_alpha(fadeType, fadeTimer, transTime)
	if fadeType == 0 then
		return sTransitionColorFadeCount[fadeTimer] * 255.0 / (transTime - 1) + 0.5 -- fade in
	else
		return (1.0 - sTransitionColorFadeCount[fadeTimer] / (transTime - 1)) * 255.0 + 0.5 -- fade out
	end
end

local function vertex_transition_color(transData, alpha)
	local verts = {}
	local r = transData.red
	local g = transData.green
	local b = transData.blue
	
	make_vertex(verts, 0, GFX_DIMENSIONS_FROM_LEFT_EDGE(0), 0, -1, 0, 0, r, g, b, alpha)
	make_vertex(verts, 1, GFX_DIMENSIONS_FROM_RIGHT_EDGE(0), 0, -1, 0, 0, r, g, b, alpha)
	make_vertex(verts, 2, GFX_DIMENSIONS_FROM_RIGHT_EDGE(0), SCREEN_HEIGHT, -1, 0, 0, r, g, b, alpha)
	make_vertex(verts, 3, GFX_DIMENSIONS_FROM_LEFT_EDGE(0), SCREEN_HEIGHT, -1, 0, 0, r, g, b, alpha)
	
	return verts
end

local function dl_transition_color(fadeTimer, transTime, transData, alpha)
	local verts = vertex_transition_color(transData, alpha)
	
	Gbi.gSPDisplayList(Game.gDisplayList, dl_proj_mtx_fullscreen)
	Gbi.gDPSetCombineMode(Game.gDisplayList, Gbi.G_CC_SHADE)
	Gbi.gDPSetRenderMode(Game.gDisplayList, Gbi.G_RM_AA_XLU_SURF2)
	Gbi.gSPVertex(Game.gDisplayList, verts, 4, 0)
	Gbi.gSPDisplayList(Game.gDisplayList, dl_draw_quad_verts_0123)
	Gbi.gSPDisplayList(Game.gDisplayList, dl_screen_transition_end)
	
	return set_and_reset_transition_fade_timer(fadeTimer, transTime)
end

local function render_fade_transition_from_color(fadeTimer, transTime, transData)
	local alpha = set_transition_color_fade_alpha(1, fadeTimer, transTime)
	
	return dl_transition_color(fadeTimer, transTime, transData, alpha)
end

local function render_fade_transition_into_color(fadeTimer, transTime, transData)
	local alpha = set_transition_color_fade_alpha(0, fadeTimer, transTime)
	
	return dl_transition_color(fadeTimer, transTime, transData, alpha)
end

local function calc_tex_transition_time(fadeTimer, transTime, transData)
	local startX = transData.startTexX
	local startY = transData.startTexY
	local endX = transData.endTexX
	local endY = transData.endTexY
	local sqrtXY = math.sqrt((startX - endX) * (startX - endX) + (startY - endY) * (startY - endY))
	local result = sTransitionColorFadeCount[fadeTimer] * sqrtXY / (transTime - 1)
	
	return result
end

local function convert_tex_transition_angle_to_pos(transData)
	local x = transData.endTexX - transData.startTexX
	local y = transData.endTexY - transData.startTexY
	
	return atan2s(x, y)
end

local function center_tex_transition_x(transData, texTransTime, texTransPos)
	local x = transData.startTexX + math.cos(texTransPos / 0x8000 * math.pi) * texTransTime
	
	return math.floor(x + 0.5)
end

local function center_tex_transition_y(transData, texTransTime, texTransPos)
	local y = transData.startTexY + math.cos(texTransPos / 0x8000 * math.pi) * texTransTime
	
	return math.floor(y + 0.5)
end

local function calc_tex_transition_radius(fadeTimer, transTime, transData)
	local texRadius = transData.endTexRadius - transData.startTexRadius
	local radiusTime = sTransitionColorFadeCount[fadeTimer] * texRadius / (transTime - 1)
	local result = transData.startTexRadius + radiusTime
	
	return math.floor(result + 0.5)
end

local function make_tex_transition_vertex(verts, n, fadeTimer, transData, centerTransX, centerTransY, texRadius1, texRadius2, tx, ty)
	local r = transData.red
	local g = transData.green
	local b = transData.blue
	local zeroTimer = sTransitionTextureFadeCount[fadeTimer]
	local centerX = texRadius1 * math.cos(zeroTimer / 0x8000 * math.pi) - texRadius2 * math.sin(zeroTimer / 0x8000 * math.pi) + centerTransX
	local centerY = texRadius1 * math.sin(zeroTimer / 0x8000 * math.pi) + texRadius2 * math.cos(zeroTimer / 0x8000 * math.pi) + centerTransY
	local x = round_float(centerX)
	local y = round_float(centerY)
	
	make_vertex(verts, n, x, y, -1, tx * 32, ty * 32, r, g, b, 255)
end

local function load_tex_transition_vertex(verts, fadeTimer, transData, centerTransX, centerTransY, texTransRadius, transTexType)
	if transTexType == TRANS_TYPE_MIRROR then
		make_tex_transition_vertex(verts, 0, fadeTimer, transData, centerTransX, centerTransY, -texTransRadius, -texTransRadius, -31, 63)
		make_tex_transition_vertex(verts, 1, fadeTimer, transData, centerTransX, centerTransY, texTransRadius, -texTransRadius, 31, 63)
		make_tex_transition_vertex(verts, 2, fadeTimer, transData, centerTransX, centerTransY, texTransRadius, texTransRadius, 31, 0)
		make_tex_transition_vertex(verts, 3, fadeTimer, transData, centerTransX, centerTransY, -texTransRadius, texTransRadius, -31, 0)
	else
		error("unimplemented transition type")
	end
	make_tex_transition_vertex(verts, 4, fadeTimer, transData, centerTransX, centerTransY, -2000, -2000, 0, 0)
	make_tex_transition_vertex(verts, 5, fadeTimer, transData, centerTransX, centerTransY, 2000, -2000, 0, 0)
	make_tex_transition_vertex(verts, 6, fadeTimer, transData, centerTransX, centerTransY, 2000, 2000, 0, 0)
	make_tex_transition_vertex(verts, 7, fadeTimer, transData, centerTransX, centerTransY, -2000, 2000, 0, 0)
end

local function render_textured_transition(fadeTimer, transTime, transData, texID, transTexType)
	local texTransTime = calc_tex_transition_time(fadeTimer, transTime, transData)
	local texTransPos = convert_tex_transition_angle_to_pos(transData)
	if texTransPos < 0 then
		error("texTransPos is negative but it is supposed to be uint")
	end
	local centerTransX = center_tex_transition_x(transData, texTransTime, texTransPos)
	local centerTransY = center_tex_transition_y(transData, texTransTime, texTransPos)
	local texTransRadius = calc_tex_transition_radius(fadeTimer, transTime, transData)
	
	local verts = {}
	
	load_tex_transition_vertex(verts, fadeTimer, transData, centerTransX, centerTransY, texTransRadius, transTexType)
	
	Gbi.gSPDisplayList(Game.gDisplayList, dl_proj_mtx_fullscreen)
	Gbi.gDPSetCombineMode(Game.gDisplayList, Gbi.G_CC_SHADE)
	Gbi.gDPSetRenderMode(Game.gDisplayList, Gbi.G_RM_AA_OPA_SURF_SURF2)
	Gbi.gSPVertex(Game.gDisplayList, verts, 8, 0)
	Gbi.gSPDisplayList(Game.gDisplayList, dl_transition_draw_filled_region)
	Gbi.gDPSetCombineMode(Game.gDisplayList, Gbi.G_CC_MODULATEIDECALA)
	Gbi.gDPSetRenderMode(Game.gDisplayList, Gbi.G_RM_AA_XLU_SURF_SURF2)
	Gbi.gDPSetTextureFilter(Game.gDisplayList, Gbi.G_TF_BILERP)
	
	assertf(sTextureTransitionID[texID], "no such sTextureTransitionID %d", texID)
	
	if transTexType == TRANS_TYPE_MIRROR then
		Gbi.gDPLoadTextureBlock(Game.gDisplayList, sTextureTransitionID[texID], Gbi.G_IM_FMT_IA, Gbi.G_IM_SIZ_8b, 32, 64, 0, bit.bor(Gbi.G_TX_WRAP, Gbi.G_TX_MIRROR), bit.bor(Gbi.G_TX_WRAP, Gbi.G_TX_MIRROR), 5, 6, Gbi.G_TX_NOLOD, Gbi.G_TX_NOLOD)
	else
		error("unimplemented transition type")
	end
	
	Gbi.gSPTexture(Game.gDisplayList, 0xFFFF, 0xFFFF, 0, Gbi.G_TX_RENDERTILE, Gbi.G_ON)
	Gbi.gSPVertex(Game.gDisplayList, verts, 4, 0)
	Gbi.gSPDisplayList(Game.gDisplayList, dl_draw_quad_verts_0123)
	Gbi.gSPTexture(Game.gDisplayList, 0xFFFF, 0xFFFF, 0, Gbi.G_TX_RENDERTILE, Gbi.G_OFF)
	Gbi.gSPDisplayList(Game.gDisplayList, dl_screen_transition_end)
	sTransitionTextureFadeCount[fadeTimer] = sTransitionTextureFadeCount[fadeTimer]+transData.texTimer
	
	return set_and_reset_transition_fade_timer(fadeTimer, transTime)
end

local render_screen_transition_switch = {
	--[WARP_TRANSITION_FADE_FROM_COLOR] = {render_fade_transition_from_color},
	[WARP_TRANSITION_FADE_INTO_COLOR] = {render_fade_transition_into_color},
	[WARP_TRANSITION_FADE_FROM_STAR] = {render_textured_transition, TEX_TRANS_STAR, TRANS_TYPE_MIRROR},
	--[WARP_TRANSITION_FADE_INTO_STAR] = {render_textured_transition, TEX_TRANS_STAR, TRANS_TYPE_MIRROR},
	--[WARP_TRANSITION_FADE_FROM_CIRCLE] = {render_textured_transition, TEX_TRANS_CIRCLE, TRANS_TYPE_MIRROR},
	--[WARP_TRANSITION_FADE_INTO_CIRCLE] = {render_textured_transition, TEX_TRANS_CIRCLE, TRANS_TYPE_MIRROR},
	--[WARP_TRANSITION_FADE_FROM_MARIO] = {render_textured_transition, TEX_TRANS_MARIO, TRANS_TYPE_CLAMP},
	--[WARP_TRANSITION_FADE_INTO_MARIO] = {render_textured_transition, TEX_TRANS_MARIO, TRANS_TYPE_CLAMP},
	--[WARP_TRANSITION_FADE_FROM_BOWSER] = {render_textured_transition, TEX_TRANS_BOWSER, TRANS_TYPE_MIRROR},
	--[WARP_TRANSITION_FADE_INTO_BOWSER] = {render_textured_transition, TEX_TRANS_BOWSER, TRANS_TYPE_MIRROR},
}
function render_screen_transition(fadeTimer, transType, transTime, transData)
	local func, TEX_TRANS, TRANS_TYPE = unpack(render_screen_transition_switch[transType])
	assertf(func, "transition type %q not implemented", _GR[transType] or tostring(transType))
	return func(fadeTimer, transTime, transData, TEX_TRANS, TRANS_TYPE)
end

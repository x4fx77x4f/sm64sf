local sTransitionColorFadeCount = {[0]=0, 0, 0, 0}
local sTransitionTextureFadeCount = {[0]=0, 0}

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
	local verts = Vtx(4)
	local r = transData.red
	local g = transData.green
	local b = transData.blue
	
	if verts ~= nil then
		make_vertex(verts, 1, GFX_DIMENSIONS_FROM_LEFT_EDGE(0), 0, -1, 0, 0, r, g, b, alpha)
		make_vertex(verts, 2, GFX_DIMENSIONS_FROM_RIGHT_EDGE(0), 0, -1, 0, 0, r, g, b, alpha)
		make_vertex(verts, 3, GFX_DIMENSIONS_FROM_RIGHT_EDGE(0), SCREEN_HEIGHT, -1, 0, 0, r, g, b, alpha)
		make_vertex(verts, 4, GFX_DIMENSIONS_FROM_LEFT_EDGE(0), SCREEN_HEIGHT, -1, 0, 0, r, g, b, alpha)
	end
	return verts
end

local function dl_transition_color(fadeTimer, transTime, transData, alpha)
	local verts = vertex_transition_color(transData, alpha)
	
	if verts ~= nil then
		gSPDisplayList(dl_proj_mtx_fullscreen)
		gDPSetCombineMode(G_CC_SHADE, G_CC_SHADE)
		gDPSetRenderMode(G_RM_AA_XLU_SURF, G_RM_AA_XLU_SURF2)
		gSPVertex(verts, 4, 0)
		gSPDisplayList(dl_draw_quad_verts_0123)
		gSPDisplayList(dl_screen_transition_end)
	end
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

local render_screen_transition_switch = {
	[WARP_TRANSITION_FADE_FROM_COLOR] = {render_fade_transition_from_color},
	[WARP_TRANSITION_FADE_INTO_COLOR] = {render_fade_transition_into_color},
	[WARP_TRANSITION_FADE_FROM_STAR] = {render_textured_transition, TEX_TRANS_STAR, TRANS_TYPE_MIRROR},
	[WARP_TRANSITION_FADE_INTO_STAR] = {render_textured_transition, TEX_TRANS_STAR, TRANS_TYPE_MIRROR},
	[WARP_TRANSITION_FADE_FROM_CIRCLE] = {render_textured_transition, TEX_TRANS_CIRCLE, TRANS_TYPE_MIRROR},
	[WARP_TRANSITION_FADE_INTO_CIRCLE] = {render_textured_transition, TEX_TRANS_CIRCLE, TRANS_TYPE_MIRROR},
	[WARP_TRANSITION_FADE_FROM_MARIO] = {render_textured_transition, TEX_TRANS_MARIO, TRANS_TYPE_CLAMP},
	[WARP_TRANSITION_FADE_INTO_MARIO] = {render_textured_transition, TEX_TRANS_MARIO, TRANS_TYPE_CLAMP},
	[WARP_TRANSITION_FADE_FROM_BOWSER] = {render_textured_transition, TEX_TRANS_BOWSER, TRANS_TYPE_MIRROR},
	[WARP_TRANSITION_FADE_INTO_BOWSER] = {render_textured_transition, TEX_TRANS_BOWSER, TRANS_TYPE_MIRROR},
}
function render_screen_transition(fadeTimer, transType, transTime, transData)
	local func, TEX_TRANS, TRANS_TYPE = unpack(render_screen_transition_switch[transType])
	return func(fadeTimer, transTime, transData, TEX_TRANS, TRANS_TYPE)
end

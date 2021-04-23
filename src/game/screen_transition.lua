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

local function dl_transition_color(fadeTimer, transTime, transData, alpha)
	--render.setRGBA(transData.red, transData.green, transData.green, alpha)
	render.setRGBA(255, 0, 0, alpha)
	render.drawRect(0, 0, 320, 240)
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

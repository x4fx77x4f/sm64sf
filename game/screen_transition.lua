-- The equivalents of this file in n64decomp/sm64 are 'src/game/screen_transition.c'
-- The equivalent of this file in sm64js is 'src/game/ScreenTransition.js'

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

local sTransitionColorFadeCount = {0, 0, 0, 0}
local sTransitionTextureFadeCount = {0, 0}

local function set_and_reset_transition_fade_timer(fadeTimer, transTime)
	sTransitionColorFadeCount[fadeTimer] = sTransitionColorFadeCount[fadeTimer]+1
	
	if sTransitionColorFadeCount[fadeTimer] == transTime then
		sTransitionColorFadeCount[fadeTimer] = 0
		sTransitionTextureFadeCount[fadeTimer] = 0
		return true
	end
	return false
end

local function set_transition_color_fade_alpha(fadeType, fadeTimer, transTime)
	osdprintf("fadeType: %d, fadeTimer: %s, transTime: %s\n", fadeType, fadeTimer, transTime)
	if fadeType == 0 then
		return sTransitionColorFadeCount[fadeTimer] * 255.0 / (transTime - 1) -- fade in
	elseif fadeType == 1 then
		return (1.0 - sTransitionColorFadeCount[fadeTimer] / (transTime - 1)) * 255.0 -- fade out
	end
	errorf("unknown fadeType %d", fadeType or -1)
end

local function dl_transition_color(fadeTimer, transTime, transData, alpha)
	render.setRGBA(transData.red, transData.green, transData.blue, alpha)
	render.drawRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
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

local lookup = {
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
	local func, texID, transTexType = unpack(assertf(lookup[transType], "invalid transType 0x%02x", transType or 0xff))
	return func(fadeTimer, transTime, transData, texID, transTexType)
end

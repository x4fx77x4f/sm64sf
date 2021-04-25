--[[
	This file is for ports that want to enable widescreen.
	
	The idea is that SCREEN_WIDTH and SCREEN_HEIGHT are still hardcoded to 320 and 240, and that
	x=0 lies at where a 4:3 left edge would be. On 16:9 widescreen, the left edge is hence at -53.33.
	
	To get better accuracy, consider using floats instead of shorts for coordinates in Vertex and Matrix structures.
	
	The conversion to integers above is for RECT commands which naturally only accept integer values.
	Note that RECT commands must be enhanced to support negative coordinates with this modification.
]]

if WIDESREEN then
	local current_aspect_ratio = SCREEN_WIDTH / SCREEN_HEIGHT
	function GFX_DIMENSIONS_FROM_LEFT_EDGE(v)
		return SCREEN_WIDTH / 2 - SCREEN_HEIGHT / 2 * current_aspect_ratio + v
	end
	function GFX_DIMENSIONS_FROM_RIGHT_EDGE(v)
		return SCREEN_WIDTH / 2 - SCREEN_HEIGHT / 2 * current_aspect_ratio - v
	end
	function GFX_DIMENSIONS_RECT_FROM_LEFT_EDGE(v)
		return math.floor(GFX_DIMENSIONS_FROM_LEFT_EDGE(v))
	end
	function GFX_DIMENSIONS_RECT_FROM_RIGHT_EDGE(v)
		return math.ceil(GFX_DIMENSIONS_FROM_RIGHT_EDGE(v))
	end
	GFX_DIMENSIONS_ASPECT_RATIO = current_aspect_ratio
else
	function GFX_DIMENSIONS_FROM_LEFT_EDGE(v)
		return v
	end
	function GFX_DIMENSIONS_FROM_RIGHT_EDGE(v)
		return SCREEN_WIDTH - v
	end
	function GFX_DIMENSIONS_RECT_FROM_LEFT_EDGE(v)
		return v
	end
	function GFX_DIMENSIONS_RECT_FROM_RIGHT_EDGE(v)
		return SCREEN_WIDTH - v
	end
	GFX_DIMENSIONS_ASPECT_RATIO = 4.0 / 3.0
end

-- If screen is taller than it is wide, radius should be equal to SCREEN_HEIGHT since we scale horizontally
function GFX_DIMENSIONS_FULL_RADIUS()
	return SCREEN_HEIGHT * (GFX_DIMENSIONS_ASPECT_RATIO > 1 and GFX_DIMENSIONS_ASPECT_RATIO or 1)
end

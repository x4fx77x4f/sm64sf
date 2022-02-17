--@name sm64sf2
--@author Sarah
--@client

-- The equivalent of this file in sm64js is 'src/index.js'

sprintf = string.format
function errorf(...)
	return error(sprintf(...))
end
function assertf(cond, ...)
	if not cond then
		return error(sprintf(...))
	end
	return cond, ...
end

VERBOSE = true
local osd_t = ""
if VERBOSE then
	function printf(...)
		return pcall(printMessage, 2, sprintf(...))
	end
	function osdprintf(...)
		osd_t = osd_t..sprintf(...)
	end
	function osdclear()
		osd_t = ""
	end
else
	function printf() end
	function osdprintf() end
	function osdclear() end
end

--@include ./engine/level_script.lua
dofile('./engine/level_script.lua')
--@include ./levels/entry.lua
dofile('./levels/entry.lua')

--@include ./game/game_init.lua
dofile('./game/game_init.lua')

local color_bg = Color(31, 31, 31)
local framerate, frames = 0, 0
local framerate_guest, frames_guest = 0, 0
local deadline = timer.systime()+1
local thread = coroutine.create(function(...)
	-- If we don't do this, StarfallEx will lose the stack trace if it happens in a coroutine.
	return xpcall(game_loop, function(err, st)
		printf("%s\n", st)
		error(err)
	end, ...)
end)
local guest_frame_passed
hook.add('render', '', function()
	render.setBackgroundColor(color_bg)
	local now = timer.systime()
	
	guest_frame_passed = coroutine.resume(thread)
	
	if VERBOSE then
		frames = frames+1
		if guest_frame_passed then
			frames_guest = frames_guest+1
		end
		if now >= deadline then
			framerate = frames
			framerate_guest = frames_guest
			frames = 0
			frames_guest = 0
			deadline = now+1
		end
		render.setFont('DebugFixed')
		local osd_t = string.format(
			"%3d host framerate\n"..
			"%3d guest framerate\n"..
			"%s",
			framerate,
			framerate_guest,
			osd_t
		)
		local osd_w, osd_h = render.getTextSize(osd_t)
		render.setRGBA(0, 0, 0, 191)
		render.drawRect(0, 0, osd_w, osd_h)
		render.setRGBA(255, 255, 255, 255)
		render.drawText(0, 0, osd_t)
	end
end)

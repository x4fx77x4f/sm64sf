--@name SM64SF
--@author x4fx77x4f
--@client

sprintf = string.format
function printf(...)
	return print(sprintf(...))
end
function errorf(...)
	return error(sprintf(...))
end
function assertf(cond, ...)
	if cond then
		return cond
	end
	return error(sprintf(...))
end
function boobytrap(...)
	local msg = sprintf(...)
	return function()
		return error(msg)
	end
end
local dbgStr
function dbgprintf(...)
	dbgStr = dbgStr..sprintf(...).."\n"
end
function dbgprintf2(...)
	dbgStr = sprintf(...).."\n"..dbgStr
end

local SF_USE_INCLUDEDATA = true
local SF_CACHE_INCLUDEDATA = true
local SF_INCLUDE_PREFIX = 'sm64sf'
local SF_PATH_USABLE_EXTENSIONS = {
	txt = true,
	dat = true,
	json = true,
	xml = true,
	csv = true,
	jpg = true,
	jpeg = true,
	png = true,
	vtf = true,
	vmt = true,
	mp3 = true,
	wav = true,
	ogg = true
}
local function SF_PATH_HASH(path)
	local ext = string.getExtensionFromFilename(path)
	ext = SF_PATH_USABLE_EXTENSIONS[ext] and ext or 'dat'
	path = string.normalizePath(path)
	path = string.lower(path)
	return sprintf(SF_INCLUDE_PREFIX..'_%s.%s', crc(path), ext)
end
local SF_PATH_USABLE = {}
local SF_PATH_PLACEHOLDER = SF_PATH_HASH('/placeholder.png')
function SF_PATH_PATCH(path)
	if SF_USE_INCLUDEDATA then
		local newpath = SF_PATH_USABLE[path]
		if newpath then
			return newpath
		end
		
		local hash = SF_PATH_HASH(path)
		local newpath = SF_CACHE_INCLUDEDATA and file.existsTemp(hash)
		if newpath then
			return newpath
		end
		
		local data = getScripts()[SF_INCLUDE_PREFIX..path]
		if data then
			newpath = file.writeTemp(hash, data)
			SF_PATH_USABLE[path] = newpath
			return newpath
		end
	end
	local newpath = SF_INCLUDE_PREFIX..'/'..path
	if not hasPermission('file.exists') or not file.exists(newpath) then
		return SF_PATH_PLACEHOLDER
	end
	return 'data/sf_filedata/'..newpath
end
--@includedata sm64sf/placeholder.png
local hash = SF_PATH_HASH('/placeholder.png')
SF_PATH_PLACEHOLDER = file.existsTemp(hash) or file.writeTemp(hash, getScripts()['sm64sf/placeholder.png'])

-- Load order is going to become a problem. I have no doubt that at some
-- point an impossible load order will be required, and when that
-- happens, it's going to fucking suck.

--@include sm64sf/include/config.lua
require('sm64sf/include/config.lua')
--@include sm64sf/include/geo_commands.lua
require('sm64sf/include/geo_commands.lua')
--@include sm64sf/include/level_commands.lua
require('sm64sf/include/level_commands.lua')
--@include sm64sf/include/pr/gbi.lua
require('sm64sf/include/pr/gbi.lua')

--@include sm64sf/src/engine/level_script.lua
require('sm64sf/src/engine/level_script.lua')

--@include sm64sf/src/menu/intro_geo.lua
require('sm64sf/src/menu/intro_geo.lua')
--@include sm64sf/src/menu/level_select_menu.lua
require('sm64sf/src/menu/level_select_menu.lua')

--@include sm64sf/src/game/area.lua
require('sm64sf/src/game/area.lua')
--@include sm64sf/src/game/game_init.lua
require('sm64sf/src/game/game_init.lua')
--@include sm64sf/src/game/object_list_processor.lua
require('sm64sf/src/game/object_list_processor.lua')
--@include sm64sf/src/game/screen_transition.lua
require('sm64sf/src/game/screen_transition.lua')

--@include sm64sf/levels/intro/geo.lua
require('sm64sf/levels/intro/geo.lua')
--@include sm64sf/levels/intro/leveldata.lua
require('sm64sf/levels/intro/leveldata.lua')
--@include sm64sf/levels/intro/script.lua
require('sm64sf/levels/intro/script.lua')
--@include sm64sf/levels/entry.lua
require('sm64sf/levels/entry.lua')

_GR = setmetatable({}, {__mode='k'})
for k, v in pairs(_G) do
	_GR[v] = tostring(k)
end

local thread = coroutine.create(thread5_game_loop)

local threshold = quotaMax()*0.5
local waitUntil = 0
local frameTime = 1/30

local fps = 0
local frames = 0
local frameExpire = timer.systime()+1

local function scaleFit(w1, h1, w2, h2)
	local scale = math.min(w1/w2, h1/h2)
	local w, h = w2*scale, h2*scale
	local x, y = (w1-w)/2, (h1-h)/2
	return x, y, w, h
end

local bg = Color(31, 31, 31)
render.createRenderTarget('screen')
render.createRenderTarget('final')
hook.add('render', '', function()
	render.setBackgroundColor(bg)
	--render.setFilterMag(TEXFILTER.POINT)
	--render.setFilterMin(TEXFILTER.POINT)
	
	dbgStr, dbgStrLines = "", 0
	
	local now = timer.systime()
	if now >= frameExpire then
		fps = frames
		frames = 0
		frameExpire = now+1
	end
	if now >= waitUntil then
		render.selectRenderTarget('screen')
			while quotaUsed() < threshold do
				if coroutine.resume(thread) then
					frames = frames+1
					break
				end
			end
			waitUntil = now+frameTime
		render.selectRenderTarget()
	end
	
	render.setRGBA(255, 255, 255, 255)
	render.setRenderTargetTexture('final')
	local sw, sh = render.getResolution()
	local x, y, w, h = scaleFit(sw, sh, SCREEN_WIDTH, SCREEN_HEIGHT)
	render.drawTexturedRectUV(x, y, w, h, 0, 0, SCREEN_WIDTH/1024, SCREEN_HEIGHT/1024)
	
	-- debug text
	dbgprintf("fps: %d", fps)
	dbgprintf("quota: %d%%", math.ceil(quotaAverage()/quotaMax()*100))
	dbgprintf("script: 0x%02X is %d at %d in %s", sCurrentCmd and sCurrentCmd.type or -1, sScriptStatus or -2, sCurrentCmdOffset or -1, _GR[sCurrentCmds] or "nil")
	-- [[
	dbgStr = string.gsub(dbgStr, "\n$", "")
	render.setFont('DebugFixed')
	render.setRGBA(0, 0, 0, 255)
	render.drawRectFast(0, 0, render.getTextSize(dbgStr))
	render.setRGBA(255, 255, 255, 255)
	render.drawText(0, 0, dbgStr)
	--]]
end)

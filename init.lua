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

--@include sm64sf/include/pr/gbi.lua
require('sm64sf/include/pr/gbi.lua')
--@include sm64sf/include/level_commands.lua
require('sm64sf/include/level_commands.lua')
--@include sm64sf/levels/entry.lua
require('sm64sf/levels/entry.lua')
--@include sm64sf/levels/intro/leveldata.lua
require('sm64sf/levels/intro/leveldata.lua')
--@include sm64sf/levels/intro/script.lua
require('sm64sf/levels/intro/script.lua')
--@include sm64sf/src/menu/intro_geo.lua
require('sm64sf/src/menu/intro_geo.lua')
--@include sm64sf/src/engine/level_script.lua
require('sm64sf/src/engine/level_script.lua')
--@include sm64sf/src/game/game_init.lua
require('sm64sf/src/game/game_init.lua')
--@include sm64sf/src/game/object_list_processor.lua
require('sm64sf/src/game/object_list_processor.lua')
--@include sm64sf/src/game/area.lua
require('sm64sf/src/game/area.lua')

local thread = coroutine.create(thread5_game_loop)

local threshold = quotaMax()*0.5
local waitUntil = 0
local frameTime = 1/30

local fps = 0
local frames = 0
local frameExpire = timer.systime()+1

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
	render.drawTexturedRectUV(0, 63, 512, 384, 0, 0, 0.3125, 0.234375)
	
	-- material debug
	--[[
	render.setMaterial(intro_seg7_texture_07007EA0)
	render.drawTexturedRect(0, 0, 32, 32)
	render.setMaterial(intro_seg7_texture_070086A0)
	render.drawTexturedRect(32, 0, 32, 32)
	render.setMaterial(intro_seg7_texture_0700B4A0)
	render.drawTexturedRect(64, 0, 128, 16)
	render.setMaterial(intro_seg7_texture_0700C4A0)
	render.drawTexturedRect(192, 0, 16, 16)
	--]]
	
	-- debug text
	dbgprintf2("fps: %d", fps)
	dbgprintf2("quota: %d%%", math.ceil(quotaAverage()/quotaMax()*100))
	-- [[
	dbgStr = string.gsub(dbgStr, "\n$", "")
	render.setFont('DebugFixed')
	render.setRGBA(0, 0, 0, 255)
	render.drawRectFast(0, 0, render.getTextSize(dbgStr))
	render.setRGBA(255, 255, 255, 255)
	render.drawText(0, 0, dbgStr)
	--]]
end)

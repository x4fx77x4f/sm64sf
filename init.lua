--@name SM64SF
--@author x4fx77x4f
--@client

sprintf = string.format
function printf(...)
	return pcall(printMessage, 2, sprintf(...))
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
function dbgprintf(...)
	dbgStr = dbgStr..sprintf(...).."\n"
end
function dbgprintf2(...)
	dbgStr = sprintf(...).."\n"..dbgStr
end

-- DEPRECATED; USE asset_loader.lua INSTEAD!
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

function SF_BOR(...)
	local n = 0
	for i=1, select('#', ...) do
		n = bit.bor(n, select(i, ...))
	end
	return n
end

-- JS compatibility
local ArrayMeta = {}
ArrayMeta.__index = ArrayMeta
function ArrayMeta:fill(n)
	for i=1, self._array_max do
		self[i] = n
	end
	return self
end
function ArrayMeta:map(func)
	if type(func) ~= 'function' then
		error("bad argument #1 to 'map' (expected function)", 2)
	end
	for k, v in pairs(self) do
		if k ~= '_array_max' then
			self[k] = func(k, v) or self[k]
		end
	end
	return self
end
function ArrayMeta:destroy()
	self._array_max = nil
	setmetatable(self, nil)
	return self
end
function Array(n)
	return setmetatable({
		_array_max = n
	}, ArrayMeta)
end
-- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/assign
function table.assign(target, ...)
	for i=1, select('#', ...) do
		local source = select(i, ...)
		for k, v in pairs(source) do
			target[k] = v
		end
	end
	return target
end
-- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/find
function table.find(tbl, func)
	local v = tbl[0]
	if v ~= nil then
		if func(v, 0, tbl) then
			return v
		end
	end
	for k, v in ipairs(tbl) do
		if func(v, k, tbl) then
			return v
		end
	end
end

local thread = coroutine.create(function()
	-- Use 'xpcall' so that Starfall's unprotected coroutine.resume
	-- doesn't get to lose our precious stack trace.
	return xpcall(function()
		_GR = setmetatable({}, {__mode='k'})
		
		-- Load order is going to become a problem. I have no doubt that at some
		-- point an impossible load order will be required, and when that
		-- happens, it's going to fucking suck.
		
		--@include sm64sf/asset_loader.lua
		require('sm64sf/asset_loader.lua')
		
		--@include sm64sf/include/config.lua
		require('sm64sf/include/config.lua')
		--@include sm64sf/include/gfx_dimensions.lua
		require('sm64sf/include/gfx_dimensions.lua')
		--@include sm64sf/include/gbi.lua
		require('sm64sf/include/gbi.lua')
		--@include sm64sf/include/segment_symbols.lua
		require('sm64sf/include/segment_symbols.lua')
		
		--@include sm64sf/src/init.lua
		require('sm64sf/src/init.lua')
		
		--@include sm64sf/src/buffers/buffers.lua
		require('sm64sf/src/buffers/buffers.lua')
		
		--@include sm64sf/src/engine/graph_node.lua
		require('sm64sf/src/engine/graph_node.lua')
		--@include sm64sf/src/engine/geo_layout.lua
		require('sm64sf/src/engine/geo_layout.lua')
		--@include sm64sf/src/engine/geo_renderer.lua
		require('sm64sf/src/engine/geo_renderer.lua')
		--@include sm64sf/src/engine/level_script.lua
		require('sm64sf/src/engine/level_script.lua')
		--@include sm64sf/src/engine/math_util.lua
		require('sm64sf/src/engine/math_util.lua')
		
		--@include sm64sf/src/menu/intro_geo.lua
		require('sm64sf/src/menu/intro_geo.lua')
		--@include sm64sf/src/menu/level_select_menu.lua
		require('sm64sf/src/menu/level_select_menu.lua')
		
		--@include sm64sf/src/game/area.lua
		require('sm64sf/src/game/area.lua')
		--@include sm64sf/src/game/game.lua
		require('sm64sf/src/game/game.lua')
		--@include sm64sf/src/game/geo_misc.lua
		require('sm64sf/src/game/geo_misc.lua')
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
		--@include sm64sf/levels/scripts.lua
		require('sm64sf/levels/scripts.lua')
		--@include sm64sf/levels/entry.lua
		require('sm64sf/levels/entry.lua')
		
		--@include sm64sf/coprocessor.lua
		require('sm64sf/coprocessor.lua')
		
		for k, v in pairs(_G) do
			if _GR[v] == nil then
				_GR[v] = tostring(k)
			end
		end
		
		GeoLayout = GeoLayout.new()
		GeoRenderer = GeoRenderer.new()
		Game:initialize()
		startGame()
		
		while true do
			coroutine.yield(true)
		end
	end, function(err, st)
		err = type(err) == 'table' and err.message or err -- Fuck off, Starfall
		pcall(printMessage, 2,
			"-----BEGIN ERROR OUTPUT BLOCK-----\n"..
			--err.."\n"..
			st.."\n"..
			"-----END ERROR OUTPUT BLOCK-----\n"
		)
		error(err)
	end)
end)

local perms = {'file.writeTemp', 'render.screen', 'render.offscreen'}
local function init(initial)
	local hasPerm = true
	for _, perm in pairs(perms) do
		if not hasPermission(perm) then
			hasPerm = false
			pcall(setupPermissionRequest, perms, "Necessary", true)
			return
		end
	end
	if initial and player() ~= owner() then
		return
	end
	hook.remove('render', 'consent')
	hook.remove('starfallUsed', 'consent')
	hook.remove('permissionrequest', 'consent')
	
	render.createRenderTarget('screen')
	render.createRenderTarget('final')
	
	local threshold = quotaMax()*0.8
	hook.add('renderoffscreen', 'main', function()
		local first = true
		render.selectRenderTarget('screen')
		while quotaAverage() < threshold do
			if coroutine.resume(thread, first) then
				return
			end
			first = false
		end
	end)
end
if SCREENGRAB then
	init()
	return
end
local bg = Color(0, 0, 0)
hook.add('render', 'consent', function()
	render.setBackgroundColor(bg)
	render.setFont('DermaDefault')
	render.drawText(10, 10, "Press E on screen to activate\n\nNOTE: Extremely early in development,\nit does not do very much right now")
end)
hook.add('starfallUsed', 'consent', function(activator, used)
	if activator ~= player() then
		return
	end
	init()
end)
hook.add('permissionrequest', 'consent', init)
init(true)

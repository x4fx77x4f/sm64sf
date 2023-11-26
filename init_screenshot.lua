--@name SM64SF
--@author x4fx77x4f
--@client
--@include ./init.lua
local hook_add = hook.add
local identifier = "x_render"
function hook.add(name, ...)
	name = string.lower(name)
	if name == "render" then
		name = identifier
	else
		assert(name ~= identifier)
	end
	return hook_add(name, ...)
end
render.createRenderTarget(identifier)
local done = false
local function argvar_capture(...)
	return {...}, select("#", ...)
end
local render_selectRenderTarget = render.selectRenderTarget
local active = false
function render.selectRenderTarget(name, ...)
	assert(name ~= identifier)
	if active == true and name == nil then
		name = identifier
	end
	return render_selectRenderTarget(name, ...)
end
local start
local background = Color(0, 0, 0)
local render_setBackgroundColor = render.setBackgroundColor
function render.setBackgroundColor(color, ...)
	background = color
	return render_setBackgroundColor(color, ...)
end
hook_add("render", "", function(...)
	local now = timer.systime()
	if start == nil then
		start = now
	end
	now = now-start
	if done == false and now >= 2 then
		local path_index = 0
		local path
		repeat
			path_index = path_index+1
			path = "screenshot_"..path_index..".png"
		until not file.existsTemp(path)
		active = true
		render_selectRenderTarget(identifier)
		render.clear(background)
		local retvals, retval_count = argvar_capture(pcall(hook.run, identifier, ...))
		if not retvals[1] then
			error(retvals[2])
		end
		render_selectRenderTarget(identifier)
		local width, height = render.getResolution()
		file.writeTemp(path, render.captureImage({
			format = "png",
			x = 0,
			y = 0,
			w = width,
			h = height,
			alpha = false,
		}))
		render.destroyRenderTarget(identifier)
		print("Done")
		done = true
		active = false
		return unpack(retvals, 2, retval_count)
	end
	return hook.run(identifier, ...)
end)
dofile("./init.lua")

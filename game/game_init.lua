-- The equivalent of this file in n64decomp/sm64 is 'src/game/game_init.c'
-- The equivalent of this file in sm64js is 'src/game/Game.js'

local gPhysicalFramebuffers = {
	[0] = 'gPhysicalFramebuffers[0]',
	[1] = 'gPhysicalFramebuffers[1]',
	[2] = 'gPhysicalFramebuffers[2]',
}
for _, rt in pairs(gPhysicalFramebuffers) do
	render.createRenderTarget(rt)
end

-- General timer that runs as the game starts
gGlobalTimer = 0x0000

-- Framebuffer rendering values (max 3)
local sRenderedFramebuffer = 0x0000
local sRenderingFramebuffer = 0x0000

-- Selects the current one of the three framebuffers.
local function select_framebuffer()
	render.selectRenderTarget(assertf(gPhysicalFramebuffers[sRenderingFramebuffer], "bad sRenderingFramebuffer %d", sRenderingFramebuffer))
	render.enableScissorRect(0, BORDER_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-BORDER_HEIGHT)
end

-- Clear the framebuffer by filling it with a color.
function clear_framebuffer(color)
	render.setColor(color)
	-- TODO: Implement and use GFX_DIMENSIONS_RECT_FROM_*_EDGE
	-- TODO: Is the -1 significant? Is it supposed to leave the rightmost and bottommost lines uncleared?
	render.drawRect(0, BORDER_HEIGHT, SCREEN_WIDTH-1, SCREEN_HEIGHT-BORDER_HEIGHT-1)
end

-- Like clear_framebuffer, but only clears part of the screen.
function clear_viewport(viewport, color)
	local vpUlx = (viewport.vp.vtrans[1] - viewport.vp.vscale[1]) / 4 + 1
	local vpUly = (viewport.vp.vtrans[2] - viewport.vp.vscale[2]) / 4 + 1
	local vpLrx = (viewport.vp.vtrans[1] + viewport.vp.vscale[1]) / 4 - 2
	local vpLry = (viewport.vp.vtrans[2] + viewport.vp.vscale[2]) / 4 - 2
	
	render.setColor(color)
	render.drawRect(vpUlx, vpUly, vpLrx, vpLry)
end

-- Initial settings for the first rendered frame.
local function render_init()
	select_framebuffer()
	clear_framebuffer(Color(0, 0, 0))
	
	sRenderingFramebuffer = sRenderingFramebuffer+1
	gGlobalTimer = gGlobalTimer+1
end

-- This function...
-- ...yields until the resume time is reached, locking the game to 30 FPS,
-- ...selects which framebuffer will be rendered to next frame.
local function handle_vsync(resume_time)
	coroutine.yield(true)
	if resume_time then
		while timer.systime() < resume_time do
			coroutine.yield()
		end
	end
	sRenderedFramebuffer = (sRenderedFramebuffer+1)%3
	sRenderingFramebuffer = (sRenderingFramebuffer+1)%3
	select_framebuffer()
	gGlobalTimer = gGlobalTimer+1
end

local max_quota = quotaMax()*0.25
function yield(...)
	if math.max(quotaAverage(), quotaTotalAverage()) >= max_quota then
		coroutine.yield(...)
		select_framebuffer()
	end
end

-- Main game loop thread. Runs forever as long as the game continues.
function game_loop()
	local script, index = level_script_entry, 1
	
	render_init()
	
	while true do
		osdclear()
		local resume_time = timer.systime()+(1/30)
		
		script, index = level_script_execute(script, index)
		
		handle_vsync(resume_time)
	end
end

-- Scales w2 and h2 down to fit within w1 and h1, while preserving aspect ratio.
local function scale_to_fit(w1, h1, w2, h2)
	local scale = math.min(w1/w2, h1/h2)
	local w, h = w2*scale, h2*scale
	local x, y = (w1-w)/2, (h1-h)/2
	return x, y, w, h, scale
end

-- Called by main thread to display the last rendered frame.
function draw_framebuffer()
	local rt = gPhysicalFramebuffers[sRenderedFramebuffer]
	render.setRenderTargetTexture(rt)
	local sw, sh = render.getResolution()
	local x, y, w, h = scale_to_fit(sw, sh, SCREEN_WIDTH, SCREEN_HEIGHT)
	render.drawTexturedRectUV(x, y, w, h, 0, 0, SCREEN_WIDTH/1024, SCREEN_HEIGHT/1024)
	return rt
end

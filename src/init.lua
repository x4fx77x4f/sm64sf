function send_display_list(gfx_list)
	GFX:run(gfx_list)
end

local n_frames = 0
local target_time = 0
local frameSpeed = 0.03

local function produce_one_frame()
	local start_frame = timer.systime()
	
	--playerInputUpdate()
	GFX:start_frame()
	Game:main_loop_one_iteration()
	-- Audio TODO
	
	local finished_frame = timer.systime()
	--table.insert(totalFrameTimeBuffer, finished_frame - start_frame)
	
	n_frames = n_frames+1
end

local threshold = quotaMax()*0.5
local waitUntil = 0
local frameTime = 1/30
local fps = 0
local framesThisSecond = 0
local frameExpire = timer.systime()+1

local function scaleFit(w1, h1, w2, h2)
	local scale = math.min(w1/w2, h1/h2)
	local w, h = w2*scale, h2*scale
	local x, y = (w1-w)/2, (h1-h)/2
	return x, y, w, h
end

local function on_anim_frame()
	render.setBackgroundColor(Color(31, 31, 31))
	
	dbgStr, dbgStrLines = "", 0
		
	local now = timer.systime()
	if now >= frameExpire then
		fps = framesThisSecond
		framesThisSecond = 0
		frameExpire = now+1
	end
	if now >= waitUntil then
		render.selectRenderTarget('screen')
			produce_one_frame()
			waitUntil = now+frameTime
			framesThisSecond = framesThisSecond+1
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
	
	local lvlcmd = LevelCommands.sCurrentScript
	local _GR2 = {
		[1] = "running",
		[0] = "sleeping",
		[-1] = "sleeping before exit",
	}
	dbgprintf(
		"LvlCmds: %s is %s at #%d doing %s",
		_GR[lvlcmd.commands] or "[???]",
		_GR2[LevelCommands.sScriptStatus] or "[???]",
		lvlcmd.index or -1,
		lvlcmd.commands[lvlcmd.index] and _GR[lvlcmd.commands[lvlcmd.index].command] or "[???]"
	)
	-- [[
	dbgStr = string.gsub(dbgStr, "\n$", "")
	render.setFont('DebugFixed')
	render.setRGBA(0, 0, 0, 255)
	render.drawRectFast(0, 0, render.getTextSize(dbgStr))
	render.setRGBA(255, 255, 255, 255)
	render.drawText(0, 0, dbgStr)
	--]]
end

local function main_func()
	-- WebGL class and n64GfxProcessor class are initialized with their constructor when they are imported
	Game:attachInterfaceToGfxProcessor(send_display_list)
	
	render.createRenderTarget('screen')
	render.createRenderTarget('final')
	hook.add('render', 'on_anim_frame', on_anim_frame)
end

local gameStarted = false

function startGame()
	gameStarted = true
	cheats = {}
	
	main_func()
end

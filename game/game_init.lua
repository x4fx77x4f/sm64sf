-- The equivalent of this file in n64decomp/sm64 is 'src/game/game_init.c'
-- The equivalent of this file in sm64js is 'src/game/Game.js'

local max_quota = quotaMax()*0.25
local function yield(...)
	if math.max(quotaAverage(), quotaTotalAverage()) >= max_quota then
		coroutine.yield(...)
	end
end

gGlobalTimer = 0

-- This function...
-- ...would send the current master display list out to be rendered,
-- ...would tell the VI which color framebuffer to be displayed,
-- ...yields until the resume time is reached, locking the game to 30 FPS,
-- ...and would select which framebuffer will be rendered and displayed to next time.
local function display_and_vsync(resume_time)
	coroutine.yield(true)
	if resume_time then
		while timer.systime() < resume_time do
			coroutine.yield()
		end
	end
	gGlobalTimer = gGlobalTimer+1
end

-- Main game loop thread. Runs forever as long as the game continues.
function game_loop()
	local script, index = level_script_entry, 1
	while true do
		osdclear()
		local resume_time = timer.systime()+(1/30)
		
		script, index = level_script_execute(script, index)
		
		display_and_vsync(resume_time)
	end
end

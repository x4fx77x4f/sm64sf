-- The equivalent of this file in n64decomp/sm64 is 'levels/entry.c'
-- The equivalent of this file in sm64js is 'src/levels/main_entry/entry.js'

level_script_entry = {
	INIT_LEVEL(),
	SLEEP(--[[frames]] 2),
	BLACKOUT(--[[active]] false),
	SET_REG(--[[value]] 0),
	EXECUTE(--[[entry]] level_intro_splash_screen),
	JUMP(--[[target]] level_script_entry),
}

level_script_entry = {
	INIT_LEVEL(),
	SLEEP(2),
	BLACKOUT(false),
	SET_REG(0),
	EXECUTE(level_intro_splash_screen),
	JUMP(level_script_entry),
}

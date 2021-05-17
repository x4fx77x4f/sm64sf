level_script_entry = {[0]=
	INIT_LEVEL(),
	SLEEP(2),
	BLACKOUT(false),
	SET_REG(0),
	EXECUTE(level_intro_splash_screen),
	JUMP(level_script_entry),
}

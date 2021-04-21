function level_script_entry()
	INIT_LEVEL()
	SLEEP(2)
	BLACKOUT(false)
	SET_REG(0)
	EXECUTE(0x14, _introSegmentRomStart, _introSegmentRomEnd, level_intro_splash_screen)
	return level_script_entry()
end

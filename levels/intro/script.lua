-- a.k.a. level_intro_entry_1
level_intro_splash_screen = {[0]=
	INIT_LEVEL(),
	FIXED_LOAD(_goddardSegmentStart, _goddardSegmentRomStart, _goddardSegmentRomEnd),
	LOAD_RAW(0x13, _behaviorSegmentRomStart, _BehaviorSegmentRomEnd),
	LOAD_MIO0(0x07, _intro_segment_7SegmentRomStart, _intro_segment_7SegmentRomEnd),
	
	-- Load "Super Mario 64" logo
	ALLOC_LEVEL_POOL(),
	AREA(1, intro_geo_0002D0),
	END_AREA(),
	FREE_LEVEL_POOL(),
	
	-- Start animation
	LOAD_AREA(1),
	
	CALL(0, lvl_intro_update), -- Call lvl intro update with var 0 - play sound its a me mario
	SLEEP(75),
	TRANSITION(WARP_TRANSITION_FADE_INTO_COLOR, 16, 0x00, 0x00, 0x00),
	SLEEP(16),
	CMD2A(1), -- a.k.a. UNLOAD_AREA
	CLEAR_LEVEL(),
	SLEEP(2),
	EXIT_AND_EXECUTE(level_intro_mario_head_regular),
}

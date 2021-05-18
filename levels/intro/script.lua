-- Derived from n64decomp, not sm64js
--[=[
-- ugly hack
local vars = {}
local prefix = ''
for var in s:gmatch('const LevelScript ([%w_]+)%[%] = {') do
	prefix = prefix..var..' = {}\n'
end
s = prefix..'\n'..s

--s = s:gsub('const LevelScript ', '')
--s = s:gsub('%[%] = {', ' = {[0]=')
--s = s:gsub('};', '}')
s = s:gsub('const LevelScript ', 'table.assign(') -- or table.inherit, or table.Inherit
s = s:gsub('%[%] = {', ', {[0]=')
s = s:gsub('};', '})')

s = s:gsub('	', '\t')
s = s:gsub(',\n\n\t', ',\n\t\n\t')
s = s:gsub('TRUE', 'true')
s = s:gsub('FALSE', 'false')
s = s:gsub('/%*', '--[[')
s = s:gsub('%*/', ']]')
s = s:gsub('FIXED_LOAD', '--FIXED_LOAD')
s = s:gsub('LOAD_RAW', '--LOAD_RAW')
s = s:gsub('LOAD_MIO0', '--LOAD_MIO0')
s = s:gsub('LOAD_MIO0_TEXTURE', '--LOAD_MIO0_TEXTURE')
--]=]

level_intro_splash_screen = {}
level_intro_mario_head_regular = {}
level_intro_mario_head_dizzy = {}
level_intro_entry_4 = {}
script_intro_L1 = {}
script_intro_L2 = {}
script_intro_L3 = {}
script_intro_L4 = {}
script_intro_L5 = {}

table.assign(level_intro_splash_screen, {[0]=
	INIT_LEVEL(),
	--FIXED_LOAD(--[[loadAddr]] _goddardSegmentStart, --[[romStart]] _goddardSegmentRomStart, --[[romEnd]] _goddardSegmentRomEnd),
	--LOAD_RAW(--[[seg]] 0x13, _behaviorSegmentRomStart, _behaviorSegmentRomEnd),
	--LOAD_MIO0(--[[seg]] 0x07, _intro_segment_7SegmentRomStart, _intro_segment_7SegmentRomEnd),
	
	-- Load "Super Mario 64" logo
	ALLOC_LEVEL_POOL(),
	AREA(--[[index]] 1, intro_geo_0002D0),
	END_AREA(),
	FREE_LEVEL_POOL(),
	
	-- Start animation
	LOAD_AREA(--[[area]] 1),
	
	CALL(--[[arg]] 0, --[[func]] lvl_intro_update),
	SLEEP(--[[frames]] 75),
	TRANSITION(--[[transType]] WARP_TRANSITION_FADE_INTO_COLOR, --[[time]] 16, --[[color]] 0x00, 0x00, 0x00),
	SLEEP(--[[frames]] 16),
	CMD2A(--[[unk2]] 1),
	CLEAR_LEVEL(),
	SLEEP(--[[frames]] 2),
	EXIT_AND_EXECUTE(--[[seg]] 0x14, _introSegmentRomStart, _introSegmentRomEnd, level_intro_mario_head_regular),
})
--level_intro_entry_1 = level_intro_splash_screen

table.assign(level_intro_mario_head_regular, {[0]=
	INIT_LEVEL(),
	BLACKOUT(--[[active]] true),
	--FIXED_LOAD(--[[loadAddr]] _goddardSegmentStart, --[[romStart]] _goddardSegmentRomStart, --[[romEnd]] _goddardSegmentRomEnd),
	--LOAD_MARIO_HEAD(--[[loadHeadID]] REGULAR_FACE),
	--LOAD_RAW(--[[seg]] 0x13, _behaviorSegmentRomStart, _behaviorSegmentRomEnd),
	--LOAD_MIO0_TEXTURE(--[[seg]] 0x0A, _title_screen_bg_mio0SegmentRomStart, _title_screen_bg_mio0SegmentRomEnd),
	
	ALLOC_LEVEL_POOL(),
	AREA(--[[index]] 1, intro_geo_mario_head_regular),
	END_AREA(),
	FREE_LEVEL_POOL(),
	
	SLEEP(--[[frames]] 2),
	BLACKOUT(--[[active]] false),
	LOAD_AREA(--[[area]] 1),
	SET_MENU_MUSIC(--[[seq]] 0x0002),
	TRANSITION(--[[transType]] WARP_TRANSITION_FADE_FROM_STAR, --[[time]] 20, --[[color]] 0x00, 0x00, 0x00),
	SLEEP(--[[frames]] 20),
	CALL_LOOP(--[[arg]] 1, --[[func]] lvl_intro_update),
	JUMP_IF(--[[op]] OP_EQ, --[[arg]] 100, script_intro_L1),
	JUMP_IF(--[[op]] OP_EQ, --[[arg]] 101, script_intro_L2),
	JUMP(script_intro_L4),
})

--level_intro_entry_2 = level_intro_mario_head_regular

table.assign(level_intro_mario_head_dizzy, {[0]=
	INIT_LEVEL(),
	BLACKOUT(--[[active]] true),
	--FIXED_LOAD(--[[loadAddr]] _goddardSegmentStart, --[[romStart]] _goddardSegmentRomStart, --[[romEnd]] _goddardSegmentRomEnd),
	LOAD_MARIO_HEAD(--[[loadHeadID]] DIZZY_FACE),
	--LOAD_RAW(--[[seg]] 0x13, _behaviorSegmentRomStart, _behaviorSegmentRomEnd),
	--LOAD_MIO0_TEXTURE(--[[seg]] 0x0A, _title_screen_bg_mio0SegmentRomStart, _title_screen_bg_mio0SegmentRomEnd),
	ALLOC_LEVEL_POOL(),
	
	AREA(--[[index]] 1, intro_geo_mario_head_dizzy),
	END_AREA(),
	
	FREE_LEVEL_POOL(),
	SLEEP(--[[frames]] 2),
	BLACKOUT(--[[active]] false),
	LOAD_AREA(--[[area]] 1),
	SET_MENU_MUSIC(--[[seq]] 0x0082),
	TRANSITION(--[[transType]] WARP_TRANSITION_FADE_FROM_STAR, --[[time]] 20, --[[color]] 0x00, 0x00, 0x00),
	SLEEP(--[[frames]] 20),
	CALL_LOOP(--[[arg]] 2, --[[func]] lvl_intro_update),
	JUMP_IF(--[[op]] OP_EQ, --[[arg]] 100, script_intro_L1),
	JUMP_IF(--[[op]] OP_EQ, --[[arg]] 101, script_intro_L2),
	JUMP(script_intro_L4),
})
--level_intro_entry_3 = level_intro_mario_head_dizzy

table.assign(level_intro_entry_4, {[0]=
	INIT_LEVEL(),
	--LOAD_RAW(--[[seg]] 0x13, _behaviorSegmentRomStart, _behaviorSegmentRomEnd),
	--LOAD_MIO0_TEXTURE(--[[seg]] 0x0A, _title_screen_bg_mio0SegmentRomStart, _title_screen_bg_mio0SegmentRomEnd),
	--LOAD_MIO0(--[[seg]] 0x07, _debug_level_select_mio0SegmentRomStart, _debug_level_select_mio0SegmentRomEnd),
	--FIXED_LOAD(--[[loadAddr]] _goddardSegmentStart, --[[romStart]] _goddardSegmentRomStart, --[[romEnd]] _goddardSegmentRomEnd),
	ALLOC_LEVEL_POOL(),
	
	AREA(--[[index]] 1, intro_geo_000414),
	END_AREA(),
	
	FREE_LEVEL_POOL(),
	LOAD_AREA(--[[area]] 1),
	SET_MENU_MUSIC(--[[seq]] 0x0002),
	TRANSITION(--[[transType]] WARP_TRANSITION_FADE_FROM_COLOR, --[[time]] 16, --[[color]] 0xFF, 0xFF, 0xFF),
	SLEEP(--[[frames]] 16),
	CALL_LOOP(--[[arg]] 3, --[[func]] lvl_intro_update),
	JUMP_IF(--[[op]] OP_EQ, --[[arg]] -1, script_intro_L5),
	JUMP(script_intro_L3),
})

table.assign(script_intro_L1, {[0]=
	STOP_MUSIC(--[[fadeOutTime]] 0x00BE),
	TRANSITION(--[[transType]] WARP_TRANSITION_FADE_INTO_COLOR, --[[time]] 16, --[[color]] 0xFF, 0xFF, 0xFF),
	SLEEP(--[[frames]] 16),
	CLEAR_LEVEL(),
	SLEEP(--[[frames]] 2),
	SET_REG(--[[value]] 16),
	EXIT_AND_EXECUTE(--[[seg]] 0x14, _menuSegmentRomStart, _menuSegmentRomEnd, level_main_menu_entry_1),
})

table.assign(script_intro_L2, {[0]=
	TRANSITION(--[[transType]] WARP_TRANSITION_FADE_INTO_COLOR, --[[time]] 16, --[[color]] 0xFF, 0xFF, 0xFF),
	SLEEP(--[[frames]] 16),
	CLEAR_LEVEL(),
	SLEEP(--[[frames]] 2),
	EXIT_AND_EXECUTE(--[[seg]] 0x14, _introSegmentRomStart, _introSegmentRomEnd, level_intro_entry_4),
})

table.assign(script_intro_L3, {[0]=
	STOP_MUSIC(--[[fadeOutTime]] 0x00BE),
	TRANSITION(--[[transType]] WARP_TRANSITION_FADE_INTO_COLOR, --[[time]] 16, --[[color]] 0xFF, 0xFF, 0xFF),
	SLEEP(--[[frames]] 16),
	CLEAR_LEVEL(),
	SLEEP(--[[frames]] 2),
	EXIT_AND_EXECUTE(--[[seg]] 0x15, _scriptsSegmentRomStart, _scriptsSegmentRomEnd, level_main_scripts_entry),
})

table.assign(script_intro_L4, {[0]=
	TRANSITION(--[[transType]] WARP_TRANSITION_FADE_INTO_COLOR, --[[time]] 16, --[[color]] 0xFF, 0xFF, 0xFF),
	SLEEP(--[[frames]] 16),
	CLEAR_LEVEL(),
	SLEEP(--[[frames]] 2),
	EXIT_AND_EXECUTE(--[[seg]] 0x15, _scriptsSegmentRomStart, _scriptsSegmentRomEnd, level_main_scripts_entry),
})

table.assign(script_intro_L5, {[0]=
	STOP_MUSIC(--[[fadeOutTime]] 0x00BE),
	TRANSITION(--[[transType]] WARP_TRANSITION_FADE_INTO_COLOR, --[[time]] 16, --[[color]] 0x00, 0x00, 0x00),
	SLEEP(--[[frames]] 16),
	CLEAR_LEVEL(),
	SLEEP(--[[frames]] 2),
	EXIT_AND_EXECUTE(--[[seg]] 0x14, _introSegmentRomStart, _introSegmentRomEnd, level_intro_splash_screen),
})

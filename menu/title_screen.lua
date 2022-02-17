-- The equivalents of this file in n64decomp/sm64 are 'src/menu/title_screen.c' and 'src/menu/title_screen.h'
-- The equivalent of this file in sm64js is 'src/menu/level_select_menu.js'

LVL_INTRO_PLAY_ITS_A_ME_MARIO = 0
LVL_INTRO_REGULAR = 1
LVL_INTRO_GAME_OVER = 2
LVL_INTRO_LEVEL_SELECT = 3

-- This file implements how title screen functions, which includes playing demo sequences, introduction screens and a level select used for testing purposes.

local sDemoCountdown = 0
local sPlayMarioGreeting = not VERSION_JP
local sPlayMarioGameOver = not VERSION_JP

local PRESS_START_DEMO_TIMER = 800

-- Run the demo timer on the PRESS START screen after a number of frames.
-- This function returns the level ID from the first byte of a demo file.
-- It also returns the level ID from intro_regular (file select or level select menu)
local function run_level_id_or_demo(level)
	error("TODO: Implement run_level_id_or_demo")
end

-- Level select intro function, updates the selected stage count if an input was received. Signals the stage to be started or the level select to be exited if start or the quit combo is pressed.
local function intro_level_select()
	error("TODO: Implement intro_level_select")
end

-- Regular intro function that handles Mario's greeting voice and game start.
local function intro_regular()
	error("TODO: Implement intro_regular")
end

-- Game over intro function that handles Mario's game over voice and game start.
local function intro_game_over()
	error("TODO: Implement intro_game_over")
end

-- Plays the casual "It's-a me, Mario!" when the game starts.
local function intro_play_its_a_me_mario()
	-- TODO: Unstub intro_play_its_a_me_mario
	--set_background_music(0, SEQ_SOUND_PLAYER, 0)
	--play_sound(SOUND_MENU_COIN_ITS_A_ME_MARIO, gGlobalSoundSource)
	return 1
end

-- Update intro functions to handle title screen actions.
-- Returns a level ID after their criteria is met.
function lvl_intro_update(arg)
	if arg == LVL_INTRO_PLAY_ITS_A_ME_MARIO then
		return intro_play_its_a_me_mario()
	elseif arg == LVL_INTRO_REGULAR then
		return intro_regular()
	elseif arg == LVL_INTRO_GAME_OVER then
		return intro_game_over()
	elseif arg == LVL_INTRO_LEVEL_SELECT then
		return intro_level_select()
	end
end

function intro_play_its_a_me_mario()
	--set_background_music(0, SEQ_SOUND_PLAYER, 0)
	--play_sound(SOUND_MENU_COIN_ITS_A_ME_MARIO, gGlobalSoundSource)
	return 1
end

function lvl_intro_update(arg1, arg2)
	local retVar
	
	if arg1 == 0 then
		retVar = intro_play_its_a_me_mario()
	elseif arg1 == 1 then
		retVar = intro_default()
	elseif arg1 == 2 then
		retVar = intro_game_over()
	elseif arg1 == 3 then
		retVar = level_select_input_loop()
	end
	return retVar
end

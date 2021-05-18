local script_L1 = {[0]=
	EXIT_AND_EXECUTE(--[[seg]] 0x14, _introSegmentRomStart, _introSegmentRomEnd, level_intro_splash_screen),
}

local script_L2 = {[0]=
	EXIT_AND_EXECUTE(--[[seg]] 0x0E, _endingSegmentRomStart, _endingSegmentRomEnd, level_ending_entry),
}

local goto_mario_head_regular = {[0]=
	EXIT_AND_EXECUTE(--[[seg]] 0x14, _introSegmentRomStart, _introSegmentRomEnd, level_intro_mario_head_regular),
}

local goto_mario_head_dizzy = {[0]=
	EXIT_AND_EXECUTE(--[[seg]] 0x14, _introSegmentRomStart, _introSegmentRomEnd, level_intro_mario_head_dizzy),
}

local script_L5 = {[0]=
	EXIT_AND_EXECUTE(--[[seg]] 0x14, _introSegmentRomStart, _introSegmentRomEnd, level_intro_entry_4),
}

level_main_scripts_entry = {}
script_func_global_1 = {}
script_func_global_2 = {}
script_func_global_3 = {}
script_func_global_4 = {}
script_func_global_5 = {}
script_func_global_6 = {}
script_func_global_7 = {}
script_func_global_8 = {}
script_func_global_9 = {}
script_func_global_10 = {}
script_func_global_11 = {}
script_func_global_12 = {}
script_func_global_13 = {}
script_func_global_14 = {}
script_func_global_15 = {}
script_func_global_16 = {}
script_func_global_17 = {}
script_func_global_18 = {}

table.assign(level_main_scripts_entry, {[0]=
	LOAD_MIO0(--[[seg]] 0x04, _group0_mio0SegmentRomStart, _group0_mio0SegmentRomEnd),
	LOAD_MIO0(--[[seg]] 0x03, _common1_mio0SegmentRomStart, _common1_mio0SegmentRomEnd),
	LOAD_RAW(--[[seg]] 0x17, _group0_geoSegmentRomStart, _group0_geoSegmentRomEnd),
	LOAD_RAW(--[[seg]] 0x16, _common1_geoSegmentRomStart, _common1_geoSegmentRomEnd),
	LOAD_RAW(--[[seg]] 0x13, _behaviorSegmentRomStart, _behaviorSegmentRomEnd),
	ALLOC_LEVEL_POOL(),
	LOAD_MODEL_FROM_GEO(MODEL_MARIO, mario_geo),
	LOAD_MODEL_FROM_GEO(MODEL_SMOKE, smoke_geo),
	LOAD_MODEL_FROM_GEO(MODEL_SPARKLES, sparkles_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BUBBLE, bubble_geo),
	LOAD_MODEL_FROM_GEO(MODEL_SMALL_WATER_SPLASH, small_water_splash_geo),
	LOAD_MODEL_FROM_GEO(MODEL_IDLE_WATER_WAVE, idle_water_wave_geo),
	LOAD_MODEL_FROM_GEO(MODEL_WATER_SPLASH, water_splash_geo),
	LOAD_MODEL_FROM_GEO(MODEL_WAVE_TRAIL, wave_trail_geo),
	LOAD_MODEL_FROM_GEO(MODEL_YELLOW_COIN, yellow_coin_geo),
	LOAD_MODEL_FROM_GEO(MODEL_STAR, star_geo),
	LOAD_MODEL_FROM_GEO(MODEL_TRANSPARENT_STAR, transparent_star_geo),
	LOAD_MODEL_FROM_GEO(MODEL_WOODEN_SIGNPOST, wooden_signpost_geo),
	LOAD_MODEL_FROM_DL(MODEL_WHITE_PARTICLE_SMALL, white_particle_small_dl, LAYER_ALPHA),
	LOAD_MODEL_FROM_GEO(MODEL_RED_FLAME, red_flame_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BLUE_FLAME, blue_flame_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BURN_SMOKE, burn_smoke_geo),
	LOAD_MODEL_FROM_GEO(MODEL_LEAVES, leaves_geo),
	LOAD_MODEL_FROM_GEO(MODEL_PURPLE_MARBLE, purple_marble_geo),
	LOAD_MODEL_FROM_GEO(MODEL_FISH, fish_geo),
	LOAD_MODEL_FROM_GEO(MODEL_FISH_SHADOW, fish_shadow_geo),
	LOAD_MODEL_FROM_GEO(MODEL_SPARKLES_ANIMATION, sparkles_animation_geo),
	LOAD_MODEL_FROM_DL(MODEL_SAND_DUST, sand_seg3_dl_0302BCD0, LAYER_ALPHA),
	LOAD_MODEL_FROM_GEO(MODEL_BUTTERFLY, butterfly_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BURN_SMOKE_UNUSED, burn_smoke_geo),
	LOAD_MODEL_FROM_DL(MODEL_PEBBLE, pebble_seg3_dl_0301CB00, LAYER_ALPHA),
	LOAD_MODEL_FROM_GEO(MODEL_MIST, mist_geo),
	LOAD_MODEL_FROM_GEO(MODEL_WHITE_PUFF, white_puff_geo),
	LOAD_MODEL_FROM_DL(MODEL_WHITE_PARTICLE_DL, white_particle_dl, LAYER_ALPHA),
	LOAD_MODEL_FROM_GEO(MODEL_WHITE_PARTICLE, white_particle_geo),
	LOAD_MODEL_FROM_GEO(MODEL_YELLOW_COIN_NO_SHADOW, yellow_coin_no_shadow_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BLUE_COIN, blue_coin_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BLUE_COIN_NO_SHADOW, blue_coin_no_shadow_geo),
	LOAD_MODEL_FROM_GEO(MODEL_MARIOS_WINGED_METAL_CAP, marios_winged_metal_cap_geo),
	LOAD_MODEL_FROM_GEO(MODEL_MARIOS_METAL_CAP, marios_metal_cap_geo),
	LOAD_MODEL_FROM_GEO(MODEL_MARIOS_WING_CAP, marios_wing_cap_geo),
	LOAD_MODEL_FROM_GEO(MODEL_MARIOS_CAP, marios_cap_geo),
	LOAD_MODEL_FROM_GEO(MODEL_MARIOS_CAP, marios_cap_geo), -- repeated
	LOAD_MODEL_FROM_GEO(MODEL_BOWSER_KEY_CUTSCENE, bowser_key_cutscene_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BOWSER_KEY, bowser_key_geo),
	LOAD_MODEL_FROM_GEO(MODEL_RED_FLAME_SHADOW, red_flame_shadow_geo),
	LOAD_MODEL_FROM_GEO(MODEL_1UP, mushroom_1up_geo),
	LOAD_MODEL_FROM_GEO(MODEL_RED_COIN, red_coin_geo),
	LOAD_MODEL_FROM_GEO(MODEL_RED_COIN_NO_SHADOW, red_coin_no_shadow_geo),
	LOAD_MODEL_FROM_GEO(MODEL_NUMBER, number_geo),
	LOAD_MODEL_FROM_GEO(MODEL_EXPLOSION, explosion_geo),
	LOAD_MODEL_FROM_GEO(MODEL_DIRT_ANIMATION, dirt_animation_geo),
	LOAD_MODEL_FROM_GEO(MODEL_CARTOON_STAR, cartoon_star_geo),
	FREE_LEVEL_POOL(),
	CALL(--[[arg]] 0, --[[func]] lvl_init_from_save_file),
	--EXIT_AND_EXECUTE(0x14, false, false, level_intro_splash_screen), -- TEMPORARY
	--[=[
	LOOP_BEGIN(),
		EXECUTE(--[[seg]] 0x14, _menuSegmentRomStart, _menuSegmentRomEnd, level_main_menu_entry_2),
		JUMP_LINK(script_exec_level_table),
		SLEEP(--[[frames]] 1),
	LOOP_UNTIL(--[[op]] OP_LT, --[[arg]] 0),
	JUMP_IF(--[[op]] OP_EQ, --[[arg]] -1, script_L2),
	JUMP_IF(--[[op]] OP_EQ, --[[arg]] -2, goto_mario_head_regular),
	JUMP_IF(--[[op]] OP_EQ, --[[arg]] -3, goto_mario_head_dizzy),
	JUMP_IF(--[[op]] OP_EQ, --[[arg]] -8, script_L1),
	JUMP_IF(--[[op]] OP_EQ, --[[arg]] -9, script_L5),
	--]=]
})

table.assign(script_func_global_1, {[0]=
	LOAD_MODEL_FROM_GEO(MODEL_BLUE_COIN_SWITCH, blue_coin_switch_geo),
	LOAD_MODEL_FROM_GEO(MODEL_AMP, amp_geo),
	LOAD_MODEL_FROM_GEO(MODEL_PURPLE_SWITCH, purple_switch_geo),
	LOAD_MODEL_FROM_GEO(MODEL_CHECKERBOARD_PLATFORM, checkerboard_platform_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BREAKABLE_BOX, breakable_box_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BREAKABLE_BOX_SMALL, breakable_box_small_geo),
	LOAD_MODEL_FROM_GEO(MODEL_EXCLAMATION_BOX_OUTLINE, exclamation_box_outline_geo),
	LOAD_MODEL_FROM_GEO(MODEL_EXCLAMATION_BOX, exclamation_box_geo),
	LOAD_MODEL_FROM_GEO(MODEL_GOOMBA, goomba_geo),
	LOAD_MODEL_FROM_DL(MODEL_EXCLAMATION_POINT, exclamation_box_outline_seg8_dl_08025F08, LAYER_ALPHA),
	LOAD_MODEL_FROM_GEO(MODEL_KOOPA_SHELL, koopa_shell_geo),
	LOAD_MODEL_FROM_GEO(MODEL_METAL_BOX, metal_box_geo),
	LOAD_MODEL_FROM_DL(MODEL_METAL_BOX_DL, metal_box_dl, LAYER_OPAQUE),
	LOAD_MODEL_FROM_GEO(MODEL_BLACK_BOBOMB, black_bobomb_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BOBOMB_BUDDY, bobomb_buddy_geo),
	LOAD_MODEL_FROM_DL(MODEL_DL_CANNON_LID, cannon_lid_seg8_dl_080048E0, LAYER_OPAQUE),
	LOAD_MODEL_FROM_GEO(MODEL_BOWLING_BALL, bowling_ball_geo),
	LOAD_MODEL_FROM_GEO(MODEL_CANNON_BARREL, cannon_barrel_geo),
	LOAD_MODEL_FROM_GEO(MODEL_CANNON_BASE, cannon_base_geo),
	LOAD_MODEL_FROM_GEO(MODEL_HEART, heart_geo),
	LOAD_MODEL_FROM_GEO(MODEL_FLYGUY, flyguy_geo),
	LOAD_MODEL_FROM_GEO(MODEL_CHUCKYA, chuckya_geo),
	LOAD_MODEL_FROM_GEO(MODEL_TRAJECTORY_MARKER_BALL, bowling_ball_track_geo),
	RETURN(),
})

table.assign(script_func_global_2, {[0]=
	LOAD_MODEL_FROM_GEO(MODEL_BULLET_BILL, bullet_bill_geo),
	LOAD_MODEL_FROM_GEO(MODEL_YELLOW_SPHERE, yellow_sphere_geo),
	LOAD_MODEL_FROM_GEO(MODEL_HOOT, hoot_geo),
	LOAD_MODEL_FROM_GEO(MODEL_YOSHI_EGG, yoshi_egg_geo),
	LOAD_MODEL_FROM_GEO(MODEL_THWOMP, thwomp_geo),
	LOAD_MODEL_FROM_GEO(MODEL_HEAVE_HO, heave_ho_geo),
	RETURN(),
})

table.assign(script_func_global_3, {[0]=
	LOAD_MODEL_FROM_GEO(MODEL_BLARGG, blargg_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BULLY, bully_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BULLY_BOSS, bully_boss_geo),
	RETURN(),
})

table.assign(script_func_global_4, {[0]=
	LOAD_MODEL_FROM_GEO(MODEL_WATER_BOMB, water_bomb_geo),
	LOAD_MODEL_FROM_GEO(MODEL_WATER_BOMB_SHADOW, water_bomb_shadow_geo),
	LOAD_MODEL_FROM_GEO(MODEL_KING_BOBOMB, king_bobomb_geo),
	RETURN(),
})

table.assign(script_func_global_5, {[0]=
	LOAD_MODEL_FROM_GEO(MODEL_MANTA_RAY, manta_seg5_geo_05008D14),
	LOAD_MODEL_FROM_GEO(MODEL_UNAGI, unagi_geo),
	LOAD_MODEL_FROM_GEO(MODEL_SUSHI, sushi_geo),
	LOAD_MODEL_FROM_DL(MODEL_DL_WHIRLPOOL, whirlpool_seg5_dl_05013CB8, LAYER_TRANSPARENT),
	LOAD_MODEL_FROM_GEO(MODEL_CLAM_SHELL, clam_shell_geo),
	RETURN(),
})

table.assign(script_func_global_6, {[0]=
	LOAD_MODEL_FROM_GEO(MODEL_POKEY_HEAD, pokey_head_geo),
	LOAD_MODEL_FROM_GEO(MODEL_POKEY_BODY_PART, pokey_body_part_geo),
	LOAD_MODEL_FROM_GEO(MODEL_TWEESTER, tweester_geo),
	LOAD_MODEL_FROM_GEO(MODEL_KLEPTO, klepto_geo),
	LOAD_MODEL_FROM_GEO(MODEL_EYEROK_LEFT_HAND, eyerok_left_hand_geo),
	LOAD_MODEL_FROM_GEO(MODEL_EYEROK_RIGHT_HAND, eyerok_right_hand_geo),
	RETURN(),
})

table.assign(script_func_global_7, {[0]=
	LOAD_MODEL_FROM_DL(MODEL_DL_MONTY_MOLE_HOLE, monty_mole_hole_seg5_dl_05000840, LAYER_TRANSPARENT_DECAL),
	LOAD_MODEL_FROM_GEO(MODEL_MONTY_MOLE, monty_mole_geo),
	LOAD_MODEL_FROM_GEO(MODEL_UKIKI, ukiki_geo),
	LOAD_MODEL_FROM_GEO(MODEL_FWOOSH, fwoosh_geo),
	RETURN(),
})

table.assign(script_func_global_8, {[0]=
	LOAD_MODEL_FROM_GEO(MODEL_SPINDRIFT, spindrift_geo),
	LOAD_MODEL_FROM_GEO(MODEL_MR_BLIZZARD_HIDDEN, mr_blizzard_hidden_geo),
	LOAD_MODEL_FROM_GEO(MODEL_MR_BLIZZARD, mr_blizzard_geo),
	LOAD_MODEL_FROM_GEO(MODEL_PENGUIN, penguin_geo),
	RETURN(),
})

table.assign(script_func_global_9, {[0]=
	LOAD_MODEL_FROM_DL(MODEL_CAP_SWITCH_EXCLAMATION, cap_switch_exclamation_seg5_dl_05002E00, LAYER_ALPHA),
	LOAD_MODEL_FROM_GEO(MODEL_CAP_SWITCH, cap_switch_geo),
	LOAD_MODEL_FROM_DL(MODEL_CAP_SWITCH_BASE, cap_switch_base_seg5_dl_05003120, LAYER_OPAQUE),
	RETURN(),
})

table.assign(script_func_global_10, {[0]=
	LOAD_MODEL_FROM_GEO(MODEL_BOO, boo_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BETA_BOO_KEY, small_key_geo),
	LOAD_MODEL_FROM_GEO(MODEL_HAUNTED_CHAIR, haunted_chair_geo),
	LOAD_MODEL_FROM_GEO(MODEL_MAD_PIANO, mad_piano_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BOOKEND_PART, bookend_part_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BOOKEND, bookend_geo),
	LOAD_MODEL_FROM_GEO(MODEL_HAUNTED_CAGE, haunted_cage_geo),
	RETURN(),
})

table.assign(script_func_global_11, {[0]=
	LOAD_MODEL_FROM_GEO(MODEL_BIRDS, birds_geo),
	LOAD_MODEL_FROM_GEO(MODEL_PEACH, peach_geo),
	LOAD_MODEL_FROM_GEO(MODEL_YOSHI, yoshi_geo),
	RETURN(),
})

table.assign(script_func_global_12, {[0]=
	LOAD_MODEL_FROM_GEO(MODEL_ENEMY_LAKITU, enemy_lakitu_geo),
	LOAD_MODEL_FROM_GEO(MODEL_SPINY_BALL, spiny_ball_geo),
	LOAD_MODEL_FROM_GEO(MODEL_SPINY, spiny_geo),
	LOAD_MODEL_FROM_GEO(MODEL_WIGGLER_HEAD, wiggler_head_geo),
	LOAD_MODEL_FROM_GEO(MODEL_WIGGLER_BODY, wiggler_body_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BUBBA, bubba_geo),
	RETURN(),
})

table.assign(script_func_global_13, {[0]=
	LOAD_MODEL_FROM_GEO(MODEL_BOWSER, bowser_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BOWSER_BOMB_CHILD_OBJ, bowser_bomb_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BOWSER_BOMB, bowser_bomb_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BOWSER_SMOKE, bowser_impact_smoke_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BOWSER_FLAMES, bowser_flames_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BOWSER_WAVE, invisible_bowser_accessory_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BOWSER2, bowser2_geo),
	RETURN(),
})

table.assign(script_func_global_14, {[0]=
	LOAD_MODEL_FROM_GEO(MODEL_BUB, bub_geo),
	LOAD_MODEL_FROM_GEO(MODEL_TREASURE_CHEST_BASE, treasure_chest_base_geo),
	LOAD_MODEL_FROM_GEO(MODEL_TREASURE_CHEST_LID, treasure_chest_lid_geo),
	LOAD_MODEL_FROM_GEO(MODEL_CYAN_FISH, cyan_fish_geo),
	LOAD_MODEL_FROM_GEO(MODEL_WATER_RING, water_ring_geo),
	LOAD_MODEL_FROM_GEO(MODEL_WATER_MINE, water_mine_geo),
	LOAD_MODEL_FROM_GEO(MODEL_SEAWEED, seaweed_geo),
	LOAD_MODEL_FROM_GEO(MODEL_SKEETER, skeeter_geo),
	RETURN(),
})

table.assign(script_func_global_15, {[0]=
	LOAD_MODEL_FROM_GEO(MODEL_PIRANHA_PLANT, piranha_plant_geo),
	LOAD_MODEL_FROM_GEO(MODEL_WHOMP, whomp_geo),
	LOAD_MODEL_FROM_GEO(MODEL_KOOPA_WITH_SHELL, koopa_with_shell_geo),
	LOAD_MODEL_FROM_GEO(MODEL_KOOPA_WITHOUT_SHELL, koopa_without_shell_geo),
	LOAD_MODEL_FROM_GEO(MODEL_METALLIC_BALL, metallic_ball_geo),
	LOAD_MODEL_FROM_GEO(MODEL_CHAIN_CHOMP, chain_chomp_geo),
	LOAD_MODEL_FROM_GEO(MODEL_KOOPA_FLAG, koopa_flag_geo),
	LOAD_MODEL_FROM_GEO(MODEL_WOODEN_POST, wooden_post_geo),
	RETURN(),
})

table.assign(script_func_global_16, {[0]=
	LOAD_MODEL_FROM_GEO(MODEL_MIPS, mips_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BOO_CASTLE, boo_castle_geo),
	LOAD_MODEL_FROM_GEO(MODEL_LAKITU, lakitu_geo),
	LOAD_MODEL_FROM_GEO(MODEL_TOAD, toad_geo),
	RETURN(),
})

table.assign(script_func_global_17, {[0]=
	LOAD_MODEL_FROM_GEO(MODEL_CHILL_BULLY, chilly_chief_geo),
	LOAD_MODEL_FROM_GEO(MODEL_BIG_CHILL_BULLY, chilly_chief_big_geo),
	LOAD_MODEL_FROM_GEO(MODEL_MONEYBAG, moneybag_geo),
	RETURN(),
})

table.assign(script_func_global_18, {[0]=
	LOAD_MODEL_FROM_GEO(MODEL_SWOOP, swoop_geo),
	LOAD_MODEL_FROM_GEO(MODEL_SCUTTLEBUG, scuttlebug_geo),
	LOAD_MODEL_FROM_GEO(MODEL_MR_I_IRIS, mr_i_iris_geo),
	LOAD_MODEL_FROM_GEO(MODEL_MR_I, mr_i_geo),
	LOAD_MODEL_FROM_GEO(MODEL_DORRIE, dorrie_geo),
	LOAD_MODEL_FROM_GEO(MODEL_SNUFIT, snufit_geo),
	RETURN(),
})

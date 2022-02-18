-- The equivalent of this file in n64decomp/sm64 is 'levels/intro/geo.c'
-- The equivalent of this file in sm64js is 'src/levels/intro/geo.js'

-- 0x0E0002D0
intro_geo_0002D0 = {
	GEO_NODE_SCREEN_AREA(0, SCREEN_WIDTH/2, SCREEN_HEIGHT/2, SCREEN_WIDTH/2, SCREEN_HEIGHT/2),
	GEO_OPEN_NODE(),
		GEO_ZBUFFER(0),
		GEO_OPEN_NODE(),
			GEO_NODE_ORTHO(100),
			GEO_OPEN_NODE(),
				GEO_BACKGROUND_COLOR(0x0001),
			GEO_CLOSE_NODE(),
		GEO_CLOSE_NODE(),
		GEO_ZBUFFER(1),
		GEO_OPEN_NODE(),
			GEO_CAMERA_FRUSTUM(45, 128, 16384),
			GEO_OPEN_NODE(),
				GEO_CAMERA(0, 0, 0, 3200, 0, 0, 0, 0x00000000),
				GEO_OPEN_NODE(),
					GEO_ASM(0, geo_intro_super_mario_64_logo),
				GEO_CLOSE_NODE(),
			GEO_CLOSE_NODE(),
		GEO_CLOSE_NODE(),
		GEO_ZBUFFER(0),
		GEO_OPEN_NODE(),
			GEO_ASM(0, geo_intro_tm_copyright),
		GEO_CLOSE_NODE(),
	GEO_CLOSE_NODE(),
	GEO_END(),
}

-- 0x0E00035C
intro_geo_mario_head_regular = {
	GEO_NODE_SCREEN_AREA(0, SCREEN_WIDTH/2, SCREEN_HEIGHT/2, SCREEN_WIDTH/2, SCREEN_HEIGHT/2),
	GEO_OPEN_NODE(),
		GEO_ZBUFFER(0),
		GEO_OPEN_NODE(),
			GEO_NODE_ORTHO(100),
			GEO_OPEN_NODE(),
				GEO_ASM(0, geo_intro_regular_backdrop),
			GEO_CLOSE_NODE(),
		GEO_CLOSE_NODE(),
		GEO_ZBUFFER(1),
		GEO_OPEN_NODE(),
			GEO_CAMERA_FRUSTUM(45, 128, 16384),
			GEO_OPEN_NODE(),
				GEO_ASM(2, geo_draw_mario_head_goddard),
			GEO_CLOSE_NODE(),
		GEO_CLOSE_NODE(),
	GEO_CLOSE_NODE(),
	GEO_END(),
}
if VERSION_SH then
	table.insert(intro_geo_mario_head_regular, 16, GEO_CLOSE_NODE())
	table.insert(intro_geo_mario_head_regular, 16, GEO_ASM(0, geo_intro_rumble_pak_graphic))
	table.insert(intro_geo_mario_head_regular, 16, GEO_OPEN_NODE())
	table.insert(intro_geo_mario_head_regular, 16, GEO_ZBUFFER(0))
	table.insert(intro_geo_mario_head_regular, 7, GEO_ASM(0, geo_intro_face_easter_egg))
end

-- 0x0E0003B8
intro_geo_mario_head_dizzy = {
	GEO_NODE_SCREEN_AREA(0, SCREEN_WIDTH/2, SCREEN_HEIGHT/2, SCREEN_WIDTH/2, SCREEN_HEIGHT/2),
	GEO_OPEN_NODE(),
		GEO_ZBUFFER(0),
		GEO_OPEN_NODE(),
			GEO_NODE_ORTHO(100),
			GEO_OPEN_NODE(),
				GEO_ASM(0, geo_intro_gameover_backdrop),
			GEO_CLOSE_NODE(),
		GEO_CLOSE_NODE(),
		GEO_ZBUFFER(1),
		GEO_OPEN_NODE(),
			GEO_CAMERA_FRUSTUM(45, 128, 16384),
			GEO_OPEN_NODE(),
				GEO_ASM(3, geo_draw_mario_head_goddard),
			GEO_CLOSE_NODE(),
		GEO_CLOSE_NODE(),
	GEO_CLOSE_NODE(),
	GEO_END(),
}
if VERSION_SH then
	table.insert(intro_geo_mario_head_dizzy, 16, GEO_CLOSE_NODE())
	table.insert(intro_geo_mario_head_dizzy, 16, GEO_ASM(0, geo_intro_rumble_pak_graphic))
	table.insert(intro_geo_mario_head_dizzy, 16, GEO_OPEN_NODE())
	table.insert(intro_geo_mario_head_dizzy, 16, GEO_ZBUFFER(0))
	table.insert(intro_geo_mario_head_dizzy, 7, GEO_ASM(0, geo_intro_face_easter_egg))
end

-- 0x0E000414
intro_geo_000414 = {
	GEO_NODE_SCREEN_AREA(0, SCREEN_WIDTH/2, SCREEN_HEIGHT/2, SCREEN_WIDTH/2, SCREEN_HEIGHT/2),
	GEO_OPEN_NODE(),
		GEO_ZBUFFER(0),
		GEO_OPEN_NODE(),
			GEO_NODE_ORTHO(100),
			GEO_OPEN_NODE(),
				GEO_ASM(0, geo_intro_regular_backdrop),
			GEO_CLOSE_NODE(),
		GEO_CLOSE_NODE(),
		GEO_ZBUFFER(1),
		GEO_OPEN_NODE(),
			GEO_CAMERA_FRUSTUM(45, 128, 16384),
			GEO_OPEN_NODE(),
				GEO_CAMERA(0, 0, 0, 1200, 0, 0, 0, 0x00000000),
				GEO_OPEN_NODE(),
					GEO_TRANSLATE_NODE_WITH_DL(LAYER_OPAQUE, -230, 300, 0, debug_level_select_dl_07000858),
					GEO_TRANSLATE_NODE_WITH_DL(LAYER_OPAQUE, -120, 300, 0, debug_level_select_dl_07001100),
					GEO_TRANSLATE_NODE_WITH_DL(LAYER_OPAQUE,  -20, 300, 0, debug_level_select_dl_07001BA0),
					GEO_TRANSLATE_NODE_WITH_DL(LAYER_OPAQUE,  100, 300, 0, debug_level_select_dl_070025F0),
					GEO_TRANSLATE_NODE_WITH_DL(LAYER_OPAQUE,  250, 300, 0, debug_level_select_dl_07003258),
					GEO_TRANSLATE_NODE_WITH_DL(LAYER_OPAQUE, -310, 100, 0, debug_level_select_dl_07003DB8),
					GEO_TRANSLATE_NODE_WITH_DL(LAYER_OPAQUE,  -90, 100, 0, debug_level_select_dl_070048C8),
					GEO_TRANSLATE_NODE_WITH_DL(LAYER_OPAQUE,   60, 100, 0, debug_level_select_dl_07005558),
					GEO_TRANSLATE_NODE_WITH_DL(LAYER_OPAQUE,  180, 100, 0, debug_level_select_dl_070059F8),
					GEO_TRANSLATE_NODE_WITH_DL(LAYER_OPAQUE,  300, 100, 0, debug_level_select_dl_070063B0),
				GEO_CLOSE_NODE(),
			GEO_CLOSE_NODE(),
		GEO_CLOSE_NODE(),
	GEO_CLOSE_NODE(),
	GEO_END(),
}

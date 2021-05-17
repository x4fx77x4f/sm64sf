Game = {}

function Game:attachInterfaceToGfxProcessor(func)
	self.send_display_list = func
end

function Game:main_loop_init()
	-- point levelCommandAddr to the entry point into the level script data.
	LevelCommands:start_new_script(level_script_entry)
end

function Game:main_loop_one_iteration()
	-- Read data from controllers
	
	-- Audio game loop tick
	
	self:config_gfx_pool()
	
	-- processor controller inputs
	
	LevelCommands:level_script_execute()
	
	self:display_and_vsync()
end

function Game:end_master_display_list()
	Gbi.gSPEndDisplayList(self.gDisplayList)
end

function Game:config_gfx_pool()
	-- some stuff with gfx pools tasks, display lists, probably not necessary for JS
	self.gDisplayList = {}
end

function Game:rsp_init()
		Gbi.gSPClearGeometryMode(self.gDisplayList, SF_BOR(Gbi.G_SHADE, Gbi.G_SHADING_SMOOTH, Gbi.G_CULL_BOTH, Gbi.G_FOG, Gbi.G_LIGHTING, Gbi.G_TEXTURE_GEN, Gbi.G_TEXTURE_GEN_LINEAR, Gbi.G_LOD))
		Gbi.gSPSetGeometryMode(self.gDisplayList, SF_BOR(Gbi.G_SHADE, Gbi.G_SHADING_SMOOTH, Gbi.G_CULL_BACK, Gbi.G_LIGHTING))
		Gbi.gSPNumLights(self.gDisplayList, 1)
		Gbi.gSPTexture(self.gDisplayList, 0, 0, 0, Gbi.G_TX_RENDERTILE, Gbi.G_OFF)
end

function Game:rdp_init()
	Gbi.gDPSetCombineMode(self.gDisplayList, Gbi.G_CC_SHADE)
	Gbi.gDPSetTextureFilter(self.gDisplayList, Gbi.G_TF_BILERP)
	Gbi.gDPSetRenderMode(self.gDisplayList, Gbi.G_RM_OPA_SURF_SURF2)
	Gbi.gDPSetCycleType(self.gDisplayList, Gbi.G_CYC_FILL)
end

function Game:init_render_image()
	self:rsp_init()
	self:rdp_init()
end

function Game:display_and_vsync()
	self.send_display_list(self.gDisplayList)
	if self.D_8032C6A0_vsyncFunc then
		self.D_8032C6A0_vsyncFunc(self.D_8032C6A0_classObject)
		self.D_8032C6A0_vsyncFunc = nil
	end
	gGlobalTimer = gGlobalTimer+1
end

function Game:snapshot_location()
	return {
		yaw = LevelUpdate.gMarioState.faceAngle[2] / (0x10000 / 360),
		x = LevelUpdate.gMarioState.pos[1],
		y = LevelUpdate.gMarioState.pos[2],
		z = LevelUpdate.gMarioState.pos[3]
	}
end

function Game:initialize()
	Game:main_loop_init() -- thread5_game_loop_init
	gGlobalTimer = 0
end

-- The equivalents of this file in n64decomp/sm64 are 'src/levels/intro/leveldata.c'
-- The equivalent of this file in sm64js is 'src/levels/intro/leveldata.js'

local scripts = getScripts()
local root
for path in pairs(scripts) do
	local i = string.find(path, '/init.lua', nil, true)
	if i then
		root = string.sub(path, 1, i) -- e.g. "sm64sf2/"
		break
	end
end
assert(root, "could not find root")
local function just_figure_it_out_please(path)
	local temppath = 'sm64sf2_'..string.gsub(path, '/', '_')
	temppath = file.existsTemp(temppath) or file.writeTemp(temppath, scripts[root..path])
	printf("[just_figure_it_out_please] temppath: %q\n", temppath)
	return material.createFromImage('../'..temppath, '')
end

-- 0x0700B3A0 - 0x0700B420
function intro_seg7_dl_0700B3A0()
	render.setRGBA(127, 255, 127, 255)
	render.setFont('DermaDefault')
	render.drawText(SCREEN_WIDTH/2, SCREEN_HEIGHT/3*1, "intro_seg7_dl_0700B3A0", TEXT_ALIGN.CENTER, TEXT_ALIGN.CENTER)
end

-- 0x0700B4A0 - 0x0700B4A2
if VERSION_EU or VERSION_SH then
	--@includedata ./2_eu_copyright.rgba16.png
	intro_seg7_texture_0700B4A0 = 'levels/intro/2_eu_copyright.rgba16.png'
else
	--@includedata ./2_copyright.rgba16.png
	intro_seg7_texture_0700B4A0 = 'levels/intro/2_copyright.rgba16.png'
end
intro_seg7_texture_0700B4A0 = just_figure_it_out_please(intro_seg7_texture_0700B4A0)

-- 0x0700C4A0 - 0x0700D4A0
if VERSION_EU then
	--@includedata ./3_eu_tm.rgba16.png
	intro_seg7_texture_0700C4A0 = 'levels/intro/3_eu_tm.rgba16.png'
elseif VERSION_SH then
	--@includedata ./3_sh_tm.rgba16.png
	intro_seg7_texture_0700C4A0 = 'levels/intro/3_sh_tm.rgba16.png'
else
	--@includedata ./3_tm.rgba16.png
	intro_seg7_texture_0700C4A0 = 'levels/intro/3_tm.rgba16.png'
end
intro_seg7_texture_0700C4A0 = just_figure_it_out_please(intro_seg7_texture_0700C4A0)

-- 0x0700C6A0 - 0x0700C790
function intro_seg7_dl_0700C6A0()
	-- Look up intro_seg7_vertex_0700B420 in n64decomp/sm64 to see what the original data looked like.
	-- Seems like the positive Y is up, not down, in N64-land, so... new_y=screen_height-original_y-original_height
	
	render.setMaterial(intro_seg7_texture_0700B4A0)
	render.drawTexturedRect(96, SCREEN_HEIGHT-58, 128, 16)
	
	render.setMaterial(intro_seg7_texture_0700C4A0)
	render.drawTexturedRect(268, SCREEN_HEIGHT-196, 16, 16)
end

-- 0x0700C790
intro_seg7_table_0700C790 = {
	0.016000, 0.052000, 0.002500, 0.148300,
	0.189200, 0.035200, 0.471600, 0.525300,
	0.116600, 0.875800, 0.947000, 0.222100,
	1.250500, 1.341300, 0.327000, 1.485400,
	1.594900, 0.406500, 1.230500, 1.563700,
	0.464300, 0.913900, 1.351300, 0.520200,
	1.022900, 1.216100, 0.574400, 1.122300,
	1.097200, 0.627000, 1.028300, 0.955600,
	0.678100, 0.934800, 1.049400, 0.727700,
	0.994200, 1.005200, 0.775900, 1.070200,
	0.961500, 0.822900, 0.995600, 0.995000,
	0.868700, 0.991600, 1.005700, 0.913500,
	1.016500, 0.985200, 0.957200, 0.985200,
	1.007100, 1.000000, 0.999900, 0.999800,
	1.010600, 1.000000, 1.000000, 1.000000,
}

-- 0x0700C880
intro_seg7_table_0700C880 = {
	1.000000, 1.000000, 1.000000, 0.987300,
	0.987300, 0.987300, 0.951400, 0.951400,
	0.951400, 0.896000, 0.896000, 0.896000,
	0.824600, 0.824600, 0.824600, 0.740700,
	0.740700, 0.740700, 0.648000, 0.648000,
	0.648000, 0.549900, 0.549900, 0.549900,
	0.450100, 0.450100, 0.450100, 0.352000,
	0.352000, 0.352000, 0.259300, 0.259300,
	0.259300, 0.175400, 0.175400, 0.175400,
	0.104000, 0.104000, 0.104000, 0.048600,
	0.048600, 0.048600, 0.012800, 0.012800,
	0.012800, 0.000000, 0.000000, 0.000000,
}

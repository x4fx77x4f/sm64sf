-- 0x07007EA0 - 0x07007EA2
intro_seg7_texture_07007EA0 = material.createFromImage(
	'../'..SF_PATH_PATCH('/levels/intro/0.rgba16.png'),
	''
)

-- 0x070086A0 - 0x070086A2
intro_seg7_texture_070086A0 = material.createFromImage(
	'../'..SF_PATH_PATCH('/levels/intro/1.rgba16.png'),
	''
)

-- 0x07008EA0 - 0x07009E38
function intro_seg7_dl_07008EA0()
	render.setMaterial(intro_seg7_texture_070086A0)
	render.draw3DWireframeBox(Vector(), Angle(0, 0, -30), Vector(-1200, -300, -100), Vector(1200, 1000, 100))
end

-- 0x0700B3A0 - 0x0700B420
function intro_seg7_dl_0700B3A0()
	intro_seg7_dl_07008EA0()
	
	-- intro_seg7_dl_07009E38
	-- intro_seg7_dl_0700ADC0
end

-- 0x0700B420 - 0x0700B460
intro_seg7_vertex_0700B420 = {
	{{{    96,     42,     -1}, 0, {     0,    512}, {0xff, 0xff, 0xff, 0xff}}},
	{{{   224,     42,     -1}, 0, {  4096,    512}, {0xff, 0xff, 0xff, 0xff}}},
	{{{   224,     58,     -1}, 0, {  4096,      0}, {0xff, 0xff, 0xff, 0xff}}},
	{{{    96,     58,     -1}, 0, {     0,      0}, {0xff, 0xff, 0xff, 0xff}}},
}

-- 0x0700B460 - 0x0700B4A0
intro_seg7_vertex_0700B460 = {
	{{{   268,    180,     -1}, 0, {     0,    512}, {0xff, 0xff, 0xff, 0xff}}},
	{{{   284,    180,     -1}, 0, {   544,    512}, {0xff, 0xff, 0xff, 0xff}}},
	{{{   284,    196,     -1}, 0, {   544,      0}, {0xff, 0xff, 0xff, 0xff}}},
	{{{   268,    196,     -1}, 0, {     0,      0}, {0xff, 0xff, 0xff, 0xff}}},
}

-- 0x0700B4A0 - 0x0700B4A2
intro_seg7_texture_0700B4A0 = material.createFromImage(
	'../'..SF_PATH_PATCH('/levels/intro/2_copyright.rgba16.png'),
	''
)

-- 0x0700C4A0 - 0x0700D4A0
intro_seg7_texture_0700C4A0 = material.createFromImage(
	'../'..SF_PATH_PATCH('/levels/intro/3_tm.rgba16.png'),
	''
)

-- 0x0700C6A0 - 0x0700C790
function intro_seg7_dl_0700C6A0()
	render.setMaterial(intro_seg7_texture_0700B4A0)
	render.drawTexturedRect(gsSPVertex(intro_seg7_vertex_0700B420))
	
	render.setMaterial(intro_seg7_texture_0700C4A0)
	render.drawTexturedRect(gsSPVertex(intro_seg7_vertex_0700B460))
end

-- 0x0700C790
intro_seg7_table_0700C790 = {[0]=
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
intro_seg7_table_0700C880 = {[0]=
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

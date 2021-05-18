-- Derived from https://github.com/sm64js/sm64js/blob/a4b809b055119b1c716f25610a59543bc9e6b2a2/src/graphics/n64GfxProcessor.js

local precomp_shaders = {
	0x01200200,
	0x00000045,
	0x00000200,
	0x01200a00,
	0x00000a00,
	0x01a00045,
	0x00000551,
	0x01045045,
	0x05a00a00,
	0x01200045,
	0x05045045,
	0x01045a00,
	0x01a00a00,
	0x0000038d,
	0x01081081,
	0x0120038d,
	0x03200045,
	0x03200a00,
	0x01a00a6f,
	0x01141045,
	0x07a00a00,
	0x05200200,
	0x03200200
}

local MAX_BUFFERED = 256
local MAX_LIGHTS = 2
local MAX_VERTICES = 64

GFX = {}

function GFX:start_frame() end

function GFX:sp_reset()
	self.rsp.modelview_matrix_stack_size = 1
	self.rsp.current_num_lights = 2
end

function GFX:run_dl(commands)
	for i=1, #commands do
		local command = commands[i]
		local opcode = command.words.w0
		local args = command.words.w1
	end
end

function GFX:flush()
	if #self.buf_vbo > 0 then
		--WebGL.draw_triangles(self.buf_vbo, self.buf_vbo_num_tris)
		self.buf_vbo = {}
		self.buf_vbo_num_tris = 0
	end
end

function GFX:run(commands)
	self:sp_reset()
	
	render.enableDepth(true)
	render.clear(Color(0, 0, 0, 255), true)
	self:run_dl(commands)
	self:flush()
end

GFX.random = 0

-- buffer
GFX.buf_vbo = {}
GFX.buf_vbo_num_tris = 0

-- RSP
GFX.rsp = {
	modelview_matrix_stack = Array(11):fill(0):map(function()
		return Array(4):fill(0):map(function()
			return Array(4):fill(0):destroy()
		end):destroy()
	end):destroy(),
	modelview_matrix_stack_size = 0,
	MP_matrix = Array(4):fill(0):map(function()
		return Array(4):fill(0):destroy()
	end):destroy(),
	P_matrix = Array(4):fill(0):map(function()
		return Array(4):fill(0):destroy()
	end):destroy(),
	current_lights = Array(MAX_LIGHTS + 1):fill(0):map(function()
		return {
			col = {0, 0, 0},
			colc = {0, 0, 0},
			dir = {0, 0, 0},
		}
	end):destroy(),
	current_lights_coeffs = Array(MAX_LIGHTS):fill(0):map(function()
		return Array(3):fill(0.0):destroy()
	end):destroy(),
	current_lookat_coeffs = Array(2):fill(0):map(function()
		return Array(3):fill(0.0):destroy()
	end):destroy(),
	current_num_lights = 0,
	lights_changed = false,
	geometry_mode = 0,
	fog_mul = 0,
	fog_offset = 0,
	texture_scaling_factor = { s = 0, t = 0 },
	loaded_vertices = Array(MAX_VERTICES + 4):fill(0):map(function()
		return {
			x = 0.0, y = 0.0, z = 0.0, w = 0.0, u = 0.0, v = 0.0,
			color = { r = 0, g = 0, b = 0, a = 0 },
			clip_rej = 0
		}
	end):destroy()
}

-- RDP
GFX.rdp = {
	palette = {},
	texture_to_load = { textureData = nil, tile_number = 0, size = 0 },
	loaded_texture = {{ textureData = nil, size_bytes = 0 }, { textureData = nil, size_bytes = 0 }},
	texture_tile = { fmt = 0, siz = 0, cms = 0, cmt = 0, uls = 0, ult = 0, lrs = 0, lrt = 0, line_size_bytes = 0 },
	textures_changed = {false, false},
	other_mode_l = 0, 
	other_mode_h = {
		[12] = 0, --Gbi.G_MDSFT_TEXTFILT
		[20] = 0 --GBI.G_MDSFT_CYCLETYPE
	},
	combine_mode = 0,
	env_color = { r = 0, g = 0, b = 0, a = 0 },
	prim_color = { r = 0, g = 0, b = 0, a = 0 },
	fog_color = { r = 0, g = 0, b = 0, a = 0 },
	fill_color = { r = 0, g = 0, b = 0, a = 0 },
	viewport = { x = 0, y = 0, width = 0, height = 0 },
	scissor = { x = 0, y = 0, width = 0, height = 0 },
	viewport_or_scissor_changed = false,
	z_buf_address = nil,
	color_image_address = nil
}

GFX.color_combiner_pool = {}

GFX.rendering_state = {
	depth_test = false,
	depth_mask = false,
	decal_mode = false,
	alpha_blend = false,
	viewport = {x=0, y=0, width=0, height=0},
	scissor = {x=0, y=0, width=0, height=0},
	shader_program = nil,
	textures = {nil, nil}
}

GFX.gfx_texture_cache = {pool={}}

-- Starfall has no shader support...

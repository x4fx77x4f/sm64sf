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
	self.rsp.lights_changed = true
end

function GFX:matrix_mul(res, a, b)
	local temp = Mat4()
	for i=0, 3 do
		for j=0, 3 do
			temp[i][j] =
				a[i][0] * b[0][j] +
				a[i][1] * b[1][j] +
				a[i][2] * b[2][j] +
				a[i][3] * b[3][j]
		end
	end
	for i=0, 3 do
		for j=0, 3 do
			res[i][j] = temp[i][j]
		end
	end
end

function GFX:cloneMatrix4x4(src)
	local dst = Mtx()
	for i=0, 3 do
		for j=0, 3 do
			dst[i][j] = src[i][j]
		end
	end
	return dst
end

function GFX:sp_matrix(parameters, og_matrix)
	local matrix = self:cloneMatrix4x4(og_matrix)
	
	if bit.band(parameters, Gbi.G_MTX_PROJECTION) ~= 0 then
		if bit.band(parameters, Gbi.G_MTX_LOAD) ~= 0 then
			self.rsp.P_matrix = matrix
		else
			self:matrix_mul(self.rsp.P_matrix, matrix, self.rsp.P_matrix)
		end
	else -- G_MTX_MODELVIEW
		if bit.band(parameters, Gbi.G_MTX_PUSH) ~= 0 and self.rsp.modelview_matrix_stack_size < 11 then
			self.rsp.modelview_matrix_stack_size = self.rsp.modelview_matrix_stack_size+1
			self.rsp.modelview_matrix_stack[self.rsp.modelview_matrix_stack_size - 1] = self.cloneMatrix4x4(self.rsp.modelview_matrix_stack[self.rsp.modelview_matrix_stack_size - 2])
		end
		if bit.band(parameters, Gbi.G_MTX_LOAD) ~= 0 then
			self.rsp.modelview_matrix_stack[self.rsp.modelview_matrix_stack_size - 1] = matrix
		else
			self:matrix_mul(
				self.rsp.modelview_matrix_stack[self.rsp.modelview_matrix_stack_size - 1],
				matrix,
				self.rsp.modelview_matrix_stack[self.rsp.modelview_matrix_stack_size - 1]
			)
		end
		self.rsp.lights_changed = true
	end
	
	self:matrix_mul(
		self.rsp.MP_matrix,
		self.rsp.modelview_matrix_stack[self.rsp.modelview_matrix_stack_size - 1],
		self.rsp.P_matrix
	)
end

function GFX:sp_geometry_mode(clear, set)
	self.rsp.geometry_mode = bit.band(self.rsp.geometry_mode, bit.bnot(clear))
	self.rsp.geometry_mode = bit.bor(self.rsp.geometry_mode, set)
end

function GFX:scale_5_8(val)
	return math.floor((val * 0xFF) / 0x1F)
end

function GFX:scale_4_8(val)
	return math.floor(val * 0x11)
end

function GFX:dp_set_fill_color(color)
	self.rdp.fill_color.r = self:scale_5_8(bit.rshift(color, 11))
	self.rdp.fill_color.g = self:scale_5_8(bit.band(bit.rshift(color, 6), 0x1f))
	self.rdp.fill_color.b = self:scale_5_8(bit.band(bit.rshift(color, 1), 0x1f))
	self.rdp.fill_color.a = bit.band(color, 1) * 255
end

local color_comb_component = {
	[Gbi.G_CCMUX_TEXEL0] = Gbi.CC_TEXEL0,
	[Gbi.G_CCMUX_TEXEL1] = Gbi.CC_TEXEL1,
	[Gbi.G_CCMUX_PRIMITIVE] = Gbi.CC_PRIM,
	[Gbi.G_CCMUX_SHADE] = Gbi.CC_SHADE,
	[Gbi.G_CCMUX_ENVIRONMENT] = Gbi.CC_ENV,
	[Gbi.G_CCMUX_TEXEL0_ALPHA] = Gbi.CC_TEXEL0A,
	[Gbi.G_CCMUX_LOD_FRACTION] = Gbi.CC_LOD,
}
function GFX:color_comb(a, b, c, d)
	return SF_BOR(
		color_comb_component[a] or Gbi.CC_0,
		bit.lshift(color_comb_component[b] or Gbi.CC_0, 3),
		bit.lshift(color_comb_component[c] or Gbi.CC_0, 6),
		bit.lshift(color_comb_component[d] or Gbi.CC_0, 9)
	)
end

function GFX:dp_set_combine_mode(rgb, alpha)
	self.rdp.combine_mode = bit.bor(rgb, bit.lshift(alpha, 12))
end

function GFX:viewportsEqual(vp1, vp2)
	return vp1.x == vp2.x and vp1.y == vp2.y and vp1.width == vp2.width and vp1.height == vp2.height
end

function GFX:lookup_or_create_shader_program(shader_id)
	-- TODO: unstub lookup_or_create_shader_program
	return shader_id
end

function GFX:generate_cc(cc_id)
	local c = {
		{0, 0, 0, 0},
		{0, 0, 0, 0},
	}
	local shader_id = bit.lshift(bit.rshift(cc_id, 24), 24) -- TODO: figure out what this does (truncating?)
	local shader_input_mapping = {
		{0, 0, 0, 0},
		{0, 0, 0, 0},
	}
	
	for i=1, 4 do
		c[1][i] = bit.band(bit.rshift(cc_id, (i * 3 - 3)), 7)
		c[2][i] = bit.band(bit.rshift(cc_id, (12 + i * 3 - 3)), 7)
	end
	
	for i=1, 2 do
		if c[i][1] == c[i][2] or c[i][3] == Gbi.CC_0 then
			c[i][1] = 0
			c[i][2] = 0
			c[i][3] = 0
		end
		
		local input_number = {0, 0, 0, 0, 0, 0, 0, 0}
		local next_input_number = Gbi.SHADER_INPUT_1
		for j=1, 4 do
			local val = 0
			local switch = c[i][j]
			if switch == Gbi.CC_0 then
				-- do nothing
			elseif switch == Gbi.CC_TEXEL0 then
				val = Gbi.SHADER_TEXEL0
			elseif switch == Gbi.CC_TEXEL1 then
				val = Gbi.SHADER_TEXEL1
			elseif switch == Gbi.CC_TEXEL0A then
				val = Gbi.SHADER_TEXEL0A
			elseif
				switch == Gbi.CC_PRIM or
				switch == Gbi.CC_SHADE or
				switch == Gbi.CC_ENV or
				switch == Gbi.CC_LOD
			then
				if input_number[switch] == 0 then
					shader_input_mapping[i][next_input_number - 1] = switch
					input_number[switch] = next_input_number
					next_input_number = next_input_number+1
				end
				val = input_number[switch]
			end
			shader_id = bit.bor(shader_id, bit.lshift(val, (i * 12 - 12 + j * 3 - 3)))
		end
	end
	
	return {
		cc_id,
		shader_input_mapping,
		prg = self:lookup_or_create_shader_program(shader_id)
	}
end

function GFX:lookup_or_create_color_combiner(cc_id)
	if self.prev_combiner ~= nil and self.prev_combiner.cc_id == cc_id then
		return self.prev_combiner
	end
	
	local other_combiner = table.find(self.color_combiner_pool, function(x)
		return x.cc_id == cc_id
	end)
	if other_combiner then
		self.prev_combiner = other_combiner
		return other_combiner
	end
	self:flush()
	local new_combiner = self:generate_cc(cc_id)
	table.insert(self.color_combiner_pool, new_combiner)
	self.prev_combiner = new_combiner
	return new_combiner
end

function GFX:import_texture_ia16(tile)
	
end

function GFX:run_dl(commands)
	for i=1, #commands do
		local command = commands[i]
		local opcode = command.words.w0
		local args = command.words.w1
	end
end

function GFX.generate()
	mesh.writePosition()
end

function GFX:flush()
	if #self.buf_vbo > 0 then
		mesh.generate(nil, MATERIAL.TRIANGLES, self.buf_vbo_num_tris, self.generate)
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

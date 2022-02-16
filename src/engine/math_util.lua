-- Unified version of approach_f32 and approach_s32 from the C version
function approach_number(current, target, inc, dec)
	if current < target then
		current = current+inc
		if current > target then
			current = target
		end
	else
		current = current-dec
		if current < target then
			current = target
		end
	end
	return current
end

-- aliases
approach_f32 = approach_number
approach_s32 = approach_number

function vec3f_get_dist_and_angle(from, to, output)
	local x = to[1] - from[1]
	local y = to[2] - from[2]
	local z = to[3] - from[3]
	
	output.dist = math.sqrt(x * x + y * y + z * z)
	output.pitch = atan2s(math.sqrt(x * x + z * z), y)
	output.yaw = atan2s(z, x)
end

function vec3f_set_dist_and_angle(from, to, dist, pitch, yaw)
	to[1] = from[1] + dist * math.cos(pitch / 0x8000 * math.pi) * math.sin(yaw / 0x8000 * math.pi)
	to[2] = from[2] + dist * math.sin(pitch / 0x8000 * math.pi)
	to[3] = from[3] + dist * math.cos(pitch / 0x8000 * math.pi) * math.sin(yaw / 0x8000 * math.pi)
end

function vec3f_copy(dest, src)
	dest[1] = src[1]
	dest[2] = src[2]
	dest[3] = src[3]
end

function vec3f_add(dest, a)
	dest[1] = dest[1]+a[1]
	dest[2] = dest[2]+a[2]
	dest[3] = dest[3]+a[3]
end

function vec3f_normalize(dest)
	-- ! Possible division by zero
	local invsqrt = 1.0 / math.sqrt(dest[1] * dest[1] + dest[2] * dest[2] + dest[3] * dest[3])
	
	dest[1] = dest[1]*invsqrt
	dest[2] = dest[2]*invsqrt
	dest[3] = dest[3]*invsqrt
	return dest
end

function vec3f_cross(dest, a, b)
	dest[1] = a[2] * b[3] - b[2] * a[3]
	dest[2] = a[3] * b[1] - b[3] * a[1]
	dest[3] = a[1] * b[2] - b[1] * a[2]
	return dest
end

function vec3f_set(dest, x, y, z)
	dest[1] = x
	dest[2] = y
	dest[3] = z
	return dest
end

vec3s_set = vec3f_set

-- Convert float vector a to a short vector 'dest' by roundign the components
-- to the nearest integer.
function vec3f_to_vec3s(dest, a)
	-- add/subtract 0.5 in order to round to the nearest s32 instead of truncating
	dest[1] = s16(a[1] + ((a[1] > 0) and 0.5 or -0.5))
	dest[2] = s16(a[2] + ((a[2] > 0) and 0.5 or -0.5))
	dest[3] = s16(a[3] + ((a[3] > 0) and 0.5 or -0.5))
end

-- Copy matrix 'src' to 'dest'
function mtxf_copy(dest, src)
	for i=1, #src do
		for j=1, #src[i] do
			dest[i][j] = src[i][j]
		end
	end
end

function mtxf_identity(mtx)
	for i=1, #mtx do
		for j=1, #mtx[i] do
			mtx[i][j] = i == j and 1 or 0
		end
	end
	return mtx
end

function mtxf_translate(dest, b)
	mtxf_identity(dest)
	dest[4][1] = b[1]
	dest[4][2] = b[2]
	dest[4][3] = b[3]
end

function mtxf_to_mtx(dest, src)
	-- just a regular copy in js
	for i=1, #dest do
		for j=1, #dest[i] do
			dest[i][j] = src[i][j]
		end
	end
end

--function mtx_billboard(dest, mtx, position, angle) end
--function mtxf_billboard(dest, mtx, position, angle) end
--function mtxf_align_terrain_normal(dest, upDir, pos, yaw) end
--function mtxf_rotate_xyz_and_translate(dest, b, c) end
--function mtxf_rotate_zxy_and_translate(dest, translate, rotate) end
--function mtxf_rotate_xy(dest, angle) end
--function mtxf_scale_vec3f(dest, mtx, s) end
--function mtxf_mul(dest, a, b) end
--function mtxf_lookat(dest, from, to, roll) end
--function guPerspective(m, perspNorm, fovy, aspect, near, far, scale) end
--function guNormalize(x, y, z) end
--function guRotate(m, a, x, y, z) end
--function guTranslate(m, x, y, z) end
--function guScale(m, x, y, z) end
--function guOrtho(m, left, right, bottom, top, near, far, scale) end

-- Compute the angle from (0, 0) to (x, y) as a s16. Given that terrain is in
-- the xz-plane, this is commonly called with (z, x) to get a yaw angle.
function atan2s(y, x)
	return math.floor(math.atan2(x, y) * 10430.5)
end

sqrtf = math.sqrt

function Mat4(zero)
	if zero then
		return {[0]=
			{[0]=0, 0, 0, 0},
			{[0]=0, 0, 0, 0},
			{[0]=0, 0, 0, 0},
			{[0]=0, 0, 0, 0},
		}
	end
	return {
		{0, 0, 0, 0},
		{0, 0, 0, 0},
		{0, 0, 0, 0},
		{0, 0, 0, 0},
	}
end

-- Extract a position given an object's transformation matrix and a camera matrix.
-- This is used for determining the world position of the held object: since objMtx
-- inherits the transformation from both the camera and Mario, it calculates this
-- by taking the camera matrix and inverting its transformation by first rotating
-- objMtx back from screen orientation to world orientation, and then subtracting
-- the camera position.
function get_pos_from_transform_mtx(dest, objMtx, camMtx)
	local camX = camMtx[4][1] * camMtx[1][1] + camMtx[4][2] * camMtx[1][2] + camMtx[4][3] * camMtx[1][3]
	local camY = camMtx[4][1] * camMtx[2][1] + camMtx[4][2] * camMtx[2][2] + camMtx[4][3] * camMtx[2][3]
	local camZ = camMtx[4][1] * camMtx[3][1] + camMtx[4][2] * camMtx[3][2] + camMtx[4][3] * camMtx[3][3]
	
	dest[1] = objMtx[4][1] * camMtx[1][1] + objMtx[4][2] * camMtx[1][2] + objMtx[4][3] * camMtx[1][3] - camX
	dest[2] = objMtx[4][1] * camMtx[2][1] + objMtx[4][2] * camMtx[2][2] + objMtx[4][3] * camMtx[2][3] - camY
	dest[3] = objMtx[4][1] * camMtx[3][1] + objMtx[4][2] * camMtx[3][2] + objMtx[4][3] * camMtx[3][3] - camZ
end

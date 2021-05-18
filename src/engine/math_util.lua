-- Compute the angle from (0, 0) to (x, y) as a s16. Given that terrain is in
-- the xz-plane, this is commonly called with (z, x) to get a yaw angle.
function atan2s(y, x)
	return math.floor(math.atan2(x, y) * 10430.5)
end

sqrtf = math.sqrt

function Mat4()
	return {[0]=
		{[0]=0, 0, 0, 0},
		{[0]=0, 0, 0, 0},
		{[0]=0, 0, 0, 0},
		{[0]=0, 0, 0, 0},
	}
end

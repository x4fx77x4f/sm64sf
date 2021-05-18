function make_vertex(vtx, n, x, y, z, tx, ty, r, g, b, a)
	vtx[n] = {
		pos = Vector(x, y, z),
		flag = 0,
		tc = {tx, ty},
		color = Color(r, g, b, a)
	}
end

function round_float(num)
	if num >= 0.0 then
		return math.floor(num + 0.5)
	else
		return math.floor(num - 0.5)
	end
end

--[[
	This file contains miscellaneous geo_asm scripts.
	 *
	In particular, it builds:
	  - the light that shows the player where to look for Tower of the Wing Cap,
	  - the flying carpets seen in Rainbow Ride, and
	  - the end screen displaying Peach's delicious cake.
]]

function make_vertex(vtx, n, x, y, z, tx, ty, r, g, b, a)
	local v = vtx[n].v
	v.ob = Vector(x, y, z)
	v.flag = 0
	v.tc = {tx, ty}
	v.cn = Color(r, g, b, a)
end

function gsSPVertex(v, n, v0)
	-- assumes rectangular; will likely have to change later
	-- right is +x, up is +y (y is OPPOSITE starfallex)
	local bl = v[1][1]
	local br = v[2][1]
	local tr = v[3][1]
	local tl = v[4][1]
	local blx, brx, trx, tlx = bl[1][1], br[1][1], tr[1][1], tl[1][1]
	local bly, bry, try, tly = bl[1][2], br[1][2], tr[1][2], tl[1][2]
	local x = blx
	local y = 240-tly
	local w = brx-blx
	local h = tly-bly
	return x, y, w, h
end

-- Derived from https://github.com/sm64js/sm64js/blob/a4b809b055119b1c716f25610a59543bc9e6b2a2/src/graphics/n64GfxProcessor.js

local function rdp_run_dl(commands)
	for i=1, #commands do
		local command = commands[i]
	end
end

local function rdp_flush()
	
end

function rdp_run(commands)
	rdp_sp_reset()
	
	render.enableDepth(true)
	render.clear(Color(0, 0, 0, 255), true)
	rdp_run_dl(commands)
	rdp_flush()
end

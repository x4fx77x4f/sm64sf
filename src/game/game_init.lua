gGlobalTimer = 0 -- u32

frameBufferIndex = 0 -- u16

-- Clear the Z buffer.
clear_z_buffer = render.clearDepth

-- Sets up the final framebuffer image.
function display_frame_buffer()
	render.setRGBA(255, 255, 255, 255)
	render.selectRenderTarget('final')
		render.setRenderTargetTexture('screen')
		render.drawTexturedRect(0, 0, 1024, 1024)
	render.selectRenderTarget('screen')
end

-- Clears the framebuffer, allowing it to be overwritten.
function clear_frame_buffer(color)
	render.clear(Color(0, 0, 0, 255), false)
end

-- Starts rendering the scene.
function init_render_image()
	clear_z_buffer()
	display_frame_buffer()
end

function rendering_init()
	init_render_image()
	clear_frame_buffer(0)
	
	frameBufferIndex = frameBufferIndex+1
	gGlobalTimer = gGlobalTimer+1
end

-- Handles vsync.
function display_and_vsync()
	frameBufferIndex = frameBufferIndex+1
	if frameBufferIndex == 3 then
		frameBufferIndex = 0
	end
	gGlobalTimer = gGlobalTimer+1
end

function thread5_game_loop()
	local addr
	
	-- point addr to the entry point into the level script data.
	addr = level_script_entry
	
	rendering_init()
	
	while true do
		addr = level_script_execute(addr)
		
		display_and_vsync()
		
		coroutine.yield(true)
	end
end
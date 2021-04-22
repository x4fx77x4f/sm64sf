local D_8032CE74 = nil
local D_8032CE78 = nil
local gWarpTransFBSetColor = 0

function print_intro_text()
	if bit.band(gGlobalTimer, 0x1F) < 20 then
		if gControllerBits == 0 then
			print_text_centered(SCREEN_WIDTH / 2, 20, "NO CONTROLLER")
		else
			print_text_centered(60, 38, "PRESS")
			print_text_centered(60, 20, "START")
		end
	end
end

function clear_areas()
	
end

function render_game()
	if true then
		--gDPSetScissor()
		--render_hud()
		
		--gDPSetScissor()
		--render_text_labels()
		--do_cutscene_handler()
		--print_displaying_credits_entry()
		--gDPSetScissor()
		--gPauseScreenMode = render_menus_and_dialogs
	else
		--render_text_labels()
		if D_8032CE78 ~= nil then
			clear_viewport(D_8032CE78, gWarpTransFBSetColor)
		else
			clear_frame_buffer(gWarpTransFBSetColor)
		end
	end
	
	D_8032CE74 = nil
	D_8032CE78 = nil
end

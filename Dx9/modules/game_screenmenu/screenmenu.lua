--[[
  By Mock the bear.

  Only to help newcomers on otclient :3

  if you want use it, its free :D
]]


Window = nil
Button = nil

-- public functions
function init()
	Window = g_ui.displayUI('screenmenu.otui')
	Window:hide()
	Button = TopMenu.addLeftButton('Screen menu', tr('Screen menu'), 'icon.png', openWindow)
end


function terminate()
	Window:destroy()
	Button:destroy()

end
function hidz()
	Window:hide()
	Button:setOn(false)
end


function openWindow()
	if Button:isOn() then
		Button:setOn(false)
		Window:hide()
	else
		Button:setOn(true)
		Window:show()
	end
end


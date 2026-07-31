--[[
  All this content is only propriety of otPokemon and use in anothers companys or otclient projects aren't autoryzed by his creator (Mock - matheus.mtb7@gmail.com)
  Unauthorized use may cause an lawsuit.
  :3
]]
Windowe = nil
topButton = nil
function init()
	g_ui.importStyle('keys.otui')
	connect(g_game, {  onGameEnd = destroy })
	Windowe = g_ui.createWidget('Jaaj', rootWidget)


end
function showLockedWindow()
	Windowe = g_ui.createWidget('Jaaj', rootWidget)
end
function destroy()
	if (Windowe) then
		Windowe:destroy();
		Windowe = nil;
	end

end
function terminate()
	destroy()
end
function sendPass()
	local pass = Windowe:getChildById('pass'):getText()
	g_game.talk("/lock "..pass..'')
	terminate()
end

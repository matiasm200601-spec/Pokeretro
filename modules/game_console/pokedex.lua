--[[
  All this content is only propriety of otPokemon and use in anothers companys or otclient projects aren't autoryzed by his creator (Mock - matheus.mtb7@gmail.com)
  Unauthorized use may cause an lawsuit.
  :3
]]
pokedex_UI = nil
topButton = nil
ITEMS = {}
ITEMS_LABELS = {}
Idss = 500
maxskills = 8
function init()
  connect(g_game, {  onGameEnd = destroy })
  topButton = TopMenu.addRightGameToggleButton('pokedex', tr('pokedex'), 'pokedex.png', callpokedex)
  defocus()
end

data = {
	{'bulbasaur','planta'},
	{'batman','BIXO VINU'},
}
function callpokedex()

end
function Pii(id)


end
function defocus()
	if pokedex_UI then
		pokedex_UI:hide()
		pokedex_UI:show()
	end
end
function openDex(data)
	--pokedex_UI = g_ui.displayUI('pokedex.otui')

	return true
end
function terminate()
  disconnect(g_game, {  onGameEnd = destroy})
  destroy()
end


function destroy()
   topButton:destroy()
  if pokedex_UI then
	 pokedex_UI:destroy()
  end
end
function closeW()
	pokedex_UI:destroy()
	topButton:setOn(false)
end




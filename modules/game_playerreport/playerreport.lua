--[[
  All this content is only propriety of otPokemon and use in anothers companys or otclient projects aren't autoryzed by his creator (Mock - matheus.mtb7@gmail.com)
  Unauthorized use may cause an lawsuit.
  :3
]]
HOTKEY = 'Ctrl+R'
HOTKEY2 = 'Ctrl+U'
Window = nil
content = nil

function init()
  g_ui.importStyle('playerreport.otui')

  Window = g_ui.createWidget('ReportWindow', rootWidget)
  Window:hide()



  g_keyboard.bindKeyDown(HOTKEY, show)
  g_keyboard.bindKeyDown(HOTKEY2, function()
  g_game.getProtocolGame():sendExtendedOpcode(5, "77BAN")

  end)

  clear()
end

function terminate()
  g_keyboard.unbindKeyDown(HOTKEY)
  g_keyboard.unbindKeyDown(HOTKEY2)
  Window:destroy()
end




function doReport()
  local player = Window:getChildById('Player_name'):getText()
  local content = Window:getChildById('content'):getText()
  local desc = Window:getChildById('Rule_content'):getText()
  if #player <= 3 or #desc <= 3 or #desc <= 3  then
		displayInfoBox("For Your Information", 'Preencha todos os campos com pelo menos 3 letras.')
		return
  end
  if player:find('&') or desc:find('&') then
	 displayInfoBox("For Your Information", 'Não use \'&\' nos campos')
	 return
  end
  g_game.getProtocolGame():sendExtendedOpcode(5, "77RPT"..player..'&'..desc..'&'..content)
  Window:hide()
  modules.game_textmessage.displayGameMessage(tr('Player: '..player..' -> '..desc))
  modules.game_textmessage.displayGameMessage(tr('Coment: '..content))
  modules.game_textmessage.displayGameMessage(tr('Report Sent, you will receive a message wen some one see this.'))
end

function show(pl)
  if g_game.isOnline() then
	clear()
	Window:getChildById('Player_name'):setText(pl or '')

    Window:show()
    Window:raise()
    Window:focus()
  end
end
function clear()
  Window:getChildById('Player_name'):setText('')
  Window:getChildById('content'):setText('')
  Window:getChildById('Rule_content'):setText('')
end
function onChangePl(id,txt)
	if 25-#txt < 0 then
		Window:getChildById('Player_name'):setText(txt:sub(1,25))
		return
	end
end
function onChangeDesc(id,txt)
	if 30-#txt < 0 then
		Window:getChildById('Rule_content'):setText(txt:sub(1,30))
		return
	end
end
function onChangeTxt(id,txt)
	if 100-#txt < 0 then
		Window:getChildById('content'):setText(txt:sub(1,100))
		return
	end
	Window:getChildById('Left'):setText('Left ('..string.format("%.3d",100-#txt)..')')
end

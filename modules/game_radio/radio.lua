control = false
Radio_butt = false --its radio button not radio ass
function init()


  Radio_butt = TopMenu.addRightGameToggleButton('Radio_butt', 'Radio', 'play.png', toggle)
  Radio_butt:setOn(true)

end

function terminate()

  disconnect(g_game, { onGameEnd = clear})
	Radio_butt:destroy()
  control:destroy()
  control =nil

end

function refresh()
  clear()

end

function clear()
  Radio_butt:destroy()
end

function toggle()

end

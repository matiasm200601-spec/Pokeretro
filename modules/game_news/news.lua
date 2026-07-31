--[[
  All this content is only propriety of otPokemon and use in anothers companys or otclient projects aren't autoryzed by his creator (Mock - matheus.mtb7@gmail.com)
  Unauthorized use may cause an lawsuit.
  :3
]]

News = { }
HOST = 'otpokemon.com'
enterGame = nil
enterGameButton = nil
CON = false
SITE = ''
if not package.path:find('game_update') then
	package.path = package.path..";modules/game_update/lua/?.lua;modules/game_update/?.lua;"
	package.cpath = package.cpath..";modules/game_update/?.dll;modules/game_update/?.o"
end
local socket = require('socket')
-- public functions
function init()
	enterGame = g_ui.displayUI('news.otui')
	enterGame:setX(200)
	--enterGame:setY(200)
	enterGame:hide()
	enterGameButton = TopMenu.addLeftButton('News', tr('News') .. ' (Ctrl + H)', 'new.png', News.openWindow)
	g_keyboard.bindKeyDown('Ctrl+H', EnterGame.openWindow)
	SITE = ''
	connect(g_game, { onGameStart = bgn })
	CON = socket.connect(HOST,80)
	print(CON)
	if CON then
		CON:send("GET /index.php HTTP/1.0\r\n")
		CON:send("Host: " .. HOST .. "\r\n")
		CON:send("Accept: text/html\r\n")
		CON:send("\r\n")
		recv()
	end

end
function recv()
	if not CON then
		return
	end
	CON:settimeout(0.1)
	local dt,st,ef = CON:receive(-1)
	if dt or ef then
		print(dt,st,ef)
		SITE = SITE..(dt or '')..(ef or '')
	end
	if st == 'closed' then
		CON:close()
		print("CLOSED")
		CON = nil
		onRecv(-1, SITE)
		return
	end
	scheduleEvent(function() recv() end, MODEBINARY and 10 or 10)
end
function onError(protocol, message, code)
  perror('Could not send statistics: ' .. message)
end
function bgn()
	hidz()
end
function string.html(s)
	s = s or self
	local se = {
		{'&ccedil;','ç'},
		{'&aacute;','á'},
		{'&atilde;','ã'},
		{'&eacute;','é'},
		{'&oacute;','ó'},
		{'&iacute;','í'},
		{'&uacute;','ú'},
		{'&quot;','"'},
		{'&ecirc;','ê'},
	}
	for i=1,#se do
		s = s:gsub(se[i][1],se[i][2])
	end
	return s
end


function onRecv(protocol, message)
  if message:find('</table>') then
	for a,b in message:gmatch("<div class=\"newsTitle\">%s*(.-)%s*</div>.-<div class=\"newsBody\">%s*(.-)%s*</div>") do --
		--print(a:html(),'\n',(b:gsub('<.->',''):html())) --,,'\n--\n--\n'
		local label = g_ui.createWidget('LineList', enterGame:getChildById('newsC'))
		label:setColor("#00f5ff")
		label:setText(a:html())
		local label = g_ui.createWidget('LineList', enterGame:getChildById('newsC'))
		label:setColor("#ff0000")
		label:setText(" - ")
		for i in b:gsub('<.->',''):html():gmatch("(.-)\n") do
			local label = g_ui.createWidget('LineList', enterGame:getChildById('newsC'))
			label:setColor("#f5f5f5")
			label:setText(i)
		end
		local label = g_ui.createWidget('LineList', enterGame:getChildById('newsC'))
		label:setColor("#ff0000")
		label:setText("- - - - - - - - - - - - - - - - - - - - -")
		local label = g_ui.createWidget('HorizontalSeparator', enterGame:getChildById('newsC'))
		label:setColor("#ff0000")
	end
	enterGame:setX(0)
	enterGame:setY(36)
	if  g_game.isOnline() then

    else
		enterGameButton:setOn(true)
		enterGame:show()
	end
  end
end

function terminate()
	enterGame:destroy()
	enterGameButton:destroy()
	disconnect(g_game, { onGameStart = bgn })
end
function hidz()
	enterGame:hide()
	enterGameButton:setOn(false)
end


function News.openWindow()
	if enterGameButton:isOn() then
		enterGameButton:setOn(false)
		enterGame:hide()
	else
		enterGameButton:setOn(true)
		enterGame:show()
	end
end


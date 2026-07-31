--[[
  All this content is only propriety of otPokemon and use in anothers companys or otclient projects aren't autoryzed by his creator (Mock - matheus.mtb7@gmail.com)
  Unauthorized use may cause an lawsuit.
  :3
]]
Pokeskills = nil
topButton = nil
itemWidget = nil
ITEMS = {}
ITEMS_LABELS = {}
CD_LABEL = {}
--2870
Idss = 8112
maxskills = 14
globalData = false
WINDOWS= {}
PLAY = nil
PRESSED = false
local pos= {100,200}
function init()
	connect(g_game, {  onGameEnd = destroy,

	})
	globalData = false
	topButton = TopMenu.addRightGameToggleButton('pokebutton', tr('Chamar pokemon'), 'topicon.png', callp)
	defocus()
	itemWidget = g_ui.createWidget('UIItem')
	itemWidget:setVirtual(true)
	itemWidget:setVisible(false)
	itemWidget:setFocusable(false)
	WINDOWS = {}
	ITEMS = {}
	ITEMS_LABELS = {}
	CD_LABEL = {}
	g_keyboard.bindKeyDown('Ctrl+T', toggle)
	loopingSec()
end
function toggle(juj)
	PRESSED = not PRESSED

		for i,b in pairs(WINDOWS) do
			if b[1] and PRESSED then
				b[1]:setOpacity(0.8)
			elseif b[1] and not PRESSED then
				b[1]:setOpacity(0.9)
			end
		end
	if not PRESSED then
		drag(juj)
		modules.game_console.togglebutton(1)
	else
		modules.game_console.togglebutton()
	end

end
function callp()
	g_game.getProtocolGame():sendExtendedOpcode(5, "77GBP")

end
function Pii(id)
	for i,b in pairs(WINDOWS) do
		if b[2] == id then
			g_game.talk("m"..b[3])
			defocus()
			--globalData.sk[i][6] = g_clock.millis() +(globalData.sk[i][3]*1000)
			break
		end
	end

end

function setColdown(i,t)

	globalData.sk[i][6] = g_clock.millis() +(t*1000)
end

function loopingSec()
	if not globalData then
		return true
	end
	for i=1,maxskills do
		if globalData.s >= i then
			reorganizeCD( math.floor((globalData.sk[i][6]/1000)-(g_clock.millis()/1000)),i)
		end
	end

	scheduleEvent(loopingSec, 100)
end

function defocus()
	for i,b in pairs(WINDOWS) do
		if b[1]		then
			b[1]:hide()
			b[1]:show()

		end
	end
end

function drag(aa)
	local M = g_window.getMousePosition()
	if g_mouse.isPressed(2) or PRESSED then
		for i,b in pairs(WINDOWS) do
			if b[1] == aa then

				b[1]:setX(M.x-32+b[7])
				b[1]:setY(M.y-32+b[8])
			end
		end
	else
		for i,b in pairs(WINDOWS) do
			if b[1] then
				if aa == -1 then

					b[1]:setX(pos[1]+(b[3]-1)*50 -32+ b[7])
					b[1]:setY(pos[2] -32 + b[8])
					b[1]:setWidth(50)
					b[1]:setHeight(50)
				else

					b[1]:setX(M.x+(b[3]-1)*50 -32+ b[7])
					b[1]:setY(M.y -32 + b[8])
					b[1]:setWidth(50)
					b[1]:setHeight(50)
				end
			end
		end
	end
	return true
end


function reorganizeCD(cd,id,r)
	if WINDOWS[id] then
		if PLAY:getLevel() >= (tonumber(globalData.sk[id][2]) or 0) then
			if tonumber(cd)	<= 0 then
				WINDOWS[id][5]:setColor('#00ff00')
				WINDOWS[id][5]:setText("    M"..id) ---cd
			else
				local color = '#'

				color = color..string.format("%.2x",math.min((cd/(globalData.sk[id][3]+1))*255,255))..string.format("%.2x",255-math.floor(math.min((cd/(globalData.sk[id][3]+1))*350,255)))..'00'
				WINDOWS[id][5]:setColor(color)
				WINDOWS[id][5]:setText('    '..cd) ---cd
			end
		else
			WINDOWS[id][5]:setColor('#ff2211')
			WINDOWS[id][5]:setText("Level "..globalData.sk[id][2]) ---cd
		end
	end
	if r then
		globalData.sk[id][6] = g_clock.millis()+(cd*1000)
	end
end

function killWindows()


	for i,b in pairs(WINDOWS) do
		if b[1] and i == 1 then
			pos[1] = b[1]:getX()
			pos[2] = b[1]:getY()
			g_settings.set('pokewindowX', b[1]:getX())
			g_settings.set('pokewindowY', b[1]:getY())
		end
		if b[1]		then

			b[1]:destroy()
			WINDOWS[i][1] = nil
		end
	end
end
function callWindow(data)

	killWindows()
	PLAY = g_game.getLocalPlayer()
	data = data or {name='?',s = math.random(1,14)}
	topButton:setOn(true)
	for i=1,maxskills do
		if i <= data.s then
			if not WINDOWS[i] then
				WINDOWS[i]= {}
			end
			pos[1] = g_settings.get('pokewindowX')~='' and tonumber(g_settings.get('pokewindowX')) or pos[1]
			pos[2] = g_settings.get('pokewindowY')~='' and tonumber(g_settings.get('pokewindowY')) or pos[2]
			WINDOWS[i][1] = g_ui.displayUI('pokejanela.otui')

			WINDOWS[i][1]:setX(pos[1]+50*(i-1))
			WINDOWS[i][1]:setY(pos[2])
			print(pos[1],'-',pos[2])
			WINDOWS[i][1]:disableResize()
			WINDOWS[i][1]:setOpacity(0.9)

			WINDOWS[i][2] = WINDOWS[i][1]:getChildById('II')
			WINDOWS[i][2]:setItemId(data.sk[i][4])
			WINDOWS[i][3] = i
			WINDOWS[i][4] = WINDOWS[i][1]:getChildById('TT')
			WINDOWS[i][4]:setColor('#00f2ff')
			WINDOWS[i][4]:setText(tr(data.sk[i][1])) --name

			WINDOWS[i][5] = WINDOWS[i][1]:getChildById('UU')
			if tonumber(data.sk[i][5])	== 0 then
				WINDOWS[i][5]:setColor('#00ff00')
				WINDOWS[i][5]:setText("  Pronto") ---cd
				data.sk[i][6] = g_clock.millis()

			else
				WINDOWS[i][5]:setColor('#ff0000')
				WINDOWS[i][5]:setText('    '..data.sk[i][5]) ---cd
				data.sk[i][6] = g_clock.millis()+(data.sk[i][5]*1000)
			end
			WINDOWS[i][7] = 0
			WINDOWS[i][8] = 0
		end
	end
	globalData = data
	loopingSec()

	return true
end
function terminate()
  disconnect(g_game, { onGameEnd = destroy,})
  itemWidget:destroy()
  topButton:destroy()
  destroy()
end


function destroy()
	killWindows()
end
function hidez()
	for i,b in pairs(WINDOWS) do
		if b[1]		then
			b[1]:hide()
		end
	end

	topButton:setOn(false)
end
function closeW()
	for i,b in pairs(WINDOWS) do

		if b[1] and i == 1 then
			pos[1] = b[1]:getX()
			pos[2] = b[1]:getY()
			g_settings.set('pokewindowX', b[1]:getX())
			g_settings.set('pokewindowY', b[1]:getY())
		end
		if b[1]		then
			b[1]:destroy()
			WINDOWS[i][1] = nil
		end
	end
	topButton:setOn(false)

end

function selectMove()
  itemWidget:setItemId(3453)
  modules.game_interface.startUseWith(itemWidget:getItem())
end

function onChooseItemMouseRelease(self, mousePosition, mouseButton)
  local item = nil
  if mouseButton == MouseLeftButton then
    local clickedWidget = modules.game_interface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
    if clickedWidget then
      if clickedWidget:getClassName() == 'UIMap' then
        local tile = clickedWidget:getTile(mousePosition)
        if tile then
          local thing = tile:getTopMoveThing()
          if thing and thing:isItem() then
            item = thing
          end
        end
      elseif clickedWidget:getClassName() == 'UIItem' and not clickedWidget:isVirtual() then
        item = clickedWidget:getItem()
      end
    end
  end

  if item then
		--itemWidget:setItemId(hotKey.itemId)
		g_game.useInventoryItemWith(2003, clickedWidget:getItem())
        --modules.game_interface.startUseWith() --jaaj
  end

  g_mouse.restoreCursor()
  self:ungrabMouse()
  self:destroy()
end


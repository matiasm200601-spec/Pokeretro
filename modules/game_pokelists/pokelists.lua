--[[
  All this content is only propriety of otPokemon and use in anothers companys or otclient projects aren't autoryzed by his creator (Mock - matheus.mtb7@gmail.com)
  Unauthorized use may cause an lawsuit.
  :3
]]
Button = nil
Window = nil
BOLAZ = {}
function init()
  connect(g_game, { onGameEnd = gaemEnd, onGameStart = bgn  })
	BOLAZ = {}
  Button = TopMenu.addRightGameToggleButton('pokelists', tr('Lista de pokemons') .. ' pokelists', 'dot.png', toggle)
  Button:setOn(true)
  Window = g_ui.displayUI('pokelists.otui')
  Window:disableResize()
  --Window:setup()
  Window:setY(36)
  Window:setX(0)
  Window:hide()
  clear()
  Window:setOn(false)
 Window:setVisible(false)



end
--[[
]]
function bgn()
	Window:show()
end
function SL(id)
	IDZ = 0
	MAKZ = 0
	if not BOLAZ[id] then
		return
	end
	for i,b in pairs(BOLAZ) do
		MAKZ = MAKZ+1
		if tonumber(b[5]) == 1 then
			IDZ = i
		end
	end
	if id == 1 and IDZ ~= 0 then
		g_game.getProtocolGame():sendExtendedOpcode(5, "77GBP")
	else
		if id == MAKZ then
			id = 1
		end
		g_game.getProtocolGame():sendExtendedOpcode(5, "77MV"..BOLAZ[id][1]..':'..id)

	end
end

function Back()

end
function reFresh(content)
	clear()

	for i,b in pairs(content) do
		local color = '#'
		if tonumber(b[5]) == 1 then
			local C = b
			b = content[1]
			if b[3] >= b[4] then
				b[4] = b[3]
			end
			Window:getChildById('SL'..i):setItemId(b[2])
			Window:getChildById('LVL'..i):setText('['..(b[9] or 1)..']')
			if b[8] == 5 then
					Window:getChildById('SS'..i):setImageSource('skull_black.png')
			elseif b[8] == 4 then
					Window:getChildById('SS'..i):setImageSource('skull_red.png')
			else
				Window:getChildById('SS'..i):setImageSource('skull_yellow.png')
			end

			if b[6] == 1 then
				Window:getChildById('TT1'):setText("OUT.")
				Window:getChildById('TT1'):setColor('#005fff')
			elseif b[3] == 0 then
				Window:getChildById('TT'..i):setText("FNT.")
				Window:getChildById('TT'..i):setColor('#ff0000')
			else


				if b[3]-b[4] == -1 then
					Window:getChildById('TT'..i):setText(string.format("%.2d%%aa",100))
				else
					Window:getChildById('TT'..i):setText(string.format("%.2d%% a",(b[3]/b[4])*100))
				end


				if (b[3]/b[4])*100 >= 100 then
					Window:getChildById('TT'..i):setMarginLeft(0)
				end

				color = color..string.format("%.2x",255-math.ceil((b[3]/b[4])*255))..string.format("%.2x",math.ceil((b[3]/b[4])*255))..string.format("%.2x",0)
				Window:getChildById('TT'..i):setColor(color)
			end
			b = C
			if b[3] >= b[4] then
				b[4] = b[3]
			end
			color = '#'
			Window:getChildById('SL1'):setItemId(b[2])
			Window:getChildById('LVL1'):setText('['..(b[9] or 1)..']')
			if b[8] == 5 then
				Window:getChildById('SS1'):setImageSource('skull_black.png')
			elseif b[8] == 4 then
				Window:getChildById('SS1'):setImageSource('skull_red.png')
			else
				Window:getChildById('SS1'):setImageSource('skull_yellow.png')
			end
			if b[6] == 1 then
				Window:getChildById('TT1'):setText("OUT.")
				Window:getChildById('TT1'):setColor('#005fff')
			elseif b[3] == 0 then
				Window:getChildById('TT1'):setText("FNT.")
				Window:getChildById('TT1'):setColor('#ff0000')
			else

				if b[3]-b[4] == -1 then
					Window:getChildById('TT1'):setText(string.format("%.2d%%bb",100))
				else
					Window:getChildById('TT1'):setText(string.format("%.2d%% b",(b[3]/b[4])*100))
				end

				if (b[3]/b[4])*100 >= 100 then
					Window:getChildById('TT1'):setMarginLeft(0)
				end
				color = color..string.format("%.2x",255-math.ceil((b[3]/b[4])*255))..string.format("%.2x",math.ceil((b[3]/b[4])*255))..string.format("%.2x",0)
				Window:getChildById('TT1'):setColor(color)
			end
		else
			Window:getChildById('SL'..i):setItemId(b[2])
			Window:getChildById('LVL'..i):setText('['..(b[9] or 1)..']')
			if b[8] == 5 then
					Window:getChildById('SS'..i):setImageSource('skull_black.png')
				elseif b[8] == 4 then
					Window:getChildById('SS'..i):setImageSource('skull_red.png')
				else
					Window:getChildById('SS'..i):setImageSource('skull_yellow.png')
				end
			if b[3] >= b[4] then
				b[4] = b[3]
			end
			if b[3] == 0 then
				Window:getChildById('TT'..i):setText("FNT.")
				Window:getChildById('TT'..i):setColor('#ff0000')
			else

				if b[3]-b[4] == -1 then
					Window:getChildById('TT'..i):setText(string.format("%.2d%%aa",100))
				else
					Window:getChildById('TT'..i):setText(string.format("%.2d%% a",(b[3]/b[4])*100))
				end

				if (b[3]/b[4])*100 >= 100 then
					Window:getChildById('TT'..i):setMarginLeft(0)
				end
				color = color..string.format("%.2x",255-math.ceil((b[3]/b[4])*255))..string.format("%.2x",math.ceil((b[3]/b[4])*255))..string.format("%.2x",0)
				Window:getChildById('TT'..i):setColor(color)
			end
		end

	end
	BOLAZ = content
end
function clear()
	if not Window then
		init()
	end
	for i=1,6 do
		Window:getChildById('SL'..i):setItemId(7746)
		--Window:getChildById('TT'..i):setText(string.format("%.2d%%",0))
		Window:getChildById('TT'..i):setText('N/A')
		Window:getChildById('TT'..i):setMarginLeft(3)
		Window:getChildById('TT'..i):setColor('#ff5f00')
		Window:getChildById('SS'..i):setImageSource('skull_white.png')
	end
end
function toggle()
  if Button:isOn() then
    Window:close()
    Button:setOn(false)
  else
    Window:open()
    Button:setOn(true)
  end
end
function gaemEnd()
	Window:hide()
end
function terminate()
  disconnect(g_game, { onGameEnd = gaemEnd, onGameStart = bgn })

  Window:destroy()
  Window= nil
  Button:destroy()

end


function onclosew()
   Button:setOn(false)
end


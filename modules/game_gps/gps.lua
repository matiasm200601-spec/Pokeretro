--[[
  Original file was taken form otclient-win32-0.5.4 and edited to fit in client form Otpokemon.
  All this content is only propriety of otPokemon and use in anothers companys or otclient projects aren't autoryzed by his creator (Mock - matheus.mtb7@gmail.com)
  Unauthorized use may cause an lawsuit.
  :3
]]




local pause = false
GPSW=nil
GPSB=nil
GPSA=nil

TRUEGPS=nil
--a

function init()
	WAYPS= {}
	connect(g_game, { onGameStart = loadS,

	onGameEnd = clear,
        })
	pause	= true
	g_keyboard.bindKeyDown('G', function()
		local player = g_game.getLocalPlayer()
		if not player then return end
		local pos = player:getPosition()
		--displayMessage("HUEHUE",pos)
		--onAdd(1, 'jeej'..os.time(),pos)
	end)
	g_keyboard.bindKeyDown('Ctrl+W', toggle)
	GPSW = g_ui.loadUI('addgps.otui', modules.game_interface.getRightPanel())
	GPSB = TopMenu.addRightGameToggleButton('GpsButton', tr('Waypoint list') .. ' (Ctrl+W)', 'map.png', toggle)
    GPSB:setOn(true)
	GPSW:setup()
	scheduleEvent(refresh,100)
	if not TRUEGPS then
		loadS()
	end



end

function endtrack()
	WAYPS.player[1]:hide()
	WAYPS.player[1]:destroy()
	for _i,child in pairs(WAYPS.player[3]:recursiveGetChildren()) do
		if 1 then
		child:hide()
		removeEvent(child.hideEvent)
		end
	end
	if WAYPS.player[3] then
		WAYPS.player[3]:destroy()
	end
	WAYPS.player=nil

end
function track(pos,name)
	if not WAYPS.player then
		displayMessage(name,pos,'player')
	else
		WAYPS.player[2] = pos
	end
end


function doAdd2()
	if GPSA then

		local name = GPSA:getChildById('name'):getText()
		local player = g_game.getLocalPlayer()
		if not player then return end
		local pos = player:getPosition()
		g_game.getProtocolGame():sendExtendedOpcode(5, "77FIND:"..name)


	end
	finishAdd()
end


function loadS()

	TRUEGPS= g_settings.getNode('WaypointStuff')


	if TRUEGPS == nil then
		TRUEGPS ={}

	else
		for i,b in pairs(TRUEGPS) do
			print(i,b)
			if b.name then
				onAdd(i, b.name,b.pos,b.active)
			end
		end
	end
end

function onMiniWindowClose()
	 GPSB:setOn(false)
end
function toggle()
  if GPSB:isOn() then
    GPSW:close()
    GPSB:setOn(false)
  else
    GPSW:open()
    GPSB:setOn(true)
  end
end





function terminate()
	clear()
	pause = false
	WAYPS= {}

    disconnect(g_game, 'onGameEnd',clear)
	  g_keyboard.unbindKeyDown('Ctrl+P')
	  disconnect(g_game, { onGameEnd = clear,
	  onGameStart = loadS,
			})
		GPSB:destroy()
    GPSW:close()

end


function onPress(widget, mousePos, mouseButton)
  if mouseButton ~= MouseRightButton then return end



  local menu = g_ui.createWidget('PopupMenu')
  menu:addOption(tr('Add new waypoint'), function() createAddWindow() end)
  if widget.jeej then
	menu:addOption(tr('Remove this waypoint'), function()
		if widget.en then
			displayMessage(widget:getText(),widget.pos,widget.ind)
		end
		TRUEGPS[widget.ind] = nil
		widget:destroy()
	end)
  end
  menu:display(mousePos)

  return true
end


function createAddWindow()
	local player = g_game.getLocalPlayer()
	if not player then return end
	if not GPSA then
	local pos = player:getPosition()
		GPSA = g_ui.displayUI('moregps.otui')
		local lab = GPSA:getChildById('labela')
		lab:setText("Position: "..pos.x..' ,'..pos.y..', '..pos.z..'.\nSet a name:')
		GPSA.pos = pos
	end
end


function doAdd()
	if GPSA then
		local pos= GPSA.pos
		onAdd(os.time(), GPSA:getChildById('name'):getText(),pos,true)
		TRUEGPS[os.time()] = {name=GPSA:getChildById('name'):getText(),pos=pos,active=true}
	end
	finishAdd()
end

function finishAdd()
  GPSA:destroy()
  GPSA = nil
end



function onAdd(id, name,pos,en)
  local Wlist = GPSW:getChildById('contentsPanel')
  local label = g_ui.createWidget('VipListLabel')
  label.onMousePress = onPress
  label:setId('gps' .. id)
  label:setText(name)
  label.pos = pos
  label.ind = id
  label.jeej = true
  label.en = en or false
	if label.en then
		 label:setColor('#ee33ff')
		 displayMessage(label:getText(),pos,id)
	else
		 label:setColor('#11ff22')
	end



  label:setPhantom(false)
  connect(label, { onDoubleClick = function (a,b,c)  displayMessage(a:getText(),a.pos,a.ind)
	a.en = not a.en
	if a.en then
		 a:setColor('#ee33ff')
	else
		 a:setColor('#11ff22')
	end
	TRUEGPS[a.ind].active = a.en
    return true end } )

  Wlist:insertChild(1, label)
end


PLAYED = {}
local angle = 45
function displayMessage(text,p2,ind)



  if not g_game.isOnline() then return end
    local player = g_game.getLocalPlayer()
    if not player then return end
  local pos = player:getPosition()


  	for i,b in pairs(WAYPS) do
		if i == ind then
			for _i,child in pairs(b[3]:recursiveGetChildren()) do
				child:destroy()
				removeEvent(child.hideEvent)
			end
			b[3]:destroy()
			b[1]:destroy()
			WAYPS[i] = nil
			return
		end
	end

	if pos then
  angle = math.deg(math.atan2((pos.x-p2.x),(pos.y-p2.y) ))
  end
  angle = (angle or 90)-90
  local panel =  g_ui.loadUI('gps.otui', modules.game_interface.getRootPanel())
  local label = panel:getChildById('centerTextMessagePanel')
  local te = panel:getChildById('text')
  if pos then
  te:setText((tostring(text) or '????')..' ('..(math.floor(math.sqrt(((pos.x-p2.x)^2)+((pos.y-p2.y)^2))))..')')
  end
  label:setVisible(true)
  te.text = text
  panel.text = text

   --[[if angle >= 0 and angle <= 45 or angle >= 315 and angle <= 360 then
	label:setImageSource('dotr.png')
   elseif angle >= 45 and angle <=135 then
	label:setImageSource('dots.png')
   elseif angle >= 135 and angle <= 225 then
	label:setImageSource('dotl.png')
   elseif angle >= 225 and angle  <= 315 then
	label:setImageSource('dot.png')
   end]]
   label:setImageSource('dat.png')
   --angle = angle + 10

   label:setMarginTop(100*math.sin(math.rad(angle)) -0)
   label:setMarginRight(100*math.cos(math.rad(angle)) +40)


    removeEvent(label.hideEvent)
    label.hideEvent = scheduleEvent(function()
		label:setVisible(false)

		end, 4000)
	removeEvent(label.hideEvent)
	WAYPS[ind] = {label,p2,panel,tostring(text),ind}


end
WAYPS = {}
function refresh()
	local player = g_game.getLocalPlayer()

	if player then
		local pos = player:getPosition()
		for i,b in pairs(WAYPS) do
			local angle = math.deg(math.atan2((pos.x-b[2].x),(pos.y-b[2].y) ))
			angle = angle-90
			local range =math.floor(math.sqrt(((pos.x-b[2].x)^2)+((pos.y-b[2].y)^2)))
			if range> 0 then
				b[1]:setMarginTop(100*math.sin(math.rad(angle)) -0)
				b[1]:setMarginRight(100*math.cos(math.rad(angle)) +30)
			else
				b[1]:setMarginTop()
				b[1]:setMarginRight(20)
			end
			local te = b[3]:getChildById('text')
			te:setText((tostring(b[4]) or '????')..' ('..(range)..')')
		end
	else
		--return
	end
	if pause then
	scheduleEvent(refresh,100)
	end
end

function clear()
	TRUEGPS.player = nil
	g_settings.setNode('WaypointStuff', TRUEGPS)
	local listt = GPSW:getChildById('contentsPanel')
   listt:destroyChildren()
	for i,b in pairs(WAYPS) do
		b[1]:hide()
		b[1]:destroy()
    	for _i,child in pairs(b[3]:recursiveGetChildren()) do
			if 1 then
			child:hide()
			removeEvent(child.hideEvent)
			end
		end
		if b[3] then
			b[3]:destroy()
		end

	end

	WAYPS= {}

end

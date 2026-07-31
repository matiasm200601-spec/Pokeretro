Extended = {}

-- private variables
local callbacks = {}
CALL = false
-- hooked functions
WW = nil
function copyToClip(wid)
	if wid == 'com' then
		g_window.setClipboardText(WW.cont)

	else
		g_window.setClipboardText(WW:getChildById(wid):getText())
	end
end
function Kill()
	WW:destroy()
	WW = nil
	g_game.getProtocolGame():sendExtendedOpcode(5, "77BAN")
end

function Solve()
	g_game.getProtocolGame():sendExtendedOpcode(5, "77SLV"..WW.time..':'..WW.sender)
	WW:destroy()
	WW = nil
	g_game.getProtocolGame():sendExtendedOpcode(5, "77BAN")
end
function openRepWindow(reported,des,cont,time,sender)
	if WW then
			WW:close()
			WW = nil
	end
	WW = g_ui.displayUI('report.otui')
	WW:getChildById('sender'):setText(sender)
	for i=1,#des do
		if i%25 == 0 then
			des = des:sub(1,i-1)..'-\n'..des:sub(i,-1)
		end
	end
	WW:getChildById('desc'):setText(des)
	WW:getChildById('reported'):setText(reported)
	WW:getChildById('ttime'):setText(os.date("%d/%m/%y %H:%M:%S",time))
	WW.time = time
	WW.sender = sender
	WW.cont = cont
	--WW:getChildById('com'):setText(cont)

	for i in cont:gmatch("(.-)\n") do
		local label = g_ui.createWidget('LineList', WW:getChildById('com'))
		label:setColor("#f5f5f5")
		label:setText(i)
	end

end


local function onExtendedOpcode(protocol, opcode, buffer)

  if opcode == 4 then
	if buffer == 'Hi?' then
		g_game.getProtocolGame():sendExtendedOpcode(4, os.time())
	end
  end
  if opcode == 5 then
		CALL = true
		local text = buffer

		if text:match("CP:(.-)!M:(.+)") then
			local name,skill = text:match("CP:(.-)!M:(.+)")
			local skills = {}
			local ss = 0
			for m,name,level,cd,id,ex in skill:gmatch("|m(%d+)@(.-)@(%d+)@(%d+)@(%d+)@(%d+)|") do
				ss = ss+1
				skills[tonumber(m)] = {name,level,cd,id,ex}
			end
			modules.game_pokewindow.callWindow({name=name,s=ss,sk=skills})
		elseif text:match("%%system%%PLI(.+)") then
			local pli = text:match("%%system%%PLI(.+)")
			for i,b in pli:gmatch('(.-):(.-);') do
				if i == 'ch' then
					local now,max = b:match('(%d+),(%d+)')
					modules.game_skills.setCaughts(tonumber(now),tonumber(max))
				end
			end
		elseif text:match("%%system%%locked;(.+)") then
			modules.game_lock.showLockedWindow(text:match("%%system%%%system%locked;(.+)"))
		elseif text:match("%%system%%PHU(%d+),(%d+)") then
			local now,max = text:match("%%system%%PHU(%d+),(%d+)")
			modules.game_healthinfo.updatePoke(tonumber(now),tonumber(max))
		elseif text:match("%%system%%SHD(%d+)") then
			local tt = text:match("%%system%%SHD(%d+)")
			modules.game_shaders.setShader(tonumber(tt))
		elseif text:match("%%system%%RPRN(.-)&(.-)&(.-)&(%d+)&(.+)") then
			local reported,des,cont,time,sender = text:match("%%system%%RPRN(.-)&(.-)&(.-)&(%d+)&(.+)")
			openRepWindow(reported,des,cont,tonumber(time),sender)
			--modules.game_shaders.setShader(tonumber(tt))
		elseif text == "%system%KP" then

			modules.game_pokewindow.closeW()
			modules.game_console.setPokeInfo(' - ','-',0,0,1,0,7746,0,1,1)
		elseif text:match("%%system%%ENDTRQCK") then
			modules.game_gps.endtrack()
		elseif text:match("%%system%%DDX(.+)") then
			modules.game_console.Parse_me(text:match("%%system%%DDX(.+)"))
		elseif text:match("%%system%%TRQCK(.-):(%d+),(%d+),(%d+)") then
			local name, x,y,z =text:match("%%system%%TRQCK(.-):(%d+),(%d+),(%d+)")
			modules.game_gps.track({x=tonumber(x),y=tonumber(y),z=tonumber(z)},name)
		elseif text:match("%%system%%FDX") then
			modules.game_console.doOpenDex()
		elseif text:match("%%system%%SND(.+)") then
			local snd = text:match("%%system%%SND(.+)")
			if g_settings.getBoolean('sound_ona') == false then
				if not PLAYED[snd] then

					PLAYED[snd] = true
				end
				--print(g_sounds.playMusic('ogg/'..snd..'.ogg', 3))
			end
		elseif text:match("%%system%%PPHP(%d+)/(%d+)") then
			local now,max= text:match("%%system%%PPHP(%d+)/(%d+)")
			modules.game_console.setPokeHP(now,max)
		elseif text:match("%%system%%PXP(%d+),(%d+),(%d+),(%d+)") then
			local lvl,now,max,med= text:match("%%system%%PXP(%d+),(%d+),(%d+),(%d+)")
			modules.game_console.setPokeExp(lvl,now,max,med)
		elseif text:match("%%system%%CTCH(%d+)") then
			local nm= text:match("%%system%%CTCH(%d+)")
			modules.game_healthinfo.onSoulChange(0, nm)
		elseif text:match("%%system%%CD(%d+)M(%d+)") then
			local tt,mm = text:match("%%system%%CD(%d+)M(%d+)")
			modules.game_pokewindow.reorganizeCD(tonumber(tt),tonumber(mm),1)

		elseif text:match("%%system%%PIN(.-),(.-),(%d+),(%d+),(%d+),{(.-)},(%d+),(%d+),(%d+),(%d+),(%d+)") then
			local name,nick,boost,hp,max,addons,port,lvl,exp,next,med = text:match("%%system%%PIN(.-),(.-),(%d+),(%d+),(%d+),{(.-)},(%d+),(%d+),(%d+),(%d+),(%d+)")
			modules.game_console.setPokeInfo(name,nick,tonumber(boost),tonumber(hp),tonumber(max),addons,tonumber(port),lvl,exp,next,med)
		elseif text:match("%%system%%UD(%d+)M(%d+)") then
			local tt,mm = text:match("%%system%%UD(%d+)M(%d+)")
			modules.game_pokewindow.reorganizeCD(tonumber(tt),tonumber(mm),1)
		elseif text:match("%%system%%COL(.-)%((%d+)%)") then
			local m,col=text:match("%%system%%COLm(%d)%((%d+)%)")
			modules.game_pokewindow.setColdown(tonumber(m),tonumber(col))

		elseif text == '%system%LP' then
			modules.game_pokelists.reFresh({})
		elseif text:match("%%system%%LP(.+)") then

			local tt = text:match("%%system%%LP(.+)")
			if tt ~= '?' then
				content = {}
				for poke,id,hp,hpmax,is,use,boost,sexo,uid,level in tt:gmatch("|(.-):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)|") do
					local maxp = tonumber(hpmax)
					content[#content+1] = {poke,tonumber(id),tonumber(hp),maxp,tonumber(is),tonumber(use),tonumber(boost),tonumber(sexo),tonumber(level)}
				end
			end
			modules.game_pokelists.reFresh(content)
			--modules.game_pokewindow.reorganizeCD(tonumber(tt),tonumber(mm),1)
		end

		return
  end
  local callback = callbacks[opcode]
  if callback then
    callback(protocol, opcode, buffer)
  end
end


function onGameStart()
	CALL = false
end

function offline()
	print("poax")
	CALL = false
end

function online()
	scheduleEvent(function()
	if not CALL then
		g_game.getProtocolGame():sendExtendedOpcode(4, "OHAI!")
	end
  end,3000)
end
-- public functions
function Extended.init()
  connect(ProtocolGame, {onGameStart=onGameStart, onExtendedOpcode = onExtendedOpcode } )
  connect(g_game, {
    onGameStart = online,
    onGameEnd = offline,

  })

end

function Extended.terminate()
  disconnect(ProtocolGame, {onGameStart=onGameStart, onExtendedOpcode = onExtendedOpcode } )
    disconnect(g_game, {
    onGameStart = online,
    onGameEnd = offline,

  })

  callbacks = nil
  Extended = nil
end

function Extended.register(opcode, callback)
  if not callback or type(callback) ~= 'function' then
    error('Invalid callback.')
    return false
  end

  if opcode < 0 or opcode > 255 then
    error('Invalid opcode. Range: 0-255')
    return false
  end

  if callbacks[opcode] then
    error('Opcode is already taken.')
    return false
  end

  callbacks[opcode] = callback
  return true
end

function Extended.unregister(opcode)
  if opcode < 0 or opcode > 255 then
    error('Invalid opcode. Range: 0-255')
    return false
  end

  if not callbacks[opcode] then
    error('Opcode is not registered.')
    return false
  end

  callbacks[opcode] = nil
  return true
end

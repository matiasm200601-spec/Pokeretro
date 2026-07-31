Icons = {}
Icons[1] = { tooltip = tr('Você está poisoned'), path = '/game_healthinfo/icons/poisoned.png', id = 'condition_poisoned' }
Icons[2] = { tooltip = tr('Você está burning'), path = '/game_healthinfo/icons/burning.png', id = 'condition_burning' }
Icons[4] = { tooltip = tr('Você está electrified'), path = '/game_healthinfo/icons/electrified.png', id = 'condition_electrified' }
Icons[8] = { tooltip = tr('You are drunk'), path = '/game_healthinfo/icons/drunk.png', id = 'condition_drunk' }
Icons[16] = { tooltip = tr('You are protected by a magic shield'), path = '/game_healthinfo/icons/magic_shield.png', id = 'condition_magic_shield' }
Icons[32] = { tooltip = tr('You are paralysed'), path = '/game_healthinfo/icons/slowed.png', id = 'condition_slowed' }
Icons[64] = { tooltip = tr('You are hasted'), path = '/game_healthinfo/icons/haste.png', id = 'condition_haste' }
Icons[128] = { tooltip = tr('You may not logout during a fight'), path = '/game_healthinfo/icons/logout_block.png', id = 'condition_logout_block' }
Icons[256] = { tooltip = tr('You are drowing'), path = '/game_healthinfo/icons/drowning.png', id = 'condition_drowning' }
Icons[512] = { tooltip = tr('You are freezing'), path = '/game_healthinfo/icons/freezing.png', id = 'condition_freezing' }
Icons[1024] = { tooltip = tr('You are dazzled'), path = '/game_healthinfo/icons/dazzled.png', id = 'condition_dazzled' }
Icons[2048] = { tooltip = tr('You are cursed'), path = '/game_healthinfo/icons/cursed.png', id = 'condition_cursed' }
Icons[4096] = { tooltip = tr('Você está strengthened'), path = '/game_healthinfo/icons/strengthened.png', id = 'condition_strengthened' }
Icons[8192] = { tooltip = tr('You may not logout or enter a protection zone'), path = '/game_healthinfo/icons/protection_zone_block.png', id = 'condition_protection_zone_block' }
Icons[16384] = { tooltip = tr('Você está within a protection zone'), path = '/game_healthinfo/icons/protection_zone.png', id = 'condition_protection_zone' }
Icons[32768] = { tooltip = tr('Você está bleeding'), path = '/game_healthinfo/icons/bleeding.png', id = 'condition_bleeding' }
Icons[65536] = { tooltip = tr('Você está hungry'), path = '/game_healthinfo/icons/hungry.png', id = 'condition_hungry' }

healthInfoWindow = nil
healthBar = nil
manaBar = nil
soulBar = nil
healthLabel = nil
manaLabel = nil
soulLabel = nil
capLabel = nil

function init()
  connect(LocalPlayer, { onHealthChange = onHealthChange,
                         onManaChange = onManaChange,
                         onStatesChange = onStatesChange,
                         onFreeCapacityChange = onFreeCapacityChange,
						 onExperienceChange = onExperienceChange,
						 onSkillChange = onSkillChange,
						 })

  connect(g_game, { onGameEnd = refresh,onGameStart = begingaem })

  healthInfoButton = TopMenu.addRightGameToggleButton('healthInfoButton', tr('Health Information'), 'healthinfo.png', toggle)
  healthInfoButton:setOn(true)

  healthInfoWindow = g_ui.loadUI('healthinfo.otui', modules.game_interface.getRightPanel())
  healthInfoWindow:disableResize()
  healthBar = healthInfoWindow:recursiveGetChildById('healthBar')
  --manaBar = healthInfoWindow:recursiveGetChildById('manaBar')
  healthLabel = healthInfoWindow:recursiveGetChildById('healthLabel')
  --manaLabel = healthInfoWindow:recursiveGetChildById('manaLabel')
  soulBar = healthInfoWindow:recursiveGetChildById('soulBar')
  soulLabel = healthInfoWindow:recursiveGetChildById('soulLabel')
  capLabel = healthInfoWindow:recursiveGetChildById('capLabel')


  tourLabel = healthInfoWindow:recursiveGetChildById('tourlab')


    expLabel = healthInfoWindow:recursiveGetChildById('expeLabel')
	expBar = healthInfoWindow:recursiveGetChildById('expbar')

  if g_game.isOnline() then
    local localPlayer = g_game.getLocalPlayer()
    onHealthChange(localPlayer, localPlayer:getHealth(), localPlayer:getMaxHealth())
    onManaChange(localPlayer, localPlayer:getMana(), localPlayer:getMaxMana())
    onStatesChange(localPlayer, localPlayer:getStates(), 0)
    --onSoulChange(localPlayer, 0)
    onFreeCapacityChange(localPlayer, localPlayer:getFreeCapacity())

	healthInfoWindow:recursiveGetChildById('naem'):setText(localPlayer:getName())
	local lavel = healthInfoWindow:recursiveGetChildById('laevl')
	lavel:setText(tr('Lvl') .. ':  ' .. localPlayer:getLevel())
  end

  healthInfoWindow:setup()
  refresh()
  begingaem()

end
function begingaem()
	scheduleEvent(function() refresh() begingaem() end, 1000)
end
function terminate()
  disconnect(LocalPlayer, { onHealthChange = onHealthChange,
                            onManaChange = onManaChange,
                            onStatesChange = onStatesChange,
                            onFreeCapacityChange = onFreeCapacityChange,
							onExperienceChange = onExperienceChange,
onSkillChange = onSkillChange,							})

  disconnect(g_game, { onGameEnd = refresh,onGameStart = refresh })

  healthInfoWindow:destroy()
  healthInfoButton:destroy()
  healthInfoWindow = nil
  healthInfoButton = nil

  healthBar = nil
  manaBar = nil
  soulBar = nil
  tourLabel =nil
	expLabel = nil
	expBar= nil
  healthLabel = nil
  manaLabel = nil
  soulLabel = nil
  capLabel = nil

  HealthInfo = nil
end
function setSkillBase(id, value, baseValue)
  if id ~= 2 or id ~= 6 then
	return
  end
  if baseValue <= 0 or value < 0 then
    return
  end
  if id == 2 then
	  local widget = skillsWindow:recursiveGetChildById("tourlab")


	  if value > baseValue then
		widget:setColor('#008b00') -- green
		skill:setTooltip(baseValue .. ' +' .. (value - baseValue))
	  elseif value < baseValue then
		widget:setColor('#b22222') -- red
		skill:setTooltip(baseValue .. ' ' .. (value - baseValue))
	  else
		widget:setColor('#bbbbbb') -- default
		skill:removeTooltip()
	  end
	else
	  local skill = skillsWindow:recursiveGetChildById(id)
	  local widget = skill:getChildById('value')

	  if value > baseValue then
		widget:setColor('#008b00') -- green
		skill:setTooltip(baseValue .. ' +' .. (value - baseValue))
	  elseif value < baseValue then
		widget:setColor('#b22222') -- red
		skill:setTooltip(baseValue .. ' ' .. (value - baseValue))
	  else
		widget:setColor('#bbbbbb') -- default
		skill:removeTooltip()
	  end
	end
end

function setSkillValue(id, value)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('value')
  widget:setText(value)
end

function refresh()
  local player = g_game.getLocalPlayer()
  if not player then return end
	healthInfoWindow:recursiveGetChildById('naem'):setText(player:getName())

	onExperienceChange(player, player:getExperience(),true)

    onSkillChange(player, 2, player:getSkillLevel(2), player:getSkillLevelPercent(2),true)
	onSkillChange(player, 6, player:getSkillLevel(6), player:getSkillLevelPercent(6),true)
	local outfitCreature=player:getOutfit()
	local outfitCreatureBox = healthInfoWindow:recursiveGetChildById('outfitCreatureBox')
	local lavel = healthInfoWindow:recursiveGetChildById('laevl')
	lavel:setText(tr('Lvl') .. ':  ' .. player:getLevel())
	  if outfitCreatureBox then
		outfitCreatureBox:setCreature(player)
	  end
	if g_game.isOnline() then
		local localPlayer = g_game.getLocalPlayer()
		onHealthChange(localPlayer, localPlayer:getHealth(), localPlayer:getMaxHealth())
		onManaChange(localPlayer, localPlayer:getMana(), localPlayer:getMaxMana())
		--onStatesChange(localPlayer, localPlayer:getStates(), 0)
		--onSoulChange(localPlayer, 0)
		onFreeCapacityChange(localPlayer, localPlayer:getFreeCapacity())

		healthInfoWindow:recursiveGetChildById('naem'):setText(localPlayer:getName())
	  end
	--toggleIcon(0)

end

function onExperienceChange(localPlayer, value,hur)
	if not hur then
		refresh()
	end
	expLabel:setText(localPlayer:getLevelPercent()..'% ('..value..')')
	expBar:setPercent(localPlayer:getLevelPercent())

	local lavel = healthInfoWindow:recursiveGetChildById('laevl')
	lavel:setText(tr('Lvl') .. ':  ' .. localPlayer:getLevel())

end

function onSkillChange(localPlayer, id, level, percent,hur)

  if id == 2 then
	tourLabel:setText(tr('Tournament') .. ':  ' .. string.format("%.3d",level))
	--setSkillValue('skillId' .. id, level)
	--setSkillPercent('skillId' .. id, percent, tr('You have %s percent to go', 100 - percent))
	--onBaseSkillChange(localPlayer, id, localPlayer:getSkillBaseLevel(id))
	elseif id == 6 then
		--onSkillChange(localPlayer, 6, localPlayer:getSkillLevel(6), localPlayer:getSkillLevelPercent(6))
		local skill = healthInfoWindow:recursiveGetChildById('fishbar')
		local lab = healthInfoWindow:recursiveGetChildById('fishlab')
		if skill then
			skill:setTooltip(percent.."%")
			skill:setPercent(percent)
			lab:setText(tr('Fishing') .. ':  '..level)

		end
	end
	if not hur then
		refresh()
	end
end

function setSkillPercent(id, percent, tooltip)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('percent')
  widget:setPercent(math.floor(percent))

  if tooltip then
    widget:setTooltip(tooltip)
  end
end

function toggle()
  if healthInfoButton:isOn() then
    healthInfoWindow:close()
    healthInfoButton:setOn(false)
  else
    healthInfoWindow:open()

    healthInfoButton:setOn(true)
	refresh()
  end
end

function hideLabels()
  capLabel:hide()
  soulLabel:hide()
  local removeHeight = capLabel:getHeight() + capLabel:getMarginTop() + capLabel:getMarginBottom()
  healthInfoWindow:setHeight(healthInfoWindow:getHeight() - removeHeight)
end

function onMiniWindowClose()
  healthInfoButton:setOn(false)
end

function offline()
  healthInfoWindow:recursiveGetChildById('conditionPanel'):destroyChildren()
end

-- hooked events
function onHealthChange(localPlayer, health, maxHealth)
  healthLabel:setText(health .. ' / ' .. maxHealth)
  healthBar:setPercent(health / maxHealth * 100)
end

function onManaChange(localPlayer, mana, maxMana)
print("mana: ",mana,maxMana)
  --manaLabel:setText(mana .. ' / ' .. maxMana)

  local percent
  if maxMana == 0 then
    percent = 100
  else
    percent = (mana * 100)/maxMana
  end
  if mana <= 6 and mana > -1 then
	for i=1,mana do
		healthInfoWindow:recursiveGetChildById('call'..i):setImageSource('pokeball.png')
	end
	for i=mana+1,6 do
		if i ~= 0 then
			healthInfoWindow:recursiveGetChildById('call'..i):setImageSource('bolas.png')
		end
	end

  end
  --manaBar:setPercent(percent)
end

function onSoulChange(localPlayer, soul)
  soulLabel:setText(tr('Catch') .. ': ' .. string.format("%.3d",soul))
end

function onFreeCapacityChange(player, freeCapacity)
  capLabel:setText(tr('Cap') .. ': ' .. freeCapacity)
end


function onStatesChange(localPlayer, now, old)
  if now == old then return end
  local bitsChanged = bit32.bxor(now, old)
  for i = 1, 32 do
    local pow = math.pow(2, i-1)
    if pow > bitsChanged then break end
    local bitChanged = bit32.band(bitsChanged, pow)
    if bitChanged ~= 0 then
      toggleIcon(bitChanged)
    end
  end
end

function toggleIcon(bitChanged)
  local content = healthInfoWindow:recursiveGetChildById('conditionPanel')

  local icon = content:getChildById(Icons[bitChanged].id)
  if icon then
    icon:destroy()
  else
    icon = g_ui.createWidget('ConditionWidget', content)
    icon:setId(Icons[bitChanged].id)
    icon:setImageSource(Icons[bitChanged].path)
    icon:setTooltip(Icons[bitChanged].tooltip)
  end
end


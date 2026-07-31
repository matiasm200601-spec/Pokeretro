function init()
--  ropeButton = modules.client_topmenu.addRightGameToggleButton('ropeButton', tr('Rope') .. ' (Ctrl+X)', '/images/topbuttons/rope', toggleRope)
--  pokedexButton = modules.client_topmenu.addRightGameToggleButton('pokedexButton', tr('Pokedex') .. ' (Ctrl+D)', '/images/topbuttons/pokedex', togglePokedex)
--  fishingButton = modules.client_topmenu.addRightGameToggleButton('fishingButton', tr('Fishing') .. ' (Ctrl+Z)', '/images/topbuttons/fishing', toggleFishing)

  g_keyboard.bindKeyDown('Ctrl+X', toggleRope)
  g_keyboard.bindKeyDown('Ctrl+Z', toggleFishing)
end

function startChooseItem(releaseCallback)
  if g_ui.isMouseGrabbed() then return end
  if not releaseCallback then
    error("No mouse release callback parameter set.")
  end
  local mouseGrabberWidget = g_ui.createWidget('UIWidget')
  mouseGrabberWidget:setVisible(false)
  mouseGrabberWidget:setFocusable(false)

  connect(mouseGrabberWidget, { onMouseRelease = releaseCallback })
  
  mouseGrabberWidget:grabMouse()
  g_mouse.pushCursor('target')
end

function onClickWithMouse(self, mousePosition, mouseButton)
  local item = nil
  if mouseButton == MouseLeftButton then
    local clickedWidget = modules.game_interface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
    if clickedWidget then
      if clickedWidget:getClassName() == 'UIMap' then
        local tile = clickedWidget:getTile(mousePosition)
        if tile then
          if currentSlot == 1 then
             item = tile:getGround()
          else
              local thing = tile:getTopMoveThing()
              if thing and thing:isItem() then
                 item = thing
              else
                 item = tile:getTopCreature()
              end
          end
        elseif clickedWidget:getClassName() == 'UIItem' and not clickedWidget:isVirtual() then
           item = clickedWidget:getItem()
        end
      end
    end
  end
    if item then
       if currentSlot == 4 and not item:isPlayer() then
          modules.game_textmessage.displayFailureMessage('Use it only in players!')
       else   
          local player = g_game.getLocalPlayer()
          g_game.useInventoryItemWith(player:getInventoryItem(currentSlot):getId(), item)
       end
    end
  g_mouse.popCursor()
  self:ungrabMouse()
  self:destroy()
end

function toggleRope()
  currentSlot = 1
  startChooseItem(onClickWithMouse)
end

function togglePokedex()
  currentSlot = 6
  startChooseItem(onClickWithMouse)
end

function toggleFishing()
  currentSlot = 2
  startChooseItem(onClickWithMouse)
end

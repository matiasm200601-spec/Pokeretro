-- @docclass
UiSkillWindow = extends(UIWindow)

function UiSkillWindow.create()
  local miniwindow = UiSkillWindow.internalCreate()
  return miniwindow
end

function UiSkillWindow:getClassName()
  return 'UiSkillWindow'
end

function UiSkillWindow:open(dontSave)
  self:setVisible(true)

  if not dontSave then
    self:setSettings({closed = false})
  end

  signalcall(self.onOpen, self)
end

function UiSkillWindow:close(dontSave)
  if not self:isExplicitlyVisible() then return end
  self:setVisible(false)

  if not dontSave then
    self:setSettings({closed = true})
  end

  signalcall(self.onClose, self)
end

function UiSkillWindow:minimize(dontSave)

  signalcall(self.onMinimize, self)
end

function UiSkillWindow:maximize(dontSave)

  signalcall(self.onMaximize, self)
end

function UiSkillWindow:setup()
  self:getChildById('closeButton'):delete()

  self:getChildById('minimizeButton'):delete()

  local oldParent = self:getParent()

  local settings = g_settings.getNode('MiniWindows')
  if settings then
    local selfSettings = settings[self:getId()]
    if selfSettings then
      if selfSettings.parentId then
        local parent = rootWidget:recursiveGetChildById(selfSettings.parentId)
        if parent then
          if parent:getClassName() == 'UiSkillWindowContainer' and selfSettings.index and parent:isOn() then
            self.miniIndex = selfSettings.index
            parent:scheduleInsert(self, selfSettings.index)
          elseif selfSettings.position then
            self:setParent(parent)
            self:setPosition(topoint(selfSettings.position))
            addEvent(function() self:bindRectToParent() end)
          end
        end
      end

      if selfSettings.minimized then
        self:minimize(true)
      else
        if selfSettings.height and self:isResizeable() then
          self:setHeight(selfSettings.height)
        elseif selfSettings.height and not self:isResizeable() then
          self:eraseSettings({height = true})
        end
      end

      if selfSettings.closed then
        self:close(true)
      end
    end
  end

  local newParent = self:getParent()

  self.miniLoaded = true

  if self.save then
    if oldParent and oldParent:getClassName() == 'UiSkillWindowContainer' then
      addEvent(function() oldParent:order() end)
    end
    if newParent and newParent:getClassName() == 'UiSkillWindowContainer' and newParent ~= oldParent then
      addEvent(function() newParent:order() end)
    end
  end

  self:fitOnParent()
end

function UiSkillWindow:onVisibilityChange(visible)
  self:fitOnParent()
end

function UiSkillWindow:onDragEnter(mousePos)
  local parent = self:getParent()
  if not parent then return false end

  if parent:getClassName() == 'UiSkillWindowContainer' then
    local containerParent = parent:getParent()
    parent:removeChild(self)
    containerParent:addChild(self)
    parent:saveChildren()
  end

  local oldPos = self:getPosition()
  self.movingReference = { x = mousePos.x - oldPos.x, y = mousePos.y - oldPos.y }
  self:setPosition(oldPos)
  self.free = true
  return true
end

function UiSkillWindow:onDragLeave(droppedWidget, mousePos)
  if self.movedWidget then
    self.setMovedChildMargin(0)
    self.movedWidget = nil
    self.setMovedChildMargin = nil
    self.movedIndex = nil
  end

  self:saveParent(self:getParent())
end

function UiSkillWindow:onDragMove(mousePos, mouseMoved)
  local oldMousePosY = mousePos.y - mouseMoved.y
  local children = rootWidget:recursiveGetChildrenByMarginPos(mousePos)
  local overAnyWidget = false
  for i=1,#children do
    local child = children[i]
    if child:getParent():getClassName() == 'UiSkillWindowContainer' then
      overAnyWidget = true

      local childCenterY = child:getY() + child:getHeight() / 2
      if child == self.movedWidget and mousePos.y < childCenterY and oldMousePosY < childCenterY then
        break
      end

      if self.movedWidget then
        self.setMovedChildMargin(0)
        self.setMovedChildMargin = nil
      end

      if mousePos.y < childCenterY then
        self.setMovedChildMargin = function(v) child:setMarginTop(v) end
        self.movedIndex = 0
      else
        self.setMovedChildMargin = function(v) child:setMarginBottom(v) end
        self.movedIndex = 1
      end

      self.movedWidget = child
      self.setMovedChildMargin(self:getHeight())
      break
    end
  end

  if not overAnyWidget and self.movedWidget then
    self.setMovedChildMargin(0)
    self.movedWidget = nil
  end

  return UIWindow.onDragMove(self, mousePos, mouseMoved)
end

function UiSkillWindow:onMousePress()
  local parent = self:getParent()
  if not parent then return false end
  if parent:getClassName() ~= 'UiSkillWindowContainer' then
    self:raise()
    return true
  end
end

function UiSkillWindow:onFocusChange(focused)
  if not focused then return end
  local parent = self:getParent()
  if parent and parent:getClassName() ~= 'UiSkillWindowContainer' then
    self:raise()
  end
end

function UiSkillWindow:onHeightChange(height)
  if not self:isOn() then
    self:setSettings({height = height})
  end
  self:fitOnParent()
end

function UiSkillWindow:getSettings(name)
  if not self.save then return nil end
  local settings = g_settings.getNode('MiniWindows')
  if settings then
    local selfSettings = settings[self:getId()]
    if selfSettings then
      return selfSettings[name]
    end
  end
  return nil
end

function UiSkillWindow:setSettings(data)
  if not self.save then return end

  local settings = g_settings.getNode('MiniWindows')
  if not settings then
    settings = {}
  end

  local id = self:getId()
  if not settings[id] then
    settings[id] = {}
  end

  for key,value in pairs(data) do
    settings[id][key] = value
  end

  g_settings.setNode('MiniWindows', settings)
end

function UiSkillWindow:eraseSettings(data)
  if not self.save then return end

  local settings = g_settings.getNode('MiniWindows')
  if not settings then
    settings = {}
  end

  local id = self:getId()
  if not settings[id] then
    settings[id] = {}
  end

  for key,value in pairs(data) do
    settings[id][key] = nil
  end

  g_settings.setNode('MiniWindows', settings)
end

function UiSkillWindow:saveParent(parent)
  local parent = self:getParent()
  if parent then
    if parent:getClassName() == 'UiSkillWindowContainer' then
      parent:saveChildren()
    else
      self:saveParentPosition(parent:getId(), self:getPosition())
    end
  end
end

function UiSkillWindow:saveParentPosition(parentId, position)
  local selfSettings = {}
  selfSettings.parentId = parentId
  selfSettings.position = pointtostring(position)
  self:setSettings(selfSettings)
end

function UiSkillWindow:saveParentIndex(parentId, index)
  local selfSettings = {}
  selfSettings.parentId = parentId
  selfSettings.index = index
  self:setSettings(selfSettings)
  self.miniIndex = index
end

function UiSkillWindow:disableResize()
  self:getChildById('bottomResizeBorder'):disable()
end

function UiSkillWindow:enableResize()
  self:getChildById('bottomResizeBorder'):enable()
end

function UiSkillWindow:fitOnParent()
  local parent = self:getParent()
  if self:isVisible() and parent and parent:getClassName() == 'UiSkillWindowContainer' then
    parent:fitAll(self)
  end
end

function UiSkillWindow:setParent(parent)
  UIWidget.setParent(self, parent)
  self:saveParent(parent)
  self:fitOnParent()
end

function UiSkillWindow:setHeight(height)
  UIWidget.setHeight(self, height)
  signalcall(self.onHeightChange, self, height)
end

function UiSkillWindow:setContentHeight(height)
  local contentsPanel = self:getChildById('contentsPanel')
  local minHeight = contentsPanel:getMarginTop() + contentsPanel:getMarginBottom() + contentsPanel:getPaddingTop() + contentsPanel:getPaddingBottom()

  local resizeBorder = self:getChildById('bottomResizeBorder')
  resizeBorder:setParentSize(minHeight + height)
end

function UiSkillWindow:setContentMinimumHeight(height)
  local contentsPanel = self:getChildById('contentsPanel')
  local minHeight = contentsPanel:getMarginTop() + contentsPanel:getMarginBottom() + contentsPanel:getPaddingTop() + contentsPanel:getPaddingBottom()

  local resizeBorder = self:getChildById('bottomResizeBorder')
  resizeBorder:setMinimum(minHeight + height)
end

function UiSkillWindow:setContentMaximumHeight(height)
  local contentsPanel = self:getChildById('contentsPanel')
  local minHeight = contentsPanel:getMarginTop() + contentsPanel:getMarginBottom() + contentsPanel:getPaddingTop() + contentsPanel:getPaddingBottom()

  local resizeBorder = self:getChildById('bottomResizeBorder')
  resizeBorder:setMaximum(minHeight + height)
end

function UiSkillWindow:getMinimumHeight()
  local resizeBorder = self:getChildById('bottomResizeBorder')
  return resizeBorder:getMinimum()
end

function UiSkillWindow:getMaximumHeight()
  local resizeBorder = self:getChildById('bottomResizeBorder')
  return resizeBorder:getMaximum()
end

function UiSkillWindow:isResizeable()
  local resizeBorder = self:getChildById('bottomResizeBorder')
  return resizeBorder:isExplicitlyVisible() and resizeBorder:isEnabled()
end

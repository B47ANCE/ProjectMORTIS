require "OptionScreens/MainScreen"
require "ISUI/ISButton"
local Panel=require "Mortis/Creator/Panel"
local T=require("Mortis/Creator/Text").get
local Menu={}
local function position(screen)
 local button=screen.mortisCreatorButton;if not button then return end
 local visible=screen.inGame~=true and screen.bottomPanel:getIsVisible()
 if button:getIsVisible()~=visible then button:setVisible(visible)end
 local h=getTextManager():getFontHeight(UIFont.Small)+12
 local anchor=screen.termsOfService or screen.reportBug
 local y=anchor and anchor:getY()or 24
 local text=T("Menu")
 local last=button.mortisLayout
 if last and last.w==screen:getWidth()and last.h==screen:getHeight()and last.font==h and last.y==y and last.text==text then return end
 button.mortisLayout={w=screen:getWidth(),h=screen:getHeight(),font=h,y=y,text=text}
 button:setWidth(math.min(screen:getWidth()-48,math.max(200,getTextManager():MeasureStringX(UIFont.Small,text)+24)));button:setHeight(h)
 button:setX(screen:getWidth()-button:getWidth()-24)
 button:setY(math.max(8,anchor and y-h-8 or 24))
end
function Menu.open(screen)
 if not screen or screen~=MainScreen.instance or screen.inGame or not screen.bottomPanel:getIsVisible()then return false end
 local panel=screen.mortisCreatorPanel
 if not panel then
  panel=Panel:new(screen);panel:initialise();panel:instantiate();screen:addChild(panel);screen.mortisCreatorPanel=panel
 elseif not panel:isDirty()then
  panel.library,panel.libraryError=panel.store:load();panel:refreshSaved(panel.loadedId)
  if panel.libraryError then panel:message(panel.libraryError)
  elseif panel.loadedId and panel.library.records[panel.loadedId]then panel:fill(panel.library.records[panel.loadedId])
  else panel:fill(require("Mortis/Creator/Model").new())end
 end
 panel:layout();screen.bottomPanel:setVisible(false);panel:setVisible(true);Menu.panel=panel
 local data=JoypadState and JoypadState.getMainMenuJoypad and JoypadState.getMainMenuJoypad()
 if data then data.focus=panel;updateJoypadFocus(data)end
 return true
end
function Menu.install()
 local screen=MainScreen.instance
 if not screen or screen.inGame or screen.mortisCreatorButton then return end
 local button=ISButton:new(0,0,200,28,T("Menu"),screen,Menu.open)
 button:initialise();button:instantiate();screen:addChild(button);screen.mortisCreatorButton=button;position(screen)
end
-- Preserve existing methods and all other UI ownership. No vanilla file edits.
if not MainScreen.mortisCreatorHooks then
 MainScreen.mortisCreatorHooks=true
 local update=MainScreen.update
 function MainScreen:update(...)
  local result=update(self,...);position(self);return result
 end
 local gain=MainScreen.onGainJoypadFocus
 function MainScreen:onGainJoypadFocus(data)
  local result=gain(self,data)
  if self.mortisCreatorButton and self.mortisCreatorButton:getIsVisible()then self:insertNewLineOfButtons(self.mortisCreatorButton)end
  return result
 end
 local down=MainScreen.onJoypadDown
 function MainScreen:onJoypadDown(button,data)
  if Joypad and button==Joypad.AButton and self.joypadButtons and self.joypadButtons[self.joypadIndex]==self.mortisCreatorButton then
   return Menu.open(self)
  end
  return down(self,button,data)
 end
 local uis=MainScreen.getAllUIs
 function MainScreen:getAllUIs()
  local list=uis(self);if self.mortisCreatorPanel then list[#list+1]=self.mortisCreatorPanel end;return list
 end
 Events.OnMainMenuEnter.Add(Menu.install)
 Events.OnResolutionChange.Add(function()
  local screen=MainScreen.instance;if screen then position(screen);if screen.mortisCreatorPanel then screen.mortisCreatorPanel:layout()end end
 end)
 Events.OnGameStart.Add(function()if Menu.panel then Menu.panel:hide();Menu.panel=nil end end)
end
Menu.install()
return Menu

-- Actual editor/menu/store with modeled native widgets and file boundaries.
local Base={};Base.__index=Base
function Base:derive(name)local c={Type=name};c.__index=c;return setmetatable(c,{__index=self})end
function Base:new(x,y,w,h)
 return setmetatable({x=x,y=y,width=w,height=h,children={},visible=true,enable=true,options={},selected=1,joypadButtonsY={}},self)
end
function Base:initialise()end
function Base:instantiate()if self.javaObject then return end;self.javaObject={};if self.createChildren then self:createChildren()end end
function Base:addChild(c)if not c.javaObject then c:instantiate()end;c.parent=self;self.children[#self.children+1]=c end
function Base:setX(v)self.x=v end;function Base:setY(v)self.y=v end
function Base:setWidth(v)self.width=v end;function Base:setHeight(v)self.height=v end
function Base:getWidth()return self.width end;function Base:getHeight()return self.height end
function Base:getY()return self.y end
function Base:setVisible(v)self.visible=v end;function Base:getIsVisible()return self.visible end
function Base:setEnable(v)self.enable=v end
function Base:setMaxTextLength(v)self.limit=v end;function Base:setTooltip(v)self.tooltip=v end
function Base:setMultipleLine(v)self.multiline=v end;function Base:setEditable(v)self.editable=v end
function Base:setText(v)self.text=v end;function Base:getText()return self.text end
function Base:focus()self.focused=true end;function Base:unfocus()self.focused=false end
function Base:addOption(v)self.options[#self.options+1]=v end
function Base:clear()self.options={};self.selected=1 end
function Base:prerender()end;function Base:drawText()end
function Base:clearJoypadButtonsList()self.joypadButtonsY={}end
function Base:insertNewLineOfButtons(...)self.joypadButtonsY[#self.joypadButtonsY+1]={...}end
function Base:onGainJoypadFocus(data)self.joyfocus=data end
function Base:onLoseJoypadFocus()end;function Base:restoreJoypadFocus()end;function Base:clearJoypadFocus()end
function Base:isFocusOnControl()return false end
function Base:onJoypadDown()self.delegated=(self.delegated or 0)+1 end
function Base:addToUIManager()self.managed=true end;function Base:removeFromUIManager()self.managed=false end
ISPanelJoypad=Base:derive('ISPanelJoypad')
ISTextEntryBox=Base:derive('ISTextEntryBox')
function ISTextEntryBox:new(text,x,y,w,h)local o=Base.new(self,x,y,w,h);o.text=text;return o end
ISComboBox=Base:derive('ISComboBox')
function ISComboBox:new(x,y,w,h,target,fn)local o=Base.new(self,x,y,w,h);o.target=target;o.change=fn;return o end
ISButton=Base:derive('ISButton')
function ISButton:new(x,y,w,h,title,target,fn)local o=Base.new(self,x,y,w,h);o.title=title;o.target=target;o.onclick=fn;return o end
function ISButton:forceClick()if self.enable then return self.onclick(self.target,self)end end
ISModalDialog=Base:derive('ISModalDialog')
function ISModalDialog:new(x,y,w,h,text,yesno,target,fn)
 local o=Base.new(self,x,y,w,h);o.target=target;o.onclick=fn;return o
end
MainScreen=Base:derive('MainScreen')
function MainScreen:update()self.nativeUpdates=(self.nativeUpdates or 0)+1 end
function MainScreen:onGainJoypadFocus(data)
 self.joypadButtonsY={{self.vanillaButton}};self.joypadButtons=self.joypadButtonsY[1];self.joypadIndex=1;self.joypadIndexY=1
end
function MainScreen:onJoypadDown()self.nativeDown=(self.nativeDown or 0)+1 end
function MainScreen:getAllUIs()return {self.otherPanel}end
for _,name in ipairs({'ISPanelJoypad','ISTextEntryBox','ISComboBox','ISButton','ISModalDialog'})do package.loaded['ISUI/'..name]=true end
package.loaded['OptionScreens/MainScreen']=true
local handlers={}
Events={};for _,name in ipairs({'OnMainMenuEnter','OnResolutionChange','OnGameStart'})do
 handlers[name]={};Events[name]={Add=function(fn)handlers[name][#handlers[name]+1]=fn end}
end
local function emit(name)for _,fn in ipairs(handlers[name])do fn()end end
local width,height,font=1024,768,16
getCore=function()return {getScreenWidth=function()return width end,getScreenHeight=function()return height end}end
getTextManager=function()return {getFontHeight=function()return font end,MeasureStringX=function(_,_,s)return #s*8 end}end
UIFont={Small='Small',Medium='Medium'};Joypad={AButton=1,BButton=2};Keyboard={KEY_ESCAPE=27,KEY_TAB=9,KEY_LCONTROL=1,KEY_RCONTROL=2,KEY_S=19,KEY_E=5}
isKeyDown=function()return false end
local joy={};JoypadState={getMainMenuJoypad=function()return joy end};updateJoypadFocus=function()end
getText=function(k)return k end;isDebugEnabled=function()return false end
local files,writes={},0
getFileReader=function(name,create)
 assert(not create)
 if files[name]==nil then return nil end
 local lines={};for line in files[name]:gmatch('([^\n]*)\n')do lines[#lines+1]=line end
 local i=0;return {readLine=function()i=i+1;return lines[i]end,close=function()end}
end
getFileWriter=function(name,create,append)
 assert(create and not append);writes=writes+1
 local body='';return {write=function(_,s)body=body..s end,close=function()files[name]=body end}
end
local forbidden=function()error('creator must never mutate gameplay or send commands')end
sendClientCommand=forbidden;sendServerCommand=forbidden;getCell=forbidden
Mortis={registerType=forbidden,assign=forbidden}
local screen=MainScreen:new(0,0,width,height);screen.inGame=false
screen.bottomPanel=Base:new(0,0,400,400);screen.termsOfService=Base:new(780,700,200,28)
screen.otherPanel=Base:new(0,0,1,1);screen.vanillaButton=ISButton:new(0,0,1,1,'Existing',{},function()end)
MainScreen.instance=screen
local Menu=require 'Mortis/Creator/MainMenu'
assert(screen.mortisCreatorButton and writes==0,'release-mode entry exists without creating files')
local count=#screen.children;emit('OnMainMenuEnter');assert(#screen.children==count,'no duplicate entry')
screen:update();assert(screen.nativeUpdates==1)
screen:onGainJoypadFocus(joy);assert(#screen.joypadButtonsY==2)
screen:onJoypadDown(1,joy);assert(screen.nativeDown==1,'native option handler is preserved')
screen.joypadButtons=screen.joypadButtonsY[2];screen.joypadIndex=1;screen:onJoypadDown(1,joy)
local panel=assert(screen.mortisCreatorPanel)
assert(panel:getIsVisible() and not screen.bottomPanel:getIsVisible() and joy.focus==panel)
assert(writes==0,'opening and editing are read-only')
assert(screen:getAllUIs()[1]==screen.otherPanel and screen:getAllUIs()[2]==panel)
panel.controls.id:setText('Example.Created');panel.controls.displayName:setText('Test Zombie')
panel:onSave();assert(panel.library.revision==1 and writes==1 and not panel:isDirty())
panel:onExport();assert(writes==2 and panel.status:getText():find('Zomboid/Lua/',1,true))
panel.controls.displayName:setText('Discard on load');panel:onLoad();assert(panel.modal)
panel.modal.onclick(panel,{internal='YES'});assert(panel.controls.displayName:getText()=='Test Zombie')
panel.section.selected=5;panel:onSection()
assert(panel.preview:getIsVisible() and panel.preview:getText():find('Mortis.registerType',1,true))
panel.section.selected=2;panel:onSection()
assert(not panel.preview:getIsVisible() and panel.controls.tier:getIsVisible() and not panel.controls.id:getIsVisible())
panel.controls.displayName:setText('Unsaved');panel:onClose();assert(panel.modal and panel:getIsVisible())
panel.modal.onclick(panel,{internal='NO'});assert(panel:isDirty() and panel:getIsVisible())
panel:onClose();panel.modal.onclick(panel,{internal='YES'})
assert(not panel:getIsVisible() and screen.bottomPanel:getIsVisible() and not panel:isDirty())
assert(Menu.open(screen));assert(panel.controls.displayName:getText()=='Test Zombie','discarded edits do not reappear')
panel:onDelete();assert(panel.modal);panel.modal.onclick(panel,{internal='YES'})
assert(next(panel.library.records)==nil and panel:isDirty(),'deletion keeps editable draft for recovery')
panel:onNew();assert(panel.modal);panel.modal.onclick(panel,{internal='YES'})
assert(panel.controls.id:getText()=='MyZombies.CustomZombie')
panel.section.selected=1;panel:onSection();panel:onKeyRelease(Keyboard.KEY_TAB)
assert(panel.controls.id.focused,'Tab reaches a visible text field')
isKeyDown=function(key)return key==Keyboard.KEY_LCONTROL end
panel:onKeyRelease(Keyboard.KEY_S);assert(not panel:isDirty(),'Ctrl+S saves the draft')
panel:onKeyRelease(Keyboard.KEY_E);assert(panel.status:getText():find('Zomboid/Lua/',1,true))
isKeyDown=function()return false end
width,height=800,600;emit('OnResolutionChange')
assert(panel:getWidth()<=width and panel:getHeight()<=height and not panel.tooSmall)
for _,label in ipairs(panel.labelPositions)do assert(panel.controls[label.key].y+panel.controls[label.key].height<=panel.status.y)end
width,height=480,360;emit('OnResolutionChange');assert(panel.tooSmall and not panel.saveButton.enable)
screen.inGame=true;screen:update();assert(not screen.mortisCreatorButton:getIsVisible())
assert(not Menu.open(screen));emit('OnGameStart');assert(not panel:getIsVisible())
assert(#handlers.OnMainMenuEnter==1 and #handlers.OnResolutionChange==1 and #handlers.OnGameStart==1)
print('Main-menu integration, real form/save/export/discard flow and bounded layout pass offline')

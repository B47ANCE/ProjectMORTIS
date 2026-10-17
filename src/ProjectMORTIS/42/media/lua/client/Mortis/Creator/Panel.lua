require "ISUI/ISPanelJoypad"
require "ISUI/ISTextEntryBox"
require "ISUI/ISComboBox"
require "ISUI/ISButton"
require "ISUI/ISModalDialog"
local Model=require "Mortis/Creator/Model"
local Store=require "Mortis/Creator/Store"
local Text=require "Mortis/Creator/Text"
local T=Text.get
local Panel=ISPanelJoypad:derive("MortisZombieCreator")
local pages={"Identity","Profiles","Appearance","References","Preview"}
local fields={{"id","displayName"},{"tier","healthMultiplier","damageTakenMultiplier"},{"outfit","hairModel","beardModel"},{"traits","behaviors"},{}}
local tiers={"inherit","shambler","fastShambler","sprinter"}
local function child(self,c)
 c:initialise();c:instantiate();self:addChild(c);return c
end
local function focus(ui)
 local data=JoypadState and JoypadState.getMainMenuJoypad and JoypadState.getMainMenuJoypad()
 if data then data.focus=ui;updateJoypadFocus(data)end
end
function Panel:new(screen,store)
 local o=ISPanelJoypad.new(self,20,20,760,560)
 o.screen=screen;o.store=store or Store.new();o.controls={};o.page=1;o.wantKeyEvents=true
 o.backgroundColor={r=.08,g=.08,b=.08,a=.98};o.borderColor={r=.6,g=.6,b=.6,a=1}
 return o
end
function Panel:createChildren()
 self.saved=child(self,ISComboBox:new(0,0,100,28))
 self.loadButton=child(self,ISButton:new(0,0,80,28,T("Load"),self,Panel.onLoad))
 self.newButton=child(self,ISButton:new(0,0,80,28,T("New"),self,Panel.onNew))
 self.section=child(self,ISComboBox:new(0,0,100,28,self,Panel.onSection))
 for _,name in ipairs(pages)do self.section:addOption(T(name))end
 for _,key in ipairs(Model.fields)do
  local c
  if key=="tier"then
   c=ISComboBox:new(0,0,100,28)
  else c=ISTextEntryBox:new("",0,0,100,28)end
  self.controls[key]=child(self,c)
  if key=="tier"then for _,tier in ipairs(tiers)do c:addOption(T(tier))end
  else
   c:setMaxTextLength((key=="traits" or key=="behaviors")and 1552 or 120)
   c:setTooltip(T(key=="id" and "IdHint" or key=="displayName" and "NameHint" or (key=="healthMultiplier" or key=="damageTakenMultiplier")and "ScaleHint" or (key=="traits" or key=="behaviors")and "ReferencesHint" or "AssetHint"))
  end
 end
 self.preview=child(self,ISTextEntryBox:new("",0,0,100,100));self.preview:setMultipleLine(true);self.preview:setEditable(false)
 self.status=child(self,ISTextEntryBox:new(T("Info"),0,0,100,48));self.status:setMultipleLine(true);self.status:setEditable(false)
 self.saveButton=child(self,ISButton:new(0,0,100,28,T("Save"),self,Panel.onSave))
 self.exportButton=child(self,ISButton:new(0,0,100,28,T("Export"),self,Panel.onExport))
 self.deleteButton=child(self,ISButton:new(0,0,100,28,T("Delete"),self,Panel.onDelete))
 self.closeButton=child(self,ISButton:new(0,0,100,28,T("Close"),self,Panel.onClose))
 self.library,self.libraryError=self.store:load()
 self:refreshSaved()
 self:fill(Model.new())
 if self.libraryError then self:message(self.libraryError)end
 self:layout()
end
function Panel:message(key,suffix)
 self.status:setText(T(key)..(suffix and " "..suffix or ""))
end
function Panel:getDraft()
 local draft={}
 for _,key in ipairs(Model.fields)do
  draft[key]=key=="tier" and tiers[self.controls.tier.selected] or self.controls[key]:getText()
 end
 return draft
end
function Panel:isDirty()return self.forceDirty or not Model.equal(self:getDraft(),self.original)end
function Panel:fill(draft)
 for _,key in ipairs(Model.fields)do
  if key=="tier"then
   for i,tier in ipairs(tiers)do if tier==draft.tier then self.controls.tier.selected=i end end
  else self.controls[key]:setText(draft[key])end
 end
 self.original=Model.copy(draft);self.forceDirty=false
end
function Panel:refreshSaved(wanted)
 self.saved:clear();self.savedIds={}
 if self.library then for id in pairs(self.library.records)do self.savedIds[#self.savedIds+1]=id end end
 table.sort(self.savedIds)
 for i,id in ipairs(self.savedIds)do self.saved:addOption(id);if id==wanted then self.saved.selected=i end end
 if #self.savedIds==0 then self.saved:addOption(T("NoneSaved"))end
 self.loadButton:setEnable(#self.savedIds>0);if self.deleteButton then self.deleteButton:setEnable(#self.savedIds>0)end
end
function Panel:confirm(key,action)
 if self.modal then return end
 local w=math.min(480,getCore():getScreenWidth()-32)
 local modal=ISModalDialog:new((getCore():getScreenWidth()-w)/2,(getCore():getScreenHeight()-180)/2,w,180,T(key),true,self,function(owner,button)
  owner.modal=nil;focus(owner)
  if button.internal=="YES"then action()end
 end)
 self.modal=modal;modal:initialise();modal:addToUIManager();focus(modal)
end
function Panel:discardThen(action)
 if self:isDirty()then self:confirm("DiscardPrompt",action)else action()end
end
function Panel:onNew()
 self:discardThen(function()
  local d=Model.new();d.displayName=T("DefaultName");self:fill(d);self.loadedId=nil;self:message("Info")
 end)
end
function Panel:onLoad()
 local id=self.savedIds[self.saved.selected];if not id then return end
 self:discardThen(function()
  local library,err=self.store:load()
  if not library then self:message(err);return end
  self.library=library;self:refreshSaved(id)
  local d=library.records[id];if not d then self:message("Missing");return end
  self:fill(d);self.loadedId=id;self:message("Loaded",id)
 end)
end
function Panel:onSave()
 if self.tooSmall then self:message("TooSmall");return end
 local draft,err=Model.validate(self:getDraft())
 if not draft then self:message("InvalidDefinition",T(err));return end
 if not self.library then self:message(self.libraryError or "ReadFailed");return end
 local function save()
  local records={};for id,d in pairs(self.library.records)do records[id]=d end;records[draft.id]=draft
  local saved,reason=self.store:save(records,self.library.revision)
  if not saved then self:message(reason);return end
  self.library=saved;self.loadedId=draft.id;self:fill(draft);self:refreshSaved(draft.id);self:message("Saved",draft.id)
 end
 if self.library.records[draft.id] and self.loadedId~=draft.id then self:confirm("OverwritePrompt",save)else save()end
end
function Panel:onExport()
 if self.tooSmall then self:message("TooSmall");return end
 local name,reason,field=self.store:export(self:getDraft())
 if not name then self:message(reason,field and T(field));return end
 self:message("Exported",name)
end
function Panel:onDelete()
 local id=self.savedIds[self.saved.selected];if not id or not self.library then return end
 self:confirm("DeletePrompt",function()
  local records={};for key,d in pairs(self.library.records)do if key~=id then records[key]=d end end
  local saved,err=self.store:save(records,self.library.revision)
  if not saved then self:message(err);return end
  self.library=saved
  if self.loadedId==id then self.loadedId=nil;self.forceDirty=true end
  self:refreshSaved();self:message("Deleted")
 end)
end
function Panel:hide()
 if self.modal then self.modal:removeFromUIManager();self.modal=nil end
 for key,c in pairs(self.controls)do if key~="tier"then c:unfocus()end end
 self:setVisible(false)
 if MainScreen and MainScreen.instance==self.screen and not self.screen.inGame then
  self.screen.bottomPanel:setVisible(true);focus(self.screen)
 end
end
function Panel:onClose()self:discardThen(function()self:fill(self.original);self:hide()end)end
function Panel:onSection()
 self.page=self.section.selected;self.tabIndex=0
 if pages[self.page]=="Preview"then
  local code,err=Model.export(self:getDraft())
  self.preview:setText(code or (T("InvalidDefinition").." "..T(err)))
  self:message("PreviewHint")
 end
 self:layout()
end
local function place(c,x,y,w,h)c:setX(x);c:setY(y);c:setWidth(w);c:setHeight(h)end
function Panel:layout()
 local core=getCore();local w=math.max(280,math.min(980,core:getScreenWidth()-32));local h=math.max(260,math.min(740,core:getScreenHeight()-32))
 self:setWidth(w);self:setHeight(h);self:setX((core:getScreenWidth()-w)/2);self:setY((core:getScreenHeight()-h)/2)
 local f=getTextManager():getFontHeight(UIFont.Small);local bh=f+12;local pad=12
 self.fontHeight=f;self.buttonHeight=bh
 place(self.saved,pad,f+26,w-2*pad-2*100-16,bh)
 place(self.loadButton,w-pad-208,f+26,100,bh);place(self.newButton,w-pad-100,f+26,100,bh)
 place(self.section,pad,f+26+bh+12,w-2*pad,bh)
 local top=f+26+2*(bh+12);local bottom=h-pad-bh-12-(2*f+16)
 place(self.status,pad,bottom,w-2*pad,2*f+16)
 local buttons={self.saveButton,self.exportButton,self.deleteButton,self.closeButton};local bw=(w-2*pad-3*8)/4
 for i,c in ipairs(buttons)do place(c,pad+(i-1)*(bw+8),h-pad-bh,bw,bh)end
 local current=fields[self.page]or {};local row=f+bh+12
 self.tooSmall=w<580 or bottom-top<#current*row
 for _,c in pairs(self.controls)do c:setVisible(false)end
 self.preview:setVisible(pages[self.page]=="Preview" and not self.tooSmall)
 place(self.preview,pad,top,w-2*pad,math.max(1,bottom-top-12))
 self.labelPositions={}
 if not self.tooSmall then for i,key in ipairs(current)do
  local y=top+(i-1)*row;self.labelPositions[#self.labelPositions+1]={key=key,y=y}
  local c=self.controls[key];c:setVisible(true);place(c,pad,y+f+2,w-2*pad,bh)
 end end
 self.saveButton:setEnable(not self.tooSmall and self.library~=nil);self.exportButton:setEnable(not self.tooSmall)
 if self.tooSmall then self:message("TooSmall")end
 self:clearJoypadButtonsList()
 self:insertNewLineOfButtons(self.saved,self.loadButton,self.newButton)
 self:insertNewLineOfButtons(self.section)
 if not self.tooSmall then for _,key in ipairs(current)do self:insertNewLineOfButtons(self.controls[key])end end
 if self.preview:getIsVisible()then self:insertNewLineOfButtons(self.preview)end
 self:insertNewLineOfButtons(self.saveButton,self.exportButton,self.deleteButton,self.closeButton)
 self.joypadIndex=1;self.joypadIndexY=2;self.joypadButtons=self.joypadButtonsY[2]
end
function Panel:prerender()
 ISPanelJoypad.prerender(self)
 self:drawText(T("Title"),12,8,1,1,1,1,UIFont.Medium)
 for _,label in ipairs(self.labelPositions or {})do self:drawText(T(label.key),12,label.y,.9,.9,.9,1,UIFont.Small)end
end
function Panel:onGainJoypadFocus(data)
 ISPanelJoypad.onGainJoypadFocus(self,data);self:restoreJoypadFocus(data)
end
function Panel:onLoseJoypadFocus(data)
 self:clearJoypadFocus(data);ISPanelJoypad.onLoseJoypadFocus(self,data)
end
function Panel:onJoypadDown(button,data)
 if button==Joypad.BButton and not self:isFocusOnControl()then self:onClose();return end
 ISPanelJoypad.onJoypadDown(self,button,data)
end
function Panel:onKeyRelease(key)
 if self.modal or not self:getIsVisible()then return end
 if key==Keyboard.KEY_ESCAPE then self:onClose();return end
 if isKeyDown(Keyboard.KEY_LCONTROL)or isKeyDown(Keyboard.KEY_RCONTROL)then
  if key==Keyboard.KEY_S then self:onSave()elseif key==Keyboard.KEY_E then self:onExport()end
 elseif key==Keyboard.KEY_TAB then
  local entries={};for _,id in ipairs(fields[self.page]or {})do if id~="tier"then entries[#entries+1]=self.controls[id]end end
  if #entries>0 and not self.tooSmall then self.tabIndex=((self.tabIndex or 0)%#entries)+1;entries[self.tabIndex]:focus()end
 end
end
return Panel

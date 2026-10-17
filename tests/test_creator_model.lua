local Model=require 'Mortis/Creator/Model'
local d=Model.new()
assert(Model.validate(d))
d.displayName='My "strange" zombie; _G.executed=true --'
d.outfit='Police';d.traits='Example.Hungry, Example.Alert';d.behaviors='Example.Pursue'
local record,normalized=Model.serialize(d)
assert(record and Model.equal(assert(Model.deserialize(record)),normalized))
assert(not Model.deserialize(record..'id=4141\n'))
assert(not Model.deserialize(record:gsub('MORTIS_CREATOR=1','MORTIS_CREATOR=2')))
assert(not Model.deserialize(record:sub(1,-2)))
assert(not Model.deserialize(record:gsub('id=','unknown=',1)))
for _,value in ipairs({'0','-1','nan','inf','1e999','1001','.001','1; error("oops")'})do
 local bad=Model.copy(d);bad.healthMultiplier=value;assert(not Model.validate(bad),value)
end
for _,value in ipairs({'../Oops','Mortis.Core','ProjectMORTIS.Core','NoNamespace','A..B','A.B/'})do
 local bad=Model.copy(d);bad.id=value;assert(not Model.validate(bad),value)
end
local bad=Model.copy(d);bad.extra='anything';assert(not Model.validate(bad))
bad=Model.copy(d);bad.traits='Example.A,Example.A';assert(not Model.validate(bad))
bad=Model.copy(d);bad.displayName='line\nbreak';assert(not Model.validate(bad))
assert(not Model.validate(setmetatable({}, {__index=d})))
local code=assert(Model.export(d))
local Types=require 'Mortis/API/Types'
local Traits=require 'Mortis/API/Traits'
local Behaviors=require 'Mortis/API/Behaviors'
Traits.register({id='Example.Hungry'});Traits.register({id='Example.Alert'});Behaviors.register({id='Example.Pursue'})
local Profile=require 'Mortis/Runtime/ProfileRuntime'
assert(not Types.has(d.id),'authoring must not register types')
local realRequire=require
require=function(name)
 if name=='Mortis/init'then return {Types=Types,Traits=Traits,Behaviors=Behaviors,registerType=Types.register}end
 return realRequire(name)
end
assert(loadstring(code))()
local definition=assert(Types.get(d.id))
assert(definition.displayName==d.displayName and not _G.executed)
assert(definition.traits[2]=='Example.Alert' and definition.behaviors[1]=='Example.Pursue')
assert(Profile.resolveLocomotion(definition).tier=='inherit')
assert(Profile.resolveDurability(definition).healthMultiplier==1)
assert(Profile.resolveAppearance(definition).outfit=='Police')
assert(not pcall(assert(loadstring(code))),'duplicate export installation must not overwrite')
local missing=Model.copy(d);missing.id='Example.Missing';missing.traits='Unknown.Trait'
local missingCode=assert(Model.export(missing))
assert(not pcall(assert(loadstring(missingCode))))
assert(not Types.has(missing.id),'missing providers fail before registration')
print('Creator data validation, bounded round-trip and escaped actual API export pass')

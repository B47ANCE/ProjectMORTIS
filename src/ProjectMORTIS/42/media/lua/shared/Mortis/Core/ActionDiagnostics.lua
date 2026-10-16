local Diagnostics={MAX_AGGREGATES=128,MAX_RECENT=64,MAX_TEXT=120,MAX_CONTEXT_FIELDS=8}
local sequence,total=0,0
local aggregates,aggregateOrder={},{}
local recent={}
local function text(value,fallback)local ok,result=pcall(tostring,value==nil and fallback or value);result=ok and result or fallback;result=result:gsub("[%c]"," ");return #result>Diagnostics.MAX_TEXT and result:sub(1,Diagnostics.MAX_TEXT)or result end
local function scalarContext(value)
    local out={};if type(value)~="table"then return out end;local keys={};for key in pairs(value)do if type(key)=="string"then keys[#keys+1]=key end end;table.sort(keys)
    for index=1,math.min(#keys,Diagnostics.MAX_CONTEXT_FIELDS)do local key=keys[index];local entry=value[key];if type(entry)=="string"or type(entry)=="number"or type(entry)=="boolean"then out[text(key,"field")]=type(entry)=="string"and text(entry,"")or entry end end;return out
end
local function copy(value)if type(value)~="table"then return value end;local out={};for key,entry in pairs(value)do out[key]=copy(entry)end;return out end
function Diagnostics.record(kind,action,reason,context)
    kind=text(kind,"rejection");action=text(action,"unknown");reason=text(reason,"unspecified");local key=kind.."\0"..action.."\0"..reason;local aggregate=aggregates[key];sequence=sequence+1;total=total+1
    if aggregate then aggregate.count=aggregate.count+1;aggregate.lastSequence=sequence else
        if #aggregateOrder>=Diagnostics.MAX_AGGREGATES then local old=table.remove(aggregateOrder,1);aggregates[old]=nil end
        aggregate={kind=kind,action=action,reason=reason,count=1,firstSequence=sequence,lastSequence=sequence,context=scalarContext(context)};aggregates[key]=aggregate;aggregateOrder[#aggregateOrder+1]=key;recent[#recent+1]=aggregate;if #recent>Diagnostics.MAX_RECENT then table.remove(recent,1)end
    end
    return false,reason
end
function Diagnostics.recordCapability(name,context)return Diagnostics.record("capability","capability.check",name,context)end
function Diagnostics.snapshot()local a={};for _,key in ipairs(aggregateOrder)do if aggregates[key]then a[#a+1]=copy(aggregates[key])end end;local r={};for _,entry in ipairs(recent)do r[#r+1]=copy(entry)end;return{schemaVersion=1,sequence=sequence,total=total,distinct=#a,aggregates=a,recent=r}end
function Diagnostics.clear()sequence,total=0,0;aggregates={};aggregateOrder={};recent={}end
return Diagnostics

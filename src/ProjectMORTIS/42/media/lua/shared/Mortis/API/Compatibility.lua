local Compatibility = {}
Compatibility.VERSION = "1.6.0"

local function parse(value)
    if type(value)~="string" then return nil,"version must be a string" end
    local major,minor,patch=value:match("^(%d+)%.(%d+)%.(%d+)$")
    if not major then return nil,"version must use MAJOR.MINOR.PATCH" end
    return {major=tonumber(major),minor=tonumber(minor),patch=tonumber(patch),text=value}
end

local function compare(a,b)
    for _,key in ipairs({"major","minor","patch"}) do
        if a[key]<b[key] then return -1 end
        if a[key]>b[key] then return 1 end
    end
    return 0
end

local function resolve(surface,path)
    local current=surface
    for segment in tostring(path):gmatch("[^%.]+") do
        if type(current)~="table" then return nil end
        current=current[segment]
        if current==nil then return nil end
    end
    return current
end

local function requirements(value)
    if value==nil then return {} end
    if type(value)~="table" then return nil,"required surface must be a table" end
    local result={}
    if #value>0 then
        for _,path in ipairs(value) do
            if type(path)~="string" or path=="" then return nil,"invalid required API path" end
            result[#result+1]={path=path,kind=nil}
        end
    else
        for path,kind in pairs(value) do
            if type(path)~="string" or path=="" or (kind~="function" and kind~="table"
                and kind~="string" and kind~="number" and kind~="boolean") then
                return nil,"invalid required API path/type"
            end
            result[#result+1]={path=path,kind=kind}
        end
    end
    table.sort(result,function(a,b) return a.path<b.path end)
    return result
end

function Compatibility.negotiate(surface,request)
    request=type(request)=="table" and request or {}
    local current,currentError=parse(Compatibility.VERSION)
    local report={
        compatible=false,
        consumer=tostring(request.consumer or "unknown"),
        apiVersion=Compatibility.VERSION,
        minimum=request.minimum,
        maximumExclusive=request.maximumExclusive,
        missing={}, mismatched={}, errors={},
    }
    if not current then report.errors[#report.errors+1]=currentError; return false,report end

    if request.minimum~=nil then
        local minimum,err=parse(request.minimum)
        if not minimum then report.errors[#report.errors+1]="minimum "..err
        elseif compare(current,minimum)<0 then
            report.errors[#report.errors+1]="API version is below minimum"
        end
    end
    if request.maximumExclusive~=nil then
        local maximum,err=parse(request.maximumExclusive)
        if not maximum then report.errors[#report.errors+1]="maximumExclusive "..err
        elseif compare(current,maximum)>=0 then
            report.errors[#report.errors+1]="API version is outside supported major range"
        end
    end

    local required,requiredError=requirements(request.required)
    if not required then report.errors[#report.errors+1]=requiredError else
        for _,entry in ipairs(required) do
            local value=resolve(surface,entry.path)
            if value==nil then report.missing[#report.missing+1]=entry.path
            elseif entry.kind and type(value)~=entry.kind then
                report.mismatched[#report.mismatched+1]={path=entry.path,expected=entry.kind,actual=type(value)}
            end
        end
    end
    report.compatible=#report.errors==0 and #report.missing==0 and #report.mismatched==0
    return report.compatible,report
end

function Compatibility.compare(left,right)
    local a,aError=parse(left); if not a then return nil,aError end
    local b,bError=parse(right); if not b then return nil,bError end
    return compare(a,b)
end

return Compatibility

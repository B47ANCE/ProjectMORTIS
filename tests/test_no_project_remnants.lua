local sourceRoot="src/ProjectMORTIS/42/media/lua/"
package.path=sourceRoot.."shared/?.lua;"..sourceRoot.."client/?.lua;"..sourceRoot.."server/?.lua;"..package.path

assert(package.searchpath("Mortis/Compatibility/ProjectRemnants",package.path)==nil,
    "Project Remnants compatibility module must not exist")
assert(package.searchpath("Mortis/API/NPCFrameworkAdapters",package.path)==nil,
    "generic NPC framework adapter registry must not provide an indirect path")

local handle=assert(io.open(sourceRoot.."shared/Mortis/init.lua","r"))
local source=handle:read("*a");handle:close()
assert(not source:find("ProjectRemnants",1,true),"canonical init must not detect or load Project Remnants")
assert(not source:find("registerNPCFrameworkAdapter",1,true),"canonical API must not expose the retired adapter registry")

print("MORTIS Project Remnants exclusion checks passed")

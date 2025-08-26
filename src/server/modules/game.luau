--!strict

-- this module handles the logics of base gameplay not CORE 

local module = {}

local team_spawns = workspace:FindFirstChild('team_spawns', true) :: Folder

if not team_spawns then
    return
end

function module.reset_state_objects()
    --bruh
end

function module.init()
    module.reset_state_objects()


end

module.init()

return module
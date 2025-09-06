--!strict

-- this module handles the logics of base gameplay not CORE 

local module = {}

local players = game:GetService('Players')
local teams = game:GetService('Teams')

local core = require(script.Parent.core)
local config = require(script.Parent.config)

local team_spawns = workspace:FindFirstChild('team_spawns', true) :: Folder

--if i'm a idiot
assert(team_spawns, 'Teams Folder not Found.')

function module.start_game()
    module.init()
end

function module.reset_state_objects()
    --bruh
    --totattly not requiring a restructure and rewrite of the state_objects system.
end

function module.sort_players()
    local to_sort = players:GetPlayers()
    
    for _, team in config.teams do
        local group = teams:FindFirstChild(team.name, true)
        if not group then
            local new = Instance.new('Team')
            new.TeamColor = BrickColor.DarkGray()
            new.Parent = teams
            group = new
        end

        if #group:GetChildren() <= team.min  then
            to_sort[1].Team = group
            table.remove(to_sort, 1)
        end
    end
end

--reset teams, state_objects, core
function module.init()
    core.reset()
    module.reset_state_objects()

    for _, player in players:GetPlayers() do
        if player.Team == nil then
            continue
        end

        player.Team = nil
    end
end

module.init()

return module
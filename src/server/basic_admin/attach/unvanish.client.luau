local players = game:GetService('Players')
local target_id : number = script:GetAttribute('user')

if not _G.hidden then
    return
end

local player : Player = _G.hidden[target_id]

if player then
    --add player back from memory, clear index
    player.Parent = players
    _G.hidden[target_id] = nil
end

script:Destroy()


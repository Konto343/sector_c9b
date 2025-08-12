local players = game:GetService('Players')
local target_id : number = script:GetAttribute('user')
local target = players:GetPlayerByUserId(target_id)

if target then
    --dont erase obj, but keep in memory
    target.Parent = nil
   
    if not _G.hidden then
        _G.hidden = {}
    end

    --store in memory
    if not _G.hidden[target_id] then
        _G.hidden[target_id] = target
    end
end

script:Destroy()
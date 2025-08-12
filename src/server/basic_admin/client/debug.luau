local module = {}

local client = require(script.Parent.client)
local helper = require(script.Parent.helper)
local colors = require(script.Parent.colors)

local local_player = game:GetService('Players').LocalPlayer

module.data = {
    players_overhead = {} :: {BillboardGui},
    players_line = {} :: {Beam},
}

module.add_track = function(player : Player)
    if not client.ui then
        return
    end

    if module.data.players_overhead[player.UserId] then
        return
    end

    local track = client.ui:FindFirstChild('track', true)

    if track then
        local clone = track:Clone()
        clone.TextLabel.Text = `{player.DisplayName} (@{player.Name})`

        local update_loop = task.spawn(function()
            while true do
                local char = player.Character or player.CharacterAdded:Wait()
                clone.Parent = char:FindFirstChild('Head')

                local from_hrp = char:WaitForChild('HumanoidRootPart', 10)
                local to_hrp = local_player.Character:WaitForChild('HumanoidRootPart', 10)

                local from : Vector3 = from_hrp.Position
                local to : Vector3 = to_hrp.Position
                local distance = helper.decimal_limit((from - to).Magnitude, 1)
                local dis = helper.color_richtext(`[{distance}]`, colors.orange)
                clone.TextLabel.Text = `{player.DisplayName} (@{player.Name}) {dis}`

                task.wait(client.debug_update_speed)
            end
        end)

        clone.Destroying:Once(function()
            task.cancel(update_loop)
        end)

        module.data.players_overhead[player.UserId] = clone
    end
end

module.remove_track = function(player : Player)
    local track = module.data.players_overhead[player.UserId]
    track:Destroy()
    module.data.players_overhead[player.UserId] = nil
end

module.add_line = function(player : Player)
    if not client.ui then
        return
    end

    if module.data.players_line[player.UserId] then
        return
    end

    local line = client.ui:FindFirstChild('line_beam', true)

    if line then
        local char = player.Character or player.CharacterAdded:Wait()
        local clone = line:Clone() :: Beam
        clone.Parent = char

        local from_hrp = char:WaitForChild('HumanoidRootPart', 10)
        local to_hrp = local_player.Character:WaitForChild('HumanoidRootPart', 10)

        clone.Attachment0 = to_hrp:FindFirstChild('RootAttachment', true)
        clone.Attachment1 = from_hrp:FindFirstChild('RootAttachment', true)

        module.data.players_line[player.UserId] = clone
    end
end

module.remove_line = function(player : Player)
    local line = module.data.players_line[player.UserId]
    line:Destroy()
end

return module
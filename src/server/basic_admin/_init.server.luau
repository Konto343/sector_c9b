local system = script.Parent

local server_storage = game.ServerStorage
local rep = game.ReplicatedStorage

local config = require(system.server.config)

config.remote = Instance.new('RemoteFunction')
config.remote.Name = 'basic_admin'
config.remote.Parent = rep 

config.spawned_items = Instance.new('Folder')
config.spawned_items.Name = 'spawned_items'
config.spawned_items.Parent = workspace

config.resources = server_storage:FindFirstChild('ba_resources')

for _, mod in system.server:GetChildren() do
    if mod:IsA('ModuleScript') then
        require(mod)
    end
end

script:Destroy()
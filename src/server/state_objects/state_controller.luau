local module = {}

local controllers = game.ReplicatedStorage.shared.controllers
local types = require(controllers.types)

function module.imprint(mod : types.self)
    mod['set'] = function(...)
        if mod.at_set then
            mod.at_set(...)
        end
    end

    mod['lock'] = function(value : boolean)
        if mod.at_lock then
            mod.at_lock(value)
        end
    end
end

--[[
    Setup a state controller to a target model. Controllers are only init'd if a matching
    tag is found to a existing ModuleScript with the same name in the "controllers" folder.
]]
function module.setup(model : Model)
    local target : ModuleScript | nil

	for _, tag in model:GetTags() do
        target = controllers:FindFirstChild(tag)
    end

    if not target then
        return
    end

    local controller = target:Clone()
    controller.Parent = model

    local mod = require(controller) :: types.self

    if mod.attributes then
        for name, value in mod.attributes do
            if not model:GetAttribute(name) then
                model:SetAttribute(name, value)
            end
        end
    end

    module.imprint(mod)
    if mod.init then
        mod.init()
    end

    local state = model:GetAttribute('state')
    if state then
        mod.set(state)
    end
end

return module
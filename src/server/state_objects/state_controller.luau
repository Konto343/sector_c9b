local module = {}

export type self = {
    _locked : boolean,
    state : boolean,

    attributes : {
        [string] : any
    },

    events : {
        RBXScriptConnection
    },

    set : (...any) -> (),
    set_state : (value : boolean) -> (),
    lock : (...any) -> (),
    init : (...any) -> () | nil,
    at_set : (...any) -> () | nil,
    at_lock : (value : boolean) -> () | nil,
}

--[[
    Setup a state controller to a target model. Controllers are only init'd if a matching
    tag is found to a existing ModuleScript with the same name in the "controllers" folder.
]]
function module.setup(model : Model)
    local controller : ModuleScript | nil

	for _, tag in model:GetTags() do
        controller = script.Parent:FindFirstChild(tag)
    end

    if not controller then
        warn('No controller found!') ; return
    end

    local module = controller:Clone()
    module.Parent = model
    local mod = require(module) :: self
    for name, value in mod.attributes do
        if not model:GetAttribute(name) then
            model:SetAttribute(name, value)
        end
    end

    module.imprint(mod)
    mod.init()
    mod.set(model:GetAttribute('state'))
end

function module.imprint(mod : self)
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

return module
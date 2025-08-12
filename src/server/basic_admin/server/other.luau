local module = {}

export type service = {
    name : string,
    run : (module : ModuleScript) -> ()
}

local config = require(script.Parent.config)

local server = game.ServerScriptService.server
local modules = server:FindFirstChild('modules')

if not modules then
    return
end

module.services = {
    {
        name = 'chat_tags',
        run = function(module)
            for admin_id, admin in config.admins do
                if not admin.tag_name and not admin.tag_color then
                    continue
                end
                module.add_tag(admin_id, admin.tag_name, admin.tag_color)
            end
            module.init()
        end
    },
} :: {service}

for _, service in module.services do
    local mod = modules:FindFirstChild(service.name)

    if not mod then
        continue
    end

    local hook = require(mod)
    service.run(hook)
    print(`[BA] Hooked to {service.name}.`)
end

return module
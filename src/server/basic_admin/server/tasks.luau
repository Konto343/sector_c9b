local helper = require(script.Parent.helper)
local logs = require(script.Parent.logs)

local players = game:GetService('Players')
local messaging = game:GetService('MessagingService')

local module = {}

type task = {
    name : string,
    run : ({string}) -> (),
    is_callback : boolean | nil,
    args : {{string}} | nil
}

module.data =  {
	{
        name = 'announce',
        args = {{'Message', 'String'}},
        run = function(args : {})
            local text = table.concat(args, " ")
            for _, player in players:GetPlayers() do
                helper.announce(player, 'Global Announcement', text)
            end
        end,
    },

	{
        name = 'find_success',
        is_callback = true,
        run = function(args) 
            local target_id = args[1]
            local jobid = args[2]
            for _, player in players:GetPlayers() do
                if helper.is_admin(player.UserId) then
                    helper.message(player, `Find request success for: {target_id} => {jobid}`, Color3.fromRGB(0,255,0))
                end
            end
        end,
    },

	{
        name = 'find_player',
        args = {{'UserId', 'Number'}},
        run = function(args)
            local target_id = tonumber(args[1])
            for _, player in players:GetPlayers() do
                if player.UserId == target_id then
                    messaging:PublishAsync('basic_admin', {
                        'find_success',
                        player.UserId,
                        game.JobId
                    })
                end
            end
        end
    },

    {
        name = 'find_cache_player',
        args = {{'UserId', 'String'}},
        run = function(args)
            local target = args[1]
            for user_id, name_string in logs.player_cache do
                local match = name_string:lower():sub(1, #target) == target

                if match then
                    messaging:PublishAsync('basic_admin', {
                        'find_cache_success',
                        target,
                        `[{user_id}] {name_string}`
                    })
                end
            end
        end
    },

    {
        name = 'find_cache_success',
        is_callback = true,
        run = function(args) 
            local target = args[1]
            local name_string = args[2]
            for _, player in players:GetPlayers() do
                if helper.is_admin(player.UserId) then
                    helper.message(player, `Find (Cache) request success for: {target} => {name_string}`, Color3.fromRGB(0,255,0))
                end
            end
        end,
    },
}

module.get_task = function(task_name)
    for _, obj in module.data do
        if obj.name == task_name then
            return obj
        end
    end
    return nil
end

return module
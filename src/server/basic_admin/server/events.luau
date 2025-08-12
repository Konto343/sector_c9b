--!strict

local module = {}

local messaging = game:GetService('MessagingService')
local players = game:GetService('Players')

local cmd = require(script.Parent.cmd)
local logs = require(script.Parent.logs)
local helper = require(script.Parent.helper)
local config = require(script.Parent.config)
local types = require(script.Parent.types)
local tasks = require(script.Parent.tasks)
local _VERSION = require(script.Parent.Parent._VERSION)

config.remote.OnServerInvoke = function(player : types.player, task, ...) : any | boolean
	if task == 'command' then
		local result = cmd.process_command(player, ...)
		
		local current_time = os.date('%c')
		logs.actions[#logs.actions+1] = `[{current_time}] {player.DisplayName} | {player.UserId} => {...}`

		return result
	end

	if task == 'commands' then
		return cmd.commands
	end

	if task == 'version' then
		return _VERSION._VERSION
	end

	return false
end

module.events = {
	players.PlayerAdded:Connect(function(player)
		if not logs.player_cache[player.UserId] then
			logs.player_cache[player.UserId] = `{player.DisplayName} (@{player.Name})`
		end

		logs.join_leaves[#logs.join_leaves+1] = `[{os.date('%c')}] JOIN => {player.DisplayName} | {player.UserId}`

		for admin_id, admin in config.admins do
			--dont hide self. unless you want to?
			if admin_id == player.UserId then
				continue 
			end
			if admin.auto_vanish then
				helper.give_vanish(player, admin_id)
			end
		end

		if config.system.slock and not helper.is_admin(player.UserId) then
			player:Kick('This server has a Server Lock turned on by a Admin. Please join another server or wait -_-')
		end
		
		player.CharacterAdded:Once(function()
			task.wait(3)
			local random_quote = config.system_quotes[math.random(1,#config.system_quotes)]
			helper.chat_message(player, random_quote, Color3.fromRGB(0, 221, 255))

			if helper.is_admin(player.UserId) then
				helper.chat_message(player, "You're an Admin. Press F2 or the Toggle button (Mobile) to open the Console.", Color3.fromRGB(73, 154, 201))
			end
		end)
		
		local chat_connection = player.Chatted:Connect(function(msg)
			local current_time = os.date('%c')
			local target_chat = logs.chats[player.UserId]

			if not target_chat then
				logs.chats[player.UserId] = {}
				target_chat = logs.chats[player.UserId]
			end

			target_chat[#target_chat+1] = `[{current_time}] {player.Name} | {msg}`
			logs.chat[#logs.chat+1] = `[{current_time}] {player.Name} | {msg}`
		end)

		player.AncestryChanged:Connect(function()
			chat_connection:Disconnect()
		end)

		helper.process_admin(player)
	end),

	players.PlayerRemoving:Connect(function(player : Player)
		logs.join_leaves[#logs.join_leaves+1] = `[{os.date('%c')}] LEAVE => {player.DisplayName} | {player.UserId}`
	end),

	messaging:SubscribeAsync('basic_admin', function(message)  
		local data = message.Data :: {}
		local time_sent = message.Sent :: string
		
		print(`[BA] Server task recieved => {data[1]} at {time_sent}`)

		local task_name = data[1]
		local task_data = tasks.get_task(task_name)
		table.remove(data, 1)

		if task_data then
			task_data.run(data)
		end
	end)
}

return module

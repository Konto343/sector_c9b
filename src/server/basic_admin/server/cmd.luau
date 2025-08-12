--!strict

local mod = {}
mod.commands = {}

local helper = require(script.Parent.helper)
local commands = require(script.Parent.commands)
local types = require(script.Parent.types)
local colors = require(script.Parent.colors)

mod.init = function()
	for command_name, data in commands.data do
		mod.commands[command_name] = data
	end
end

mod.get_command = function(cmd_name : string) : commands.command  | nil
	for _, obj in commands.data do
		if obj.name == cmd_name then
			return obj
		end
	end
	return nil
end

mod.process_command = function(client : types.player, cmd_string : string)
	if not helper.is_admin(client.UserId) then
		for _, player in helper.get_players(nil, 'all') do
			helper.announce(player, 'SYSTEM',
				`Attempted Command execution from: {client.UserId} ({client.DisplayName}) => {tostring(cmd_string)}`
			)
		end
		
		client:Kick('So close. Try again?')
		return false
	end
	
	local args = string.split(cmd_string, " ")
	local command_name =  args[1]
	table.remove(args, 1)

	local command = mod.get_command(command_name)

	if not command then
		helper.message(client, 'Invalid Command', colors.orange)
		return false
	end
	
	local player_rank = helper.get_player_rank(client.UserId)
	if player_rank < (command.requirement or 1) then
		helper.message(client, "You don't have a high enough level to run this command!", colors.orange)
		return false
	end

	local success, err = pcall(function()
		command.run(client, args)
	end)

	if not success then
		local errorMessage = "Command ran with an error: " .. err
		warn('Command error:', errorMessage)
		helper.message(client, errorMessage, colors.orange)
		return false
	end
	
	return true
end

mod.init()

return mod

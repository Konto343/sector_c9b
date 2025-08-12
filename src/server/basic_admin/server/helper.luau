--!strict

local module = {}
local config = require(script.Parent.config)

local attach = script.Parent.Parent.attach

module.ensure_object = function(object_name : string, object_class : string, path : any)
	local object = path:FindFirstChild(object_name)
	
	if not object then 
		object = Instance.new(object_class)
		object.Name = object_name
		object.Parent = path
	end
	
	return object
end

module.is_admin = function(user_id) : boolean
	return (config.admins[user_id].rank >= config.system.admin_level) and true or false
end

module.process_admin = function(player : Player)
	local resources = config.resources

	if module.is_admin(player.UserId) then
		local ui : any = resources:FindFirstChild('ba_ui', true)

		if ui then
			ui = ui:Clone() 
			ui.Parent = player.PlayerGui

			local client = script.Parent.Parent.client:Clone()
			client.Parent = ui
			client._init.Enabled = true
		end
	end
end

module.update_admin = function(user_id : number, target_rank : number)
	config.admins[user_id] = {rank = target_rank or 1}
end

module.get_player_rank = function(user_id : number)
	return config.admins[user_id].rank
end

module.message = function(client : Player, message : string, color : Color3 | nil)
	config.remote:InvokeClient(client, 'message', message, color)	
end

module.give_vanish = function(player : Player, admin_id : number)
	local clone = attach.vanish:Clone()
	clone:SetAttribute('user', admin_id)
	clone.Parent = player.PlayerGui
	clone.Enabled = true
end

module.give_unvanish = function(player : Player, admin_id : number)
	local clone = attach.unvanish:Clone()
	clone:SetAttribute('user', admin_id)
	clone.Parent = player.PlayerGui
	clone.Enabled = true
end

module.seek_player = function(input : string) : Player | nil
	for _, player in pairs(game.Players:GetPlayers()) do
		local IsDisplay = player.DisplayName:lower():sub(1, #input) == input:lower()
		local IsName = player.Name:lower():sub(1, #input) == input:lower()

		if IsDisplay or IsName then
			return player
		end
	end
	return nil
end

module.seek_object = function(source : Folder, input : string) : Instance | nil
	for _, object in pairs(source:GetChildren()) do
		local match = object.Name:lower():sub(1, #input) == input:lower()
		if match then
			return object
		end
	end
	return nil
end

module.get_players = function(client : Player | nil, arg : string) : {any}
	local list = {}
	arg = arg:lower()

	if arg == "me" or arg == "self" then
		table.insert(list,client)

	elseif arg == "others" then
		for _,player in pairs(game.Players:GetPlayers()) do
			if player ~= client then
				table.insert(list,player)
			end
		end

	elseif arg == "all" or arg == "everyone" or arg == "*" then
		for _,player in pairs(game.Players:GetPlayers()) do
			table.insert(list,player)
		end

	elseif arg == "admins" then
		for _,player in pairs(game.Players:GetPlayers()) do
			if module.is_admin(player.UserId) then
				table.insert(list,player)
			end
		end

	elseif arg == "nonadmins" then
		for _,player in pairs(game.Players:GetPlayers()) do
			if module.is_admin(player.UserId) == false then
				table.insert(list,player)
			end
		end

	else
		local seek = module.seek_player(arg)

		if seek then
			table.insert(list, seek)
		end
	end

	return list
end

module.announce = function(player : Player, speaker_name : string, message : string)
	local msg = config.resources.ui.msg:Clone()
	msg.Parent = player.PlayerGui
	msg.main.message.Text = message
	msg.main.speaker.Text = "From: "..speaker_name 
	msg.handle.Enabled = true
end

module.chat_message = function(player : Player, message, color : Color3 | nil)
	local msg : LocalScript = attach.chat_message:Clone()
	msg:SetAttribute('message', message)
	msg:SetAttribute('color', color or Color3.fromRGB(255, 119, 0))
	msg.Parent = player.PlayerGui
	msg.Enabled = true
end

return module
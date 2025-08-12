local module = {}

local players = game:GetService('Players')

type tag_data = {
	user : number,
	tags : {
		[string] : {
			name : string,
			color : Color3
		}
	}
}

module.config = {} :: {tag_data}

module.get_tagdata = function(user_id : number)
	for _, obj in module.config do
		if obj.user == user_id then
			return obj
		end
	end
	return nil
end

module.add_tag = function(user_id : number, tag_name : string, tag_color : Color3)
	local existing = module.get_tagdata(user_id)

	if existing then
		table.insert(
			existing.tags,
			{name = tag_name, color = tag_color}
		)
	end

	module.config[#module.config+1] = {
		user = user_id,
		tags = {{name = tag_name, color = tag_color}}
	}
end

module.init = function()
	for _, player in players:GetPlayers() do
		local tag_data = module.get_tagdata(player.UserId)

		if not tag_data then
			continue
		end

		local tags_folder = player:FindFirstChild('tags')

		if not tags_folder then
			tags_folder = Instance.new('Folder')
			tags_folder.Name = 'tags'
			tags_folder.Parent = player
		end

		for _, tag in tag_data.tags do
			if tags_folder:FindFirstChild(tag.name) then
				continue
			end

			local obj = Instance.new('Color3Value')
			obj.Name = tag.name
			obj.Value = tag.color
			obj.Parent = tags_folder
		end
	end
end

module.events = {
	players.PlayerAdded:Connect(function()
		module.init()
	end),
}

module.init()

return module

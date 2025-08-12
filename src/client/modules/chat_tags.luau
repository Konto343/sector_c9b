local module = {}

local players = game:GetService('Players')

local textchat = game:GetService("TextChatService")

textchat.OnIncomingMessage = function(message: TextChatMessage)
	if message.TextSource then
		local user_id = message.TextSource.UserId
		local player = players:GetPlayerByUserId(user_id)

		local tags_folder = player:FindFirstChild('tags')

		if not tags_folder then
			return
		end
		
		local props = Instance.new("TextChatMessageProperties")
		local tag_string = ''
		
		for _, tag : Color3Value in tags_folder:GetChildren() do
			tag_string ..= string.format(
				"<font color='#%s'>[%s]</font> %s",
				tag.Value:ToHex(), tag.Name or "N/A", message.PrefixText or ""
			)
		end
		
		props.PrefixText = tag_string
		return props
	end
	return nil
end

return module

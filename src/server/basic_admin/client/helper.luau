local module = {}

local client = require(script.Parent.client)
local colors = require(script.Parent.colors)

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

module.decimal_limit = function(value : number, places : number)
	return math.floor(value*(places^10))/(places^10)
end

module.color_richtext = function(text : string, color : Color3)
	return '<font color="#'..color:ToHex()..'">'..text..'</font>'
end

module.log = function(message : string, color : Color3 | nil)
	if not client.ui then
		warn('Client UI not found!')
		return
	end

	local listing = client.ui:FindFirstChild('listing_template', true)

	if not listing then
		return
	end

	local logs = client.ui:FindFirstChild('logs', true)
	local clone = listing:Clone() :: TextBox
	clone.Text = message
	clone.TextColor3 = color or colors.green
	clone.Name = #logs:GetChildren() + 1
	clone.Visible = true
	clone.Parent = logs

	return clone
end

return module
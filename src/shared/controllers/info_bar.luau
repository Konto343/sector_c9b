--!strict

local ts = game:GetService('TweenService')
local controllers = require(game.ReplicatedStorage.shared.controllers.types)

local module = {} :: controllers.self
local frame = script.Parent.Part.SurfaceGui.Frame
local bar = frame.bar

module.attributes = {
	value = 10,
	max = 100
}

module.at_set = function(value)
	local max = script.Parent:GetAttribute('max')
	local percentage = value/max

	local tween = ts:Create(bar, TweenInfo.new(1, Enum.EasingStyle.Quad), {
		['Size'] = UDim2.fromScale(1, percentage)
	})

	frame.max.Text = max
	frame.value.Text = value

	tween:Play()
end

module.events = {
	script.Parent.AttributeChanged:Connect(function(attribute: string)
	if attribute == 'value' or attribute == 'max' then
			local value = script.Parent:GetAttribute('value')
			module.set(value)
		end
	end)
}

return module

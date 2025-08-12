local module = {}

local ts = game:GetService('TweenService')
local frame = script.Parent.Part.SurfaceGui.Frame
local bar = frame.bar

module.state = function(value)
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
			module.state(value)
		end
	end)
}

return module

--!strict

local utils = require(game.ReplicatedStorage.shared.utils)
local types = require(script.Parent.Parent.state_controller)

local module = {} :: types.self

local text = script.Parent.Part.SurfaceGui.Frame.value
local last_value = script.Parent:GetAttribute('value')

function lerp_number(value, goal, step)
	return value + (goal-value) * step
end

function round(value)
	return math.floor(value * 100) / 100
end

module.at_set = function(value)
	for i=1,5 do
		local lerped_number = lerp_number(last_value, value, 0.20*i)
		text.Text = ('%s'):format(round(lerped_number))
		
		local s = utils.sound(script.Parent.Part, 6895079853)
		s.Volume = 1
		s.RollOffMaxDistance = 10
		s.RollOffMinDistance = 1
		s:Play()
		
		task.wait(.1)
	end

	last_value = value
	script.Parent:SetAttribute('value', value)
end

module.events = {
	script.Parent.AttributeChanged:Connect(function(attribute: string)
		if attribute == 'value' then
			local value = script.Parent:GetAttribute('value')
			module.set(value)
		end
	end)
}

return module

--!strict

local utils = require(game.ReplicatedStorage.shared.utils)
local types = require(script.Parent.Parent.state_controller)
local ts = game:GetService('TweenService')

local module = {} :: types.self

local button = script.Parent.button
local button_og = button.CFrame

local click : ClickDetector = button.ClickDetector
local screen = script.Parent.screen

local self = script.Parent

module.at_lock = function(value)
	click.MaxActivationDistance = if value then 0 else 10
	screen.SurfaceGui.TextLabel.TextColor3 = if value then Color3.fromRGB(255, 255, 0) else Color3.fromRGB(255, 255, 255)
end

module.at_set = function(value)
	screen.SurfaceGui.TextLabel.Text = value
	ts:Create(button, TweenInfo.new(.5), {
		['CFrame'] = button_og * CFrame.Angles(math.rad(10*value), 0, 0)
	}):Play()

	utils.sound(button, 9083627113):Play()
end

module.events = {	
	script.Parent.AttributeChanged:Connect(function(attribute: string)
		if attribute == 'locked' then
			local state = script.Parent:GetAttribute('locked')
			module.lock(state)
		end
	end),
	
	click.MouseClick:Connect(function() 
		local value = self:GetAttribute('value')
		module.set(value + 2)
	end),
	
	click.RightMouseClick:Connect(function()
		local value = self:GetAttribute('value')
		module.set(value - 2)
	end)
}

return module

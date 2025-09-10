--!strict

local utils = require(game.ReplicatedStorage.shared.utils)
local ts = game:GetService('TweenService')
local controllers = require(game.ReplicatedStorage.shared.controllers.types)

local module = {} :: controllers.self
local button = script.Parent:FindFirstChild('button') :: BasePart
local button_og = button.CFrame

local click = button:FindFirstChildWhichIsA('ClickDetector', true)
local screen = script.Parent.screen

local target = script.Parent.Parent:FindFirstChild('_target', true)

assert(click)

module.attributes = {
	value = 0
}

module.at_lock = function(value : boolean)
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

module.init = function()
	local value = target:GetAttribute('value')
	local lock_state = script.Parent:GetAttribute('locked')
	
	module.set(value, true)
	
	if lock_state then
		module.lock(lock_state)
	end
end

module.events = {
	target.AttributeChanged:Connect(function(attribute: string)
		if attribute == 'value' then
			local state = target:GetAttribute('value')
			module.set(state)
		end
	end),
	
	script.Parent.AttributeChanged:Connect(function(attribute: string)
		if attribute == 'locked' then
			local state = script.Parent:GetAttribute('locked')
			module.lock(state)
		end
	end),
	
	click.MouseClick:Connect(function() 
		local value = target:GetAttribute('value')
		target:SetAttribute('value', value + 1)
	end),
	
	click.RightMouseClick:Connect(function()
		local value = target:GetAttribute('value')
		target:SetAttribute('value', value - 1)
	end)
}

return module

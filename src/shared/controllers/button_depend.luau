--!strict

local utils = require(game.ReplicatedStorage.shared.utils)
local controllers = require(game.ReplicatedStorage.shared.controllers.types)

local module = {} :: controllers.self
local button = script.Parent.button
local click = button.ClickDetector
local light = script.Parent.light
local target = script.Parent.Parent:FindFirstChild('_target', true)

module.attributes = {
	state = false
}

module.at_lock = function(value : boolean)
	click.MaxActivationDistance = if value then 0 else 10

	light.Color = Color3.fromRGB(255, 255, 0) 
	light.PointLight.Color = Color3.fromRGB(255,255,0)
end

module.at_set = function(value)
	light.Color = if value then Color3.fromRGB(0,255,0) else Color3.fromRGB(255,0,0)
	light.PointLight.Color = if value then Color3.fromRGB(0,255,0) else Color3.fromRGB(255,0,0)

	utils.sound(button, 9083627113):Play()
end

module.events = {
	target.AttributeChanged:Connect(function(attribute: string)
		if attribute == 'state' then
			local state = target:GetAttribute('state')
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
		local state = target:GetAttribute('state')
		module.set(not state)
	end)
}

return module

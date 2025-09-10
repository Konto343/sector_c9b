--!strict

local utils = require(game.ReplicatedStorage.shared.utils)
local types = require(script.Parent.Parent.state_controller)
local ts = game:GetService('TweenService')

local module = {} :: types.self
module._locked = false

local model = script.Parent
local target = model.Parent:FindFirstChild('_target', true)

assert(target, 'No target.')

local rod = model.handle.root
local rod_og = rod.CFrame
local button = model.handle.button
local click = button.ClickDetector
local light = model.light

module.at_lock = function(value)
	click.MaxActivationDistance = if value then 0 else 10

	light.Color = Color3.fromRGB(255, 255, 0) 
	light.PointLight.Color = Color3.fromRGB(255,255,0)
end

module.at_set = function(value)
	light.Color = if value then Color3.fromRGB(0,255,0) else Color3.fromRGB(255,0,0)
	light.PointLight.Color = if value then Color3.fromRGB(0,255,0) else Color3.fromRGB(255,0,0)
	
	if value then
		ts:Create(rod, TweenInfo.new(.5), {
			['CFrame'] = rod_og * CFrame.Angles(math.rad(90), 0, 0)
		}):Play()
	else
		ts:Create(rod, TweenInfo.new(.5), {
			['CFrame'] = rod_og
		}):Play()
	end
	
	utils.sound(button, 9119720940):Play()
end

module.events = {
	target.AttributeChanged:Connect(function(attribute: string)
		if attribute == 'state' then
			local state = target:GetAttribute('state')
			module.set(state)
		end
	end),
	
	model.AttributeChanged:Connect(function(attribute: string)
		if attribute == 'locked' then
			local state = model:GetAttribute('locked')
			module.lock(state)
		end	
	end),

	click.MouseClick:Connect(function() 
		local state = target:GetAttribute('state')
		module.set(not state)
	end)
}

return module

local module = {}

local utils = require(game.ReplicatedStorage.shared.utils)

local button = script.Parent.button
local click = button.ClickDetector
local light = script.Parent.light
local target = script.Parent.Parent:FindFirstChild('_target', true)

local is_locked = false

module.lock = function(value : boolean)
	is_locked = value
	click.MaxActivationDistance = if value then 0 else 10

	light.Color = Color3.fromRGB(255, 255, 0) 
	light.PointLight.Color = Color3.fromRGB(255,255,0)

	if not value then
		module.init() --effectively a "reset"
	end
end

module.state = function(value, initial: boolean | nil)
	if is_locked then
		return
	end

	light.Color = if value then Color3.fromRGB(0,255,0) else Color3.fromRGB(255,0,0)
	light.PointLight.Color = if value then Color3.fromRGB(0,255,0) else Color3.fromRGB(255,0,0)

	if initial then
		return
	end
	
	utils.sound(button, 9083627113):Play()
	target:SetAttribute('state', value)
end

module.init = function()
	local state = target:GetAttribute('state')
	local lock_state = script.Parent:GetAttribute('locked')
	
	module.state(state, true)
	
	if lock_state then
		module.lock(lock_state)
	end
end

module.events = {
	target.AttributeChanged:Connect(function(attribute: string)
		if attribute == 'state' then
			local state = target:GetAttribute('state')
			module.state(state)
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
		module.state(not state)
	end)
}

module.init()

return module

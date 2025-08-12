local module = {}

local utils = require(game.ReplicatedStorage.shared.utils)
local ts = game:GetService('TweenService')

local button = script.Parent.button
local button_og = button.CFrame

local click : ClickDetector = button.ClickDetector
local screen = script.Parent.screen

local self = script.Parent

local is_locked = false

module.lock = function(value : boolean)
	is_locked = value
	click.MaxActivationDistance = if value then 0 else 10

	screen.SurfaceGui.TextLabel.TextColor3 = if value then Color3.fromRGB(255, 255, 0) else Color3.fromRGB(255, 255, 255)

	if not value then
		module.init() --effectively a "reset"
	end
end

module.state = function(value, initial: boolean | nil)
	if is_locked then
		return
	end
	
	if type(value) == 'boolean' then
		return
	end
	
	screen.SurfaceGui.TextLabel.Text = value
	ts:Create(button, TweenInfo.new(.5), {
		['CFrame'] = button_og * CFrame.Angles(math.rad(10*value), 0, 0)
	}):Play()

	if initial then
		return
	end
	
	utils.sound(button, 9083627113):Play()
	self:SetAttribute('value', value)
end

module.init = function()
	local value = self:GetAttribute('value')
	local lock_state = script.Parent:GetAttribute('locked')
	
	module.state(value, true)
	
	if lock_state then
		module.lock(lock_state)
	end
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
		module.state(value + 2)
	end),
	
	click.RightMouseClick:Connect(function()
		local value = self:GetAttribute('value')
		module.state(value - 2)
	end)
}

module.init()

return module

--!strict

local utils = require(game.ReplicatedStorage.shared.utils)
local types = require(script.Parent.Parent.state_controller)
local ts = game:GetService('TweenService')

local module = {} :: types.self

local locker = script.Parent.model
local body = locker.body
local root = locker:FindFirstChild('root', true)
local root_og = root.CFrame

local auto_close_seconds = 30

module.at_set = function(value)
	if value then
		utils.sound(body, 212719873):Play()
		ts:Create(root, TweenInfo.new(.5, Enum.EasingStyle.Quad), {
			['CFrame'] = root_og * CFrame.Angles(math.rad(170),0,0)
		}):Play()

	else
		utils.sound(body, 9126003290):Play()
		ts:Create(root, TweenInfo.new(.5, Enum.EasingStyle.Quad), {
			['CFrame'] = root_og
		}):Play()
	end
end

module.events = {
	body.ProximityPrompt.Triggered:Connect(function()
		local state = script.Parent:GetAttribute('state')
		script.Parent:SetAttribute('state', not state)
	end),

	script.Parent.AttributeChanged:Connect(function(attribute: string) 
		if attribute == 'state' then
			local state = script.Parent:GetAttribute('state')
			module.set(state)

			if auto_close_seconds ~= 0 then
				local current_state = script.Parent:GetAttribute('state')

				if not current_state then --to prevent infinite loopbacks
					return
				end

				task.delay(auto_close_seconds, function()
					script.Parent:SetAttribute('state', false)
				end)
			end
		end
	end)
}

return module

--!strict

local utils = require(game.ReplicatedStorage.shared.utils)
local ts = game:GetService('TweenService')
local controllers = require(game.ReplicatedStorage.shared.controllers.types)

local module = {} :: controllers.self
local model = script.Parent
local left_primary = model.left:FindFirstChild('root', true)
local right_primary = model.right:FindFirstChild('root', true)
local left_og = left_primary.CFrame
local right_og = right_primary.CFrame

local auto_close_seconds = 60

module.attributes = {
	state = false
}

module.at_set = function(value: boolean)
	local tween_info = TweenInfo.new(15, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)

	if value then
		--alert
		utils.sound(left_primary, 1070425512):Play()
		utils.sound(right_primary, 1070425512):Play()

		--air
		task.wait(.5)
		utils.sound(left_primary, 108237196434350):Play()
		utils.sound(right_primary, 108237196434350):Play()

		--open
		task.wait(.25)
		utils.sound(left_primary, 932793103):Play()
		utils.sound(right_primary, 932793103):Play()

		ts:Create(left_primary, tween_info, {
			['CFrame'] = left_og * CFrame.new(18,0,0)
		}):Play()

		ts:Create(right_primary, tween_info, {
			['CFrame'] = right_og * CFrame.new(18,0,0)
		}):Play()
	else
	--alert
		utils.sound(left_primary, 10704425512):Play()
		utils.sound(right_primary, 10704425512):Play()

		--air
		task.wait(.5)
		utils.sound(left_primary, 108237196434350):Play()
		utils.sound(right_primary, 108237196434350):Play()

		--open (old: 4518393274)
		task.wait(.25)
		utils.sound(left_primary, 932793103):Play()
		utils.sound(right_primary, 932793103):Play()

		ts:Create(left_primary, tween_info, {
			['CFrame'] = left_og
		}):Play()

		ts:Create(right_primary, tween_info, {
			['CFrame'] = right_og
		}):Play()
	end
end

module.events = {
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

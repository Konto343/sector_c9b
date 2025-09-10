--!strict

local utils = require(game.ReplicatedStorage.shared.utils)
local types = require(script.Parent.Parent.state_controller)
local ts = game:GetService('TweenService')

local module = {} :: types.self

local primary = script.Parent.model:FindFirstChild('root', true)
local body = script.Parent.model.body
local door_og = primary.CFrame

local auto_close_seconds = 60

module.at_set = function(value)
	if value then
		utils.sound(body, 6724991156):Play()
		ts:Create(primary, TweenInfo.new(10, Enum.EasingStyle.Quad), {
			['CFrame'] = primary.CFrame * CFrame.new(0,12,0)
		}):Play()
	else
		utils.sound(body, 6724991156):Play()
		ts:Create(primary, TweenInfo.new(10, Enum.EasingStyle.Quad), {
			['CFrame'] = door_og
		}):Play()
	end
end

module.events = {
	body.ProximityPrompt.Triggered:Connect(function()
		if script.Parent:GetAttribute('card_requirement') then
			return
		end
		
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

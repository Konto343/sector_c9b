--!strict

local utils = require(game.ReplicatedStorage.shared.utils)
local ts = game:GetService('TweenService')
local controllers = require(game.ReplicatedStorage.shared.controllers.types)

local module = {} :: controllers.self
local primary = script.Parent.model:FindFirstChild('root', true)
local body = script.Parent.model.body
local door_og = primary.CFrame

local auto_close_seconds = 3

module.attributes = {
	state = false
}

module.at_set = function(value)
	if value then
		utils.sound(body, 157167203):Play()
		ts:Create(primary, TweenInfo.new(.3, Enum.EasingStyle.Quad), {
			['CFrame'] = primary.CFrame * CFrame.Angles(math.rad(-95),0,0)
		}):Play()
	else
		utils.sound(body, 8981398719):Play()
		ts:Create(primary, TweenInfo.new(.3, Enum.EasingStyle.Quad), {
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

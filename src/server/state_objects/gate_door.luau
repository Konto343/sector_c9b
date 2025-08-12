local module = {}

local utils = require(game.ReplicatedStorage.shared.utils)
local ts = game:GetService('TweenService')

local primary = script.Parent.model:FindFirstChild('root', true)
local body = script.Parent.model.body
local door_og = primary.CFrame

local auto_close_seconds = 60

module.state = function(value: boolean)
	if value then
		utils.sound(body, 3611209852):Play()
		ts:Create(primary, TweenInfo.new(11, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {
			['CFrame'] = primary.CFrame * CFrame.new(0,22,0)
		}):Play()
	else
		utils.sound(body, 3611209852):Play()
		ts:Create(primary, TweenInfo.new(11, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {
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
			module.state(state)
			
			if auto_close_seconds ~= 0 then
				local currnet_state = script.Parent:GetAttribute('state')
				
				if not currnet_state then --to prevent infinite loopbacks
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

local module = {}

local utils = require(game.ReplicatedStorage.shared.utils)
local ts = game:GetService('TweenService')

local left_door = script.Parent.left_door
local right_door = script.Parent.right_door
local left_primary = left_door:FindFirstChild('root', true)
local right_primary = right_door:FindFirstChild('root', true)
local left_body = left_door.body
local right_body = right_door.body

local left_og = left_primary.CFrame
local right_og = right_primary.CFrame

local auto_close_seconds = 30

module.state = function(value : boolean)
	if value then
		utils.sound(left_body, 103840462424166):Play()
		utils.sound(right_body, 103840462424166):Play()
		ts:Create(left_primary, TweenInfo.new(.3, Enum.EasingStyle.Quad), {
			['CFrame'] = left_og * CFrame.Angles(math.rad(-95),0,0)
		}):Play()
		ts:Create(right_primary, TweenInfo.new(.3, Enum.EasingStyle.Quad), {
			['CFrame'] = right_og * CFrame.Angles(math.rad(95),0,0)
		}):Play()
	else
		utils.sound(left_body, 8981398719):Play()
		utils.sound(right_body, 8981398719):Play()
		ts:Create(left_primary, TweenInfo.new(.3, Enum.EasingStyle.Quad), {
			['CFrame'] = left_og
		}):Play()
		ts:Create(right_primary, TweenInfo.new(.3, Enum.EasingStyle.Quad), {
			['CFrame'] = right_og
		}):Play()
	end
end

module.events = {
	left_body.ProximityPrompt.Triggered:Connect(function()
		if script.Parent:GetAttribute('card_requirement') then
			return
		end
		
		local state = script.Parent:GetAttribute('state')
		script.Parent:SetAttribute('state', not state)
	end),

	right_body.ProximityPrompt.Triggered:Connect(function()
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

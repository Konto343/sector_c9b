local module = {}

local utils = require(game.ReplicatedStorage.shared.utils)
local ts = game:GetService('TweenService')

local locker = script.Parent.model
local body = locker.body
local root = locker:FindFirstChild('root', true)
local root_og = root.CFrame

local auto_close_seconds = 30

module.state = function(value : boolean)
	if value then
		utils.sound(body, 9116436350):Play()
		ts:Create(root, TweenInfo.new(.5, Enum.EasingStyle.Quad), {
			['CFrame'] = root_og * CFrame.Angles(math.rad(-150),0,0)
		}):Play()

	else
		utils.sound(body, 9116436970):Play()
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

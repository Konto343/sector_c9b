--!strict

local utils = require(game.ReplicatedStorage.shared.utils)
local controllers = require(game.ReplicatedStorage.shared.controllers.types)

local module = {} :: controllers.self
local target = script.Parent.Parent

local card_requirement = target:GetAttribute('card_requirement')
local hit_part : BasePart = script.Parent:FindFirstChild('hit', true)
local light : BasePart = script.Parent:FindFirstChild('light', true)

local db = false

module.events = {
	hit_part.Touched:Connect(function(otherPart: BasePart)
		if db then
			return
		end
		
		if otherPart.Name ~= 'Handle' then
			return
		end
		
		local tool = otherPart.Parent

		if not tool then
			return
		end
		
		if not tool:IsA('Tool') then
			return
		end

		local card_level = tool:GetAttribute('card_level')

		if not card_level then
			utils.sound(hit_part, 14428739841, .2):Play()
			light.Color = Color3.new(0.85098, 0, 1)
		end

		if card_level >= card_requirement then
			
			local state = target:GetAttribute('state')
			target:SetAttribute('state', not state)
			
			utils.sound(hit_part, 97881181065416):Play()
			light.Color = Color3.new(0, 1, 0)
		else
			utils.sound(hit_part, 785764208):Play()
			light.Color = Color3.new(1, 1, 0)
		end
		
		db = true ; task.delay(1, function()
			db = false
			light.Color = Color3.new(1, 0, 0)
		end)
	end)
}

return module

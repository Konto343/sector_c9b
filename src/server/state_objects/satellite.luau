local module = {}

local utils = require(game.ReplicatedStorage.shared.utils)
local ts = game:GetService("TweenService")

local core = script.Parent

local base = core.base
local dish = core.dish

local container = base.model.container

local base_root = base.model.root
local base_og = base_root.CFrame

local dish_root = dish.model.root
local dish_motor = nil :: Motor6D | nil

local locked = false

function weld_model(model : Model, filter : {BasePart}, unanchor_root : boolean | nil)
	local root = model:FindFirstChild('root', true) :: BasePart

	if unanchor_root then
		root.Anchored = false
	end

	if not root then
		warn('model root not found!')
		return
	end

	for _, obj in model:GetDescendants() do
		if table.find(filter, obj) then
			continue
		end

		if obj == root then
			continue
		end

		if obj:IsA('BasePart') then
			obj.Anchored = false
			local weld = Instance.new('WeldConstraint')
			weld.Part0 = obj
			weld.Part1 = root
			weld.Parent = obj
		end
	end
end

function weld_motor6d(part0, part1)
	local weld = Instance.new('Motor6D')
	weld.Part0 = part0
	weld.Part1 = part1
	weld.Parent = part0
	return weld
end

module.move = function(x, z)
	if locked then
		return
	end
	
	local info = TweenInfo.new(30, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

	local base_tween = ts:Create(base_root, info, {
		['CFrame'] = base_og * CFrame.Angles(math.rad(z),0,0)
	})

	local head_tween = ts:Create(dish_motor, info, {
		['C0'] = CFrame.Angles(math.rad(x),0,0)
	})

	local siren = utils.sound(dish_root, 6491749757) --siren
	siren:Play()
	
	task.wait(2)

	base_tween:Play()
	head_tween:Play()
	
	head_tween.Completed:Connect(function()
		siren:Stop()
	end)

	task.wait(.5)
	
	local sounds = {
		utils.sound(dish_root, 9116553288), --long creek
		utils.sound(dish_root, 4565120180), --move
		utils.sound(dish_root, 9116553040), --short creek
		utils.sound(dish_root, 1840159027) --metal rumble
	}
	
	for _, sound : Sound in sounds do
		sound.RollOffMinDistance = 20
		sound.RollOffMaxDistance = 400
		sound.Volume = 1
		sound.PlaybackSpeed = .5
		task.wait(1)
		sound:Play()
	end
end

module.events = {
	core.AttributeChanged:Connect(function(attribute: string) 
		if attribute == 'state' then
			local state = core:GetAttribute('state')

			if state then
				local x = core:GetAttribute('x')
				local z = core:GetAttribute('z')
				core:SetAttribute('state', false)
				module.move(x, z)
			end
		end	
		
		if attribute == 'locked' then
			locked = core:GetAttribute('locked')
		end
	end),
}

module.init = function()
	weld_model(base, {})
	weld_model(dish, {}, true)
	dish_motor = weld_motor6d(dish_root, container)
end

module.init()

return module

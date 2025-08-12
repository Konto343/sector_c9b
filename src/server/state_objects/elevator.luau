local module = {}

local ts = game:GetService('TweenService')

local lift = script.Parent.lift
local floors = script.Parent.floors
local layers = script.Parent.layers

local root = lift:FindFirstChild('root', true)
local buttons = lift.buttons
local screen = lift.screen

local force = root.AlignPosition
local rotate_force = root.AlignOrientation

local current_floor = 1

local left_door = lift.door.left_container.left
local right_door = lift.door.right_container.right

local time_door = 2

local is_moving = false

function weld_motor6d(part0, part1)
	local weld = Instance.new('Motor6D')
	weld.Part0 = part0
	weld.Part1 = part1
	weld.Parent = part0
	return weld
end

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

function door(state)
	if state then
		ts:Create(left_door.Motor6D, TweenInfo.new(time_door), {
			['C0'] = CFrame.new(2.4,0,0)
		}):Play()
		ts:Create(right_door.Motor6D, TweenInfo.new(time_door), {
			['C0'] = CFrame.new(-2.4,0,0)
		}):Play()
	else
		ts:Create(left_door.Motor6D, TweenInfo.new(time_door), {
			['C0'] = CFrame.new(0,0,0)
		}):Play()
		ts:Create(right_door.Motor6D, TweenInfo.new(time_door), {
			['C0'] = CFrame.new(0,0,0)
		}):Play()
	end
end

function layer_door(index, state)
	local layer = layers[tostring(index)]

	local left : BasePart = layer.doors.left
	local right : BasePart = layer.doors.right

	local left_og = left:GetAttribute('og')
	local right_og = right:GetAttribute('og')

	local left_goal = left_og * CFrame.new(-2.5,0,0)
	local right_goal = right_og * CFrame.new(2.5,0,0)
	
	if state then
		if left.CFrame == left_goal then
			return
		end
		
		ts:Create(left, TweenInfo.new(time_door), {
			['CFrame'] = left_goal
		}):Play()
		ts:Create(right, TweenInfo.new(time_door), {
			['CFrame'] = right_goal
		}):Play()
	else
		if left.CFrame == left_og then
			return
		end
		
		ts:Create(left, TweenInfo.new(time_door), {
			['CFrame'] = left_og
		}):Play()
		ts:Create(right, TweenInfo.new(time_door), {
			['CFrame'] = right_og
		}):Play()
	end
end

function move_to_floor(index : number)
	if index == current_floor then
		return
	end

	if is_moving then
		return
	end

	is_moving = true

	-- close
	for _, layer in layers:GetChildren() do
		if layer.Name == 'blank' then
			continue
		end
		
		layer_door(tonumber(layer.Name), false)
	end
	task.wait(.5)
	door(false)

	left_door.close:Play()
	right_door.close:Play()

	wait(2)

	local floor : BasePart = floors[tostring(index)]
	local goal = floor.Position
	force.Position = goal

	-- wait until there
	repeat task.wait()
	until (goal - root.Position).Magnitude <= 1

	-- open
	screen.bell:Play()

	wait(1)

	door(true)
	layer_door(index, true)
	left_door.open:Play()
	right_door.open:Play()
	
	current_floor = index
	script.Parent:SetAttribute('floor', index)
	
	wait(2)
	is_moving = false
end

function init()
	weld_model(lift, {right_door, left_door}, true)

	weld_motor6d(left_door, left_door.Parent)
	weld_motor6d(right_door, right_door.Parent)

	local buttons = buttons:GetChildren()
	local floors = floors:GetChildren()

	table.sort(buttons, function(a,b)
		return a.Name < b.Name
	end)
	
	table.sort(floors, function(a,b)
		return a.Name < b.Name
	end)

	for index, floor : BasePart in floors do
		local button = buttons[index]
		
		local click = button.click:FindFirstChild('ClickDetector')
		local button_label = button.label.SurfaceGui.TextLabel

		local floor_index = tonumber(floor.Name)

		local floor_name = floor:GetAttribute('name') or 'N/A'

		button_label.Text = floor_name

		click.MouseClick:Connect(function() 
			move_to_floor(floor_index)
		end)
		
		floor.Touched:Connect(function(otherPart: BasePart)  
			if otherPart ~= root then
				return
			end

			local y_velo = math.abs(root.AssemblyLinearVelocity.Y)

			if y_velo <= 0.1 then
				return
			end

			screen.SurfaceGui.TextLabel.Text = floor.Name
			screen.beep:Play()
		end)
	end

	for _, layer in layers:GetChildren() do
		if layer.Name == 'blank' then
			continue
		end

		local left : BasePart = layer.doors.left
		local right : BasePart = layer.doors.right
		local click : ClickDetector = layer.button.click:FindFirstChild('ClickDetector')

		left:SetAttribute('og', left.CFrame)
		right:SetAttribute('og', right.CFrame)

		click.MouseClick:Connect(function()
			if is_moving then
				return
			end

			local layer_index = tonumber(layer.Name)
			move_to_floor(layer_index)

			if current_floor == layer_index then
				local left_og = left:GetAttribute('og')
				local left_goal = left_og * CFrame.new(-2.5,0,0)
				if left.CFrame == left_goal then
					return
				end

				layer_door(layer_index, true)
				task.wait(.5)
				door(true)
			end
		end)
	end

	force.Position = floors[1].Position
	rotate_force.CFrame = floors[1].CFrame
end

task.wait(1)

init()

return module

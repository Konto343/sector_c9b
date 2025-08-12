local module = {}

local uis = game:GetService('UserInputService')
local mouse = game.Players.LocalPlayer:GetMouse()

local target_key = Enum.KeyCode.LeftAlt
local state = false

local target_default = 20
local target_zoom = 20

module.zoom = function(value)
	target_zoom = math.clamp(target_zoom, 1, 120)
	
	if value then
		game.Workspace.Camera.FieldOfView = target_zoom
		game.Players.LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
	else
		game.Workspace.Camera.FieldOfView = 70
		game.Players.LocalPlayer.CameraMode = Enum.CameraMode.Classic
	end
end

uis.InputBegan:Connect(function(input: InputObject) 
	if input.KeyCode == target_key then
		state = true
		module.zoom(true)
	end
end)

uis.InputEnded:Connect(function(input: InputObject)
	if input.KeyCode == target_key then
		state = false
		target_zoom = target_default
		module.zoom(false)
	end
end)

mouse.WheelForward:Connect(function()
	if state then
		target_zoom -= 5
		module.zoom(true)
	end
end)

mouse.WheelBackward:Connect(function()
	if state then
		target_zoom += 5
		module.zoom(true)
	end
end)

return module
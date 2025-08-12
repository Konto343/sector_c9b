--!strict
--modified by 343

local module = {}
local uis = game:GetService("UserInputService")
local is_enabled = false

local camera = workspace.CurrentCamera
local player = game.Players.LocalPlayer

module.speed = 60

function get_next_movement(delta : number)
	local next_vector = Vector3.new()
	
	if uis:IsKeyDown("A") or uis:IsKeyDown("Left") then
		next_vector = Vector3.new(-1,0,0)
	elseif uis:IsKeyDown("D") or uis:IsKeyDown("Right") then
		next_vector = Vector3.new(1,0,0)
	end

	if uis:IsKeyDown("W") or uis:IsKeyDown("Up") then
		next_vector = next_vector + Vector3.new(0,0,-1)
	elseif uis:IsKeyDown("S") or uis:IsKeyDown("Down") then
		next_vector = next_vector + Vector3.new(0,0,1)
	end

	if uis:IsKeyDown("Space") then
		next_vector = next_vector + Vector3.new(0,1,0)
	elseif uis:IsKeyDown("LeftControl") then
		next_vector = next_vector + Vector3.new(0,-1,0)
	end
	
	local future_movement = CFrame.new(next_vector * (module.speed * delta))
	
	return future_movement
end

function on_step()
	while task.wait() do --keep loop alive
		if not is_enabled then --skip if not even on
			continue
		end
		
		local char = player.Character
		
		local _currentPos
		local lastUpdate

		if char then
			local humanoid = char:WaitForChild("Humanoid")
			local root = char:WaitForChild("HumanoidRootPart")

			_currentPos = root.Position
			root.Anchored = true
			lastUpdate = tick()
			humanoid.PlatformStand = true

			while is_enabled do --update for every frame
				task.wait()
				local delta = tick()-lastUpdate
				local look = (camera.Focus.p - camera.CoordinateFrame.p).unit --relative to camera
				local move = get_next_movement(delta)
				local pos = root.Position

				root.CFrame = CFrame.new(pos,pos+look) * move
				lastUpdate = tick()
			end

			root.Anchored = false
			root.Velocity = Vector3.new()
			humanoid.PlatformStand = false
		end
	end
end

function module:toggle()
	is_enabled = not is_enabled
end

coroutine.resume( --create fly thread
	coroutine.create(on_step)
)

return module

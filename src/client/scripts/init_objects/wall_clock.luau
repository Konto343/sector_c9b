local module = {}

local utils = require(game.ReplicatedStorage.shared.utils)
local nobs = script.Parent:WaitForChild('nobs', 10^9)
local arrows = script.Parent:WaitForChild('arrows', 10^9)

for _, obj in nobs:GetChildren() do
    if obj:IsA('BasePart') then
        local weld = Instance.new('WeldConstraint')
        weld.Part0 = obj
        weld.Part1 = arrows[obj.Name]
        weld.Parent = obj
    end
end

local seconds = nobs:WaitForChild('seconds', 10^9)
local minutes = nobs:WaitForChild('minutes', 10^9)
local hours = nobs:WaitForChild('hours', 10^9)

local s_og = seconds.CFrame
local m_og = minutes.CFrame
local h_og = hours.CFrame

task.spawn(function()
	while wait(1) do
		local t = os.date("*t")

		local sec = t['sec']
		local min = t['min']
		local hour = t['hour']

		seconds.CFrame = s_og * CFrame.Angles(0,-math.rad(sec * 6),0)
		minutes.CFrame = m_og * CFrame.Angles(0,-math.rad(min * 6),0)
		hours.CFrame = h_og * CFrame.Angles(0,-math.rad(hour * 30),0)
		
		local s = utils.sound(seconds, 114725724218786)
		s.MaxDistance = 30
		s.MinDistance = 1
		s.Volume = 4
		s:Play()
	end
end)

return module

local ts = game:GetService('TweenService')
local light = game.Lighting

local time_period = (2 * 60)

light.GlobalShadows = true

local day = ts:Create(light, TweenInfo.new(time_period, Enum.EasingStyle.Linear), {
	['ClockTime'] = 12,
	['EnvironmentDiffuseScale'] = 1,
	['FogColor'] = Color3.fromRGB(227, 227, 227),
	['FogEnd'] = 3000,
	['FogStart'] = 100
})

local night = ts:Create(light, TweenInfo.new(time_period, Enum.EasingStyle.Linear), {
	['ClockTime'] = 0,
	['EnvironmentDiffuseScale'] = .25,
	['FogColor'] = Color3.fromRGB(21, 21, 21),
	['FogEnd'] = 2000,
	['FogStart'] = 25
})

while true do
	night:Play()
	night.Completed:Wait()
	
	day:Play()
	day.Completed:Wait()	
end
local module = {}

module.sound = function(parent : Instance, sound_id : number, volume : number | nil)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. sound_id
	sound.Volume = volume or .5
	sound.RollOffMaxDistance = 400
	sound.Parent = parent
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	return sound
end

return module

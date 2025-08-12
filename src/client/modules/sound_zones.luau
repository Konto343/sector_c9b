--!strict

local module = {}

local sounds_folder = Instance.new('Folder')
sounds_folder.Parent = script
sounds_folder.Name = 'sounds'

local ts = game:GetService("TweenService")
local collection = game:GetService('CollectionService')

local sound_tween_time = 6
local default_volume = .4
local update_speed = 1/3
local zones = {} :: {sound_zone}

type sound_zone = {
	id : string,
	area : BasePart?,
	sound : Sound,
	source_sound : Sound,
	priority : number | any
}

module.get_zone = function(id : string) : sound_zone | nil 
	for _, obj in zones do
		if obj['id'] == id then
			return obj
		end
	end
	return nil
end

module.add_zone = function(obj : Sound)
	local zone_data = module.get_zone(obj.SoundId)

	if zone_data then 
		return 
	end
	
	if not obj:HasTag('sound_zone') then 
		return 
	end

	if obj.Parent and not obj.Parent:IsA('BasePart') then
		return
	end

	local clone = obj:Clone()
	clone.Parent = sounds_folder

	table.insert(zones, {
		id = obj.SoundId,
		area = obj.Parent,
		sound = clone,
		source_sound = obj,
		priority = obj:GetAttribute('priority') or 1
	})
end

module.events = {
	collection:GetInstanceAddedSignal('sound_zone'):Connect(function(obj)
		if not obj:IsA('Sound') then
			return
		end
		module.add_zone(obj)
	end)
}

while task.wait(update_speed) do
	local in_zones = {}

	local tween_info = TweenInfo.new(sound_tween_time)

	for _, zone_data in zones do
		local zone = zone_data.area
		local sound = zone_data.sound

		local local_player = game.Players.LocalPlayer
		local character = local_player.Character
		local hrp = character:FindFirstChild('HumanoidRootPart')
		
		if not zone then
			continue
		end

		if not hrp then
			continue 
		end
		
		local region = Region3.new(
			zone.Position-(zone.Size/2),
			zone.Position+(zone.Size/2)
		)

		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		params.FilterDescendantsInstances = {hrp}
	
		local in_zone = #workspace:GetPartBoundsInBox(
			region.CFrame, region.Size, params
		) ~= 0

		if in_zone then
			table.insert(in_zones, zone_data)
		else
			ts:Create(sound, tween_info,{
				['Volume'] = 0
			}):Play()
		end
	end

	if #in_zones >= 2 then
		table.sort(in_zones, function(a,b)
			return a.priority > b.priority
		end)
	end

	local active_zone = in_zones[1]
	if active_zone then
		if not active_zone.sound.Playing then
			active_zone.sound:Play()
		end

		ts:Create(active_zone.sound, tween_info,{
			['Volume'] = active_zone.source_sound.Volume or default_volume
		}):Play()
	end

	table.remove(in_zones, 1)
	for _,zone in in_zones do
		ts:Create(zone.sound, tween_info,{
			['Volume'] = 0
		}):Play()
	end
end

return module
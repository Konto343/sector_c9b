--!strict

local module = {}

local helper = require(script.Parent.helper)
local config = require(script.Parent.config)
local types = require(script.Parent.types)
local logs = require(script.Parent.logs)
local tasks = require(script.Parent.tasks)
local colors = require(script.Parent.colors)

local plrs = game:GetService('Players')
local lighting = game:GetService('Lighting')
local ts = game:GetService('TweenService')
local tp = game:GetService('TeleportService')
local debris = game:GetService('Debris')
local messaging = game:GetService('MessagingService')

export type command = {
	name : string,
	requirement : number | any,
	args : {{string}} | nil,
	info : string,
	run : (client : types.player, args : {any}, ...any) -> ()
}

module.data = {
	------------------------------------------------------ LOGGING COMMANDS

    {
		name = 'chat',
		requirement = 10,
		args = {{'index_start', 'Number'}, {'index_end', 'Number'}},
		info = "Get chat logs of the server",
		run = function(client, args)
			local index_start = tonumber(args[1]) or 1
			local index_end = tonumber(args[2]) or 100

			helper.message(client, ('[Total: %i]'):format(#logs.chat))

			for i=index_start, index_end do
				local msg = logs.chat[i]

				if not msg then
					continue
				end

				helper.message(client, msg)
			end
		end,
	},

	{
		name = 'actions',
		requirement = 10,
		args = {{'index_start', 'Number'}, {'index_end', 'Number'}},
		info = "Get action logs of the server (from admins)",
		run = function(client, args)
			local index_start = tonumber(args[1]) or 1
			local index_end = tonumber(args[2]) or 100

			helper.message(client, ('[Total: %i]'):format(#logs.chat))

			for i=index_start, index_end do
				local msg = logs.actions[i]

				if not msg then
					continue
				end

				helper.message(client, msg)
			end
		end,
	},

	{
		name = 'chatsof',
		requirement = 10,
		args = {{'player', 'Player'}},
		info = "Get chat logs of a player",
		run = function(client, args)
			for _,player in pairs(helper.get_players(client, args[1])) do
				local chat = logs.chats[player.UserId]

				if not chat then
					helper.message(client, 'There are no chat logs for this player.')
					return
				end

				for _, msg in chat do
					helper.message(client, `{player.DisplayName} {msg}`)
				end
			end
		end,
	},

	{
		name = 'joinleaves',
		requirement = 10,
		info = "Get join/leaves logs of the server",
		run = function(client)
			helper.message(client, ('[all: %i]'):format(#logs.join_leaves))
			
			for _, msg in logs.join_leaves do
				local color = msg:match('JOIN') and colors.blue or colors.orange
				helper.chat_message(client, msg, color)
			end
		end,
	},

	{
		name = 'test',
		requirement = 0,
		info = "This is used for client/server testing.",
		run = function(client)
			helper.message(client, "Testing message. Nice.", colors.orange)
		end,
	},

	------------------------------------------------------ GENERAL COMMANDS

	{
		name = 'admin',
		requirement = 10,
		args = {{'player', 'Player'}, {'level', 'Number'}},
		info = "Give a player admin (But no UI)",
		run = function(client, args)
			local players = helper.get_players(client, args[1])	
			local target_rank = tonumber(args[2]) or 3

			for _, player in players do
				helper.message(client, "Granted admin to "..player.DisplayName)
				helper.update_admin(player, target_rank)
			end
		end,
	},

	{
		name = 'process_admin',
		requirement = 10,
		args = {{'player', 'Player'}},
		info = "[VERY DANGEOUS COMMAND] Reprocess a player through the admin system (Grants UI)",
		run = function(client, args)
			local players = helper.get_players(client, args[1])	

			for _, player in players do
				helper.message(client, "Processed admin to "..player.DisplayName)
				helper.process_admin(player)
			end
		end,
	},

	{
		name = 'user',
		requirement = 1,
		args = {{'player', 'Player'}},
		info = 'List info about a user',
		run = function(client, args)
			for _, player in helper.get_players(client, args[1]) do
				helper.message(client, `{player.DisplayName} (@{player.Name})`)
			end
		end,
	},

	{
		name = 'list_tasks',
		requirement = 10,
		info = 'List all tasks that MessageService monitors for.',
		run = function(client)
			for _, obj in tasks.data do
				if obj.is_callback then
					continue
				end

				local arg_string = ''
				for _, arg_set in obj.args do
					arg_string ..= `[{table.concat(arg_set, ' : ')}] `
				end
				helper.message(client, ('%-20s %s'):format(obj.name, arg_string))
			end
		end,
	},

	{
		name = 'task',
		requirement = 10,
		args = {{'task', 'String'}, {'args', '...'}},
		info = 'Give out a task for *all* servers to do.',
		run = function(client, args)
			messaging:PublishAsync('basic_admin', args)
		end,
	},

	{
		name = 'vanish',
		requirement = 10,
		args = {{'task', 'String'}, {'args', '...'}},
		info = 'Make yourself disappear for other players',
		run = function(client, args)
			for _, player in plrs:GetPlayers() do
				if player.UserId == client.UserId then
					continue
				end
				helper.give_vanish(player, client.UserId)
			end
		end,
	},

	{
		name = 'unvanish',
		requirement = 10,
		args = {{'task', 'String'}, {'args', '...'}},
		info = 'Make yourself disappear for other players',
		run = function(client, args)
			for _, player in plrs:GetPlayers() do
				if player.UserId == client.UserId then
					continue
				end
				helper.give_unvanish(player, client.UserId)
			end
		end,
	},

	{
		name = 'list',
		requirement = 1,
		info = "list system resources",
		args = {{'seek', 'String'}},
		run = function(client, args)
			local target = config.resources:GetChildren()

			if args[1] then
				for _, child in config.resources:GetChildren() do
					if string.lower(child.Name) == args[1] then
						target = child:GetChildren()
						break
					end
				end
			end

			for _, obj in pairs(target) do
				helper.message(client, ('+ %s'):format(obj.Name))
			end
		end
	},

	{
		name = 'kick',
		requirement = 7,
		args = {{'player', 'Player'}, {'message', 'String'}},
		info = "Kick a person",
		run = function(client, args)
			local message = args[2] or '[No Reason Given]'

			for _,player in pairs(helper.get_players(client, args[1])) do
				player:Kick("You have been kicked by an admin. | Reason: "..message)
				helper.message(client, "Kicked: "..player.Name)
			end
		end
	},

	{
		name = 'bans',
		requirement = 7,
		args = {{'player', 'Player'}},
		info = "List the bans of the entire game.",
		run = function(client, args)
			local user_id = tonumber(args[1])
			local ban_history = plrs:GetBanHistoryAsync(user_id)
			for _, item in ban_history do
				local dr = item['DisplayReason']
				local pr = item['PrivateReason']
				local start = item['StartTime']
				local duration = item['Duration']
				local state = item['Ban'] and 'ban' or 'unban'
				local place = (item['PlaceId'] == -1) and 'universe' or item['PlaceId']

				local message = `[{start}] Reason: {dr} ({pr}) | For: {duration} | Action: {state} | Place: {place}`
				helper.message(client, message)
			end
		end
	},

	{
		name = 'ban',
		requirement = 7,
		args = {{'player', 'Player'}, {'seconds', 'Number'}, {'reason', 'String'}, {'private_reason', 'String'}},
		info = "Ban a person",
		run = function(client, args)
			local user_ids = {}

			for _,player in pairs(helper.get_players(client, args[1])) do
				table.insert(user_ids, player.UserId)
			end

			plrs:BanAsync({
				UserIds = user_ids,
				ApplyToUniverse = true,
				Duration = tonumber(args[2] or -1), --'-1' for infinite ban
				DisplayReason = args[3] or '[No ban reason provided]',
				PrivateReason = args[4] or '[No private reason provided]',
				ExcludeAltAccounts = false, --for a ip ban
			})

			helper.message(client, `Banned {#user_ids} players.`)
		end
	},

	{
		name = 'unban',
		requirement = 7,
		args = {{'user_id', 'Number'}},
		info = "Unban a person",
		run = function(client, args)
			plrs:UnbanAsync({
				UserIds = {tostring(args[1])},
				ApplyToUniverse = true
			})

			helper.message(client, "Unbanned: "..args[1] or "N/A")
		end
	},

	{
		name = 'slock',
		requirement = 7,
		info = "Toggle players from joining temporarily",
		run = function(client)
			config.system.slock = not config.system.slock
			helper.message(client, `Slock: {config.system.slock}`)
		end
	},

	{
		name = 'admins',
		requirement = 10,
		info = 'List all admins currently in the system.',
		run = function(client)

			for userid, data in config.admins do
				local message = ''

				local user = 'N/A'
				local color = colors.green

				pcall(function()
					user = plrs:GetNameFromUserIdAsync(userid)
				end)

				if userid == client.UserId then
					message = ('%s (%i) => LVL %i'):format(user, userid, data.rank)
					color = colors.orange
				else
					message = ('%s (%i) => LVL %i'):format(user, userid, data.rank)
				end

				helper.message(client, message, color)
			end
		end,
	},

	{
		name = 'serverinfo',
		requirement = 0,
		info = 'Get info about the current server.',
		run = function(client)
			local infos = {
				['jobid'] = game.JobId,
				['name'] = game.Name,
				['placeid'] = game.PlaceId,
				['gameid'] = game.GameId,
				['private-serverid'] = game.PrivateServerId,
				['server-run-time'] = `{workspace.DistributedGameTime} ({workspace.DistributedGameTime} Minutes)`
			}

			for name, data in pairs(infos) do
				if type(data) == 'number' then
					helper.message(client, ('%s -> %.2f'):format(name, data))
				else
					helper.message(client, ('%s -> %s'):format(name, data))
				end
			end
		end,
	},

	{
		name = 'announce',
		requirement = 5,
		args = {{'player', 'Player'}, {'message', 'String'}},
		info = "Display a ui message to players",
		run = function(client, args)
			local words = {}
			for i=2,#args do
				table.insert(words,args[i])
			end
			local message = table.concat(words," ")

			for _,player in pairs(helper.get_players(client, args[1])) do
				helper.announce(player, client.DisplayName, message)
			end
		end
	},
	
	{
		name = 'chat_message',
		requirement = 5,
		args = {{'player', 'Player'}, {'message', 'String'}},
		info = "Display a chat message to players",
		run = function(client, args)
			local words = {}
			for i=2,#args do
				table.insert(words,args[i])
			end
			local message = table.concat(words," ")

			for _,player in pairs(helper.get_players(client, args[1])) do
				helper.chat_message(player, message)
			end
		end
	},

	{
		name = 'kill',
		requirement = 7,
		args = {{'player', 'Player'}},
		info = "Kill a person",
		run = function(client, args)
			for _,player in pairs(helper.get_players(client, args[1])) do
				local char = player.Character 
				local humanoid = char:FindFirstChildWhichIsA('Humanoid')

				if humanoid then
					humanoid.Health = 0
				end
			end
		end
	},
	
	{
		name = 'anchor',
		requirement = 5,
		args = {{'player', 'Player'}},
		info = 'Toggles a player\'s Anchor in place.',
		run = function(client, args)
			local targets = args[1] or 'me'

			for _,player in pairs(helper.get_players(client, targets)) do
				local char : types.char_r6 = player.Character 
				local hrp = char.HumanoidRootPart

				hrp.Anchored = not hrp.Anchored
			end
		end,
	},

	{
		name = 'id',
		requirement = 5,
		args = {{'player', 'Player'}},
		info = "Grabs a user's id",
		run = function(client, args)
			for _,player in pairs(helper.get_players(client, args[1])) do
				helper.message(client, `{player.DisplayName}: {player.UserId}`)
			end
		end
	},

	{
		name = 'thru',
		requirement = 5,
		args = {{'player', 'Player'}},
		info = "Move a player foward",
		run = function(client, args)
			local target = args[1] or 'me'
			for _,player in pairs(helper.get_players(client,target)) do
				local char = player.Character 
				if char then
					char:PivotTo(char:GetPivot() * CFrame.new(0,0,-5))
				end
			end
		end
	},

	{
		name = 'freeze',
		requirement = 7,
		args = {{'player', 'Player'}},
		info = "Freeze a person (Sets walk and jump power to zero)",
		run = function(client, args)
			for _,player in pairs(helper.get_players(client, args[1])) do
				local char = player.Character 
				local humanoid = char:FindFirstChildWhichIsA('Humanoid')

				if humanoid then
					humanoid.WalkSpeed = 0
					humanoid.JumpPower = 0
				end			
			end
		end
	},

	{
		name = 'unfreeze',
		requirement = 7,
		args = {{'player', 'Player'}},
		info = "Unfreeze a person",
		run = function(client, args)
			for _,player in pairs(helper.get_players(client, args[1])) do
				local char = player.Character 
				local humanoid = char:FindFirstChildWhichIsA('Humanoid')

				if humanoid then
					humanoid.WalkSpeed = 16
					humanoid.JumpPower = 50
				end
			end
		end
	},

	{
		name = 'hide',
		requirement = 7,
		args = {{'player', 'Player'}},
		info = "Make a person invisible",
		run = function(client, args)
			for _,player in pairs(helper.get_players(client, args[1])) do
				local char = player.Character 

				for _, obj in pairs(char:GetDescendants()) do
					if obj.Name == 'HumanoidRootPart' then
						for _, obj in obj:GetDescendants() do
							if obj:IsA('Sound') then
								obj.Volume = 0
							end
						end	
						
						continue
					end
					
					if obj:IsA('BasePart') then
						obj.Transparency = 1
					end

					if obj:IsA('Decal') then
						obj.Transparency = 1
					end

					if obj:IsA('BillboardGui') then
						obj.Enabled = false
					end

					if obj:IsA('ParticleEmiiter') then
						obj.Enabled = false
					end
				end
			end
		end
	},

	{
		name = 'show',
		requirement = 7,
		args = {{'player', 'Player'}},
		info = "Make a person visible",
		run = function(client, args)
			for _,player in pairs(helper.get_players(client, args[1])) do
				local char = player.Character 

				for _, obj in pairs(char:GetDescendants()) do
					if obj.Name == 'HumanoidRootPart' then
						for _, obj in obj:GetDescendants() do
							if obj:IsA('Sound') then
								obj.Volume = 0.65
							end
						end	

						continue
					end
					
					if obj:IsA('BasePart') then
						obj.Transparency = 0
					end

					if obj:IsA('Decal') then
						obj.Transparency = 0
					end

					if obj:IsA('BillboardGui') then
						obj.Enabled = true
					end

					if obj:IsA('ParticleEmiiter') then
						obj.Enabled = true
					end
				end
			end
		end
	},

	{
		name = 'trail',
		requirement = 5,
		args = {{'player', 'Player'}},
		info = "Give person a trail",
		run = function(client, args)
			for _,player in pairs(helper.get_players(client, args[1])) do
				local char : types.char_r6 = player.Character 
				local trail : any = char:FindFirstChild('Trail')

				if not trail then
					trail = Instance.new('Trail')
					trail.Parent = char
					trail.Attachment0 = char.HumanoidRootPart.RootAttachment
					trail.Attachment1 = char.Head:FindFirstChild('NeckRigAttachment')
					trail.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(188, 188, 188))
				else
					trail:Destroy()
				end
			end
		end
	},

	{
		name = 'goto',
		requirement = 7,
		args = {{'player', 'Player'}},
		info = "Go to a person",
		run = function(client, args)
			for _, player in pairs(helper.get_players(client, args[1])) do
				local char : types.char_r6 = player.Character 
				client.Character.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame
			end
		end
	},

	{
		name = 'bring',
		requirement = 7,
		args = {{'player', 'Player'}},
		info = "Bring a person to you",
		run = function(client, args)
			for _,player in pairs(helper.get_players(client, args[1])) do
				local char : types.char_r6 = player.Character 
				local client_char : types.char_r6 = client.Character
				char.HumanoidRootPart.CFrame = client_char.HumanoidRootPart.CFrame
			end
		end
	},

	{
		name = 'god',
		requirement = 7,
		args = {{'player', 'Player'}},
		info = "Set a persons health to inf.",
		run = function(client, args)
			for _,player in pairs(helper.get_players(client, args[1])) do
				local char = player.Character 
				local humanoid = char:FindFirstChildWhichIsA('Humanoid')

				if humanoid then
					humanoid.MaxHealth = math.huge
					humanoid.Health = math.huge
				end	
			end
		end
	},

	{
		name = 'reset',
		requirement = 7,
		args = {{'player', 'Player'}},
		info = "Respawn a person",
		run = function(client, args)
			for _, player in pairs(helper.get_players(client, args[1])) do
				local char : types.char_r6 = player.Character  
				local og_pos = char.HumanoidRootPart.Position

				player:LoadCharacter()

				repeat 
					task.wait() 
				until (char ~= nil) and char:FindFirstChild('HumanoidRootPart')

				char:MoveTo(og_pos)
			end
		end
	},

	{
		name = 'ff',
		requirement = 7,
		args = {{'player', 'Player'}},
		info = "Add a force field",
		run = function(client, args)
			for _,player in pairs(helper.get_players(client, args[1])) do
				local char = player.Character 
				local force = Instance.new("ForceField")
				force.Parent = char
			end
		end
	},

	{
		name = 'yaai',
		requirement = 7,
		args = {{'player', 'Player'}, {'Private Reason', 'String'} , {'Duration', 'Number'}},
		info = "Lazily IP ban exploiters with this",
		run = function(client, args)
			for _, player : Player in pairs(helper.get_players(client, args[1])) do
				task.spawn(function()
					local yaai = config.resources.ui.yaai:Clone() :: ScreenGui
					yaai.Parent = player.PlayerGui
					local script = yaai:FindFirstChild('LocalScript', true) :: LocalScript

					if script then
						script.Enabled = true
					end

					task.wait(5.3)

					plrs:BanAsync({
						UserIds = {player.UserId},
						Duration = tonumber(args[3]) or -1,
						DisplayReason = 'HA HA HA HAA HA HA HA HAA HAA HA',
						PrivateReason = `Was banned with the "yaai" command for => {args[2]}`
					})
				end)
			end
		end
	},

	{
		name = 'unff',
		requirement = 7,
		args = {{'player', 'Player'}},
		info = "Remove a force field",
		run = function(client, args)
			for _,player in pairs(helper.get_players(client, args[1])) do
				local char = player.Character 
				for _,Obj in pairs(char:GetDescendants()) do
					if Obj:IsA('ForceField') then
						Obj:Destroy()
					end
				end
			end
		end
	},

	{
		name = 'ungod',
		requirement = 7,
		args = {{'player', 'Player'}},
		info = "Set a persons health to Normal",
		run = function(client, args)
			for _,player in pairs(helper.get_players(client, args[1])) do
				local char = player.Character 
				local humanoid = char:FindFirstChildWhichIsA('Humanoid')

				if humanoid then
					humanoid.MaxHealth = 100
					humanoid.Health = 100
				end	
			end
		end
	},

	{
		name = 'speed',
		requirement = 7,
		args = {{'player', 'Player'}, {'value', 'Number'}},
		info = "Set a persons walkSpeed",
		run = function(client, args)
			local value = tonumber(args[2])

			for _,player in pairs(helper.get_players(client, args[1])) do
				local char : types.char_r6 = player.Character 
				local humanoid = char.Humanoid

				if humanoid then
					humanoid.WalkSpeed = value or 16
				end
			end
		end
	},

	{
		name = 'jump',
		requirement = 7,
		args = {{'player', 'Player'}, {'value', 'Number'}},
		info = "Set a persons jump power",
		run = function(client, args)
			local value = tonumber(args[2])

			for _,player in pairs(helper.get_players(client, args[1])) do
				local char : types.char_r6 = player.Character 
				local humanoid = char.Humanoid

				if humanoid then
					humanoid.UseJumpPower = true
					humanoid.JumpPower = value or 50
				end
			end
		end
	},

	{
		name = 'give',
		requirement = 7,
		args = {{'player', 'Player'}, {'tool_name', 'String'}},
		info = "Give a person a tool",
		run = function(client, args)
			local target = args[2]
			for _,player in pairs(helper.get_players(client, args[1])) do
				local tool = helper.seek_object(config.resources.tools, target)

				if tool ~= nil then
					local clone = tool:Clone()
					clone.Parent = player.Backpack
				end
			end
		end
	},

	{
		name = 'btools',
		requirement = 7,
		args = {{'player', 'Player'}},
		info = "Give a person a tool",
		run = function(client, args)
			for _,player in pairs(helper.get_players(client, args[1] or 'me')) do
				local clone = config.resources.tools['Building Tools']:Clone()
				clone.Parent = player.Backpack
			end
		end
	},

	{
		name = 'fling',
		requirement = 7,
		args = {{'player', 'Player'}},
		info = "Send a player into the sky",
		run = function(client, args)
			for _,player in pairs(helper.get_players(client, args[1])) do
				local char : types.char_r6 = player.Character 
				local hrp = char.HumanoidRootPart 

				local body_force = Instance.new("BodyVelocity") 
				body_force.Velocity = Vector3.new(math.huge,math.huge,math.huge)
				body_force.MaxForce = Vector3.new(99999,99999,99999)
				body_force.Parent = hrp

				debris:AddItem(body_force, 2)
			end
		end
	},

	{
		name = 'r6',
		requirement = 7,
		args = {{'player', 'Player'}},
		info = "Sets a player to r6",
		run = function(client, args)
			for _,player in pairs(helper.get_players(client, args[1])) do
				require(config.resources.other.R6Module):r6(player.Name)
			end
		end
	},

	{
		name = 'drip',
		requirement = 10,
		args = {{'player', 'Player'}},
		info = "Gives a player extreme/insane drip",
		run = function(client, args)
			for _,player in pairs(helper.get_players(client, args[1])) do
				local char = player.Character 

				for _,obj in pairs(char:GetChildren()) do
					if obj:IsA('Shirt') or obj:IsA('Pants') then
						obj:Destroy()
					end
				end

				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://3094151055"
				sound.Volume = 1
				sound.TimePosition = 0.54
				sound.Parent = char:FindFirstChild("HumanoidRootPart")

				sound:Play()

				local shirt = Instance.new("Shirt")
				shirt.ShirtTemplate = "http://www.roblox.com/asset/?id=6010347354"
				shirt.Parent = char

				local pants = Instance.new("Pants")
				pants.PantsTemplate = "http://www.roblox.com/asset/?id=4516098725"
				pants.Parent = char
			end
		end
	},

	{
		name = 'prop',
		requirement = 7,
		args = {{'player', 'Player'}, {'prop_name', 'String'}, {'amount', 'Number'}},
		info = "Spawns a prop on a player",
		run = function(client, args)
			local target = args[2]
			local amount = tonumber(args[3]) or 1

			for _,player in pairs(helper.get_players(client, args[1])) do
				local char : types.char_r6 = player.Character 
				local obj = helper.seek_object(config.resources.props, target)
				local padding_height = 10

				if not obj then
					continue
				end

				for index=1, amount do
					local clone = obj:Clone()
					clone.Parent = config.spawned_items

					local hrp = char.HumanoidRootPart
					local to = (hrp.CFrame * CFrame.new(0,padding_height * index,0))

					if clone:IsA('Model') then
						clone:MoveTo(to.Position)
					elseif clone:IsA('BasePart') then
						clone.CFrame = to
					end
				end
			end
		end
	},

	{
		name = 'cube',
		requirement = 4,
		args = {{'player', 'Player'}, {'amount', 'Number'}, {'box_radius', 'Number'}},
		info = "Spawns a cube on a player",
		run = function(client, args)
			local amount = tonumber(args[2]) :: number
			local size = tonumber(args[3]) :: number

			for _,player in pairs(helper.get_players(client, args[1])) do
				for index=1, amount do
					local padding_height = size
					local box = Instance.new('Part')
					box.Size = Vector3.new(size, size, size)
					box.Parent = config.spawned_items

					local char : types.char_r6 = player.Character 
					local pos = char.HumanoidRootPart.Position + Vector3.new(0,padding_height * index,0)
					box.Position = pos
				end
			end
		end
	},

	{
		name = 'npc',
		requirement = 7,
		args = {{'player', 'Player'}, {'prop_name', 'Number'}, {'amount', 'Number'}},
		info = "Spawns a npc on a player",
		run = function(client, args)
			local target = args[2]
			local amount = args[3] or 1

			for _,player in pairs(helper.get_players(client, args[1])) do
				local char : types.char_r6 = player.Character 
				local npc = helper.seek_object(config.resources.npcs, target or 'dummy')
				local padding_height = 5

				if not npc then
					continue
				end

				for index=1, amount do
					local clone = npc:Clone()
					clone.Parent = config.spawned_items

					local pos = char.HumanoidRootPart.CFrame * CFrame.new(0,padding_height * index,0)

					if clone:IsA('Model') then
						clone:PivotTo(pos)
					end
				end
			end
		end
	},

	{
		name = 'vehicle',
		requirement = 7,
		args = {{'player', 'Player'}, {'vehicle_name', 'Number'}, {'amount', 'Number'}},
		info = "Spawns a vehicle",
		run = function(client, args)
			local target = args[2]
			local amount = tonumber(args[3]) or 1

			for _,player in pairs(helper.get_players(client, args[1])) do
				local char : types.char_r6 = player.Character 
				local obj = helper.seek_object(config.resources.vehicles, target) :: Model
				local padding_height = 40

				if not obj then
					continue
				end

				for index=1, amount do
					local clone = obj:Clone()
					clone.Parent = config.spawned_items
					clone:MoveTo(char.HumanoidRootPart.Position + Vector3.new(20, padding_height * index ,20))
				end
			end
		end
	},

	{
		name = 'cls',
		requirement = 7,
		info = "Clears all objects spawned by system",
		run = function()
			config.spawned_items:ClearAllChildren()
		end
	},

	{
		name = 'char',
		requirement = 7,
		args = {{'player', 'Player'}, {'user_id', 'Number'}},
		info = "Change a player's character",
		run = function(client, args)
			local target = args[2]
			for _,player in pairs(helper.get_players(client, args[1])) do
				local char : types.char_r6 = player.Character 
				char.Humanoid:ApplyDescription(game.players:GetHumanoidDescriptionFromUserId(target))
			end
		end
	},

	{
		name = 'breakjoints',
		requirement = 7,
		args = {{'player', 'Player'}},
		info ='Break the joints of a player.',
		run = function(client, args)
			for _,player in pairs(helper.get_players(client, args[1])) do
				local char : any = player.Character 
				char:BreakJoints()
			end
		end
	},

	{
		name = 'size',
		requirement = 7,
		args = {{'player', 'Player'}, {'size', 'Number'}},
		info = "Size player's character by a scaling number",
		run = function(client, args)
			local factor = tonumber(args[2])

			for _,player in pairs(helper.get_players(client, args[1])) do
				local char = player.Character 
				char:ScaleTo(factor)
			end
		end,
	},

	{
		name = 'freecam',
		requirement = 5,
		args = {{'player', 'Player'}},
		info = "Give freecam to a player",
		run = function(client, args)
			for _,player in pairs(helper.get_players(client, args[1])) do
				config.resources.ui.Freecam:Clone().Parent = player.PlayerGui
			end
			return "You now have freecam (Shift + P, to activate/stop)"
		end
	},

	{
		name = 'grayscale',
		requirement = 7,
		info = "Toggle a grayscale to lighting",
		run = function()
			local gray = lighting:FindFirstChild("GrayScale")

			if not gray then
				gray = Instance.new('ColorCorrectionEffect')
				gray.Parent = lighting
				gray.Name = "grayscale"
				gray.Saturation = -1
			else
				gray:Destroy()
			end
		end
	},

	{
		name = 'time',
		requirement = 7,
		args = {{'clock_time', 'Number'}, {'latitude', 'Number'}, {'tween_time', 'Number'}},
		info = "Set the time",
		run = function(client, args)
			local clock_time = tonumber(args[1])
			local geo_lat = tonumber(args[2])
			local tween_time = tonumber(args[3])

			ts:Create(lighting,TweenInfo.new(tween_time),{
				ClockTime = clock_time,
				GeographicLatitude = geo_lat
			}):Play()
		end
	},

	{
		name = 'fog',
		requirement = 7,
		args = {{'start', 'Number'}, {'end', 'Number'}, {'tween_time', 'Number'}},
		info = "Set the fog",
		run = function(client, args)
			local start_distance = tonumber(args[1])
			local end_distance = tonumber(args[2])
			local tween_time = tonumber(args[3]) or 2

			local Info = TweenInfo.new(tween_time)
			ts:Create(lighting,Info,{
				FogStart = start_distance,
				FogEnd = end_distance
			}):Play()
		end
	},

	{
		name = 'baseplate',
		requirement = 7,
		args = {},
		info = "Create a 2048 by 2048 baseplate directly below you.",
		run = function(client)
			local char = helper.get_players(client, 'me')[1].Character :: types.char_r6

			local baseplate = config.resources.other.Baseplate:Clone()
			baseplate.Position = char.HumanoidRootPart.Position + Vector3.new(0,-20,0)
			baseplate.Parent = workspace
		end
	},

	{
		name = 'gravity',
		requirement = 7,
		args = {{'value', 'Number'}},
		info = "Set the gravity",
		run = function(client, args)
			workspace.Gravity = tonumber(args[1])
		end
	},

	{
		name = 'teleport',
		requirement = 7,
		args = {{'player', 'Player'}, {'place_id', 'Number'}},
		info = 'Teleport people to another game',
		run = function(client, args)
			local players = helper.get_players(client, args[1])
			tp:TeleportAsync(
				tonumber(args[2]),
				players
			)
		end,
	},

		{
		name = 'warp',
		requirement = 7,
		args = {{'player', 'Player'}, {'jobid', 'String'}},
		info = 'Teleport people to another server with an JobId',
		run = function(client, args)
			local players = helper.get_players(client, args[1])
			tp:TeleportAsync(
				game.PlaceId,
				players,
				Instance.new('TeleportOptions'):SetTeleportData({
					placeId = game.PlaceId,
					jobId = tostring(args[2])
				})
			)
		end,
	},

	------------------------------------------------------ CUSTOM COMMANDS

	{
		name = 'strange',
		requirement = 10,
		args = {{'player', 'Player'}},
		info = 'Load the Strange-Matter script to a player',
		run = function(client, args)
			local players = helper.get_players(client, args[1])

			for _, player in players do
				local strange = config.resources.other.strange_matter:Clone()
				strange.Parent = player.Character
				strange.self_.Enabled = true
			end
		end,
	},

	{
		name = 'tier9',
		requirement = 10,
		args = {{'player', 'Player'}},
		info = 'Load the TIER-9 SafeGuard script to a player.',
		run = function(client, args)
			local players = helper.get_players(client, args[1])

			for _, player in players do
				local strange = config.resources.other.t9_safe_guard:Clone()
				strange.Parent = player.Character
				strange.self_.Enabled = true
			end
		end,
	},
} :: {command}

return module
local module = {}

export type command = {
	name : string,
	requirement : number | any,
	args : {{string}} | nil,
	info : string,
	run : (client : Player, args : {any}, ...any) -> ()
}

local helper = require(script.Parent.helper)
local _client = require(script.Parent.client)
local colors = require(script.Parent.colors)
local debug = require(script.Parent.debug)

local lighting = game:GetService('Lighting')

module.data = {
	{
		name = 'clear',
		info = "Clear the command logs",
		run = function(client)
			local ba_ui = client.PlayerGui:WaitForChild('ba_ui', 10)

			if not ba_ui then
				return
			end

			local menu_logs = ba_ui:FindFirstChild('logs', true)

			if not menu_logs then
				return
			end

			for _, item in menu_logs:GetChildren() do
				if item:IsA('TextBox') then
					item:Destroy()
				end
			end
		end,
	},

	{
		name = 'filter',
		args = {{'regex', 'String'}},
		info = "Filter the command logs",
		run = function(client, args)
			local ba_ui = client.PlayerGui:FindFirstChild('ba_ui')

			if not ba_ui then
				return
			end

			local menu_logs = ba_ui:FindFirstChild('logs', true)

			if not menu_logs then
				return
			end

			for _, item in menu_logs:GetChildren() do
				if item:IsA('TextBox') and string.match(item.Text, args[1]) == nil then
					item:Destroy()
				end
			end
		end,
	},

	{
		name = 'fixcam',
		info="Fixs the players camera",
		run = function(client)
			local camera : Camera = workspace.CurrentCamera
			client.CameraMode = Enum.CameraMode.Classic
			camera.CameraSubject = client.Character:FindFirstChildWhichIsA("Humanoid")
		end
	},	

	{
		name = 'noclip',
		info="Toggle the user to fly and noclip through walls",
		run = function()
			if not _client.ui then
				return
			end
			
			local noclip = _client.ui:FindFirstChild('noclip', true)
	
			if noclip then
				require(noclip):toggle()
			end
		end
	},	

	{
		name = 'offline',
		info="Turns a offline model",
		run = function(client)
			local ba_client = client.PlayerGui:FindFirstChild('ba_client', true)

			if ba_client then
				local mod = require(ba_client:FindFirstChild('offline'))
				mod:toggle()
			end
		end
	},	

	{
		name = 'focustorso',
		info ='Focuses the camera target to your torso',
		run = function(client)
			local torso = client.Character:FindFirstChild("Torso") :: BasePart
			local camera : Camera = workspace.CurrentCamera
			camera.CameraSubject = torso
		end
	},

	{
		name = 'view',
		args = {{'player', 'Player'}},
		info="Spectate a person",
		run = function(client,args)
			local player = helper.seek_player(args[1])

			if not player then
				return
			end

			local char = player.Character 

			if not char then
				return
			end

			if player then
				game.Workspace.Camera.CameraSubject = char:FindFirstChild('Humanoid')
			end
		end
	},

	{
		name = 'unview',
		info="Resets your camera position",
		run = function(client)
			game.Workspace.Camera.CameraSubject = client.Character.Humanoid
		end
	},

	{
		name = 'maxzoom',
		args = {{'distance', 'Number'}},
		info="Changes max zoom",
		run = function(client,args)
			local distance = tonumber(args[1]) :: number
			client.CameraMaxZoomDistance = distance
		end
	},

	{
		name = 'shadows',
		info="Toggle global shadows",
		run = function()
			local state = lighting.GlobalShadows
			lighting.GlobalShadows = not state
		end
	},

	{
		name = 'debug_players',
		info = 'Toggle the debug UI for players',
		run = function()
			for _, bill in debug.data.players_overhead do
				bill.Enabled = not bill.Enabled
			end
		end
	},

	{
		name = 'debug_lines',
		info = 'Toggle the debug lines to players',
		run = function()
			for _, line in debug.data.players_line do
				line.Enabled = not line.Enabled
			end
		end
	},

	{
		name = 'fullbright',
		info="Toggle a immense brightness to the world",
		run = function()
			if lighting.Brightness == 30 then
				lighting.Brightness = 1
			else
				lighting.Brightness = 30
			end
		end
	},

	{
		name = 'players',
		requirements = 1,
		info = "List the players in the server.",
		run = function()
			for i, player in game.Players:GetPlayers() do
				helper.log(`{i} | {player.DisplayName} | @{player.Name} | {player.UserId}`)
			end
		end
	},

	{
		name = 'version',
		requirements = 1,
		info = "Print the version of the Basic Admin System.",
		run = function()
			local version = _client.remote:InvokeServer('version')
			helper.log(version, colors.orange)
		end
	},

	{
		name = 'help',
		requirement = 0,
		args = {{'seek_term', 'String'}},
		info = "List all the system commands",
		run = function(client, args)
			for _, cmd in _client.commands do
				if args[1] then
					if cmd.name ~= args[1] then
						continue
					end
				end

				local data = {} :: any
				if cmd.args then
					for _, arg in cmd.args do
						table.insert(data, `[{arg[1]} : {arg[2]}] `)
					end
				end
				
				local command_args = table.concat(data, '')
				local cmd_name = string.format('%-25s', cmd.name)
				local cmd_info = string.format('%-60s', cmd.info)

				helper.log(cmd_name .. cmd_info .. command_args)
			end
		end	
	}
}

return module

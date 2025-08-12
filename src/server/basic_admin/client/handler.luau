--!strict

local module = {}

local input = game:GetService("UserInputService")
local startergui = game:GetService('StarterGui')

local player = game.Players.LocalPlayer

local client = require(script.Parent.client)
local cmd = require(script.Parent.cmd)
local colors = require(script.Parent.colors)
local helper = require(script.Parent.helper)
local menu_key = client.config.ui_key

local ui = script.Parent.Parent
local toggle = ui.toggle
local menu = ui.menu
local logs = menu.logs
local bar : TextBox = menu.bar

local predictions_preview = menu.predictions

local command_history = {}
local pointer_pos = 0

local menu_state = false
local focus_sate = false

client.ui = ui

module.get_predictions = function(user_input : string)
	local predictions = {}
	
	for _, data in client.commands do
		if user_input:sub(1,#user_input) == data.name:sub(1,#user_input) then
			predictions[#predictions+1] = data.name
		end
	end
	return predictions
end

module.set_history = function()
	pcall(function()
		pointer_pos = math.clamp(pointer_pos, 1, #command_history)
		bar.Text = command_history[(#command_history+1) - pointer_pos] 
		task.wait()
		bar.CursorPosition = 999
	end)
end

module.toggle_menu = function(force_state : boolean | nil)	
	menu_state = not menu_state

	if force_state ~= nil then
		menu_state = force_state
	end
	
	menu.Visible = menu_state
	startergui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not menu_state)
end

module.lecture = function()
	local start_up = {
		'We trust you have received the usual lecture from the local System',
		'Administrator. It usually boils down to these three things:',
		'',
		'   #1) Respect the privacy of others.',
		'   #2) Think before you type.',
		'   #3) With great power comes great responsibility.'
	}

	for i=1, #start_up do
		helper.log(start_up[i], colors.orange)
	end

	helper.log('You are admin!', colors.blue)
end

client.remote.OnClientInvoke = function(task, msg : string, color : Color3 | nil)
	if task == 'message' then
		helper.log(msg, color)
	end
end

module.events = {
	bar:GetPropertyChangedSignal('Text'):Connect(function()
		local command = cmd.get_command(bar.Text:split(' ')[1])
		if command then
			bar.TextColor3 = Color3.fromRGB(255,255,255)
			return
		end
		bar.TextColor3 = Color3.fromRGB(255,0,0)
	end),

	input.InputBegan:Connect(function(pressed)
		if focus_sate then
			local user_input = bar.Text:split(' ')[1]
			local first_arg = user_input
			local predictions = module.get_predictions(first_arg)

			if pressed.KeyCode == menu_key then
				module.toggle_menu()
				bar:ReleaseFocus()
			end
			
			if #predictions == 0 then
				predictions_preview.Text = ''
				return
			end

			local preview = {} :: {string}
			
			for _, predict in predictions do
				local command = cmd.get_command(predict)
				local data = {}

				if not command then
					continue
				end

				if command.args then
					table.insert(data, '|')
					for _, arg in command.args do
						table.insert(data, helper.color_richtext(`{arg[1]}: {arg[2]}`, colors.orange))
					end
				end
				table.insert(preview,
					`{command.name} {(#predictions <= 2) and `| {command.info}` or ''} {table.concat(data, ' + ')}`
				)
			end
			
			predictions_preview.Text = table.concat(preview, '\n')
		elseif pressed.KeyCode == menu_key then
			module.toggle_menu()
			
			if menu_state then
				bar.Text = ""		
				task.wait()
				bar:CaptureFocus()
			end
		end

		if pressed.KeyCode == Enum.KeyCode.Tab then
			local predictions = module.get_predictions(bar.Text:split(' ')[1])
			
			if #predictions >= 1 then
				task.wait()
				bar.Text = predictions[1]..' '
				bar.CursorPosition = 999
			end
		end

		if pressed.KeyCode == Enum.KeyCode.Up then
			pointer_pos += 1
			module.set_history()
		end

		if pressed.KeyCode == Enum.KeyCode.Down then
			pointer_pos -= 1
			module.set_history()
		end
	end),

	input.InputChanged:Connect(function(input: InputObject, gpe : boolean)
		if gpe then
			return
		end

		local mouse = input.UserInputType == Enum.UserInputType.MouseMovement
		local text = input.UserInputType == Enum.UserInputType.TextInput
		local wheel = input.UserInputType == Enum.UserInputType.MouseWheel

		toggle.Visible = not (mouse or text or wheel)
	end),

	bar.Focused:Connect(function()
		focus_sate = true
	end),

	bar.FocusLost:Connect(function()
		focus_sate = false

		if bar.Text ~= "" then
			local user_input = bar.Text
			local target_command = user_input:split(' ')[1]
			local command_data = cmd.get_command(target_command)
			helper.log(`> {user_input}`, colors.blue)
			
			if command_data and not command_data['is_server'] then
				cmd.process_command(player, user_input)
			else
				local result = client.remote:InvokeServer('command', user_input)
				if not result then
					helper.log(`Invalid command => "{target_command}"`, colors.orange)
				end
			end
			
			table.insert(command_history, user_input)
			bar.Text = ''
			task.wait()
			bar:CaptureFocus()

			for i=1, 10 do --if you see this, then uh... This code is Perfect.
				logs.CanvasPosition = Vector2.new(0, 10^6)
				task.wait()
			end
		else
			module.toggle_menu(false)
		end
		
		pointer_pos = -1
	end),

	toggle.MouseButton1Down:Connect(function()
		module.toggle_menu()
	end)
}

ui.Parent = player.PlayerGui
module.lecture()

return module
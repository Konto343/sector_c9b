--konto343's ui lib

local uis = game:GetService('UserInputService')
local players = game:GetService('Players')

local local_player = players.LocalPlayer
	
local module = {}
module.__index = module

module.directions = {
	['center'] = Vector2.new(.5, .5),
	['right'] = Vector2.new(1, .5),
	['left'] = Vector2.new(0, .5),
	['bottom'] = Vector2.new(.5, 1),
	['top'] = Vector2.new(.5, 0),
}

module.config = {
	bg1 = Color3.fromRGB(25, 25, 25),
	bg2 = Color3.fromRGB(38, 38, 38),
	bg3 = Color3.fromRGB(51, 51, 51),
	bg4 = Color3.fromRGB(64, 64, 64),
	
	fg1 = Color3.fromRGB(255, 255, 255),
	
	border = Color3.fromRGB(35, 35, 35),
	accent = Color3.fromRGB(255, 187, 84),
	
	font = Enum.Font.RobotoMono
}

function module.new(ui_name : string)
	local ui = Instance.new('ScreenGui')
	ui.Name = ui_name
	ui.ResetOnSpawn = false
	ui.Parent = local_player:FindFirstChild('PlayerGui')

	return ui
end

function module.window(x_px : number, y_px : number, parent : ScreenGui, hide : boolean)
	local item = Instance.new('Frame')
	item.BackgroundColor3 = module.config.bg1
	item.BorderColor3 = module.config.border
	item.BorderSizePixel = 4
	item.Size = UDim2.fromOffset(x_px, y_px)
	item.ClipsDescendants = true
	item.Parent = parent
	item.Visible = not hide

	local self = setmetatable({}, module)
	self.item = item :: Frame

	return self
end

function module.header(parent : BasePlayerGui, text : string, height : number | nil)
	local item = Instance.new('TextLabel')
	item.BackgroundTransparency = 1
	item.Size = UDim2.new(1, 0, 0, height or 20)
	item.TextColor3 = module.config.fg1
	item.Font = module.config.font
	item.Text = text
	item.Parent = parent
	
	local self = setmetatable({}, module)
	self.item = item :: TextLabel
	
	return self
end

function module.item(className : string, parent : BasePlayerGui, height : number | nil)
	local item = Instance.new(className)
	item.Size = UDim2.new(1, 0, 0, height or 20)
	
	item.BackgroundColor3 = module.config.bg2
	item.BorderColor3 = module.config.border
	item.Parent = parent
	
	if table.find({'TextLabel', 'TextBox'}, className) then
		item.TextColor3 = module.config.fg1
		item.Font = module.config.font
	end

	local self = setmetatable({}, module)
	self.item = item :: TextLabel & TextBox & Frame & TextButton & ScrollingFrame & ImageLabel
	
	return self
end

--------------- methods

function module:pad(pad_amount : number)
	local pad = Instance.new('UIPadding')
	pad.PaddingTop = UDim.new(0, pad_amount)
	pad.PaddingLeft = UDim.new(0, pad_amount)
	pad.PaddingRight = UDim.new(0, pad_amount)
	pad.PaddingBottom = UDim.new(0, pad_amount)
	pad.Parent = self.item
	return self, pad
end

function module:pad_horz(pad_amount : number)
	local pad = Instance.new('UIPadding')
	pad.PaddingLeft = UDim.new(0, pad_amount)
	pad.PaddingRight = UDim.new(0, pad_amount)
	pad.Parent = self.item
	return self, pad
end

function module:pad_fix(pad_amount : number)
	local x = self.item.Size.X
	local y = self.item.Size.Y
	self.item.Size = UDim2.new(x.Scale, x.Offset, y.Scale, y.Offset - pad_amount)
	return self
end

function module:anchor(direction : Vector2)
	self.item.Position = UDim2.fromScale(direction.X, direction.Y)
	self.item.AnchorPoint = direction
	return self
end

function module:containerize(pad_amount : number | nil)
	local container = Instance.new('Frame')
	container.LayoutOrder = self.item.LayoutOrder
	container.Size = self.item.Size
	container.Parent = self.item.Parent
	container.BackgroundTransparency = 1
	
	local pad = Instance.new('UIPadding')
	pad.PaddingTop = UDim.new(0, pad_amount)
	pad.Parent = container
	
	self.item.Size = UDim2.fromScale(1, 1) --fill old space + padding
	self.item.Parent = container
	return self, container
end

function module:bind(key : Enum.KeyCode, run : () -> ())
	uis.InputBegan:Connect(function(input, gpe)
		if input.KeyCode == key then
			run()
		end
	end)
	return self
end

function module:draggable()
	local frame = self.item :: BasePlayerGui

	local drag_toggle
	local drag_input
	local drag_start
	local start_position

	local function update_drag(Input)
		local delta = Input.Position - drag_start
		local pos = UDim2.new(
			start_position.X.Scale, 
			start_position.X.Offset + delta.X, 
			start_position.Y.Scale, start_position.Y.Offset + delta.Y)

		frame.Position = pos
	end

	frame.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 
			or input.UserInputType == Enum.UserInputType.Touch) 
			and uis:GetFocusedTextBox() == nil then
			
			drag_toggle = true
			drag_start = input.Position
			start_position = frame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					drag_toggle = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement 
			or input.UserInputType == Enum.UserInputType.Touch then
			drag_input = input
		end
	end)

	uis.InputChanged:Connect(function(Input)
		if Input == drag_input and drag_toggle then
			update_drag(Input)
		end
	end)

	return self
end

function module:list_layout(amount : number | nil)
	local list = Instance.new('UIListLayout')
	list.Padding = UDim.new(0, amount or 10)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = self.item
	return self, list
end

function module:corner(amount : number | nil)
	local corner = Instance.new('UICorner')
	corner.CornerRadius = UDim.new(0, amount or 10)
	corner.Parent = self.item
	return self, corner
end

function module:fill()
	self.item.Size = UDim2.fromScale(1,1)
	return self
end

function module:canvas_adapt()
	local canvas = self.item :: ScrollingFrame
	local layout = self.item:FindFirstChildWhichIsA('UIListLayout', true) or self.item:FindFirstChildWhichIsA('UIGridLayout', true) :: UILayout & UIGridLayout
	
	canvas.DescendantAdded:Connect(function()
		canvas.CanvasSize = UDim2.fromOffset(
			layout.AbsoluteContentSize.X, layout.AbsoluteContentSize.Y + 20
		)
	end)
	return self
end

return module

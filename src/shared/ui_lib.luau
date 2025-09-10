--!strict

--1.0.2

local module = {}

local uis = game:GetService('UserInputService')
local players = game:GetService('Players')
local local_player = players.LocalPlayer
	
module.anchors = {
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

function module.ui(ui_name : string)
	local ui = Instance.new('ScreenGui')
	ui.Name = ui_name
	ui.ResetOnSpawn = false
	ui.Parent = local_player:FindFirstChild('PlayerGui')

	return ui
end

function module.item(className : string, parent : ScreenGui | GuiObject, height : number | nil)
	local self = {}

	local obj = Instance.new(className) :: GuiObject & TextLabel
	obj.Size = UDim2.new(1, 0, 0, height or 20)
	obj.BackgroundColor3 = module.config.bg2
	obj.BorderColor3 = module.config.border
	obj.Parent = parent

	self.obj = obj
	
	if table.find({'TextLabel', 'TextBox'}, className) then
		obj.TextColor3 = module.config.fg1
		obj.Font = module.config.font
	end

	function self:pad(pad_amount : number)
		local pad = Instance.new('UIPadding')
		pad.PaddingTop = UDim.new(0, pad_amount)
		pad.PaddingLeft = UDim.new(0, pad_amount)
		pad.PaddingRight = UDim.new(0, pad_amount)
		pad.PaddingBottom = UDim.new(0, pad_amount)
		pad.Parent = self.obj
		return self, pad
	end

	function self:pad_horz(pad_amount : number)
		local pad = Instance.new('UIPadding')
		pad.PaddingLeft = UDim.new(0, pad_amount)
		pad.PaddingRight = UDim.new(0, pad_amount)
		pad.Parent = self.obj
		return self, pad
	end

	function self:pad_fix(pad_amount : number)
		local x = self.obj.Size.X :: UDim
		local y = self.obj.Size.Y :: UDim
		self.obj.Size = UDim2.new(x.Scale, x.Offset, y.Scale, y.Offset - pad_amount)
		return self
	end

	function self:anchor(direction : Vector2)
		self.obj.Position = UDim2.fromScale(direction.X, direction.Y)
		self.obj.AnchorPoint = direction
		return self
	end

	function self:containerize(pad_amount : number | nil)
		local container = Instance.new('Frame')
		container.LayoutOrder = self.obj.LayoutOrder
		container.Size = self.obj.Size
		container.Parent = self.obj.Parent
		container.BackgroundTransparency = 1
		
		local pad = Instance.new('UIPadding')
		pad.PaddingTop = UDim.new(0, pad_amount)
		pad.Parent = container
		
		self.obj.Size = UDim2.fromScale(1, 1)
		self.obj.Parent = container
		return self, container
	end

	function self:bind(key : Enum.KeyCode, run : () -> ())
		uis.InputBegan:Connect(function(input, gpe)
			if input.KeyCode == key then
				run()
			end
		end)
		return self
	end

	function self:draggable()
		local frame = self.obj :: Frame

		local drag_toggle : boolean
		local drag_input : InputObject
		local drag_start : Vector3
		local start_position : UDim2

		local function update_drag(input : InputObject)
			local delta = input.Position - drag_start
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

		uis.InputChanged:Connect(function(input)
			if (input.UserInputType == drag_input.UserInputType) and drag_toggle then
				update_drag(input)
			end
		end)

		return self
	end

	function self:list_layout(amount : number | nil, x_align : Enum.HorizontalAlignment, y_align : Enum.VerticalAlignment)
		local list = Instance.new('UIListLayout')
		list.HorizontalAlignment = x_align
		list.VerticalAlignment = y_align
		list.Padding = UDim.new(0, amount or 10)
		list.SortOrder = Enum.SortOrder.LayoutOrder
		list.Parent = self.obj
		return self, list
	end

	function self:corner(amount : number | nil)
		local corner = Instance.new('UICorner')
		corner.CornerRadius = UDim.new(0, amount or 10)
		corner.Parent = self.obj
		return self, corner
	end

	function self:fill()
		self.obj.Size = UDim2.fromScale(1,1)
		return self
	end

	function self:canvas_adapt()
		local canvas = self.obj :: ScrollingFrame
		local layout = self.obj:FindFirstChildWhichIsA('UIListLayout', true) or self.obj:FindFirstChildWhichIsA('UIGridLayout', true) :: UILayout & UIGridLayout
		
		canvas.DescendantAdded:Connect(function()
			canvas.CanvasSize = UDim2.fromOffset(
				layout.AbsoluteContentSize.X, layout.AbsoluteContentSize.Y + 20
			)
		end)
		return self
	end

	return self
end

return module

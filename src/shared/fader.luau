--!strict

local module = {}

local ts = game:GetService('TweenService')
local players = game:GetService('Players')

local local_player = players.LocalPlayer

type self = {
    _frame : Frame
}

function create_fade()
    local ui = Instance.new('ScreenGui')
    ui.Parent = local_player.PlayerGui

    local fade = Instance.new('Frame')
    fade.Size = UDim2.fromScale(2, 2)
    fade.AnchorPoint = Vector2.new(.5, .5)
    fade.BackgroundColor3 = Color3.fromRGB(0, 0 ,0)
    fade.Parent = ui

    return fade
end

function module.new()
    local self = setmetatable({} :: self, module)
    self._frame = create_fade()

    return self
end

function module.fade(self : self, tween_info : TweenInfo, callback : ()->())
    local fade_in = ts:Create(
        self._frame, 
        tween_info, 
        {BackgroundTransparency = 0}
    )

    local fade_out = ts:Create(
        self._frame, 
        tween_info, 
        {BackgroundTransparency = 1}
    )

    fade_in:Play()
    fade_in.Completed:Once(function()
        callback()
        fade_out:Play()
    end)
end


return module
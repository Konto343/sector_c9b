--!strict

local ui = require(game.ReplicatedStorage.shared.ui_lib)

local module = {}

local root = ui.ui('main')

local side_menu = ui.item('Frame', root)
side_menu.obj.Size = UDim2.fromScale(.25, 1)
side_menu.obj.BackgroundTransparency = 1
side_menu
:anchor(ui.anchors.left)
:pad(20)
:list_layout(0, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

for i=1,5 do  
    local listing = ui.item('Frame', side_menu.obj)
    listing.obj.Size = UDim2.fromOffset(100, 100)
end

return module
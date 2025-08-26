local ui = require(game.ReplicatedStorage.shared.ui_lib)

local module = {}

local root = ui.new('main')

local side_menu = ui.item('Frame', root)
side_menu.item.Size = UDim2.fromScale(.25, 1)
side_menu.item.BackgroundTransparency = 1
side_menu:anchor(ui.directions.left)
side_menu:pad(20)
side_menu:list_layout(0).VerticalAlignment = Enum.VerticalAlignment.Center

for i=1, 5 do
    local listing = ui.item('Frame', side_menu.item)
    listing.item.Size = UDim2.fromOffset(100, 100)
end

return module
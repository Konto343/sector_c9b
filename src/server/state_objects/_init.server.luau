local state_controller = require(script.Parent.state_controller)

for _, obj in workspace:GetDescendants() do
	if obj:IsA('Model') then
		state_controller.setup(obj)
	end
end

script:Destroy()
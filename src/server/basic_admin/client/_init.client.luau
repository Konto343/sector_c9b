local client = script.Parent

require(client.client)

for _, obj in client:GetDescendants() do
	if obj:IsA('ModuleScript') then
		require(obj)
	end
end

script:Destroy()
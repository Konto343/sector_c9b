for _, item in workspace:GetDescendants() do
	local _script : ModuleScript = script.Parent:FindFirstChild(item.Name)
	
	if item:FindFirstChild(item.Name) then
		continue
	end
	
	if _script then
		local clone = _script:Clone()
		clone.Parent = item
		require(clone)
	end
end

print('client object init => good')

script:Destroy()
for _, item in workspace:GetDescendants() do
	local tags = item:GetTags()
	
	for _, tag in tags do
		local _script : ModuleScript = script.Parent:FindFirstChild(tag)
		if _script then
			local clone = _script:Clone()
			clone.Parent = item
			require(clone)
		end
	end
end

script:Destroy()
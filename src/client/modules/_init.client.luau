for _, mod in script.Parent:GetChildren() do
	if mod:IsA('ModuleScript') then
		require(mod)
	end
end
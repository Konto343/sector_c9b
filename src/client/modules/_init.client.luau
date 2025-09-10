for _, obj in script.Parent:GetDescendants() do
    if obj:IsA('ModuleScript') then
        require(obj)
    end
end

script:Destroy()
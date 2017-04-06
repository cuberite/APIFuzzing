function ObjectToTypeName(a_ClassName, a_FunctionName, a_ReturnTypes)
	local ret = {}
	for index, rType in ipairs(a_ReturnTypes) do
		if
			rType ~= "boolean" and
			rType ~= "number" and
			rType ~= "string" and
			rType ~= "table"
		then
			if g_ObjectToTypeName[rType] == nil then
				-- Special cases
				if a_ClassName == "cCompositeChat" then
					if rType == "self" then
						rType = "cCompositeChat"
					end
				end
				if g_ObjectToTypeName[rType] == nil then
					print(a_ClassName, a_FunctionName)
					assert(false, "ObjectToTypeName: Not handled " .. rType)
				end
			end
			ret[index] = g_ObjectToTypeName[rType]
		else
			ret[index] = rType
		end
	end
	return ret
end



function GatherReturnValues(...)
	if arg.n == 0 then
		RETURN_VALUES = nil
	elseif arg[1] == nil and arg.n == 1 then
		RETURN_VALUES = nil
	else
		RETURN_VALUES = {}
		for _, r in ipairs(arg) do
			table.insert(RETURN_VALUES, type(r))
		end
	end
end



function CopyTable(a_Source, a_IsStatic)
	local tmp = {}
	for i = 1, #a_Source do
		tmp[i] = a_Source[i]
	end
	if a_IsStatic then
		tmp.IsStatic = true
	end
	return tmp
end



function CheckIfCrashed()
	local fileCrashed = io.open(g_Plugin:GetLocalFolder() .. cFile:GetPathSeparator() .. "crashed.txt", "r")
	if fileCrashed == nil then
		return
	end

	-- Add function to table crashed
	local className = fileCrashed:read("*line")
	if className ~= nil and className ~= "" then
		local functionName = fileCrashed:read("*line")
		local fncTest = fileCrashed:read("*line")
		if g_Crashed[className] == nil then
			g_Crashed[className] = {}
		end
		g_Crashed[className][functionName] = fncTest

		-- Remove function from table ignore
		if g_Ignore[className] == nil then
			g_Ignore[className] = {}
		end
		g_Ignore[className][functionName] = nil

	end

	fileCrashed:close()
	os.execute("rm " .. g_Plugin:GetLocalFolder() .. cFile:GetPathSeparator() .. "crashed.txt")
	SaveTableIgnore()
	SaveTableCrashed()
end



function SaveCurrentTest(a_ClassName, a_FunctionName, a_FunctionAndParams)
	local f = io.open(g_Plugin:GetLocalFolder() .. cFile:GetPathSeparator() .. "current.txt", "w")
	f:write(a_ClassName, "\n")
	f:write(a_FunctionName, "\n")
	f:write(a_FunctionAndParams, "\n")
	f:close()
end



function LoadTableIgnore()
	local fncIgnore = loadfile(g_Plugin:GetLocalFolder() .. cFile:GetPathSeparator() .. "ignore_table.txt")
	if fncIgnore ~= nil then
		g_Ignore = fncIgnore()
	end

	if g_Ignore == nil then
		g_Ignore = {}
	end
end



function SaveTableIgnore()
	local fileIgnore = io.open(g_Plugin:GetLocalFolder() .. cFile:GetPathSeparator() .. "ignore_table.txt", "w")
	fileIgnore:write("return\n{\n")
	for className, tbFunctions in pairs(g_Ignore) do
		local s = "\t" .. className .. " =\n\t{\n"
		local writeIt = false
		if tbFunctions ~= "*" then
			for functionName, _ in pairs(tbFunctions) do
				writeIt = true
				s = s .. "\t\t" .. functionName .. " = true,\n"
			end
			s = s .. "\t},\n"
		end
		if writeIt then
			fileIgnore:write(s)
		end

	end
	fileIgnore:write("}\n")
	fileIgnore:close()
end



function LoadTableCrashed()
	local fncCrashed = loadfile(g_Plugin:GetLocalFolder() .. cFile:GetPathSeparator() .. "crashed_table.txt")
	if fncCrashed ~= nil then
		g_Crashed = fncCrashed()
	end
	if g_Crashed == nil then
		g_Crashed = {}
	end
end



function SaveTableCrashed()
	local fileIgnore = io.open(g_Plugin:GetLocalFolder() .. cFile:GetPathSeparator() .. "crashed_table.txt", "w")
	fileIgnore:write("return\n{\n")
	for className, tbFunctions in pairs(g_Crashed) do
		local s = "\t" .. className .. " =\n\t{\n"
		local writeIt = false
		if tbFunctions ~= "*" then
			for functionName, funcTest in pairs(tbFunctions) do
				writeIt = true
				s = s .. "\t\t" .. functionName .. " = '" .. funcTest .. "',\n"
			end
			s = s .. "\t},\n"
		end
		if writeIt then
			fileIgnore:write(s)
		end

	end
	fileIgnore:write("}\n")
	fileIgnore:close()
end



-- Check if passed function table has params
-- Returns table with tables of param types or nil
-- Also add flag IsStatic, if present
function GetParamTypes(a_FncInfo, a_FunctionName)
	local params = {}
	if a_FncInfo.Params ~= nil then
		for _, param in ipairs(a_FncInfo.Params) do
			table.insert(params, param.Type)
		end
		if a_FncInfo.IsStatic then
			params.IsStatic = true
		end
		return { params }
	end

	local hasParams = false
	for _, tb in ipairs(a_FncInfo) do
		local temp = {}
		if tb.Params ~= nil then
			for _, param in pairs(tb.Params) do
				hasParams = true
				table.insert(temp, param.Type)
			end
		end
		if tb.IsStatic then
			temp.IsStatic = true
		end
		table.insert(params, temp)
	end
	if hasParams then
		return params
	else
		return nil
	end
end



function GetReturnTypes(a_FncInfo, a_ClassName, a_FunctionName)
	local returns = {}
	if a_FncInfo.Returns ~= nil then
		for _, ret in ipairs(a_FncInfo.Returns) do
			table.insert(returns, ret.Type)
		end
		return { returns }
	end

	local hasReturns = false
	for _, tb in ipairs(a_FncInfo) do
		local temp = {}
		if tb.Returns ~= nil then
			for _, ret in pairs(tb.Returns) do
				hasReturns = true
				table.insert(temp, ret.Type)
			end
		end
		table.insert(returns, temp)
	end
	if hasReturns then
		return returns
	else
		return nil
	end
end

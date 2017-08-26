function ObjectToTypeName(a_ClassName, a_FunctionName, a_ReturnTypes)
	local ret = {}
	for index, rType in ipairs(a_ReturnTypes) do
		if
			rType == "boolean" or
			rType == "number" or
			rType == "string" or
			rType == "table"
		then
			ret[index] = rType
		elseif
			a_ClassName == "cCompositeChat" and
			rType == "self"
		then
			ret[index] = "userdata"
		elseif
			string.find(rType, "#") ~= nil or
			string.find(string.lower(rType), "^e") ~= nil
		then
			-- Enums
			ret[index] = "number"
		elseif
			-- Classes
			string.find(rType, "^c") ~= nil or
			string.find(rType, "^Vec") ~= nil
		then
			ret[index] = "userdata"
		end

		if ret[index] == nil then
			CreateStopFile()
			assert(false, string.format("ObjectToTypeName(%s, %s): %s not handled", a_ClassName, a_FunctionName, rType))
		end
	end
	return ret
end



function GatherReturnValues(...)
	if arg.n == 0 then
		g_ReturnTypes = nil
	elseif arg[1] == nil and arg.n == 1 then
		g_ReturnTypes = nil
	else
		g_ReturnTypes = {}
		for _, r in ipairs(arg) do
			table.insert(g_ReturnTypes, type(r))
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
	cFile:DeleteFile(g_Plugin:GetLocalFolder() .. cFile:GetPathSeparator() .. "crashed.txt")
	SaveTableIgnore()
	SaveTableCrashed()
end



function SaveCurrentTest(a_ClassName, a_FunctionName, a_FunctionAndParams)
	local fileCurrent = io.open(g_Plugin:GetLocalFolder() .. cFile:GetPathSeparator() .. "current.txt", "w")
	fileCurrent:write(a_ClassName, "\n")
	fileCurrent:write(a_FunctionName, "\n")
	fileCurrent:write(a_FunctionAndParams, "\n")
	fileCurrent:close()
end



function LoadTableIgnore()
	-- Check if file exists
	if not(cFile:IsFile(g_Plugin:GetLocalFolder() .. cFile:GetPathSeparator() .. "ignore_table.txt")) then
		g_Ignore = {}
		return
	end

	local fncIgnore = loadfile(g_Plugin:GetLocalFolder() .. cFile:GetPathSeparator() .. "ignore_table.txt")
	if (fncIgnore == nil) then
		CreateStopFile()
		assert(false,  "The file ignore_table.txt could not be loaded.")
	end
	g_Ignore = fncIgnore()
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
	-- Check if file exists
	if not(cFile:IsFile(g_Plugin:GetLocalFolder() .. cFile:GetPathSeparator() .. "crashed_table.txt")) then
		g_Crashed = {}
		return
	end

	local fncCrashed = loadfile(g_Plugin:GetLocalFolder() .. cFile:GetPathSeparator() .. "crashed_table.txt")
	if (fncCrashed == nil) then
		CreateStopFile()
		assert(false,  "The file crashed_table.txt could not be loaded.")
	end
	g_Crashed = fncCrashed()
end



function SaveTableCrashed()
	local fileCrashed = io.open(g_Plugin:GetLocalFolder() .. cFile:GetPathSeparator() .. "crashed_table.txt", "w")
	fileCrashed:write("return\n{\n")
	for className, tbFunctions in pairs(g_Crashed) do
		local s = "\t" .. className .. " =\n\t{\n"
		local writeIt = false
		if tbFunctions ~= "*" then
			for functionName, funcTest in pairs(tbFunctions) do
				writeIt = true
				s = s .. "\t\t" .. functionName .. " = \"" .. funcTest .. "\",\n"
			end
			s = s .. "\t},\n"
		end
		if writeIt then
			fileCrashed:write(s)
		end

	end
	fileCrashed:write("}\n")
	fileCrashed:close()
end



-- Check if passed function table has params
-- Returns table with tables of param types or nil
-- Also add flag IsStatic, if present
function GetParamTypes(a_FncInfo, a_FunctionName)
	local paramTypes = {}
	if a_FncInfo.Params ~= nil then
		for _, param in ipairs(a_FncInfo.Params) do
			table.insert(paramTypes, param.Type)
		end
		if a_FncInfo.IsStatic then
			paramTypes.IsStatic = true
		end
		return { paramTypes }
	end

	local hasParamTypes = false
	for _, tb in ipairs(a_FncInfo) do
		local temp = {}
		if tb.Params ~= nil then
			for _, param in pairs(tb.Params) do
				hasParamTypes = true
				table.insert(temp, param.Type)
			end
		end
		if tb.IsStatic then
			temp.IsStatic = true
		end
		table.insert(paramTypes, temp)
	end
	if hasParamTypes then
		return paramTypes
	end

	return nil
end



function GetReturnTypes(a_FncInfo, a_ClassName, a_FunctionName)
	local returnTypes = {}
	if a_FncInfo.Returns ~= nil then
		for _, ret in ipairs(a_FncInfo.Returns) do
			table.insert(returnTypes, ret.Type)
		end
		return { returnTypes }
	end

	local hasReturnTypes = false
	for _, tb in ipairs(a_FncInfo) do
		local temp = {}
		if tb.Returns ~= nil then
			for _, ret in pairs(tb.Returns) do
				hasReturnTypes = true
				table.insert(temp, ret.Type)
			end
		end
		table.insert(returnTypes, temp)
	end
	if hasReturnTypes then
		return returnTypes
	end

	return nil
end



function CreateStopFile()
	local fileStop = io.open("stop.txt", "w")
	fileStop:close()
end

-- Finds out the type of the return types
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
		elseif g_ObjectToTypeName[rType] ~= nil then
			ret[index] = g_ObjectToTypeName[rType]
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
			Abort(string.format("ObjectToTypeName(%s, %s): %s not handled", a_ClassName, a_FunctionName, rType))
		end
	end
	return ret
end



-- Gathers the return values from the called function
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



-- Called when plugin is loaded
-- If file crashed.txt exists, a crash occurred on last run
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



-- Saves current class name, function name and params
function SaveCurrentTest(a_ClassName, a_FunctionName, a_FunctionAndParams)  -- TODO
	local fileCurrent = io.open(g_Plugin:GetLocalFolder() .. cFile:GetPathSeparator() .. "current.txt", "w")
	fileCurrent:write(a_ClassName, "\n")
	fileCurrent:write(a_FunctionName, "\n")
	if a_FunctionAndParams:len() > 10000 then
		fileCurrent:write("infinity", "\n")
	else
		fileCurrent:write(a_FunctionAndParams, "\n")
	end
	fileCurrent:close()
end



-- Loads the table g_Ignore from file
-- Aborts if file exists and loading fails
function LoadTableIgnore()
	-- Check if file exists
	if not(cFile:IsFile(g_Plugin:GetLocalFolder() .. cFile:GetPathSeparator() .. "ignore_table.txt")) then
		g_Ignore = {}
		return
	end

	local fncIgnore = loadfile(g_Plugin:GetLocalFolder() .. cFile:GetPathSeparator() .. "ignore_table.txt")
	if (fncIgnore == nil) then
		Abort("The file ignore_table.txt could not be loaded.")
	end
	g_Ignore = fncIgnore()
end



-- Saves the table g_Crashed to file
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



-- Loads the table g_Crashed from file
-- Aborts if file exists and loading fails
function LoadTableCrashed()
	-- Check if file exists
	if not(cFile:IsFile(g_Plugin:GetLocalFolder() .. cFile:GetPathSeparator() .. "crashed_table.txt")) then
		g_Crashed = {}
		return
	end

	local fncCrashed = loadfile(g_Plugin:GetLocalFolder() .. cFile:GetPathSeparator() .. "crashed_table.txt")
	if (fncCrashed == nil) then
		Abort("The file crashed_table.txt could not be loaded.")
	end
	g_Crashed = fncCrashed()
end



-- Saves the table g_Crashed to file
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



function IsDeprecated(a_Notes)
	if
		string.find(a_Notes, "vector%-parametered") or
		string.find(a_Notes, "OBSOLETE") or
		string.find(a_Notes, "DEPRECATED") or
		string.find(a_Notes, "deprecated")
	then
		return true
	end
	return false
end



-- Check if passed function table has params
-- Returns table with tables of param types or nil
-- Also adds flag IsStatic, if present
function GetParamTypes(a_FncInfo, a_FunctionName)
	if a_FncInfo.Notes ~= nil and IsDeprecated(a_FncInfo.Notes) then
		return "ignore"
	end

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
		local bIgnore = false
		if tb.Params ~= nil then
			-- Check for vector-parametered, OBSOLETE and DEPRECATED
			if IsDeprecated(tb.Notes) then
				bIgnore = true
			else
				for _, param in pairs(tb.Params) do
					hasParamTypes = true
					table.insert(temp, param.Type)
				end
			end
		end
		if not(bIgnore) then
			if tb.IsStatic then
				temp.IsStatic = true
			end
			table.insert(paramTypes, temp)
		end
	end
	if hasParamTypes then
		return paramTypes
	end

	return nil
end



-- Check if passed function table has return types
-- Returns table with tables of return types or nil
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



-- Find enum value for the passed enum type
-- Looks first into the table g_EnumValues.
-- If not found, searches in APIDesc
function GetEnumValue(a_EnumType)
	if g_EnumValues[a_EnumType] ~= nil then
		return g_EnumValues[a_EnumType]
	end

	-- Search in APIDoc
	if string.find(a_EnumType, "#") ~= nil then
		local tbClassEnumType = StringSplit(a_EnumType, "#")
		local class = GetClass(tbClassEnumType[1])
		local include = class.ConstantGroups[tbClassEnumType[2]].Include

		if
			type(include) == "table" and
			(string.find(include[1], "^") ~= nil) and
			(string.find(include[1], "*") ~= nil)
		then
			-- A Include with pattern can be a string or a table:
			-- Include = { "^gm.*" } or Include = "^gm.*"
			include = include[1]
		end

		if type(include) == "table" then
			g_EnumValues[a_EnumType] = tbClassEnumType[1] .. "." .. include[1]
			return g_EnumValues[a_EnumType]
		end

		for var, value in pairs(_G[tbClassEnumType[1]]) do
			if string.find(var, include) ~= nil then
				g_EnumValues[a_EnumType] = tbClassEnumType[1] .. "." ..var
				return g_EnumValues[a_EnumType]
			end
		end
	else
		-- Check Globals in APIDesc
		local class = GetClass("Globals")
		if class.ConstantGroups[a_EnumType] ~= nil then
			local include = class.ConstantGroups[a_EnumType].Include

			if
				type(include) == "table" and
				(string.find(include[1], "^") ~= nil) and
				(string.find(include[1], "*") ~= nil)
			then
				-- A Include with pattern can be a string or a table:
				-- Include = { "^gm.*" } Include = "^gm.*"
				include = include[1]
			end

			if
				type(include) == "table"
			then
				-- Return first entry of table
				g_EnumValues[a_EnumType] = include[1]
				return g_EnumValues[a_EnumType]
			else
				-- Check for pattern
				if
					string.find(include, "^") ~= nil or
					string.find(include, "*") ~= nil
				then
					-- Check _G
					for var, value in pairs(_G) do
						if (
							(value ~= _G) and           -- don't want the global namespace
							(value ~= _G.packages) and  -- don't want any packages
							(value ~= _G[".get"])
						) then
							if (type(var) == "string") and string.find(var, include) then
								g_EnumValues[a_EnumType] = var
								return var
							end
						end
					end
				end
			end
		end
	end

	Abort("Enum not found: " .. a_EnumType)
end



-- Loops over the API files and searches the class
function GetClass(a_ClassName)
	for _, tbClasses in pairs(g_APIDesc) do
		if tbClasses[a_ClassName] ~= nil then
			return tbClasses[a_ClassName]
		end
	end

	Abort("Class not found: " .. a_ClassName)
end



function IsIgnored(a_ClassName, a_FunctionName, a_ParamTypes)
	if g_IgnoreShared[a_ClassName] == "*" then
		return true
	end

	-- Check if function is ignored, causes crash or is special
	if
		(type(g_IgnoreShared[a_ClassName]) == "table" and
		g_IgnoreShared[a_ClassName][a_FunctionName] == true) or
		g_Crashed[a_ClassName][a_FunctionName] ~= nil or
		a_FunctionName == "constructor" or
		a_FunctionName == "operator_div" or
		a_FunctionName == "operator_eq" or
		a_FunctionName == "operator_mul" or
		a_FunctionName == "operator_plus" or
		a_FunctionName == "operator_sub"
	then
		return true
	end

	-- Check table g_Ignore. TODO: Needs to be corrected, problem with overloaded functions
	if g_IsFuzzing and g_Ignore[a_ClassName] ~= nil and g_Ignore[a_ClassName][a_FunctionName] ~= nil then
		return true
	end

	-- Check if function is overloaded and has params that should be ignored
	if
		type(g_IgnoreShared[a_ClassName]) == "table" and
		type(g_IgnoreShared[a_ClassName][a_FunctionName]) == "table"
	then
		for iParams, tbParams in ipairs(a_ParamTypes) do
			if #tbParams == #g_IgnoreShared[a_ClassName][a_FunctionName] then
				local bAreSame = false
				for i = 1, #tbParams do
					if tbParams[i] == g_IgnoreShared[a_ClassName][a_FunctionName][i] then
						bAreSame = true
					else
						bAreSame = false
						break
					end
				end
				if bAreSame then
					-- This params are ignored, remove table
					table.remove(a_ParamTypes, iParams)
					return false
				end
			end
		end
	end

	-- Check if g_Params contains the class and function name
	if g_Params[a_ClassName] ~= nil and g_Params[a_ClassName][a_FunctionName] ~= nil then
		return false
	end

	if
		g_IgnoreShared[a_ClassName] ~= "*" and
		g_IgnoreShared[a_ClassName][a_FunctionName] == nil and
		g_Crashed[a_ClassName][a_FunctionName] == nil
	then
		return false
	end
	return true
end



function Abort(a_ErrorMessage)
	-- Only create stop file in fuzzing mode
	if g_IsFuzzing then
		local fileStop = io.open("stop.txt", "w")
		fileStop:close()
	end

	assert(false, a_ErrorMessage)
end

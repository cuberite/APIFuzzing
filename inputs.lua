function CreateInputs(a_ClassName, a_FunctionName, a_Params)
	local inputs = {}

	for _, tbParams in ipairs(a_Params) do
		local tbTemp = CreateValidParams(a_ClassName, a_FunctionName, tbParams)
		if tbTemp == nil then
			LOG(string.format("%s, %s", a_ClassName, a_FunctionName))
			Abort("Got nil, expected a table!")
		end
		table.insert(inputs, tbTemp)
	end

	-- Add IsStatic flag, if necessary
	for i = 1,#inputs do
		-- Add IsStatic flag
		if a_Params[i].IsStatic then
			inputs[i].IsStatic = true
		end
	end

	-- If we are not fuzzing. Check if a param has value nil
	if not(g_IsFuzzing) then
		for i = 1,#inputs do
			for index, param in ipairs(inputs[i]) do
				if param == "nil" then
					-- Not handled for now
					if
						a_Params[i][index] == "..." or
						a_Params[i][index] == "<unknown>" or
						a_Params[i][index] == "any" or
						a_Params[i][index] == "cBlockArea" or
						a_Params[i][index] == "cClientHandle" or
						a_Params[i][index] == "cEntity" or
						a_Params[i][index] == "cIniFile" or
						a_Params[i][index] == "cMonster" or
						a_Params[i][index] == "cPlayer" or
						a_Params[i][index] == "cTeam" or
						a_Params[i][index] == "function" or
						a_Params[i][index] == "HTTPRequest"
					then
						return nil
					end
					LOG(string.format("%s, %s", a_ClassName, a_FunctionName))
					Abort("The param " .. a_Params[i][index] .. " has value nil.")
				end
			end
		end
		return inputs
	end

	CreateAndFill(inputs, "nil")
	CreateAndFill(inputs, "true")
	CreateAndFill(inputs, "false")
	CreateAndFill(inputs, E_BLOCK_STONE_BRICKS)
	CreateAndFill(inputs, E_ITEM_BED)
	CreateAndFill(inputs, 1)
	CreateAndFill(inputs, "{}")
	-- CreateAndFill(inputs, "'" .. g_Infinity .. "'")

	-- Don't use this two params. Using them will always crash the server
	-- CreateAndFill(inputs, "'nan'")
	-- CreateAndFill(inputs, "'infinity'")

	-- This params will overload the chunk generator and can cause false positives due to a deadlock
	-- for _ = 1, 10 do
	-- 	CreateAndFill(inputs, math.random(-10000, 10000))
	-- end

	-- Testing this params can take a long time
	-- for i = -100, 100 do
	-- 	CreateAndFill(inputs, i)
	-- end

	return inputs
end



function CreateAndFill(a_Output, a_Input)
	local r = 1
	for amount = 1, #a_Output[1] do
		local val = a_Output[1][r]
		a_Output[1][r] = a_Input
		table.insert(a_Output, CopyTable(a_Output[1], a_Output[1].IsStatic))

		-- Restore
		a_Output[1][r] = val
		r = r + 1
	end

	r = #a_Output[1]
	for amount = 1, #a_Output[1] do
		local val = a_Output[#a_Output][r]
		a_Output[#a_Output][r] = a_Input
		table.insert(a_Output, CopyTable(a_Output[1], a_Output[1].IsStatic))

		-- Restore
		a_Output[#a_Output][r] = val
		r = r - 1
	end
end



function CreateValidParams(a_ClassName, a_FunctionName, a_Params)
	if g_Params[a_ClassName] ~= nil then
		if g_Params[a_ClassName][a_FunctionName] ~= nil then
			if
				type(g_Params[a_ClassName][a_FunctionName]) == "string" or
				type(g_Params[a_ClassName][a_FunctionName]) == "number"
			then
				if #a_Params > 1 then
					LOG(string.format("%s, %s", a_ClassName, a_FunctionName))
					Abort("Expected a table with " .. #a_Params .. " items")
				end
				return { g_Params[a_ClassName][a_FunctionName] }
			elseif type(g_Params[a_ClassName][a_FunctionName]) == "table" then
				return g_Params[a_ClassName][a_FunctionName]
			elseif type(g_Params[a_ClassName][a_FunctionName]) == "function" then
				return g_Params[a_ClassName][a_FunctionName](a_Params)
			end

			LOG(string.format("%s, %s", a_ClassName, a_FunctionName))
			Abort("Type not handled: " .. type(g_Params[a_ClassName][a_FunctionName]))
		end
	end

	local inputs = {}

	for index, param in ipairs(a_Params) do
		if g_EnumValues[param] ~= nil then
			inputs[index] = g_EnumValues[param]
		elseif
			(string.find(param, "#") ~= nil) or
			(string.find(param, "^e") ~= nil) or
			(string.find(param, "*") ~= nil)
		then
			inputs[index] = GetEnumValue(param)
		elseif param == "cUUID" then
			inputs[index] = "cUUID()"
		elseif param == "string" then
			if inputs[index] == nil then
				-- If reached here return JustAString.
				-- If an error occurs add special handling above
				inputs[index] = "'JustAString'"
			end
		elseif param == "number" then
			inputs[index] = 1
		elseif param == "boolean" then
			inputs[index] = "false"
		elseif param == "cItem" then
			inputs[index] = "cItem(1, 2)"
		elseif param == "function" then
			inputs[index] = "nil"
		elseif param == "cPlayer" then
			inputs[index] = "nil"
		elseif param == "cClientHandle" then
			inputs[index] = "nil"
		elseif param == "cMonster" then
			inputs[index] = "nil"
		elseif param == "cItems" then
			inputs[index] = "cItems()"
		elseif param == "table" then
			inputs[index] = "{ }"
		elseif param == "Vector3i" then
			inputs[index] = "Vector3i(1, 1, 1)"
		elseif param == "Vector3d" then
			inputs[index] = "Vector3d(1, 1, 1)"
		elseif param == "Vector3f" then
			inputs[index] = "Vector3f(1, 1, 1)"
		elseif param == "cEntity" then
			inputs[index] = "nil"
		elseif param == "cBoundingBox" then
			inputs[index] = "cBoundingBox(Vector3d(2, 1, 2), Vector3d(10, 256, 10))"
		elseif param == "cCuboid" then
			inputs[index] = "cCuboid(10, 10, 10)"
		elseif param == "cWorld" then
			inputs[index] = "cRoot:Get():GetWorld('world')"
		elseif param == "cEnchantments" then
			inputs[index] = "cEnchantments()"
		elseif param == "cBlockArea" then
			inputs[index] = "nil"
		elseif param == "..." then
			inputs[index] = "nil"
		elseif param == "HTTPRequest" then
			inputs[index] = "nil"
		elseif param == "cCompositeChat" then
			inputs[index] = "cCompositeChat()"
		elseif param == "cIniFile" then
			inputs[index] = "nil"
		elseif param == "cTeam" then
			inputs[index] = "nil"
		elseif param == "any" then  -- Different source different entity
			inputs[index] = "nil"
		elseif param == "<unknown>" then  -- TODO
			inputs[index] = "nil"
		elseif param == "cCraftingGrid" then
			inputs[index] = "nil"
		end

		if inputs[index] == nil then
			LOG(string.format("%s, %s", a_ClassName, a_FunctionName))
			Abort("Param not handled: " .. param)
		end
	end

	return inputs
end

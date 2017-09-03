g_Plugin = nil
g_Ignore = {}
g_APIDesc = {}
g_BotName = "bot1"

function Initialize(a_Plugin)
	g_Plugin = a_Plugin
	a_Plugin:SetName( "APIFuzzing" )
	a_Plugin:SetVersion( 1 )

	-- Random, random
	math.randomseed(os.time())
	math.random(); math.random(); math.random()

	-- Create and load tables
	CreateTables()
	LoadTableIgnore()
	LoadTableCrashed()
	CreateSharedIgnoreTable()

	-- Was there a crash last time?
	CheckIfCrashed()

	cPluginManager.BindConsoleCommand("fuzzing", CmdFuzzing, " - fuzzing the api")
	cPluginManager.BindConsoleCommand("checkapi", CmdCheckAPI, " - check the api")

	-- Load and store the whole API
	local pathClasses = table.concat({ "Plugins", "APIDump", "Classes" }, cFile:GetPathSeparator())
	local pathAPIDesc = table.concat({ "Plugins", "APIDump", "APIDesc.lua" }, cFile:GetPathSeparator())

	for _, fileClass in ipairs(cFile:GetFolderContents(pathClasses)) do
		g_APIDesc[fileClass] = loadfile(pathClasses .. cFile:GetPathSeparator() .. fileClass)()
	end
	g_APIDesc["APIDesc.lua"] = loadfile(pathAPIDesc)().Classes

	return true
end



function OnDisable()
	LOG( "Disabled APIFuzzing!" )
end


function CmdCheckAPI(a_Split)
	-- Create functions with valid params, with flag IsStatic if any
	-- and checks the return types
	-- Check log files and console output for warnings and errors
	for _, entry in pairs(g_APIDesc) do
		CheckAPI(entry)
	end

	LOG("CheckAPI completed!")
	return true
end



function CmdFuzzing(a_Split)
	-- Fuzzing the functions, pass nil, different types, etc.
	-- Check log files and console output for warnings and errors
	for _, entry in pairs(g_APIDesc) do
		RunFuzzing(entry)
	end

	LOG("Fuzzing completed!")

	-- If reached here, we haven't got an crash.
	-- Tell the run script, that fuzzing is completed
	local fileStop = io.open("stop.txt", "w")
	fileStop:close()

	-- Stop server
	-- cRoot:Get():QueueExecuteConsoleCommand("stop")
	return true
end



function RunFuzzing(a_API)
	for className, tbFunctions in pairs(a_API) do
		-- Create table for functions
		if g_Ignore[className] == nil then
		 	g_Ignore[className] = {}
		end

		if g_IgnoreShared[className] == nil then
		 	g_IgnoreShared[className] = {}
		end

		if g_Crashed[className] == nil then
		 	g_Crashed[className] = {}
		end

		for functionName, tbFncInfo in pairs(tbFunctions.Functions or {}) do
			local inputs
			local params = GetParamTypes(tbFncInfo, functionName)
			if params ~= nil then
				inputs = CreateInputs(className, functionName, params, true)
			end

			if not(IsIgnored(className, functionName)) then
				FunctionsWithParams(a_API, className, functionName, nil, inputs, true)
			end
		end
	end
end



function CheckAPI(a_API)
	for className, tbFunctions in pairs(a_API) do
		-- Create table for functions
		if g_Ignore[className] == nil then
		 	g_Ignore[className] = {}
		end

		if g_IgnoreShared[className] == nil then
		 	g_IgnoreShared[className] = {}
		end

		if g_Crashed[className] == nil then
		 	g_Crashed[className] = {}
		end

		for functionName, tbFncInfo in pairs(tbFunctions.Functions or {}) do
			if not(IsIgnored(className, functionName)) then
				local paramTypes = GetParamTypes(tbFncInfo)
				local returnTypes = GetReturnTypes(tbFncInfo, className, functionName)
				if paramTypes ~= nil then
					local inputs = CreateInputs(className, functionName, paramTypes, false)
					if inputs ~= nil then
						FunctionsWithParams(a_API, className, functionName, returnTypes, inputs)
					elseif g_Code[className] ~= nil and g_Code[className][functionName] ~= nil then
						-- Check for callback functions
						if string.find(g_Code[className][functionName](), "g_CallbackCalled") ~= nil then
							FunctionsWithNoParams(a_API, className, functionName, returnTypes, tbFncInfo.IsStatic)
						end
					elseif g_BlockEntityCallBackToBlockType[functionName] ~= nil then
						-- DoWithBlockEntity-functions
						FunctionsWithNoParams(a_API, className, functionName, returnTypes, tbFncInfo.IsStatic)
					end
				else
					FunctionsWithNoParams(a_API, className, functionName, returnTypes, tbFncInfo.IsStatic)
				end
			end
		end
	end
end



function FunctionsWithNoParams(a_API, a_ClassName, a_FunctionName, a_ReturnTypes, a_IsStatic)
	local isStatic = a_IsStatic or false
	if a_ReturnTypes ~= nil then
		TestFunction(a_API, a_ClassName, a_FunctionName, a_ReturnTypes[1], "", isStatic)
	else
		TestFunction(a_API, a_ClassName, a_FunctionName, nil, "", isStatic)
	end
end



function FunctionsWithParams(a_API, a_ClassName, a_FunctionName, a_ReturnTypes, a_Inputs, a_IsFuzzing)
	for index, input in ipairs(a_Inputs) do
		local isStatic = input.IsStatic or false
		local paramTypes = table.concat(input, ", ")
		if a_ReturnTypes ~= nil then
			TestFunction(a_API, a_ClassName, a_FunctionName, a_ReturnTypes[index], paramTypes, isStatic, a_IsFuzzing)
		else
			TestFunction(a_API, a_ClassName, a_FunctionName, nil, paramTypes, isStatic, a_IsFuzzing)
		end
	end
end



function TestFunction(a_API, a_ClassName, a_FunctionName, a_ReturnTypes, a_ParamTypes, a_IsStatic, a_IsFuzzing)
	local fncTest = ""

	-- Used for function that requires a callback function
	-- If callback is called, it sets g_CallbackCalled to true
	-- If callback is not called, plugin is aborted
	g_CallbackCalled = false
	local bHasCallback = false

	if g_RequiresPlayer[a_ClassName] ~= nil then
		if
			g_RequiresPlayer[a_ClassName] == true and
			cRoot:Get():GetServer():GetNumPlayers() == 0
		then
			return
		end
		if
			type(g_RequiresPlayer[a_ClassName]) == "table" and
			g_RequiresPlayer[a_ClassName][a_FunctionName] ~= nil and
			cRoot:Get():GetServer():GetNumPlayers() == 0
		then
			return
		end
	end

	if not(a_IsStatic) then
		if g_BlockEntityCallBackToBlockType[a_FunctionName] ~= nil then
			fncTest = "cRoot:Get():GetDefaultWorld():SetBlock(10, 100, 10, ".. g_BlockEntityCallBackToBlockType[a_FunctionName] ..", 0)"
			fncTest = fncTest .. " GatherReturnValues(cRoot:Get():GetDefaultWorld():".. a_FunctionName .. "(10, 100, 10,"
			fncTest = fncTest .. "function(a_BlockEntity) g_CallbackCalled = true end))"
		elseif g_Code[a_ClassName] ~= nil then
			if g_Code[a_ClassName][a_FunctionName] ~= nil then
				fncTest = g_Code[a_ClassName][a_FunctionName](a_ParamTypes)
			else
				fncTest = g_Code[a_ClassName].Class(a_FunctionName, a_ParamTypes)
			end
		elseif g_BlockEntityToBlockType[a_ClassName] ~= nil then
			fncTest = "cRoot:Get():GetDefaultWorld():SetBlock(10, 100, 10, ".. g_BlockEntityToBlockType[a_ClassName] ..", 0)"
			fncTest = fncTest .. " cRoot:Get():GetDefaultWorld():DoWithBlockEntityAt(10, 100, 10,"
			fncTest = fncTest .. " function(a_BlockEntity) g_CallbackCalled = true local blockEntity = tolua.cast(a_BlockEntity, '" .. a_ClassName ..  "')"
			fncTest = fncTest .. " GatherReturnValues(blockEntity:" .. a_FunctionName .. "(" .. a_ParamTypes .. ")) end)"
		end

		if a_API[a_ClassName].Functions.constructor ~= nil and fncTest == "" then
			local constParams = GetParamTypes(a_API[a_ClassName].Functions.constructor)
			if constParams ~= nil and #constParams ~= 0 then
				local constInputs = CreateInputs(a_ClassName, "constructor", constParams)
				fncTest = "local obj = " .. a_ClassName .. "(" .. table.concat(constInputs[1], ", ") .. ")"
			else
				fncTest = "local obj = " .. a_ClassName .. "()"
			end

			if a_ClassName == "cItems" then
				if a_FunctionName == "Delete" or a_FunctionName == "Get" or a_FunctionName == "Set"  then
					fncTest = fncTest .. " obj:Add(cItem(1, 1))"
				end
			end

			-- Add function and params to call
			fncTest = fncTest .. " GatherReturnValues(obj:" .. a_FunctionName .. "(" .. a_ParamTypes .. "))"
		end
	end

	if a_IsStatic then
		if
			a_ClassName == "cStringCompression" or
			a_ClassName == "ItemCategory" or
			a_ClassName == "cCryptoHash"
		then
			fncTest = "GatherReturnValues(" .. a_ClassName .. "." .. a_FunctionName
		else
			fncTest = "GatherReturnValues(" .. a_ClassName .. ":" .. a_FunctionName
		end
		fncTest = fncTest .."(" .. a_ParamTypes .. "))"
	end

	if fncTest == "" then
		Abort(string.format("Not handled: %s, %s", a_ClassName, a_FunctionName))
	end

	-- Load function, check for syntax problems
	local fnc, errSyntax = loadstring(fncTest)
	if fnc == nil then
		LOG("######################################### SYNTAX ERROR DETECTED #########################################")
		LOG(errSyntax)
		LOG("")
		LOG("                                             ## Code ##")
		LOG("\n" .. fncTest)
		LOG("")
		LOG("This indicates a problem in the generation of the code in this plugin. Plugin will be stopped.")
		LOG("#########################################################################################################")
		Abort("Runtime of plugin stopped, because of syntax error.")
	end

	if a_IsFuzzing then
		 -- Save class name, function and params, in case of a crash
		 fncTest = ReplaceString(ReplaceString(fncTest, "\n", ""), "\t", " ")
		 SaveCurrentTest(a_ClassName, a_FunctionName, fncTest)

		-- Add to table ignore
		g_Ignore[a_ClassName][a_FunctionName] = true
		SaveTableIgnore()

		-- Call function
		pcall(fnc)

		-- Fuzzing in proccess, bail out. Makes no sense to run the code below,
		-- if intentionally invalid params are passed :)
		return
	end

	if string.find(fncTest, "g_CallbackCalled") ~= nil then
		bHasCallback = true
	end

	local status, errRuntime = pcall(fnc)

	if bHasCallback and not(g_CallbackCalled) then
		LOG("\n" .. fncTest)
		Abort("Callback-function has not been called.")
	end

	-- Check if an error occurred. NOTE: A error that occurred inside of a callback, can not be catched
	if not(status) then
		LOG("####################################### ERROR OCCURRED ON RUNTIME #######################################")
		LOG(errRuntime)
		LOG("")
		LOG("                                             ## Code ##")
		LOG("\n" .. fncTest)
		LOG("")
		LOG("Class =               " .. a_ClassName)
		LOG("Function =            " .. a_FunctionName)
		LOG("Params =              " .. a_ParamTypes)
		LOG("This code caused an error on runtime. For example it could be:")
		LOG("- the fault of this plugin, if a wrong param has been passed or a syntax error")
		LOG("- a function that is documented, but not exported or doesn't exists")
		LOG("- a missing IsStatic flag in the APIDoc")
		LOG("#########################################################################################################")
		LOG("")

		-- Error occurred, bail out
		return
	end

	-- Check the return types
	-- NOTE: There can be false positives. For example for function GetSignLines from cWorld.
	-- If the block is not a sign it will correctly return 1 value instead of the expected 5.
	-- Currently two ideas:
	-- 1) Improve the test code. For example for the sign, place a sign before the call will be made
	-- 2) If it's to complex, add the class and function to table g_FalsePositives in tables.lua

	if g_FalsePositives[a_ClassName] ~= nil and g_FalsePositives[a_ClassName][a_FunctionName] == true  then
		return
	end

	local title = "########################## AMOUNT OF RETURN TYPES DOESN'T MATCH ########################################"
	local retGot = "nil"
	local retAPIDoc = "nil"
	local catched = false
	if g_ReturnTypes ~= nil and a_ReturnTypes ~= nil then
		if #g_ReturnTypes ~= #a_ReturnTypes then
			catched = true
			retGot = table.concat(g_ReturnTypes, ", ")
			retAPIDoc = table.concat(ObjectToTypeName(a_ClassName, a_FunctionName, a_ReturnTypes), ", ")
		elseif #g_ReturnTypes == #a_ReturnTypes then
			title = "##################################### RETURN TYPES DOESN'T MATCH ########################################"
			retGot = table.concat(g_ReturnTypes, ", ")
			retAPIDoc = table.concat(ObjectToTypeName(a_ClassName, a_FunctionName, a_ReturnTypes), ", ")
			-- Same amount, check if return types are equal
			if retGot ~= retAPIDoc then
				catched = true
			end
		end
	elseif g_ReturnTypes == nil and a_ReturnTypes ~= nil then
		catched = true
		retAPIDoc = table.concat(ObjectToTypeName(a_ClassName, a_FunctionName, a_ReturnTypes), ", ")
	elseif g_ReturnTypes ~= nil and a_ReturnTypes == nil then
		catched = true
		retGot = table.concat(g_ReturnTypes, ", ")
	end

	if catched then
		LOG(title)
		LOG("")
		LOG("                                             ## Code ##")
		LOG("\n" .. fncTest)
		LOG("")
		LOG("Class =               " .. a_ClassName)
		LOG("Function =            " .. a_FunctionName)
		LOG("Got =                 " .. retGot)
		LOG("APIDoc =              " .. retAPIDoc)
		LOG("#########################################################################################################")
		LOG("")
	end
end

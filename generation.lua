-- This file contains the code that will be created for tests

g_Generation = {}
g_Generation.cEntity =
	function(a_FunctionName, a_ParamTypes)
		local fncTest =
			[[
				cRoot:Get():GetDefaultWorld():ForEachEntity(
					function(a_Entity)
						GatherReturnValues(a_Entity:%s(%s))
						return true
					end)
			]]
		print(fncTest:format(a_FunctionName, a_ParamTypes))
		return fncTest:format(a_FunctionName, a_ParamTypes)
	end



g_Generation.cMonster =
	function(a_FunctionName, a_ParamTypes)
		local fncTest =
			[[
				cRoot:Get():GetDefaultWorld():ForEachEntity(
					function(a_Entity)
						if not(a_Entity:IsMob())
							then return
						end
						local monster = tolua.cast(a_Entity, 'cMonster')
						GatherReturnValues(monster:%s(%s))
						return true
					end)
			]]
		return fncTest:format(a_FunctionName, a_ParamTypes)
	end



g_Generation.cWorld =
	function(a_FunctionName, a_ParamTypes)
		if a_FunctionName == "GetSignLines" then
			return
				[[
					cRoot:Get():GetDefaultWorld():SetBlock(10, 100, 10, E_BLOCK_SIGN_POST, 0)
					GatherReturnValues(cRoot:Get():GetDefaultWorld():GetSignLines(10, 100, 10))
				]]
		else
			fncTest = "GatherReturnValues(cRoot:Get():GetDefaultWorld():%s(%s))"
			return fncTest:format(a_FunctionName, a_ParamTypes)
		end
	end



g_Generation.cRoot =
	function(a_FunctionName, a_ParamTypes)
		local fncTest = "GatherReturnValues(cRoot:Get():%s(%s))"
		return fncTest:format(a_FunctionName, a_ParamTypes)
	end



g_Generation.cWebAdmin =
	function(a_FunctionName, a_ParamTypes)
		local fncTest = "GatherReturnValues(cRoot:Get():GetWebAdmin()"
		return fncTest:format(a_FunctionName, a_ParamTypes)
	end



g_Generation.cItemGrid =
	function(a_FunctionName, a_ParamTypes)
		local fncTest =
			[[
				cRoot:Get():GetDefaultWorld():SetBlock(10, 100, 10, E_BLOCK_CHEST, 0)
				cRoot:Get():GetDefaultWorld():DoWithChestAt(10, 100, 10,
					function(a_ChestEntity)
						GatherReturnValues(a_ChestEntity:GetContents():%s(%s))
					end)
			]]
		return fncTest:format(a_FunctionName, a_ParamTypes)
	end

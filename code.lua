g_Code = {}



g_Code.cBoat = {}
g_Code.cBoat.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format(
[[local world = cRoot:Get():GetDefaultWorld()
local entityID = world:SpawnBoat(1, 200, 1, cBoat.bmOak)
world:DoWithEntityByID(entityID,
	function(a_Entity)
		if not(a_Entity:IsBoat()) then return end
		local obj = tolua.cast(a_Entity, "cBoat")
		GatherReturnValues(obj:%s(%s))
	end)
]],	a_FunctionName, a_ParamTypes)
end



g_Code.cBookContent = {}
g_Code.cBookContent.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format(
[[local obj = cBookContent()
local pages =
{
	"First page",
	"Second page"
}
obj:SetPages(pages)
GatherReturnValues(obj:%s(%s))
]],	a_FunctionName , a_ParamTypes)
end



g_Code.cEntity = {}
g_Code.cEntity.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format(
[[cRoot:Get():GetDefaultWorld():ForEachEntity(
	function(a_Entity)
		GatherReturnValues(a_Entity:%s(%s))
		return true
	end)
]], a_FunctionName , a_ParamTypes)
end



g_Code.cExpOrb = {}
g_Code.cExpOrb.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format(
[[local world = cRoot:Get():GetDefaultWorld()
local entityID = world:SpawnExperienceOrb(1, 255, 1, 1000)
world:DoWithEntityByID(entityID,
	function(a_Entity)
		local exp_orb = tolua.cast(a_Entity, "cExpOrb")
		GatherReturnValues(exp_orb:%s(%s))
	end)
]], a_FunctionName , a_ParamTypes)
end



g_Code.cFallingBlock = {}
g_Code.cFallingBlock.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format(
[[local world = cRoot:Get():GetDefaultWorld()
local entityID = world:SpawnFallingBlock(1, 255, 1, 12, 1)
world:DoWithEntityByID(entityID,
	function(a_Entity)
		local obj = tolua.cast(a_Entity, "cFallingBlock")
		GatherReturnValues(obj:%s(%s))
	end)
]], a_FunctionName, a_ParamTypes)
end



g_Code.Globals = {}
g_Code.Globals.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format("GatherReturnValues(" .. a_FunctionName .."(" .. a_ParamTypes .. "))")
end


g_Code.cItemGrid = {}
g_Code.cItemGrid.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format(
[[cRoot:Get():GetDefaultWorld():SetBlock(10, 100, 10, E_BLOCK_CHEST, 0)
cRoot:Get():GetDefaultWorld():DoWithChestAt(10, 100, 10,
function(a_ChestEntity)
	GatherReturnValues(a_ChestEntity:GetContents():%s(%s))
end)
]], a_FunctionName, a_ParamTypes)
end



g_Code.cMonster = {}
g_Code.cMonster.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format(
[[cRoot:Get():GetDefaultWorld():ForEachEntity(
	function(a_Entity)
		if not(a_Entity:IsMob()) then return end
		local monster = tolua.cast(a_Entity, 'cMonster' )
		GatherReturnValues(monster:%s(%s))
		return true
	end)
]],	a_FunctionName, a_ParamTypes)
end



g_Code.cPickup = {}
g_Code.cPickup.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format(
[[local world = cRoot:Get():GetDefaultWorld()
local items = cItems() items:Add(cItem(1, 64))
world:SpawnItemPickups(items, 1, 200, 1, 0)
world:ForEachEntity(
	function(a_Entity)
		if not(a_Entity:IsPickup()) then return end
		local obj = tolua.cast(a_Entity, "cPickup") GatherReturnValues(obj:%s(%s))
	end)
]],	a_FunctionName, a_ParamTypes)
end



g_Code.cWorld = {}
g_Code.cWorld.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format("GatherReturnValues(cRoot:Get():GetDefaultWorld():%s(%s))", a_FunctionName, a_ParamTypes)
end

g_Code.cWorld.GetSignLines =
function(a_ParamTypes)
	return
[[cRoot:Get():GetDefaultWorld():SetBlock(10, 100, 10, E_BLOCK_SIGN_POST, 0)
GatherReturnValues(cRoot:Get():GetDefaultWorld():GetSignLines(10, 100, 10))]]
end



g_Code.cRoot = {}
g_Code.cRoot.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format("GatherReturnValues(cRoot:Get():%s(%s))", a_FunctionName, a_ParamTypes)
end



g_Code.cServer = {}
g_Code.cServer.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format("GatherReturnValues(cRoot:Get():GetServer():%s(%s))", a_FunctionName, a_ParamTypes)
end



g_Code.cWebAdmin = {}
g_Code.cWebAdmin.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format("GatherReturnValues(cRoot:Get():GetWebAdmin():%s(%s))", a_FunctionName, a_ParamTypes)
end

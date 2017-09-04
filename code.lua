g_Code = {}



g_Code.cBoat = {}
g_Code.cBoat.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format(
[[local world = cRoot:Get():GetDefaultWorld()
local entityID = world:SpawnBoat(1, 200, 1, cBoat.bmOak)
world:DoWithEntityByID(entityID,
	function(a_Entity)
		g_CallbackCalled = true
		local obj = tolua.cast(a_Entity, "cBoat")
		GatherReturnValues(obj:%s(%s))
	end)]],	a_FunctionName, a_ParamTypes)
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
GatherReturnValues(obj:%s(%s))]], a_FunctionName , a_ParamTypes)
end



g_Code.cClientHandle = {}
g_Code.cClientHandle.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format(
[[local world = cRoot:Get():GetDefaultWorld()
world:DoWithPlayer('%s',
	function(a_Player)
		g_CallbackCalled = true
		GatherReturnValues(a_Player:GetClientHandle():%s(%s))
	end)]], g_BotName, a_FunctionName, a_ParamTypes)
end



g_Code.cEntity = {}
g_Code.cEntity.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format(
[[cRoot:Get():GetDefaultWorld():ForEachEntity(
	function(a_Entity)
		g_CallbackCalled = true
		GatherReturnValues(a_Entity:%s(%s))
		return true
	end)]], a_FunctionName , a_ParamTypes)
end



g_Code.cExpOrb = {}
g_Code.cExpOrb.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format(
[[local world = cRoot:Get():GetDefaultWorld()
local entityID = world:SpawnExperienceOrb(1, 255, 1, 1000)
world:DoWithEntityByID(entityID,
	function(a_Entity)
		g_CallbackCalled = true
		local obj = tolua.cast(a_Entity, "cExpOrb")
		GatherReturnValues(obj:%s(%s))
	end)]], a_FunctionName , a_ParamTypes)
end



g_Code.cFallingBlock = {}
g_Code.cFallingBlock.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format(
[[local world = cRoot:Get():GetDefaultWorld()
local entityID = world:SpawnFallingBlock(1, 255, 1, 12, 1)
world:DoWithEntityByID(entityID,
	function(a_Entity)
		g_CallbackCalled = true
		local obj = tolua.cast(a_Entity, "cFallingBlock")
		GatherReturnValues(obj:%s(%s))
	end)]], a_FunctionName, a_ParamTypes)
end



g_Code.Globals = {}
g_Code.Globals.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format("GatherReturnValues(" .. a_FunctionName .."(" .. a_ParamTypes .. "))")
end



g_Code.cInventory = {}
g_Code.cInventory.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format(
[[local world = cRoot:Get():GetDefaultWorld()
world:DoWithPlayer('%s',
	function(a_Player)
		g_CallbackCalled = true
		GatherReturnValues(a_Player:GetInventory():%s(%s))
	end)]],	g_BotName, a_FunctionName, a_ParamTypes)
end



g_Code.cItemGrid = {}
g_Code.cItemGrid.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format(
[[cRoot:Get():GetDefaultWorld():SetBlock(10, 100, 10, E_BLOCK_CHEST, 0)
cRoot:Get():GetDefaultWorld():DoWithChestAt(10, 100, 10,
	function(a_ChestEntity)
		g_CallbackCalled = true
		GatherReturnValues(a_ChestEntity:GetContents():%s(%s))
	end)]], a_FunctionName, a_ParamTypes)
end



g_Code.cMonster = {}
g_Code.cMonster.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format(
[[cRoot:Get():GetDefaultWorld():ForEachEntity(
	function(a_Entity)
		g_CallbackCalled = true
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
local entityID = world:SpawnItemPickup(0, 100, 0, cItem(1, 64), 0, 0, 0, 200)
world:DoWithEntityByID(entityID,
	function(a_Entity)
		g_CallbackCalled = true
		local obj = tolua.cast(a_Entity, "cPickup")
		GatherReturnValues(obj:%s(%s))
	end)
]],	a_FunctionName, a_ParamTypes)
end



g_Code.cPlayer = {}
g_Code.cPlayer.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format(
[[local world = cRoot:Get():GetDefaultWorld()
world:DoWithPlayer('%s',
	function(a_Player)
		g_CallbackCalled = true
		GatherReturnValues(a_Player:%s(%s))
	end)
]],	g_BotName, a_FunctionName, a_ParamTypes)
end

g_Code.cPawn = {}
g_Code.cPawn.Class = g_Code.cPlayer.Class



g_Code.cWorld = {}
g_Code.cWorld.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format("GatherReturnValues(cRoot:Get():GetDefaultWorld():%s(%s))", a_FunctionName, a_ParamTypes)
end

g_Code.cWorld.DoWithEntityByID =
function()
	return
[[local world = cRoot:Get():GetDefaultWorld()
local entityID = world:SpawnBoat(1, 200, 1, cBoat.bmOak)
GatherReturnValues(world:DoWithEntityByID(entityID,
	function(a_Entity)
		g_CallbackCalled = true
		return true
	end))]]
end

g_Code.cWorld.ForEachBlockEntityInChunk =
function()
	return
[[cRoot:Get():GetDefaultWorld():SetBlock(5, 100, 5, E_BLOCK_CHEST, 0)
GatherReturnValues(cRoot:Get():GetDefaultWorld():ForEachBlockEntityInChunk(0, 0,
	function(a_BlockEntity)
		g_CallbackCalled = true
		return true
	end))]]
end

g_Code.cWorld.ForEachBrewingstandInChunk =
function()
	return
[[cRoot:Get():GetDefaultWorld():SetBlock(5, 100, 5, E_BLOCK_BREWING_STAND, 0)
GatherReturnValues(cRoot:Get():GetDefaultWorld():ForEachBrewingstandInChunk(0, 0,
	function(a_ChestEntity)
		g_CallbackCalled = true
		return true
	end))]]
end

g_Code.cWorld.ForEachChestInChunk =
function()
	return
[[cRoot:Get():GetDefaultWorld():SetBlock(5, 100, 5, E_BLOCK_CHEST, 0)
GatherReturnValues(cRoot:Get():GetDefaultWorld():ForEachChestInChunk(0, 0,
	function(a_ChestEntity)
		g_CallbackCalled = true
		return true
	end))]]
end

g_Code.cWorld.ForEachEntityInBox =
function()
	return
[[local world = cRoot:Get():GetDefaultWorld()
world:SpawnBoat(15, 150, 15, cBoat.bmOak)
GatherReturnValues(world:ForEachEntityInBox(
	cBoundingBox(Vector3d(1, 60, 1), Vector3d(30, 200, 30)),
	function(a_Entity)
		g_CallbackCalled = true
		return true
	end))]]
end

g_Code.cWorld.ForEachEntityInChunk =
function()
	return
[[local world = cRoot:Get():GetDefaultWorld()
GatherReturnValues(world:ForEachEntityInChunk(0, 0,
	function(a_Entity)
		g_CallbackCalled = true
		return true
	end))]]
end

g_Code.cWorld.ForEachFurnaceInChunk =
function()
	return
[[cRoot:Get():GetDefaultWorld():SetBlock(5, 100, 5, E_BLOCK_FURNACE, 0)
GatherReturnValues(cRoot:Get():GetDefaultWorld():ForEachFurnaceInChunk(0, 0,
	function(a_FurnaceEntity)
		g_CallbackCalled = true
		return true
	end))]]
end

g_Code.cWorld.GetSignLines =
function(a_ParamTypes)
	return
[[cRoot:Get():GetDefaultWorld():SetBlock(10, 100, 10, E_BLOCK_SIGN_POST, 0)
GatherReturnValues(cRoot:Get():GetDefaultWorld():GetSignLines(10, 100, 10))]]
end


g_Code.cPluginManager = {}
g_Code.cPluginManager.Class =
function(a_FunctionName, a_ParamTypes)
	return string.format("GatherReturnValues(cPluginManager:Get():%s(%s))", a_FunctionName, a_ParamTypes)
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

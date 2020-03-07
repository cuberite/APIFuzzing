-- Contains valid params for functions

g_Params = {}


g_Params.cBlockArea = {}
g_Params.cBlockArea.Write =
function(a_Params)
	if #a_Params == 2 then
		return
		{
			"cRoot:Get():GetDefaultWorld()",
			"Vector3i(0, 0, 0)"
		}
	elseif #a_Params == 3 then
		return
		{
			"cRoot:Get():GetDefaultWorld()",
			"Vector3i(0, 0, 0)",
			"3"
		}
	elseif #a_Params == 4 then
		return
		{
			"cRoot:Get():GetDefaultWorld()",
			"0", "0", "0"
		}
	elseif #a_Params == 5 then
		return
		{
			"cRoot:Get():GetDefaultWorld()",
			"0", "0", "0",
			"3"
		}
	end
	return a_Params
end

g_Params.cBlockArea.DoWithBlockEntityAt =
function(a_Params)
	if #a_Params == 2 then
		return { "1", "1", "1", "function(a_BlockEntity) return true end" }
	elseif #a_Params == 4 then
		return { "Vector3i(1, 1, 1)", "function(a_BlockEntity) return true end" }
	end
end

g_Params.cBlockArea.DoWithBlockEntityRelAt = g_Params.cBlockArea.DoWithBlockEntityAt



g_Params.cBoat = {}
g_Params.cBoat.ItemToMaterial = "cItem(E_ITEM_ACACIA_BOAT)"



g_Params.cBoundingBox = {}
g_Params.cBoundingBox.CalcLineIntersection =
function(a_Params)
	if #a_Params == 2 then
		return { "Vector3d(192, 139, 114)", "Vector3d(85, 37, 32)" }
	elseif #a_Params == 4 then
		return
		{
			"Vector3d(45, 17, 124)", "Vector3d(243, 229, 236)",
			"Vector3d(8, 83, 155)", "Vector3d(204, 14, 129)"
		}
	end
end
g_Params.cBoundingBox.constructor = { 110, 188, 5, 176, 67, 160 }
g_Params.cBoundingBox.Intersect = "cBoundingBox(163, 190, 19, 91, 137, 244)"



g_Params.cCraftingGrid = {}
g_Params.cCraftingGrid.ConsumeGrid = "cCraftingGrid(1, 1)"
g_Params.cCraftingGrid.GetItem = { 0, 0 }
g_Params.cCraftingGrid.SetItem =
function(a_Params)
	if #a_Params == 3 then
		return { 0, 0, "cItem(1)" }
	elseif #a_Params == 5 then
		return { 0, 0, 1, 1, 0 }
	end
end



g_Params.cEnchantments = {}
g_Params.cEnchantments.AddFromString = "'Looting = 1'"
g_Params.cEnchantments.StringToEnchantmentID = "'Infinity'"



g_Params.ItemCategory = {}
g_Params.ItemCategory.IsArmor = "E_ITEM_DIAMOND_HORSE_ARMOR"
g_Params.ItemCategory.IsAxe =   "E_ITEM_DIAMOND_AXE"
g_Params.ItemCategory.IsBoots = "E_ITEM_DIAMOND_BOOTS"
g_Params.ItemCategory.IsChestPlate = "E_ITEM_CHAIN_CHESTPLATE"
g_Params.ItemCategory.IsHelmet = "E_ITEM_LEATHER_CAP"
g_Params.ItemCategory.IsHoe = "E_ITEM_WOODEN_HOE"
g_Params.ItemCategory.IsLeggings = "E_ITEM_LEATHER_PANTS"
g_Params.ItemCategory.IsMinecart = "E_ITEM_CHEST_MINECART"
g_Params.ItemCategory.IsPickaxe = "E_ITEM_DIAMOND_PICKAXE"
g_Params.ItemCategory.IsShovel = "E_ITEM_DIAMOND_SHOVEL"
g_Params.ItemCategory.IsSword = "E_ITEM_DIAMOND_SWORD"
g_Params.ItemCategory.IsTool = "E_ITEM_DIAMOND_PICKAXE"



g_Params.cItems = {}
g_Params.cItems.AddItemGrid = "a_ChestEntity:GetContents()"
g_Params.cItems.Delete = 0
g_Params.cItems.Get = 0
g_Params.cItems.Set =
function(a_Params)
	if #a_Params == 2 then
		return { 0, "cItem(1)" }
	elseif #a_Params == 4 then
		return { 0, 1, 1, 0 }
	end
end



g_Params.cJson = {}
g_Params.cJson.Parse = "'{ \"amount\" : 30 }'"
g_Params.cJson.Serialize = { "{ ['amount'] = 30 }", "{}" }



g_Params.cLineBlockTracer = {}
g_Params.cLineBlockTracer.FirstSolidHitTrace =
function(a_Params)
	if #a_Params == 3 then
		return
		{
			"cRoot:Get():GetDefaultWorld()",
			"Vector3d(1, 255, 1)",
			"Vector3d(1, 1, 1)"
		}
	elseif #a_Params == 7 then
		return
		{
			"cRoot:Get():GetDefaultWorld()",
			1, 255, 1, 1, 1 , 1
		}
	end
end



g_Params.cPlayer = {}
g_Params.cPlayer.OpenWindow = "cLuaWindow(cWindow.wtChest, 9, 3, 'Hidden chest')"



g_Params.cPluginManager = {}
g_Params.cPluginManager.DoWithPlugin =
{ "'Core'", "function() g_CallbackCalled = true return true end" }
g_Params.cPluginManager.ForEachCommand =
"function() g_CallbackCalled = true return true end"
g_Params.cPluginManager.ForEachConsoleCommand =
"function() g_CallbackCalled = true return true end"
g_Params.cPluginManager.ForEachPlugin =
"function() g_CallbackCalled = true return true end"



g_Params.cRoot = {}
g_Params.cRoot.DoWithPlayerByUUID =
{
	"g_BotUUID",
	"function(a_Player) g_CallbackCalled = true end"
}

g_Params.cRoot.FindAndDoWithPlayer =
{
	"g_BotName",
	"function() g_CallbackCalled = true end"
}

g_Params.cRoot.ForEachPlayer = "function() g_CallbackCalled = true return true end"
g_Params.cRoot.ForEachWorld = "function() g_CallbackCalled = true return true end"
g_Params.cRoot.GetBrewingRecipe = { "cItem(E_ITEM_POTION)", "cItem(E_ITEM_NETHER_WART)" }
g_Params.cRoot.GetFurnaceRecipe = "cItem(E_ITEM_RAW_FISH)"
g_Params.cRoot.GetWorld = "'world'"


g_Params.cWorld = {}
g_Params.cWorld.DoWithPlayer =
{
	"g_BotName",
	"function() g_CallbackCalled = true end"
}
g_Params.cWorld.DoWithPlayerByUUID =
{
	"g_BotUUID",
	"function() g_CallbackCalled = true end"
}

g_Params.cWorld.FindAndDoWithPlayer =
{
	"g_BotName",
	"function() g_CallbackCalled = true end"
}
g_Params.cWorld.ForEachEntity = "function() g_CallbackCalled = true return true end"
g_Params.cWorld.ForEachLoadedChunk = "function() g_CallbackCalled = true return true end"
g_Params.cWorld.ForEachPlayer = "function() g_CallbackCalled = true return true end"



g_Params.Globals = {}
g_Params.Globals.StringToDimension = "'Sky'"

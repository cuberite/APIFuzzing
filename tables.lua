function CreateTables()
	-- Blockentities to BlockType
	g_BlockEntityToBlockType = {}
	g_BlockEntityToBlockType.cBeaconEntity = E_BLOCK_BEACON
	g_BlockEntityToBlockType.cBedEntity = E_BLOCK_BED
	g_BlockEntityToBlockType.cBrewingstandEntity = E_BLOCK_BREWING_STAND
	g_BlockEntityToBlockType.cCommandBlockEntity = E_BLOCK_COMMAND_BLOCK
	g_BlockEntityToBlockType.cDispenserEntity = E_BLOCK_DISPENSER
	g_BlockEntityToBlockType.cDropSpenserEntity = E_BLOCK_DROPPER
	g_BlockEntityToBlockType.cFlowerPotEntity = E_BLOCK_FLOWER_POT
	g_BlockEntityToBlockType.cJukeboxEntity = E_BLOCK_JUKEBOX
	g_BlockEntityToBlockType.cFurnaceEntity = E_BLOCK_FURNACE
	g_BlockEntityToBlockType.cMobHeadEntity = E_BLOCK_HEAD
	g_BlockEntityToBlockType.cMobSpawnerEntity = E_BLOCK_MOB_SPAWNER
	g_BlockEntityToBlockType.cNoteEntity = E_BLOCK_NOTE_BLOCK

	g_ObjectToTypeName = {}

	-- Classes
	g_ObjectToTypeName.ItemCategory = "userdata"
	g_ObjectToTypeName.TakeDamageInfo = "userdata"
	g_ObjectToTypeName.Vector3d = "userdata"
	g_ObjectToTypeName.Vector3f = "userdata"
	g_ObjectToTypeName.Vector3i = "userdata"


	-- Table containg enum type to enum value
	g_EnumValues = {}
	g_EnumValues.EMCSBiome = "biSky"
	g_EnumValues.eMonsterType = "mtBat"
	g_EnumValues.SmokeDirection = "SmokeDirection.EAST"
	g_EnumValues.eGameMode = "gmAdventure"


	-- This list contains functions (if any) that causes false positives
	-- TODO: Add better test code for the functions below to correct them
	-- [Class name][Function name]
	g_FalsePositives = {}
end



function CreateSharedIgnoreTable()
	-- This table contains classes / functions that are ignored
	g_IgnoreShared = {}

	-- ## Initialize tables ##
	g_IgnoreShared.cBlockInfo = {}
	g_IgnoreShared.cCompositeChat = {}
	g_IgnoreShared.cDispenserEntity = {}
	g_IgnoreShared.cDropSpenserEntity = {}
	g_IgnoreShared.cEntity = {}
	g_IgnoreShared.cMonster = {}
	g_IgnoreShared.cRoot = {}
	g_IgnoreShared.cSplashPotionEntity = {}
	g_IgnoreShared.cWebAdmin = {}
	g_IgnoreShared.cWorld = {}
	g_IgnoreShared.Globals = {}


	-- ## Ignore a single or more functions ##

	-- Documented, but not exported
	g_IgnoreShared.cCompositeChat.AddShowAchievementPart = true
	g_IgnoreShared.cDispenserEntity.SpawnProjectileFromDispenser = true

	-- Deprecated
	g_IgnoreShared.cBlockInfo.GetPlaceSound = true
	g_IgnoreShared.cWebAdmin.GetURLEncodedString = true
	g_IgnoreShared.cWorld.WakeUpSimulators = true
	g_IgnoreShared.cWorld.WakeUpSimulatorsInArea = true
	g_IgnoreShared.Globals.LOGWARN = true
	g_IgnoreShared.Globals.md5 = true
	g_IgnoreShared.Globals.StringToMobType = true

	-- Outputs to console, ignore it
	g_IgnoreShared.cRoot.QueueExecuteConsoleCommand = true
	g_IgnoreShared.cWorld.SetLinkedEndWorldName = true
	g_IgnoreShared.cWorld.SetLinkedNetherWorldName = true
	g_IgnoreShared.cWorld.SetLinkedOverworldName = true
	g_IgnoreShared.Globals.LOG = true
	g_IgnoreShared.Globals.LOGERROR = true
	g_IgnoreShared.Globals.LOGINFO = true
	g_IgnoreShared.Globals.LOGWARNING = true
	g_IgnoreShared.Globals.StringToDimension = true

	-- Discussion in process #3651, #3649
	g_IgnoreShared.cEntity.MoveToWorld = true
	g_IgnoreShared.cEntity.ScheduleMoveToWorld = true

	-- Marked as to be removed from the api
	g_IgnoreShared.cEntity.KilledBy = true
	g_IgnoreShared.cEntity.SetHeight = true
	g_IgnoreShared.cEntity.SetWidth = true

	-- cSplashPotionEntity:SetEntityEffect requires a instance of
	-- cEntityEffect, but cEntityEffect has only static functions
	g_IgnoreShared.cSplashPotionEntity.SetEntityEffect = true

	-- Crashes the server
	g_IgnoreShared.cEntity.HandleSpeedFromAttachee = true  -- #3662

	-- Needs an monster as param
	g_IgnoreShared.cMonster.GetLeashedTo = true


	-- ## Whole class ignored ##

	-- Deprecated
	g_IgnoreShared.cTracer = "*"

	-- Requires a placed painting
	g_IgnoreShared.cPainting = "*"

	-- Outputs to console, ignore it
	g_IgnoreShared.cCraftingGrid = "*"
	g_IgnoreShared.cRankManager = "*"
	g_IgnoreShared.cStringCompression = "*"

	-- Database
	g_IgnoreShared.sqlite3 = "*"

	-- Can write out of bounds and corrupts memory, this could then lead to a crash
	g_IgnoreShared.cBlockArea = "*"

	-- Has only function SetFuseTicks with param number
	g_IgnoreShared.cTNTEntity = "*"

	-- Needs a hook to access the objects
	g_IgnoreShared.cChunkDesc = "*"
	g_IgnoreShared.cCraftingRecipe = "*"

	-- Requires cChunkDesc
	g_IgnoreShared.cSignEntity = "*"

	-- Unclear
	g_IgnoreShared.cItemFrame = "*"
	g_IgnoreShared.cMap = "*"
	g_IgnoreShared.cMapManager = "*"

	-- cWorld:CreateProjectile
	g_IgnoreShared.cArrowEntity = "*"
	g_IgnoreShared.cFireworkEntity = "*"
	g_IgnoreShared.cProjectileEntity = "*"
	g_IgnoreShared.cSplashPotionEntity = "*"

	-- Has only function SetFacing wth param eBlockFace
	g_IgnoreShared.cHangingEntity = "*"

	-- Has only function GetOutputBlockPos with param number
	g_IgnoreShared.cHopperEntity = "*"

	-- Requires player
	g_IgnoreShared.cFloater = "*"
	g_IgnoreShared.cInventory = "*"
	g_IgnoreShared.cObjective = "*"
	g_IgnoreShared.cScoreboard = "*"
	g_IgnoreShared.cTeam = "*"

	-- Contains callbacks
	g_IgnoreShared.lxp = "*"

	-- Is cLuaWindow
	g_IgnoreShared.cWindow = "*"

	-- Better not
	g_IgnoreShared.cPlugin = "*"
	g_IgnoreShared.cPluginLua = "*"
	g_IgnoreShared.cPluginManager = "*"

	-- Is checked in classes that inherit from it
	g_IgnoreShared.cBlockEntity = "*"
	g_IgnoreShared.cBlockEntityWithItems = "*"

	-- Don't want to ddos "internet"
	g_IgnoreShared.cNetwork = "*"
	g_IgnoreShared.cServerHandle = "*"
	g_IgnoreShared.cTCPLink = "*"
	g_IgnoreShared.cUDPEndpoint = "*"
	g_IgnoreShared.cUrlClient = "*"
	g_IgnoreShared.cUrlParser = "*"

	-- Static function cast is unsafe
	g_IgnoreShared.tolua = "*"

	-- Don't want to ddos mojang api server
	g_IgnoreShared.cMojangAPI = "*"

	-- Dangerous, dangerous, very dangerous
	g_IgnoreShared.cFile = "*"
	g_IgnoreShared.cIniFile = "*"

	-- Deadlocks
	g_IgnoreShared.cClientHandle = "*"  -- Needs a connected player
	g_IgnoreShared.cPawn = "*"
	g_IgnoreShared.cPlayer = "*"
end

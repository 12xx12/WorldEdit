
function Initialize(Plugin)
	OnePlayerX = {}
	OnePlayerY = {}
	OnePlayerZ = {}
	TwoPlayerX = {}
	TwoPlayerY = {}
	TwoPlayerZ = {}
	Blocks = {}
	SP = {}
	Air = {}
	X = {}
	PosY = {}
	Z = {}
	PLUGIN = Plugin
	PLUGIN:SetName("WorldEdit")
	PLUGIN:SetVersion(1)
	
	PluginManager = cRoot:Get():GetPluginManager()
	PluginManager:AddHook(PLUGIN, cPluginManager.HOOK_PLAYER_BREAKING_BLOCK)
	PluginManager:AddHook(PLUGIN, cPluginManager.HOOK_PLAYER_RIGHT_CLICK)
	PluginManager:AddHook(PLUGIN, cPluginManager.HOOK_PLAYER_LEFT_CLICK)
	
	PluginManager:BindCommand("/descend",       "worldedit.navigation.descend",   HandleDescendCommand,        " Go down a floor" )	
	PluginManager:BindCommand("/ascend",        "worldedit.navigation.ascend",    HandleAscendCommand,         " Go up a floor" )	
	PluginManager:BindCommand("//green",        "worldedit.green",                HandleGreenCommand,          " [radius] - Greens the area" )	
	PluginManager:BindCommand("//size",	        "worldedit.selection.size",       HandleSizeCommand,           " Get the size of the selection")
	PluginManager:BindCommand("//paste",        "worldedit.clipboard.paste",	  HandlePasteCommand,          " Pastes the clipboard's contents.")
	PluginManager:BindCommand("//copy",	        "worldedit.clipboard.copy",       HandleCopyCommand,           " Copy the selection to the clipboard")
	PluginManager:BindCommand("//cut",	        "worldedit.clipboard.cut",        HandleCutCommand,            " Cut the selection to the clipboard")
	PluginManager:BindCommand("//schematic",    "",                               HandleSchematicCommand,      " Schematic-related commands")
	PluginManager:BindCommand("//set",	        "worldedit.region.set",           HandleSetCommand,   	       " Set all the blocks inside the selection to a block")
	PluginManager:BindCommand("//replace",      "worldedit.region.replace",       HandleReplaceCommand,        " Replace all the blocks in the selection with another")
	PluginManager:BindCommand("//walls",        "worldedit.region.walls",         HandleWallsCommand,          " Build the four sides of the selection")
	PluginManager:BindCommand("//wand",	        "worldedit.wand",                 HandleWandCommand,           " Get the wand object")
	PluginManager:BindCommand("//setbiome",	    "worldedit.biome.set",            HandleSetBiomeCommand,       " Set the biome of the region.")
	PluginManager:BindCommand("/biomelist",	    "worldedit.biomelist",            HandleBiomeListCommand,      " Gets all biomes available.")
	PluginManager:BindCommand("/snow",	        "worldedit.snow",                 HandleSnowCommand,           " Simulates snow")
	PluginManager:BindCommand("/thaw",	        "worldedit.thaw",                 HandleThawCommand,           " Thaws the area")
	PluginManager:BindCommand("//",	            "worldedit.superpickaxe",         HandleSuperPickCommand,      " Toggle the super pickaxe pickaxe function")

	LoadSettings()
	BlockArea = cBlockArea()
	LOG("Initialized " .. PLUGIN:GetName() .. " v" .. PLUGIN:GetVersion())
	return true
end

function HandleCutCommand( Split, Player )
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true
	end
	if OnePlayerX[Player:GetName()] < TwoPlayerX[Player:GetName()] then
		OneX = OnePlayerX[Player:GetName()]
		TwoX = TwoPlayerX[Player:GetName()]
	else
		OneX = TwoPlayerX[Player:GetName()]
		TwoX = OnePlayerX[Player:GetName()]
	end
	if OnePlayerY[Player:GetName()] < TwoPlayerY[Player:GetName()] then
		OneY = OnePlayerY[Player:GetName()]
		TwoY = TwoPlayerY[Player:GetName()]
	else
		OneY = TwoPlayerY[Player:GetName()]
		TwoY = OnePlayerY[Player:GetName()]
	end
	if OnePlayerZ[Player:GetName()] < TwoPlayerZ[Player:GetName()] then
		OneZ = OnePlayerZ[Player:GetName()]
		TwoZ = TwoPlayerZ[Player:GetName()]
	else
		OneZ = TwoPlayerZ[Player:GetName()]
		TwoZ = OnePlayerZ[Player:GetName()]
	end
	World = Player:GetWorld()
	Cut = cBlockArea()
	BlockArea:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	Cut:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	Cut:Fill( 1, 0, 0 )
	Cut:Write( World, OneX, OneY, OneZ )
	Player:SendMessage( cChatColor. LightPurple .. "Block(s) cut." )
	return true
end

function HandleDescendCommand( Split, Player )
	World = Player:GetWorld()
	if Player:GetPosY() ~= 1 then
		X[Player:GetName()] = math.floor( Player:GetPosX() )
		Z[Player:GetName()] = math.floor( Player:GetPosZ() )
		PosY[Player:GetName()] = math.floor( Player:GetPosY() )
		while PosY[Player:GetName()] ~= 1 do 
			if World:GetBlock( X[Player:GetName()], PosY[Player:GetName()], Z[Player:GetName()]) == 0 then
				if Air[Player:GetName()] == true then
					while World:GetBlock( X[Player:GetName()], PosY[Player:GetName()], Z[Player:GetName()]) == 0 do
						PosY[Player:GetName()] = PosY[Player:GetName()] - 1
					end
					break
				end
			else
				Air[Player:GetName()] = true
			end
			PosY[Player:GetName()] = PosY[Player:GetName()] - 1
		end
		if PosY[Player:GetName()] ~= nil then
			if Air[Player:GetName()] == true then
				if PosY[Player:GetName()] ~= 1 then
					Player:TeleportTo( Player:GetPosX(), PosY[Player:GetName()] + 1, Player:GetPosZ() )
				end
				Air[Player:GetName()] = false
				PosY[Player:GetName()] = nil
			end
		end		
	end
	Player:SendMessage( cChatColor.LightPurple .. "Descended a level." )
	return true
end

function HandleAscendCommand( Split, Player )
	World = Player:GetWorld()
	if Player:GetPosY() == World:GetHeight( math.floor(Player:GetPosX()), math.floor((Player:GetPosZ()) ) ) then
		Player:SendMessage( cChatColor.LightPurple .. "Ascended a level." )
	else
		X[Player:GetName()] = math.floor(Player:GetPosX())
		Z[Player:GetName()] = math.floor(Player:GetPosZ())
		for Y = math.floor(Player:GetPosY()), World:GetHeight( X[Player:GetName()], Z[Player:GetName()] ) + 1 do
			if World:GetBlock( X[Player:GetName()], Y, Z[Player:GetName()] ) == 0 then
				if Air[Player:GetName()] == true then
					PosY[Player:GetName()] = Y
					break
				end
			else
				Air[Player:GetName()] = true
			end
		end
		if PosY[Player:GetName()] ~= nil then
			if Air[Player:GetName()] == true then			
				Player:TeleportTo( Player:GetPosX(), PosY[Player:GetName()], Player:GetPosZ() )
				Air[Player:GetName()] = false
				PosY[Player:GetName()] = nil
			end
		end		
	end	
	Player:SendMessage( cChatColor.LightPurple .. "Ascended a level." )
	return true
end

function HandleGreenCommand( Split, Player )
	World = Player:GetWorld()
	if Split[2] == nil then
		Radius = 5
	elseif tonumber(Split[2]) == nil then
		Player:SendMessage( cChatColor.Green .. "Usage: /green [Radius]" )
	else
		Radius = Split[2]
	end
	X = Player:GetPosX()
	Z = Player:GetPosZ()
	Blocks[Player:GetName()] = 0
	for x=X - Radius, X + Radius do
		for z=Z - Radius, Z + Radius do
			y = World:GetHeight(x, z)
			if World:GetBlock(x, y, z) == 3 then
				Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
				World:SetBlock(x, y, z, 2, 0)
			end
		end
	end
	Player:SendMessage( cChatColor.LightPurple .. Blocks[Player:GetName()] .. " surfaces greened." )
	return true
end

function GetSize( Player )
	if OnePlayerX[Player:GetName()] > TwoPlayerX[Player:GetName()] then
		X = OnePlayerX[Player:GetName()] - TwoPlayerX[Player:GetName()] + 1
	else
		X = TwoPlayerX[Player:GetName()] - OnePlayerX[Player:GetName()] + 1
	end
	if OnePlayerY[Player:GetName()] > TwoPlayerY[Player:GetName()] then
		Y = OnePlayerY[Player:GetName()] - TwoPlayerY[Player:GetName()] + 1
	else
		Y = TwoPlayerY[Player:GetName()] - OnePlayerY[Player:GetName()] + 1
	end
	if OnePlayerZ[Player:GetName()] > TwoPlayerZ[Player:GetName()] then
		Z = OnePlayerZ[Player:GetName()] - TwoPlayerZ[Player:GetName()] + 1
	else
		Z = TwoPlayerZ[Player:GetName()] - OnePlayerZ[Player:GetName()] + 1
	end
	return X * Y * Z
end

function HandleSizeCommand( Split, Player )
	if OnePlayerX[Player:GetName()] ~= nil and TwoPlayerX[Player:GetName()] ~= nil then
		Player:SendMessage( cChatColor.LightPurple .. "the selection is " .. GetSize( Player ) .. " block(s) big" )
	else
		Player:SendMessage( cChatColor.LightPurple .. "Please select a region first" )
	end
	return true
end

function HandleWallsCommand( Split, Player )
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true
	end
	if Split[2] == nil then
		Player:SendMessage( cChatColor.Rose .. "Please say a block ID" )
	end
	Block = StringSplit( Split[2], ":" )
	if Block[1] == nil then
		Block[1] = 0
	end
	if Block[2] == nil then
		Block[2] = 0
	end
	if OnePlayerX[Player:GetName()] < TwoPlayerX[Player:GetName()] then
		OneX = OnePlayerX[Player:GetName()]
		TwoX = TwoPlayerX[Player:GetName()]
	else
		OneX = TwoPlayerX[Player:GetName()]
		TwoX = OnePlayerX[Player:GetName()]
	end
	if OnePlayerY[Player:GetName()] < TwoPlayerY[Player:GetName()] then
		OneY = OnePlayerY[Player:GetName()]
		TwoY = TwoPlayerY[Player:GetName()]
	else
		OneY = TwoPlayerY[Player:GetName()]
		TwoY = OnePlayerY[Player:GetName()]
	end
	if OnePlayerZ[Player:GetName()] < TwoPlayerZ[Player:GetName()] then
		OneZ = OnePlayerZ[Player:GetName()]
		TwoZ = TwoPlayerZ[Player:GetName()]
	else
		OneZ = TwoPlayerZ[Player:GetName()]
		TwoZ = OnePlayerZ[Player:GetName()]
	end
	World = Player:GetWorld()	
	BlockArea:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	BlockArea:FillRelCuboid( 1, BlockArea:GetSizeX(), 1, 1, 1, 1, 1, Block[1], Block[2] )
	BlockArea:Write( World, OneX, OneY, OneZ )
	return true
end

function HandlePasteCommand( Split, Player )
	if BlockArea:Write( Player:GetWorld(), Player:GetPosX(), Player:GetPosY(), Player:GetPosZ(), 3 ) == false then
		Player:SendMessage( cChatColor.LightPurple .. "You didn't copy anything" )
	else
		Player:SendMessage( cChatColor.LightPurple .. "Pasted relative to you." )
	end
	return true
end

function HandleSchematicCommand( Split, Player )
	if string.upper(Split[2]) == "SAVE" then
		if Player:HasPermission("worldedit.schematic.save") then
			if Split[3] == nil then
				Player:SendMessage( cChatColor.Green .. "Please state a schematic name" )
				return true
			end	
			BlockArea:SaveToSchematicFile( "Schematics/" .. Split[3] .. ".Schematic" )
			Player:SendMessage( cChatColor.LightPurple .. "Clipboard saved to " .. Split[3] )
		end
	elseif string.upper(Split[2]) == "LOAD" then
		if Player:HasPermission("worldedit.schematic.load") then
			if Split[3] == nil then
				Player:SendMessage( cChatColor.Green .. "Please state a schematic name" )
				return true
			end 		
			BlockArea:LoadFromSchematicFile( "Schematics/" .. Split[3] .. ".Schematic" )
			Player:SendMessage( cChatColor.LightPurple .. "Clipboard " .. Split[3] .. " is loaded" ) 
		end
	end
	return true
end

function HandleCopyCommand( Split, Player )
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true
	end
	if OnePlayerX[Player:GetName()] < TwoPlayerX[Player:GetName()] then
		OneX = OnePlayerX[Player:GetName()]
		TwoX = TwoPlayerX[Player:GetName()]
	else
		OneX = TwoPlayerX[Player:GetName()]
		TwoX = OnePlayerX[Player:GetName()]
	end
	if OnePlayerY[Player:GetName()] < TwoPlayerY[Player:GetName()] then
		OneY = OnePlayerY[Player:GetName()]
		TwoY = TwoPlayerY[Player:GetName()]
	else
		OneY = TwoPlayerY[Player:GetName()]
		TwoY = OnePlayerY[Player:GetName()]
	end
	if OnePlayerZ[Player:GetName()] < TwoPlayerZ[Player:GetName()] then
		OneZ = OnePlayerZ[Player:GetName()]
		TwoZ = TwoPlayerZ[Player:GetName()]
	else
		OneZ = TwoPlayerZ[Player:GetName()]
		TwoZ = OnePlayerZ[Player:GetName()]
	end
	World = Player:GetWorld()
	BlockArea:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	Player:SendMessage( cChatColor. LightPurple .. "Block(s) copied." )
	return true
end
	
	
function HandleWandCommand( Split, Player )
	Item = cItem( Wand, 1 )
	if( Player:GetInventory():AddItem( Item ) == true ) then
		Player:SendMessage( cChatColor.Green .. "You have a wooden axe now." )
	else
		Player:SendMessage( cChatColor.Green .. "Not enough inventory space" )
	end
	return true
end

function LoadSettings()
	SettingsIni = cIniFile( PLUGIN:GetLocalDirectory() .. "/Config.ini" )
	SettingsIni:ReadFile()
	Wand = SettingsIni:GetValueSetI("General", "WandItem", 271 )
	
	SettingsIni:WriteFile()
end

function HandleSuperPickCommand( Split, Player )
	if SP[Player:GetName()] == nil or SP[Player:GetName()] == false then
		SP[Player:GetName()] = true
		Player:SendMessage( cChatColor.LightPurple .. "Super pick activated" )
	elseif SP[Player:GetName()] == true then
		SP[Player:GetName()] = false
		Player:SendMessage( cChatColor.LightPurple .. "Super pick deactivated" )
	end
	return true
end

function HandleThawCommand( Split, Player )
	World = Player:GetWorld()
	if Split[2] == nil then
		Radius = 5
	elseif tonumber(Split[2]) == nil then
		Player:SendMessage( cChatColor.Green .. "Usage: /thaw [Radius]" )
	else
		Radius = Split[2]
	end
	X = Player:GetPosX()
	Z = Player:GetPosZ()
	Blocks[Player:GetName()] = 0
	for x=X - Radius, X + Radius do
		for z=Z - Radius, Z + Radius do
			y = World:GetHeight(x, z)
			if World:GetBlock(x, y, z) == 78 then
				Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
				World:SetBlock(x, y, z, 0, 0)
			elseif World:GetBlock(x, y, z) == 79 then
				Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
				World:SetBlock(x, y, z, 8, 0)
			end
		end
	end
	Player:SendMessage( cChatColor.LightPurple .. Blocks[Player:GetName()] .. " surfaces thawed" )
	return true
end

function HandleSnowCommand( Split, Player )
	World = Player:GetWorld()
	if Split[2] == nil then
		Radius = 5
	elseif tonumber(Split[2]) == nil then
		Player:SendMessage( cChatColor.Green .. "Usage: /snow [Radius]" )
	else
		Radius = Split[2]
	end
	X = Player:GetPosX()
	Z = Player:GetPosZ()
	Blocks[Player:GetName()] = 0
	for x=X - Radius, X + Radius do
		for z=Z - Radius, Z + Radius do
			y = World:GetHeight(x, z)
			if World:GetBlock(x, y , z) == 9 then
				Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
				World:SetBlock(x, y, z, 79, 0)
			elseif World:GetBlock(x, y , z) == 10 then
				Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
				World:SetBlock(x, y, z, 49, 0)
			else
				Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
				World:SetBlock(x, y + 1, z, 78, 0)
			end
		end
	end
	Player:SendMessage( cChatColor.LightPurple .. Blocks[Player:GetName()] .. " surfaces covered. Let is snow~" )
	return true
end

function OnPlayerBreakingBlock(Player, BlockX, BlockY, BlockZ, BlockFace, BlockType, BlockMeta)
	if Player:GetEquippedItem().m_ItemType == Wand then
		OnePlayerX[Player:GetName()] = BlockX
		OnePlayerY[Player:GetName()] = BlockY
		OnePlayerZ[Player:GetName()] = BlockZ
		if OnePlayerX[Player:GetName()] ~= nil and TwoPlayerX[Player:GetName()] ~= nil then
			if OnePlayerX[Player:GetName()] < TwoPlayerX[Player:GetName()] then
				OneX = OnePlayerX[Player:GetName()]
				TwoX = TwoPlayerX[Player:GetName()]
			else
				OneX = TwoPlayerX[Player:GetName()]
				TwoX = OnePlayerX[Player:GetName()]
			end
			if OnePlayerY[Player:GetName()] < TwoPlayerY[Player:GetName()] then
				OneY = OnePlayerY[Player:GetName()]
				TwoY = TwoPlayerY[Player:GetName()]
			else
				OneY = TwoPlayerY[Player:GetName()]
				TwoY = OnePlayerY[Player:GetName()]
			end
			if OnePlayerZ[Player:GetName()] < TwoPlayerZ[Player:GetName()] then
				OneZ = OnePlayerZ[Player:GetName()]
				TwoZ = TwoPlayerZ[Player:GetName()]
			else
				OneZ = TwoPlayerZ[Player:GetName()]
				TwoZ = OnePlayerZ[Player:GetName()]
			end
			Player:SendMessage( cChatColor.LightPurple .. 'First position set to (' .. BlockX .. ".0, " .. BlockY .. ".0, " .. BlockZ .. ".0) (" .. GetSize( Player ) .. ")." )
		else
			Player:SendMessage( cChatColor.LightPurple .. 'First position set to (' .. BlockX .. ".0, " .. BlockY .. ".0, " .. BlockZ .. ".0)." )
		end
		return true
	end
end

function OnPlayerLeftClick(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
	if SP[Player:GetName()] == true then
		World = Player:GetWorld()
		Item = cItem( World:GetBlock( BlockX, BlockY, BlockZ ), 10, World:GetBlockMeta( BlockX, BlockY, BlockZ ) )
		cPickup( BlockX, BlockY, BlockZ, Item, 0.0, 0.0, 0.0 )
		World:DigBlock( BlockX, BlockY, BlockZ ) 		
	end
end

function OnPlayerRightClick(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
	if Player:GetEquippedItem().m_ItemType == Wand then
		if BlockX == -1 and BlockZ == -1 and BlockY == 255 then
			return false
		end
		TwoPlayerX[Player:GetName()] = BlockX
		TwoPlayerY[Player:GetName()] = BlockY
		TwoPlayerZ[Player:GetName()] = BlockZ
		if OnePlayerX[Player:GetName()] ~= nil and TwoPlayerX[Player:GetName()] ~= nil then
			if OnePlayerX[Player:GetName()] < TwoPlayerX[Player:GetName()] then
				OneX = OnePlayerX[Player:GetName()]
				TwoX = TwoPlayerX[Player:GetName()]
			else
				OneX = TwoPlayerX[Player:GetName()]
				TwoX = OnePlayerX[Player:GetName()]
			end
			if OnePlayerY[Player:GetName()] < TwoPlayerY[Player:GetName()] then
				OneY = OnePlayerY[Player:GetName()]
				TwoY = TwoPlayerY[Player:GetName()]
			else
				OneY = TwoPlayerY[Player:GetName()]
				TwoY = OnePlayerY[Player:GetName()]
			end
			if OnePlayerZ[Player:GetName()] < TwoPlayerZ[Player:GetName()] then
				OneZ = OnePlayerZ[Player:GetName()]
				TwoZ = TwoPlayerZ[Player:GetName()]
			else
				OneZ = TwoPlayerZ[Player:GetName()]
				TwoZ = OnePlayerZ[Player:GetName()]
			end
			Blocks[Player:GetName()] = 0
			Player:SendMessage( cChatColor.LightPurple .. 'Second position set to (' .. BlockX .. ".0, " .. BlockY .. ".0, " .. BlockZ .. ".0) (" .. GetSize( Player ) .. ")." )
		else
			Player:SendMessage( cChatColor.LightPurple .. 'Second position set to (' .. BlockX .. ".0, " .. BlockY .. ".0, " .. BlockZ .. ".0)." )
		end
		return true
	end
end

function HandleBiomeListCommand( Split, Player )
	if Split[2] == nil then 
		Split[2] = 1 
	end
	if tonumber(Split[2]) == 1 then
		Player:SendMessage( cChatColor.Green .. "Page 1" )
		Player:SendMessage( "Ocean" )
		Player:SendMessage( "Plains" )
		Player:SendMessage( "Desert" )
		Player:SendMessage( "Extreme_Hills" )
		Player:SendMessage( "Forest" )
		Player:SendMessage( "Taiga" )
		Player:SendMessage( "Swampland" )
		Player:SendMessage( "River" )
	elseif tonumber(Split[2]) == 2 then
		Player:SendMessage( cChatColor.Green .. "Page 2" )
		Player:SendMessage( "Hell" )
		Player:SendMessage( "Sky" )
		Player:SendMessage( "FrozenOcean" )
		Player:SendMessage( "FrozenRiver" )
		Player:SendMessage( "Ice_Plains" )
		Player:SendMessage( "Ice_Mountains" )
		Player:SendMessage( "MushroomIsland" )
		Player:SendMessage( "MushroomIslandShore" )
	elseif tonumber(Split[2]) == 3 then
		Player:SendMessage( cChatColor.Green .. "Page 3" )
		Player:SendMessage( "Beach" )
		Player:SendMessage( "DesertHills" )
		Player:SendMessage( "ForestHills" )
		Player:SendMessage( "TaigaHills " )
		Player:SendMessage( "Extreme_Hills_Edge" )
		Player:SendMessage( "Jungle" )
		Player:SendMessage( "JungleHills" )
	else
		Player:SendMessage( "/biomelist [Page]" )
	end
	return true
end

function SetBiomeFromString( Split, Player )
	Split[2] = string.upper(Split[2])
	if Split[2] == "OCEAN" then
		return 0
	elseif Split[2] == "PLAINS" then
		return 1
	elseif Split[2] == "DESERT" then
		return 2
	elseif Split[2] == "EXTEME_HILLS" then
		return 3
	elseif Split[2] == "FOREST" then
		return 4
	elseif Split[2] == "TAIGA" then
		return 5
	elseif Split[2] == "SWAMPLAND" then
		return 6
	elseif Split[2] == "RIVER" then
		return 7
	elseif Split[2] == "HELL" then
		return 8
	elseif Split[2] == "SKY" then
		return 9
	elseif Split[2] == "FROZENOCEAN" then
		return 10
	elseif Split[2] == "FROZENRIVER" then
		return 11
	elseif Split[2] == "ICE_PLAINS" then
		return 12
	elseif Split[2] == "ICE_MOUNTAINS" then
		return 13
	elseif Split[2] == "MUSHROOMISLAND" then
		return 14
	elseif Split[2] == "MUSHROOMISLANDSHORE" then
		return 15
	elseif Split[2] == "BEACH" then
		return 16
	elseif Split[2] == "DESERTHILLS" then
		return 17
	elseif Split[2] == "FORESTHILLS" then
		return 18
	elseif Split[2] == "TAIGAHILLS" then
		return 19
	elseif Split[2] == "EXTEME_HILLS_EDGE" then
		return 20
	elseif Split[2] == "JUNGLE" then
		return 21
	elseif Split[2] == "JUNGLEHILLS" then
		return 22
	else
		return false
	end
end

function HandleSetBiomeCommand( Split, Player )
	if Split[2] == nil then
		Player:SendMessage( cChatColor.Rose .. "Please say a biome" )
		return true
	end
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true
	end
	Biome = SetBiomeFromString( Split, Player )
	if Biome == false then
		Player:SendMessage( "Please specify a valid biome" )
		return true
	end
	--World = Player:GetWorld()
	if OnePlayerX[Player:GetName()] < TwoPlayerX[Player:GetName()] then
		OneX = OnePlayerX[Player:GetName()]
		TwoX = TwoPlayerX[Player:GetName()]
	else
		OneX = TwoPlayerX[Player:GetName()]
		TwoX = OnePlayerX[Player:GetName()]
	end
	if OnePlayerZ[Player:GetName()] < TwoPlayerZ[Player:GetName()] then
		OneZ = OnePlayerZ[Player:GetName()]
		TwoZ = TwoPlayerZ[Player:GetName()]
	else
		OneZ = TwoPlayerZ[Player:GetName()]
		TwoZ = OnePlayerZ[Player:GetName()]
	end
	for X=OneX, TwoX do
		for Z=OneZ, TwoZ do
			cChunkDesc:SetBiome( X, Z, Biome )
		end
	end
end

function HandleSetCommand( Split, Player )
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true
	end
	if Split[2] == nil then
		Player:SendMessage( cChatColor.Rose .. "Please say a block ID" )
	end
	Block = StringSplit( Split[2], ":" )
	if Block[1] == nil then
		Block[1] = 0
	end
	if Block[2] == nil then
		Block[2] = 0
	end
	if OnePlayerX[Player:GetName()] < TwoPlayerX[Player:GetName()] then
		OneX = OnePlayerX[Player:GetName()]
		TwoX = TwoPlayerX[Player:GetName()]
	else
		OneX = TwoPlayerX[Player:GetName()]
		TwoX = OnePlayerX[Player:GetName()]
	end
	if OnePlayerY[Player:GetName()] < TwoPlayerY[Player:GetName()] then
		OneY = OnePlayerY[Player:GetName()]
		TwoY = TwoPlayerY[Player:GetName()]
	else
		OneY = TwoPlayerY[Player:GetName()]
		TwoY = OnePlayerY[Player:GetName()]
	end
	if OnePlayerZ[Player:GetName()] < TwoPlayerZ[Player:GetName()] then
		OneZ = OnePlayerZ[Player:GetName()]
		TwoZ = TwoPlayerZ[Player:GetName()]
	else
		OneZ = TwoPlayerZ[Player:GetName()]
		TwoZ = OnePlayerZ[Player:GetName()]
	end
	World = Player:GetWorld()	
	BlockArea:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	BlockArea:Fill( 1, Block[1], Block[2] )
	BlockArea:Write( World, OneX, OneY, OneZ )
	Player:SendMessage( cChatColor.LightPurple .. GetSize( Player ) .. " block(s) have been changed." )
	return true
end




function HandleReplaceCommand( Split, Player )
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true
	end
	if Split[2] == nil or Split[3] == nil then
		Player:SendMessage( cChatColor.Rose .. "Please say a block ID" )
	end
	ChangeBlock = StringSplit( Split[2], ":" )
	if ChangeBlock[1] == nil then
		ChangeBlock[1] = 0
	end
	ToChangeBlock = StringSplit( Split[3], ":" )
	if ToChangeBlock[1] == nil then
		ToChangeBlock[1] = 0
	end
	if ToChangeBlock[2] == nil then
		ToChangeBlock[2] = 0
	end
	ChangeBlock[1] = tonumber(ChangeBlock[1])
	if ChangeBlock[2] ~= nil then
		ChangeBlock[2] = tonumber(ChangeBlock[2])
	end
	ToChangeBlock[1] = tonumber(ToChangeBlock[1])
	ToChangeBlock[2] = tonumber(ToChangeBlock[2])
	if OnePlayerX[Player:GetName()] < TwoPlayerX[Player:GetName()] then
		OneX = OnePlayerX[Player:GetName()]
		TwoX = TwoPlayerX[Player:GetName()]
	else
		OneX = TwoPlayerX[Player:GetName()]
		TwoX = OnePlayerX[Player:GetName()]
	end
	if OnePlayerY[Player:GetName()] < TwoPlayerY[Player:GetName()] then
		OneY = OnePlayerY[Player:GetName()]
		TwoY = TwoPlayerY[Player:GetName()]
	else
		OneY = TwoPlayerY[Player:GetName()]
		TwoY = OnePlayerY[Player:GetName()]
	end
	if OnePlayerZ[Player:GetName()] < TwoPlayerZ[Player:GetName()] then
		OneZ = OnePlayerZ[Player:GetName()]
		TwoZ = TwoPlayerZ[Player:GetName()]
	else
		OneZ = TwoPlayerZ[Player:GetName()]
		TwoZ = OnePlayerZ[Player:GetName()]
	end
	World = Player:GetWorld()
	Blocks[Player:GetName()] = 0
	BlockArea:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	for X=0, BlockArea:GetSizeX() - 1 do
		for Y=0, BlockArea:GetSizeY() - 1 do
			for Z=0, BlockArea:GetSizeZ() - 1 do
				if BlockArea:GetRelBlockType( X, Y, Z ) == ChangeBlock[1] then
					if BlockArea:GetRelBlockMeta( X, Y, Z ) == ChangeBlock[2] or ChangeBlock[2] == nil then
						BlockArea:SetRelBlockType( X, Y, Z, ToChangeBlock[1] )
						BlockArea:SetRelBlockMeta( X, Y, Z, ToChangeBlock[2] )
						Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
					end
				end
			end
		end
	end
	BlockArea:Write( World, OneX, OneY, OneZ )
	Player:SendMessage( cChatColor.LightPurple .. Blocks[Player:GetName()] .. " block(s) have been changed." )
	return true
end
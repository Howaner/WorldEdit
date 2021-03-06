
-- cmd_functions.lua

-- Implements the helper functions that do the actual filling / replacing / blocktracing work






--- Gets the number of blocks in that region.
function CountBlocks(a_PlayerState, a_Player, a_World, a_BlockTable)
	-- Read the area:
	local Area = cBlockArea()
	local MinX, MaxX = a_PlayerState.Selection:GetXCoordsSorted()
	local MinY, MaxY = a_PlayerState.Selection:GetYCoordsSorted()
	local MinZ, MaxZ = a_PlayerState.Selection:GetZCoordsSorted()
	Area:Read(a_World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ)
	
	-- Replace the blocks:
	local XSize = MaxX - MinX
	local YSize = MaxY - MinY
	local ZSize = MaxZ - MinZ
	local NumBlocks = 0
	
	for X = 0, XSize do
		for Y = 0, YSize do
			for Z = 0, ZSize do
				local BlockType, BlockMeta = Area:GetRelBlockTypeMeta(X, Y, Z)
				if (a_BlockTable[BlockType] and (a_BlockTable[BlockType].TypeOnly or a_BlockTable[BlockType].BlockMeta == BlockMeta)) then
					NumBlocks = NumBlocks + 1
				end
			end
		end
	end
	
	return NumBlocks
end




--- Fills the walls of the selection stored in the specified cPlayerState with the specified block type
-- Returns the number of blocks changed, or no value if disallowed
-- The original contents are pushed onto PlayerState's Undo stack
function FillWalls(a_PlayerState, a_Player, a_World, a_DstBlockTable)
	-- Check with other plugins if the operation is okay:
	if not(CheckAreaCallbacks(a_PlayerState.Selection:GetSortedCuboid(), a_Player, a_World, "walls")) then
		return
	end
	
	-- Push an Undo onto the stack:
	a_PlayerState:PushUndoInSelection(a_World, "walls")

	local Area = cBlockArea()
	local MinX, MaxX = a_PlayerState.Selection:GetXCoordsSorted()
	local MinY, MaxY = a_PlayerState.Selection:GetYCoordsSorted()
	local MinZ, MaxZ = a_PlayerState.Selection:GetZCoordsSorted()
	local XSize = MaxX - MinX
	local YSize = MaxY - MinY
	local ZSize = MaxZ - MinZ
	
	-- Read the area into a cBlockArea
	Area:Read(a_World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ, cBlockArea.baTypes + cBlockArea.baMetas)
	
	local NumDstBlocks = #a_DstBlockTable
	
	-- Place the walls
	for Y = 0, YSize do
		for X = 0, XSize do
			local Block = a_DstBlockTable[math.random(1, NumDstBlocks)]
			Area:SetRelBlockTypeMeta(X, Y, 0, Block.BlockType, Block.BlockMeta)
			
			Block = a_DstBlockTable[math.random(1, NumDstBlocks)]
			Area:SetRelBlockTypeMeta(X, Y, ZSize, Block.BlockType, Block.BlockMeta)
		end
		
		-- The X for loop already did the 0 coordinate and ZSize so we don't have to do that here
		for Z = 1, ZSize - 1 do
			local Block = a_DstBlockTable[math.random(1, NumDstBlocks)]
			Area:SetRelBlockTypeMeta(0, Y, Z, Block.BlockType, Block.BlockMeta)
			
			Block = a_DstBlockTable[math.random(1, NumDstBlocks)]
			Area:SetRelBlockTypeMeta(XSize, Y, Z, Block.BlockType, Block.BlockMeta)
		end
	end

	Area:Write(a_World, MinX, MinY, MinZ)
	Area:Clear()
	a_World:WakeUpSimulatorsInArea(MinX - 1, MaxX + 1, MinY - 1, MaxY + 1, MinZ - 1, MaxZ + 1)
	
	-- Calculate the number of changed blocks:
	local VolumeIncluding = (XSize + 1) * (YSize + 1) * (ZSize + 1)  -- Volume of the cuboid INcluding the walls
	local VolumeExcluding = (XSize - 1) * (YSize + 1) * (ZSize - 1)  -- Volume of the cuboid EXcluding the walls
	if (VolumeExcluding < 0) then
		VolumeExcluding = 0
	end
	return VolumeIncluding - VolumeExcluding
end





--- Fills the faces of the selection stored in the specified cPlayerState with the specified block type
-- Returns the number of blocks changed, or no value if disallowed
-- The original contents are pushed onto PlayerState's Undo stack
function FillFaces(a_PlayerState, a_Player, a_World, a_DstBlockTable)
	-- Check with other plugins if the operation is okay:
	if not(CheckAreaCallbacks(a_PlayerState.Selection:GetSortedCuboid(), a_Player, a_World, "faces")) then
		return
	end
	
	-- Push an Undo onto the stack:
	a_PlayerState:PushUndoInSelection(a_World, "faces")

	-- Fill the faces:
	local Area = cBlockArea()
	local MinX, MaxX = a_PlayerState.Selection:GetXCoordsSorted()
	local MinY, MaxY = a_PlayerState.Selection:GetYCoordsSorted()
	local MinZ, MaxZ = a_PlayerState.Selection:GetZCoordsSorted()
	local XSize = MaxX - MinX
	local YSize = MaxY - MinY
	local ZSize = MaxZ - MinZ
	
	-- Read the area into a cBlockArea
	Area:Read(a_World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ, cBlockArea.baTypes + cBlockArea.baMetas)
	
	local NumDstBlocks = #a_DstBlockTable
	
	-- Place the walls
	for Y = 0, YSize do
		for X = 0, XSize do
			local Block = a_DstBlockTable[math.random(1, NumDstBlocks)]
			Area:SetRelBlockTypeMeta(X, Y, 0, Block.BlockType, Block.BlockMeta)
			
			Block = a_DstBlockTable[math.random(1, NumDstBlocks)]
			Area:SetRelBlockTypeMeta(X, Y, ZSize, Block.BlockType, Block.BlockMeta)
		end
		
		-- The X for loop already did the 0 coordinate and ZSize so we don't have to do that here
		for Z = 1, ZSize - 1 do
			local Block = a_DstBlockTable[math.random(1, NumDstBlocks)]
			Area:SetRelBlockTypeMeta(0, Y, Z, Block.BlockType, Block.BlockMeta)
			
			Block = a_DstBlockTable[math.random(1, NumDstBlocks)]
			Area:SetRelBlockTypeMeta(XSize, Y, Z, Block.BlockType, Block.BlockMeta)
		end
	end
	
	-- Place the ceiling and floor
	for Y = 0, YSize, YSize do
		for X = 0, XSize do
			for Z = 0, ZSize do
				local Block = a_DstBlockTable[math.random(1, NumDstBlocks)]
				Area:SetRelBlockTypeMeta(X, Y, Z, Block.BlockType, Block.BlockMeta)
			end
		end
	end
	
	Area:Write(a_World, MinX, MinY, MinZ)
	Area:Clear()
	a_World:WakeUpSimulatorsInArea(MinX - 1, MaxX + 1, MinY - 1, MaxY + 1, MinZ - 1, MaxZ + 1)
	
	-- Calculate the number of changed blocks:
	local VolumeIncluding = (XSize + 1) * (YSize + 1) * (ZSize + 1)  -- Volume of the cuboid INcluding the faces
	local VolumeExcluding = (XSize - 1) * (YSize - 1) * (ZSize - 1)  -- Volume of the cuboid EXcluding the faces
	if (VolumeExcluding < 0) then
		VolumeExcluding = 0
	end
	return VolumeIncluding - VolumeExcluding
end





--- Fills the selection stored in the specified cPlayerState with the specified block type
-- Returns the number of blocks changed, or no value if disallowed
-- The original contents are pushed onto PlayerState's Undo stack
function FillSelection(a_PlayerState, a_Player, a_World, a_DstBlockTable)
	-- Check with other plugins if the operation is okay:
	if not(CheckAreaCallbacks(a_PlayerState.Selection:GetSortedCuboid(), a_Player, a_World, "fill")) then
		return
	end
	
	-- Push an Undo onto the stack:
	a_PlayerState:PushUndoInSelection(a_World, "fill")

	-- Fill the selection:
	local Area = cBlockArea()
	local MinX, MaxX = a_PlayerState.Selection:GetXCoordsSorted()
	local MinY, MaxY = a_PlayerState.Selection:GetYCoordsSorted()
	local MinZ, MaxZ = a_PlayerState.Selection:GetZCoordsSorted()
	
	Area:Create(MaxX - MinX + 1, MaxY - MinY + 1, MaxZ - MinZ + 1)
	
	local SizeX, SizeY, SizeZ = Area:GetSize()
	SizeX, SizeY, SizeZ = SizeX - 1, SizeY - 1, SizeZ - 1

	local BlockTable = CalculateBlockChances(a_DstBlockTable)

	for X = 0, SizeX do
		for Y = 0, SizeY do
			for Z = 0, SizeZ do
				local RandomNumber = math.random()
				for Idx, Value in ipairs(BlockTable) do
					if (RandomNumber <= Value.Chance) then
						Area:SetRelBlockTypeMeta(X, Y, Z, Value.BlockType, Value.BlockMeta)
						break
					end
				end
			end
		end
	end
	
	Area:Write(a_World, MinX, MinY, MinZ)
	Area:Clear()
	a_World:WakeUpSimulatorsInArea(MinX - 1, MaxX + 1, MinY - 1, MaxY + 1, MinZ - 1, MaxZ + 1)
	
	return (MaxX - MinX + 1) * (MaxY - MinY + 1) * (MaxZ - MinZ + 1)
end





--- Replaces the specified blocks in the selection stored in the specified cPlayerState
-- Returns the number of blocks changed, or no value if disallowed
-- The original contents are pushed onto PlayerState's Undo stack
-- If a_TypeOnly is set, the block meta is ignored will be replaced
function ReplaceSelection(a_PlayerState, a_Player, a_World, a_SrcBlockTable, a_DstBlockTable)
	-- Check with other plugins if the operation is okay:
	if not(CheckAreaCallbacks(a_PlayerState.Selection:GetSortedCuboid(), a_Player, a_World, "replace")) then
		return
	end
	
	-- Push an Undo onto the stack:
	a_PlayerState:PushUndoInSelection(a_World, "replace")

	-- Read the area to be replaced:
	local Area = cBlockArea()
	local MinX, MaxX = a_PlayerState.Selection:GetXCoordsSorted()
	local MinY, MaxY = a_PlayerState.Selection:GetYCoordsSorted()
	local MinZ, MaxZ = a_PlayerState.Selection:GetZCoordsSorted()
	Area:Read(a_World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ)
	
	-- Read percents from the DstBlock table
	local MaxChance = 0
	for Idx, Value in ipairs(a_DstBlockTable) do
		MaxChance = MaxChance + Value.Chance
	end
	
	local BlockTable = {}
	local Temp = 0
	for Idx, Value in ipairs(a_DstBlockTable) do
		Temp = Temp + Value.Chance / MaxChance
		table.insert(BlockTable, {BlockType = Value.BlockType, BlockMeta = Value.BlockMeta, Chance = Temp})
	end
	
	-- Replace the blocks:
	local XSize = MaxX - MinX
	local YSize = MaxY - MinY
	local ZSize = MaxZ - MinZ
	local NumBlocks = 0
	
	for X = 0, XSize do
		for Y = 0, YSize do
			for Z = 0, ZSize do
				local BlockType, BlockMeta = Area:GetRelBlockTypeMeta(X, Y, Z)
				if (a_SrcBlockTable[BlockType] and (a_SrcBlockTable[BlockType].TypeOnly or a_SrcBlockTable[BlockType].SrcBlockMeta == BlockMeta)) then
					local RandomNumber = math.random()
					for Idx, Value in ipairs(BlockTable) do
						if (RandomNumber <= Value.Chance) then
							Area:SetRelBlockTypeMeta(X, Y, Z, Value.BlockType, Value.BlockMeta)
							NumBlocks = NumBlocks + 1
							break
						end
					end
				end
			end
		end
	end
	
	-- Write the area back to world:
	Area:Write(a_World, MinX, MinY, MinZ)
	a_World:WakeUpSimulatorsInArea(MinX - 1, MaxX + 1, MinY - 1, MaxY + 1, MinZ - 1, MaxZ + 1)
	
	return NumBlocks
end




RetrieveBlockTypesTemp = {}
function RetrieveBlockTypes(Input)
	if (RetrieveBlockTypesTemp[Input] ~= nil) then
		return RetrieveBlockTypesTemp[Input]
	end
	
	local RawDstBlockTable = StringSplit(Input, ",")
	local BlockTable = {}
	for Idx, Value in ipairs(RawDstBlockTable) do
		-- Block chance
		local Chance = 100
		if (string.find(Value, "%", 1, true) ~= nil) then
			local SplittedValues = StringSplit(Value, "%")
			if (#SplittedValues ~= 2) then
				return false
			end
			Chance = tonumber(SplittedValues[1])
			Value = SplittedValues[2]
			
			if (Chance == nil) then
				return false
			end
		end
		
		local BlockType, BlockMeta = GetBlockTypeMeta(Value)
		if not(BlockType) then
			return false
		end
		table.insert(BlockTable, {BlockType = BlockType, BlockMeta = BlockMeta, Chance = Chance})
	end
	
	RetrieveBlockTypesTemp[Input] = BlockTable
	return BlockTable
end





-- Calculate the chances for a block and returns the changed table. It is used for % params.
function CalculateBlockChances(BlockTable)
	local MaxChance = 0
	for Idx, Value in ipairs(BlockTable) do
		MaxChance = MaxChance + Value.Chance
	end
	
	local NewBlockTable = {}
	local Temp = 0
	for Idx, Value in ipairs(BlockTable) do
		Temp = Temp + Value.Chance / MaxChance
		table.insert(NewBlockTable, {BlockType = Value.BlockType, BlockMeta = Value.BlockMeta, Chance = Temp})
	end

	return NewBlockTable
end





-- Returns the coordinates (in a vector) from a block that the player has targeted. Returns nil if not block found.
function GetTargetBlock(a_Player)
	local MaxDistance = 150  -- A max distance of 150 blocks

	local FoundBlock = nil
	local Callbacks = {
		OnNextBlock = function(a_BlockX, a_BlockY, a_BlockZ, a_BlockType, a_BlockMeta)
			if (a_BlockType ~= E_BLOCK_AIR) then
				FoundBlock = { x = a_BlockX, y = a_BlockY, z = a_BlockZ }
				return true
			end
		end
	};

	local EyePos = a_Player:GetEyePosition()
	local LookVector = a_Player:GetLookVector()
	LookVector:Normalize()

	local Start = EyePos + LookVector + LookVector
	local End = EyePos + LookVector * MaxDistance

	local HitNothing = cLineBlockTracer.Trace(a_Player:GetWorld(), Callbacks, Start.x, Start.y, Start.z, End.x, End.y, End.z)
	if (HitNothing) then
		-- No block found
		return nil
	end

	return Vector3i(FoundBlock.x, FoundBlock.y, FoundBlock.z)
end





-- Create a sphere at these coordinates. Returns the affected blocks count.
function CreateSphereAt(a_BlockTable, a_Position, a_Player, a_Radius, a_Hollow)
	-- Check if other plugins agree with the operation:
	local World = a_Player:GetWorld()
	local MinX, MaxX = a_Position.x - a_Radius, a_Position.x + a_Radius
	local MinY, MaxY = a_Position.y - a_Radius, a_Position.y + a_Radius
	local MinZ, MaxZ = a_Position.z - a_Radius, a_Position.z + a_Radius
	local Cuboid = cCuboid(MinX, MinY, MinZ, MaxX, MaxY, MaxZ)
	Cuboid:ClampY(0, 255)

	local ActionName = "sphere"
	if (a_Hollow) then
		ActionName = "hsphere"
	end

	if not(CheckAreaCallbacks(Cuboid, a_Player, World, ActionName)) then
		return 0
	end

	-- Push the area into an undo stack:
	local State = GetPlayerState(a_Player)
	State.UndoStack:PushUndoFromCuboid(World, Cuboid)

	-- Read the current contents of the world:
	local BlockArea = cBlockArea()
	BlockArea:Read(World, Cuboid, cBlockArea.baTypes + cBlockArea.baMetas)

	local BlockTable = CalculateBlockChances(a_BlockTable)

	-- Change blocks inside the sphere:
	local MidPoint = Vector3d(a_Radius, a_Position.y - MinY, a_Radius)  -- Midpoint of the sphere, relative to the area
	local NumBlocks = 0
	local SqrRadius = a_Radius * a_Radius
	for Y = 0, Cuboid.p2.y - Cuboid.p1.y do  -- The Cuboid has been Y-clamped correctly, take advantage of that
		for Z = 0, 2 * a_Radius do
			for X = 0, 2 * a_Radius do
				local ChangeBlock = false
				if (a_Hollow) then
					local Distance = math.floor((MidPoint - Vector3d(X, Y, Z)):Length())
					if (Distance == a_Radius) then
						ChangeBlock = true
					end
				else
					local Distance = math.floor((MidPoint - Vector3d(X, Y, Z)):SqrLength())
					if (Distance <= SqrRadius) then
						ChangeBlock = true
					end
				end

				if (ChangeBlock) then
					local RandomNumber = math.random()
					for Idx, Value in ipairs(BlockTable) do
						if (RandomNumber <= Value.Chance) then
							BlockArea:SetRelBlockTypeMeta(X, Y, Z, Value.BlockType, Value.BlockMeta)
							break
						end
					end
					NumBlocks = NumBlocks + 1
				end
			end
		end
	end

	-- Write the area back to world:
	BlockArea:Write(World, MinX, MinY, MinZ)
	return NumBlocks
end





-- Create a cylinder at these coordinates. Returns the affected blocks count.
function CreateCylinderAt(a_BlockTable, a_Position, a_Player, a_Radius, a_Height, a_Hollow)
	local MinX, MaxX = a_Position.x - a_Radius, a_Position.x + a_Radius
	local MinY, MaxY = a_Position.y, a_Position.y + a_Height
	local MinZ, MaxZ = a_Position.z - a_Radius, a_Position.z + a_Radius
	local World = a_Player:GetWorld()
	
	local Cuboid = cCuboid(MinX, MinY, MinZ, MaxX, MaxY, MaxZ)
	Cuboid:ClampY(0, 255)

	local ActionName = "cyl"
	if (a_Hollow) then
		ActionName = "hcyl"
	end

	if not(CheckAreaCallbacks(Cuboid, a_Player, World, ActionName)) then
		return 0
	end
	
	-- Push the area into an undo stack:
	local State = GetPlayerState(a_Player)
	State.UndoStack:PushUndoFromCuboid(World, Cuboid)

	local BlockTable = CalculateBlockChances(a_BlockTable)
	local BlockArea = cBlockArea()
	BlockArea:Read(World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ, cBlockArea.baTypes + cBlockArea.baMetas)
	local Size = a_Radius * 2
	local MiddleVector = Vector3d(a_Radius, 0, a_Radius)
	local NumBlocks = 0

	for Y = 0, a_Height do
		for X = 0, Size do
			for Z = 0, Size do
				local TempVector = Vector3d(X, 0, Z)
				local Distance = math.floor((MiddleVector - TempVector):Length())

				if (
					((Distance <= a_Radius) and (not a_Hollow)) or
					((Distance == a_Radius) and a_Hollow)
				) then
					local RandomNumber = math.random()
					for Idx, Value in ipairs(BlockTable) do
						if (RandomNumber <= Value.Chance) then
							BlockArea:SetRelBlockTypeMeta(X, Y, Z, Value.BlockType, Value.BlockMeta)
							break
						end
					end
					NumBlocks = NumBlocks + 1
				end
			end
		end
	end
	
	BlockArea:Write(World, MinX, MinY, MinZ)
	return NumBlocks
end





-------------------------------------------
------------RIGHTCLICKCOMPASS--------------
-------------------------------------------
function RightClickCompass(Player)
	local World = Player:GetWorld()
	local Teleported = false
	local WentThroughBlock = false
	
	local Callbacks = {
		OnNextBlock = function(X, Y, Z, BlockType, BlockMeta)
			if not cBlockInfo:IsTransparent(BlockType) then
				WentThroughBlock = true
			else
				if WentThroughBlock then
					if BlockType == E_BLOCK_AIR and cBlockInfo:IsSolid(World:GetBlock(X, Y - 1, Z)) then
						Player:TeleportToCoords(X + 0.5, Y, Z + 0.5)
						Teleported = true
						return true
					else
						for y = Y, 1, -1 do
							if cBlockInfo:IsSolid(World:GetBlock(X, y, Z)) then
								Player:TeleportToCoords(X + 0.5, y + 1, Z + 0.5)
								Teleported = true
								return true
							end
						end
					end
				end
			end
		end;
	};
	local EyePos = Player:GetEyePosition()
	local LookVector = Player:GetLookVector()
	LookVector:Normalize()	

	local Start = EyePos
	local End = EyePos + LookVector * 75
	
	cLineBlockTracer.Trace(World, Callbacks, Start.x, Start.y, Start.z, End.x, End.y, End.z)
	if not Teleported then
		Player:SendMessage(cChatColor.Rose .. "Nothing to pass through!")
	end
end


------------------------------------------
------------LEFTCLICKCOMPASS--------------
------------------------------------------
function LeftClickCompass(Player)
	local World = Player:GetWorld()
	local HasHit = false
	
	-- Remember the coords of the last checked block:
	local LastX = Player:GetPosX()
	local LastY = Player:GetPosY()
	local LastZ = Player:GetPosZ()
	
	-- Callback that checks whether the block on the traced line is non-solid:
	local Callbacks = {
		OnNextBlock = function(X, Y, Z, BlockType, BlockMeta)
			if BlockType ~= E_BLOCK_AIR and not cBlockInfo:IsOneHitDig(BlockType) then
				local IsValid, WorldHeight = World:TryGetHeight(X, Z)
				for y = Y, WorldHeight + 1 do
					if not cBlockInfo:IsSolid(World:GetBlock(X, y, Z)) then
						Y = y
						break
					end
				end
				Player:TeleportToCoords(X + 0.5, Y, Z + 0.5)
				HasHit = true
				return true
			end
			LastX = X
			LastY = Y
			LastZ = Z
		end
	};
	
	-- Trace the line from the player's eyes in their look direction:
	local EyePos = Player:GetEyePosition()
	local LookVector = Player:GetLookVector()
	LookVector:Normalize()
	local Start = EyePos
	local End = EyePos + LookVector * 75
	cLineBlockTracer.Trace(World, Callbacks, Start.x, Start.y, Start.z, End.x, End.y, End.z)
	
	-- If no block has been hit, teleport the player to the last checked block location (known non-solid):
	if not(HasHit) then
		Player:TeleportToCoords(LastX + 0.5, LastY, LastZ + 0.5)
	end
	
	return true
end





--- Traces blocks in a line-of-sight of the player until it hits a non-air non-1-hit-dig block
-- Returns the coords of the block as a table {x = ..., y = ..., z = ... }
-- If nothing is hit within the specified distance, returns nil
function HPosSelect(a_Player, a_MaxDistance)
	assert(tolua.type(a_Player) == "cPlayer")
	a_MaxDistance = a_MaxDistance or 150
	
	-- Prepare the vectors to be used for the tracing:
	local Start = a_Player:GetEyePosition()
	local LookVector = a_Player:GetLookVector()
	LookVector:Normalize()
	local End = Start + LookVector * a_MaxDistance
	
	-- The callback checks the blocktype of the hit, saves coords if true hit and aborts:
	local hpos = nil
	local Callbacks =
	{
		OnNextBlock = function(a_X, a_Y, a_Z, a_BlockType, a_BlockMeta)
			if ((a_BlockType ~= E_BLOCK_AIR) and not(cBlockInfo:IsOneHitDig(a_BlockType))) then
				hpos = {x = a_X, y = a_Y, z = a_Z }
				return true
			end
		end
	}
	
	-- Trace:
	if (cLineBlockTracer.Trace(a_Player:GetWorld(), Callbacks, Start.x, Start.y, Start.z, End.x, End.y, End.z)) then
		-- Nothing reached within the distance, return nil for failure
		return nil
	end
	return hpos
end





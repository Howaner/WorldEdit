----------------------------------------------
----------------------UP----------------------
----------------------------------------------
function HandleUpCommand(Split, Player)
	if #Split < 2 then
		Player:SendMessage(cChatColor.Rose .. "Too few arguments.")
		Player:SendMessage(cChatColor.Rose .. "/up <block>")
		return true
	elseif #Split > 2 then
		Player:SendMessage(cChatColor.Rose .. "Too many arguments.")
		Player:SendMessage(cChatColor.Rose .. "/up <block>")
		return true
	end
	
	local Height = tonumber(Split[2])
	if Height == nil then -- The given string isn't a number. bail out.
		Player:SendMessage(cChatColor.Rose .. 'Number expected; string"' .. Split[2] .. '" given.')
		return true
	end
	local Y = math.floor(Player:GetPosY())
	local y = math.floor(Player:GetPosY()) + Height
	local X = math.floor(Player:GetPosX())
	local Z = math.floor(Player:GetPosZ())
	local World = Player:GetWorld()
	for Y = Y, y + 1 do
		if World:GetBlock(X, Y, Z) ~= E_BLOCK_AIR then
			Player:SendMessage(cChatColor.Rose .. "You would hit something above you.")
			return true
		end
	end
	
	if not CheckIfInsideAreas(X, X, y - 1, y - 1, Z, Z, Player, World, "up") then
		World:SetBlock(X, y - 1, Z, 20, 0)
	end
	
	Player:TeleportToCoords(X + 0.5, y, Z + 0.5)
	Player:SendMessage(cChatColor.LightPurple .. "Whoosh!")
	return true
end


----------------------------------------------
--------------------JUMPTO--------------------
----------------------------------------------
function HandleJumpToCommand(Split, Player)
	if #Split ~= 1 then
		Player:SendMessage(cChatColor.Rose .. "Too many arguments.")
		Player:SendMessage(cChatColor.Rose .. "/jumpto")
		return true
	end
	
	LeftClickCompass(Player, Player:GetWorld())
	Player:SendMessage(cChatColor.LightPurple .. "Poof!!")
	return true
end


----------------------------------------------
---------------------THRU---------------------
----------------------------------------------
function HandleThruCommand(Split, Player)
	if #Split ~= 1 then
		Player:SendMessage(cChatColor.Rose .. "Too many arguments.")
		Player:SendMessage(cChatColor.Rose .. "/thru")
		return true
	end
	
	RightClickCompass(Player, Player:GetWorld())
	Player:SendMessage(cChatColor.LightPurple .. "Whoosh!")
	return true
end


-----------------------------------------------
--------------------DESCEND--------------------
-----------------------------------------------
function HandleDescendCommand(Split, Player)
	local World = Player:GetWorld()
	if Player:GetPosY() < 1 then
		Player:SendMessage(cChatColor.LightPurple .. "Descended a level.")
		return true
	end
	
	local FoundYCoordinate = false
	local WentThroughBlock = false
	local XPos = math.floor(Player:GetPosX())
	local YPos = Player:GetPosY()
	local ZPos = math.floor(Player:GetPosZ())

	for Y = math.floor(YPos), 1, -1 do
		if World:GetBlock(XPos, Y, ZPos) ~= E_BLOCK_AIR then
			WentThroughBlock = true
		else
			if WentThroughBlock then
				for y = Y, 1, -1 do
					if cBlockInfo:IsSolid(World:GetBlock(XPos, y, ZPos)) then
						YPos = y
						FoundYCoordinate = true
						break
					end
				end
				
				if FoundYCoordinate then
					break
				end
			end
		end
	end
	
	if FoundYCoordinate then
		Player:TeleportToCoords(Player:GetPosX(), YPos + 1, Player:GetPosZ())
	end
	
	Player:SendMessage(cChatColor.LightPurple .. "Descended a level.")
	return true
end


------------------------------------------------
---------------------ASCEND---------------------
------------------------------------------------
function HandleAscendCommand(Split, Player)
	local World = Player:GetWorld()
	local XPos = math.floor(Player:GetPosX())
	local YPos = Player:GetPosY()
	local ZPos = math.floor(Player:GetPosZ())
	
	local IsValid, WorldHeight = World:TryGetHeight(XPos, ZPos)
	
	if not IsValid then
		Player:SendMessage(cChatColor.LightPurple .. "Ascended a level.")
		return true
	end
	
	if Player:GetPosY() == WorldHeight then
		Player:SendMessage(cChatColor.LightPurple .. "Ascended a level.")
		return true
	end
	
	
	local WentThroughBlock = false

	for Y = math.floor(Player:GetPosY()), WorldHeight + 1 do
		if World:GetBlock(XPos, Y, ZPos) == E_BLOCK_AIR then
			if WentThroughBlock then
				YPos = Y
				break
			end
		else
			WentThroughBlock = true
		end
	end
	
	if WentThroughBlock then			
		Player:TeleportToCoords(Player:GetPosX(), YPos, Player:GetPosZ())
	end
	
	Player:SendMessage(cChatColor.LightPurple .. "Ascended a level.")
	return true
end


------------------------------------------------
----------------------CEIL----------------------
------------------------------------------------
function HandleCeilCommand(Split, Player)
	if #Split > 2 then
		Player:SendMessage(cChatColor.Rose .. "Too many arguments.")
		Player:SendMessage(cChatColor.Rose .. "/ceil [cleurance]")
		return true
	end
	
	local BlockFromCeil
	if Split[2] == nil then
		BlockFromCeil = 0
	else
		BlockFromCeil = tonumber(Split[2])
	end
	
	if BlockFromCeil == nil then
		Player:SendMessage(cChatColor.Rose .. 'Number expected; string "' .. Split[2] .. '" given.')
		return true
	end
	local World = Player:GetWorld()
	local X = math.floor(Player:GetPosX())
	local Y = math.floor(Player:GetPosY())
	local Z = math.floor(Player:GetPosZ())
	local IsValid, WorldHeight = World:TryGetHeight(X, Z)
	
	if not IsValid then
		Player:SendMessage(cChatColor.LightPurple .. "Whoosh!")
		return true
	end
	
	if Y >= WorldHeight + 1 then
		Player:SendMessage(cChatColor.Rose .. "No free spot above you found.")
		return true
	end
	
	for y=Y, WorldHeight do
		if World:GetBlock(X, y, Z) ~= E_BLOCK_AIR then
			if not CheckIfInsideAreas(X, X, y - BlockFromCeil - 3, y - BlockFromCeil - 3, Z, Z, Player, PlayerWorld, "ceil") then
				World:SetBlock(X, y - BlockFromCeil - 3, Z, E_BLOCK_GLASS, 0)
			end
			local I = y - BlockFromCeil - 2
			if I == Y then
				Player:SendMessage(cChatColor.Rose .. "No free spot above you found.")
				return true
			end
			Player:TeleportToCoords(X + 0.5, I, Z + 0.5)
			break
		end
	end
	
	Player:SendMessage(cChatColor.LightPurple .. "Whoosh!")
	return true
end
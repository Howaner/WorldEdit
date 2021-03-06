
-- cmd_Other.lua

-- Has the commands that don't really fit in a category.





-- Complete CUI handshake
function HandleWorldEditCuiCommand(a_Split, a_Player)
	-- /we cui
	
	local State = GetPlayerState(a_Player)
	State.IsWECUIActivated = true
	State.Selection:NotifySelectionChanged()
	return true
end





-- Sends the version of the plugin.
function HandleWorldEditVersionCommand(a_Split, a_Player)
	-- /we version
	
	a_Player:SendMessage(cChatColor.LightPurple .. "This is version " .. PLUGIN:GetVersion())
	return true
end





-- Reloads the WorldEdit plugin.
function HandleWorldEditReloadCommand(Split, Player)
	-- /we reload
	
	if (not Player:HasPermission("worldedit.reload")) then
		Player:SendMessage(cChatColor.Rose .. "You do not have permission to reload WorldEdit.")
		return true
	end
	
	Player:SendMessage(cChatColor.LightPurple .. "Worldedit is reloading")
	cRoot:Get():GetPluginManager():DisablePlugin(PLUGIN:GetName()) -- disable the plugin
	DisablePlugin = true -- make sure the plugin loads again ;)
	return true
end





-- Sends all the available commands to the player.
function HandleWorldEditHelpCommand(Split, Player)
	-- /we help
	
	if not PlayerHasWEPermission(Player, "worldedit.help") then
		Player:SendMessage(cChatColor.Rose .. "You do not have permission for this command.")
		return true
	end
	
	local Commands = ""
	for Command, Information in pairs(g_PluginInfo.Commands) do
		Commands = Commands .. cChatColor.LightPurple .. Command .. ", "
	end
	
	Player:SendMessage(cChatColor.LightPurple .. "Available commands:")
	Player:SendMessage(string.sub(Commands, 1, string.len(Commands) - 2)) -- Remove the last ", "
	return true
end





-- Gives the player the wand item.
function HandleWandCommand(Split, Player)
	-- //wand
	
	Item = cItem(Wand) -- create the cItem object
	if (Player:GetInventory():AddItem(Item)) then -- check if the player got the item
		Player:SendMessage(cChatColor.Green .. "You have received the wand.")
	else
		Player:SendMessage(cChatColor.Green .. "Not enough inventory space.")
	end
	return true
end





-- Toggles if the wand is active or not.
function HandleToggleEditWandCommand(a_Split, a_Player)
	-- //togglewand
	
	local State = GetPlayerState(a_Player)
	if not(State.WandActivated) then
		State.WandActivated = true
		a_Player:SendMessage(cChatColor.LightPurple .. "Edit wand enabled.")
	else
		State.WandActivated = false
		a_Player:SendMessage(cChatColor.LightPurple .. "Edit wand disabled.")
	end
	return true
end





-- Loads and executes a craftscript
function HandleCraftScriptCommand(a_Split, a_Player)
	-- /cs <scriptname>
	
	local PlayerState = GetPlayerState(a_Player)
	
	if (not a_Split[2]) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: /cs <scriptname>")
		return true
	end
	
	local Succes, Err = PlayerState.CraftScript:SelectScript(a_Split[2])
	if (not Succes) then
		a_Player:SendMessage(cChatColor.Rose .. Err)
		return true
	end
	
	local Arguments = a_Split
	table.remove(Arguments, 1); table.remove(Arguments, 1)
	
	Succes, Err = PlayerState.CraftScript:Execute(a_Player, Arguments)
	if (not Succes) then
		a_Player:SendMessage(cChatColor.Rose .. Err)
		return true
	end
	
	a_Player:SendMessage(cChatColor.LightPurple .. "Script executed.")
	return true
end





-- Executes the last used craftscript.
function HandleLastCraftScriptCommand(a_Split, a_Player)
	-- /.s
	
	local PlayerState = GetPlayerState(a_Player)
	
	local Arguments = a_Split
	table.remove(Arguments, 1)
	
	Succes, Err = PlayerState.CraftScript:Execute(a_Player, Arguments)
	if (not Succes) then
		a_Player:SendMessage(cChatColor.Rose .. Err)
		return true
	end
	
	a_Player:SendMessage(cChatColor.Rose .. "Script Executed")
	return true
end





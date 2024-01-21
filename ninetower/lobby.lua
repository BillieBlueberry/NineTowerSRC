-- there used to be the location thing in the corner in here but I moved it
function LobbyLoadingandIntializing (i)

    local i=1, _MaxPlayers();
	_OpenScript("gamemodes/ninetower/location.lua");
    _PlayerSetMaxSpeed( i, speed);
    _OpenScript("ULib/ulib_plugin.lua")
    _ServerCommand("npc_citizen_auto_player_squad 0 \n")
    
end

function SendPeople(Caller, Activator, Server)
    _ServerCommand("ulib_plugin_cexec " .. tostring(Caller) .. " connect " .. Server .. "\n")
end

local cached = {}
local data = {}
if pmselect then
    for _, hook in pairs(pmselect.hooks) do
        UnHookEvent(hook)
    end
    gConsoleCommands.playermodel = nil
    cached = pmselect.cached
    data = pmselect.data
end

pmselect = {
    hooks = {},
    playermodels = {
        {"Half-Life 2: Main NPCs", {
            {"Alyx", "models/Player/alyx.mdl"},
            {"Barney", "models/Player/barney.mdl"},
            {"Breen", "models/Player/breen.mdl"},
            {"Eli", "models/Player/eli.mdl"},
            {"Kleiner", "models/Player/Kleiner.mdl"},
            {"Mossman", "models/Player/mossman.mdl"}
        }},
        {"Half-Life 2: Other NPCs", {
            {"Monk", "models/Player/monk.mdl"},
            {"Odessa", "models/Player/odessa.mdl"},
            {"Gman", "models/Player/gman_high.mdl"},
        }},
        {"Half-Life 2: Citizens", {
            {"Male 02", "models/Player/male_02.mdl"},
            {"Male 03", "models/Player/male_03.mdl"},
            {"Male 08", "models/Player/male_08.mdl"},
            {"Female 04", "models/Player/female_04.mdl"},
            {"Female 06", "models/Player/female_06.mdl"},
            {"Female 07", "models/Player/female_07.mdl"},
        }},
        {"Half-Life 2: Combine", {
            {"Metrocop", "models/Player/police.mdl"},
            {"Combine Soldier", "models/Player/combine_soldier.mdl"},
            {"Combine Soldier Prison Guard", "models/Player/combine_soldier_prisonguard.mdl"},
            {"Combine Super Soldier", "models/Player/combine_super_soldier.mdl"},
            {"Stripped", "models/Player/stripped.mdl"},
            {"Stalker", "models/Player/stalker.mdl"},
        }},
        {"Half-Life 2: Corpses", {
            {"Charple", "models/Player/charple01.mdl"},
            {"Corpse", "models/Player/corpse1.mdl"},
        }},
        {"Other", {
            {"Semper", "models/player.mdl"},
            {"larry", "models/nothing_forever/larry.mdl"},
        }}
    },
    cached = cached,
    data = data
}
cached = nil
data = nil


-- Internal functions
local function add_category(player)
    for _, category in pairs(pmselect.playermodels) do
        _spawnmenu.AddItem(player, "Playermodels", "@" .. category[1], "echo test")
        for _, data in pairs(category[2]) do
            _spawnmenu.AddItem(player, "Playermodels", "+" .. data[1], "playermodel " .. data[2])
        end
    end
end

local function update_model(player)
    local model = pmselect.data[player]
    if _EntGetModel(player) ~= model then
        if pmselect.cached[model] ~= true then
            _EntPrecacheModel(model)
            pmselect.cached[model] = true
        end
        _EntSetModel(player, model)
    end
end

for player = 1, _MaxPlayers() do
    if _PlayerInfo(player, "connected") == true then
        if pmselect.data[player] == nil then
            pmselect.data[player] = _EntGetModel(player)
        end
        _spawnmenu.RemoveCategory(player, "Playermodels")
        add_category(player)
        update_model(player)
    end
end


-- Console command
CONCOMMAND("playermodel", function(player, model)
    pmselect.data[player] = model
    update_model(player)
end)


-- Hooks
pmselect.hooks.join = HookEvent("eventPlayerInitialSpawn", function(player)
    add_category(player)
    update_model(player)
end)

pmselect.hooks.leave = HookEvent("eventPlayerDisconnect", function(_, player, _, _, _)
    -- You should probably save the models preferences instead of cleaning 'em after the player leaves
    pmselect.data[player] = nil
end)

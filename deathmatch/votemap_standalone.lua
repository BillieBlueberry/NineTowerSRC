
function gmodtext(userid, font, c, x, y, text, fadein, fadeout, dur, name, ent, offset)
	local chan
	
	if tonumber(name) then
		chan = name
		if not chan then print("name failed") end
	else
		chan = addToName(userid, name, TEXT)
		if not chan then print("addtoname failed") end
	end
	
	if not chan then return end
	
	_GModText_Start(font)
	_GModText_AllowOffscreen(false)
	_GModText_SetColor(c[1], c[2], c[3], c[4])
	_GModText_SetPos(x, y)
	_GModText_SetText(text)
	_GModText_SetTime(dur, fadein, fadeout)
	if ent then _GModText_SetEntity(ent) end
	if offset then _GModText_SetEntityOffset(offset) end
	_GModText_Send(userid, chan)
end

function gmodrect(userid, mat, c, x, y, w, h, dur, name)
	local chan
	
	if tonumber(name) then
		chan = name
	else
		chan = addToName(userid, name, RECT)
	end
	
	if not chan then return end
		
	_GModRect_Start(mat or "gmod/white")
	_GModRect_SetColor(c[1], c[2], c[3], c[4])
	_GModRect_SetPos(x, y, w, h)
	_GModRect_SetTime(dur, 0, 0)
	_GModRect_Send(userid, chan)
end


votemapvotes = votemapvotes or {}
-- votemapvotes = {
    -- ["STEAM_ID_PENDING"] = "gm_construct",
-- }


maplist = {
    "nt_dm_nuke",
    "nt_dm_runoff_v2",
    "nt_dm_office_v2",
}


hidemaps = {
	"gm_hideandseek_outland",
	"gm_hideandseek_yard",
}

votemap_changemap_timeleft = 10
votemap_showCancelMsg = true


local function votemap_curplayers()
	local x = 0
	
	for i=1,_MaxPlayers() do
		if _PlayerInfo(i, "connected") then
			x = x + 1
		end
	end
	
	return x
end


local function votemap_isOnline(steamid)
	local x = 0
	
	for i=1,_MaxPlayers() do
		if _PlayerInfo(i, "connected") and _PlayerInfo(i, "networkid") == steamid then
			return true
		end
	end
	
	return false
end


local function votemap_changemap_timed()
    local tally = {}
	local totalvotes = 0
	
    --figure out which map has the most amount of votes
    for steamid, map in pairs(votemapvotes) do
        if votemap_isOnline(steamid) then
            totalvotes = totalvotes + 1
        
            if not tally[map] then
                tally[map] = 1
            else
                tally[map] = tally[map] + 1
            end
        end
    end
    
    local amt = 0
    local new_map = ""
        
    for map,votes in pairs(tally) do
        if votes == amt then
            new_map = ""
            amt = votes
        elseif votes > amt then
            new_map = map
            amt = votes
        end
    end
    
    if (new_map ~= "" and amt >= votemap_curplayers()) then
        votemap_changemap_timeleft = votemap_changemap_timeleft - 1
        
        print("","votemap",new_map,"time",votemap_changemap_timeleft)
        
        gmodtext(0, "ImpactMassive", {0,255,64,255}, -1, 0, "Votemap:\nMap '"..new_map.."' won!\nChanging in: "..votemap_changemap_timeleft, 0.5, 0.5, 5, 10527)
        
        votemap_showCancelMsg = true
        
        if votemap_changemap_timeleft <= 0 then
            _ServerCommand("changelevel "..new_map.."\n")
        end
    elseif votemap_showCancelMsg == true then
        gmodtext(0, "ImpactMassive", {255,0,0,255}, -1, 0, "Votemap canceled! (Not enough votes)", 0.5, 0.5, 5, 10527)
    
        votemap_showCancelMsg = false
        votemap_changemap_timeleft = 10
    end
end
RegisterTimer("votemap_changemap_timed", 1, 0, votemap_changemap_timed)


local function cc_votemap(userid, args)
    
    if not table.hasvalue(maplist, args) then
        return
    end
    
    local steamid = _PlayerInfo(userid, "networkid")
    
	if args == "#saltcube" then
		votemapvotes[steamid] = nil
		gmodtext(userid, "ImpactMassive", {255,0,0,255}, -1, 0, "Your vote was removed", 0.5, 0.5, 5, 10527)
		return
	end

	-- if CmdSpamCheck(userid, "votemap", 5) then return end
    
    votemapvotes[steamid] = args
    
    gmodtext(userid, "ImpactMassive", {255,0,0,255}, -1, 0, "You voted for "..args, 0.5, 0.5, 5, 10527)
    
	RegisterTimerOnce(0.3, _player.ShowPanel, userid, "spawnmenu", false)
	-- RegisterTimerOnce(timeout, _player.ShowPanel, userid, "spawnmenu", true)
end
-- AddCommand("votemap", nil, cc_votemap, "(map) - Hold down Q and go to votemap in order to vote a map")
-- AddCommand("votemap", {"votemap"}, cc_votemap, "(map) - Hold down Q and go to votemap in order to vote a map")
CONCOMMAND("votemap", cc_votemap)


-- # = ragdoll
-- : = car
-- ! = effect
-- ' = sprite
-- ~/@ = label
-- = = run console command
local function votemap_qmenu(userid)
    
	_spawnmenu.RemoveCategory(userid, "[Votemap]")
    
	_spawnmenu.AddItem( userid, "[Votemap]", "+Update list", "votemap_qmenu;qmenu_setcat [Votemap]")
	_spawnmenu.AddItem( userid, "[Votemap]", "+Remove vote", "votemap #saltcube;votemap_qmenu;qmenu_setcat [Votemap]")
	_spawnmenu.AddItem( userid, "[Votemap]", "@ ")
    _spawnmenu.AddItem( userid, "[Votemap]", "@- Everyone has to vote for the")
    _spawnmenu.AddItem( userid, "[Votemap]", "@same map in order for the server")
    _spawnmenu.AddItem( userid, "[Votemap]", "@to change map")
    _spawnmenu.AddItem( userid, "[Votemap]", "@  ")
	_spawnmenu.AddItem( userid, "[Votemap]", "@Vote for a map:")
    if votemapvotes[_PlayerInfo(userid,"networkid")] then
        _spawnmenu.AddItem( userid, "[Votemap]", "@You voted for: "..votemapvotes[_PlayerInfo(userid,"networkid")])
--		gmodtext(0, "ImpactMassive", {0,255,64,255}, -1, 0, "You voted for:"..votemapvotes[_PlayerInfo(userid,"networkid")], 0.5, 0.5, 5, 10527)
    end
    
    for k,v in pairs(maplist) do
    
        local cleanName = string.gsub(v, "gm_", "")
        cleanName = string.gsub(cleanName, "nt_dm_", "")
        
        if string.sub(v, 1, 1) == "~" then
            RegisterTimerOnce(k*0.03, _spawnmenu.AddItem, userid, "[Votemap]", cleanName, "")
        else
            RegisterTimerOnce(k*0.03, _spawnmenu.AddItem, userid, "[Votemap]", "+"..cleanName, "votemap "..v..  ";votemap_qmenu;qmenu_setcat [Votemap]")
        end
	end
end
CONCOMMAND("votemap_qmenu", votemap_qmenu)


local function votemap_auth(userid)
	RegisterTimerOnce(10, votemap_qmenu, userid)
end
RegisterEvent("eventPlayerInitialSpawn", "votemap_auth", votemap_auth)


for i=1,_MaxPlayers() do
    if _PlayerInfo(i, "connected") then
        votemap_qmenu(i)
    end
end
--changelevel gm_birdman

function table.hasvalue(t, val)
    for _,v in pairs(t) do
        if val == v then
            return true
        end
    end
    return false
end
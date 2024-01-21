gLuaThinkFunctions = gLuaThinkFunctions or {}
Timer = Timer or {}
g_EvenHooks = g_EvenHooks or {}
DoTimers = nil
XLU_PLUGINS = {}
XLU_PLUGIN = nil
showHookErrors=true
showEvents=false
writeErrors=false
old_showHookErrors=showHookErrors

local dumperrors=0


function XLU_CHECKPLUGIN(XLU_PLUGIN)
	XLU_PLUGINS[XLU_PLUGIN] = XLU_PLUGINS[XLU_PLUGIN] or {}
	XLU_PLUGINS[XLU_PLUGIN].Commands = XLU_PLUGINS[XLU_PLUGIN].Commands or {}
	XLU_PLUGINS[XLU_PLUGIN].Hooks = XLU_PLUGINS[XLU_PLUGIN].Hooks or {}
	XLU_PLUGINS[XLU_PLUGIN].Timers = XLU_PLUGINS[XLU_PLUGIN].Timers or {}
	XLU_PLUGINS[XLU_PLUGIN].Thinks = XLU_PLUGINS[XLU_PLUGIN].Thinks or {}
end
		
function MSG(s)
	if writeErrors or (dumperrors ~= 0 and dumperrors > _CurTime()) then
		-- _file.Write("lua/xlu/_hook_unbreaker.txt", _file.Read("lua/xlu/_hook_unbreaker.txt").."\r\nL "..tostring(logtime())..": "..s)
		--_PrintMessageAll(HUD_PRINTCONSOLE, s)
	elseif dumperrors ~= 0 then
		dumperrors=0
		showHookErrors=old_showHookErrors
	end
	if showHookErrors then
		_Msg(s.."\n")
	end
end

local function cc_dumperrors(userid, args)
	args=tonumber(args)
	if not args or args < 1 or args > 60 then args=60 end
	dumperrors=_CurTime() + args
	old_showHookErrors=showHookErrors
	showHookErrors=true
	_PrintMessage(userid, HUD_PRINTCONSOLE, "Dumping errors for the next "..args.." seconds")
	--_PrintMessage(userid, HUD_PRINTTALK, "Dumping errors for the next "..args.." seconds")
end
CONCOMMAND("lua_dumperrors", cc_dumperrors)

local timers_b
local timers_e

function LuaTimers()
	for k,v in Timer do
		if v then
			if v.time + v.delay < _CurTime() then
				v.time=_CurTime()
				if not Timer[k].func then
					MSG("Timer '"..tostring(k).."' tried to call a nil function!")
					Timer[k]=nil
					break
				else
					timers_b, timers_e=pcall(Timer[k].func, unpack(Timer[k].arg))
					if not timers_b then
						MSG("Timer '"..tostring(k).."' Failed: "..tostring(timers_e))
						Timer[k]=nil
						break
					end
				end
				if v.reps > 1 then
					v.reps=v.reps - 1
				elseif v.reps == 1 then
					Timer[k]=nil
				end
			end
		end
	end
end


local thinks_b
local thinks_e

function DoLuaThinkFunctions()
	for k,v in gLuaThinkFunctions do
		thinks_b, thinks_e=pcall(v)
		if not thinks_b then
			MSG("Think '"..tostring(k).."' Failed: "..tostring(thinks_e))
			gLuaThinkFunctions[k]=nil
			break
		end
	end
	LuaTimers()
end


local events_b
local events_e

function DoEventHook(name, ...)
	if showEvents then
		Msg("Lua Event: ["..arg.n.."]  "..name.."( ")
		for i=1, arg.n do
			Msg(tostring(arg[i]))
			if (i < arg.n) then Msg(", ") end
		end 
		Msg(" )\n")
	end
	for k,v in g_EvenHooks do
		-- if type(k) == "number" or tonumber(k) then
			-- MSG("Hook '"..tostring(name).."' was a number!")
			-- g_EvenHooks[k]=nil
			-- break
		-- end
		if g_EvenHooks[k] and g_EvenHooks[k].name and g_EvenHooks[k].name == name then
			if not g_EvenHooks[k].func then
				MSG("Hook '"..tostring(k).."' tried to call a nil function!")
				--g_EvenHooks[k]=nil
				break
			else
				events_b, events_e=pcall(g_EvenHooks[k].func, unpack(arg))
				if not events_b then
					MSG("Hook '"..tostring(k).."' Failed: "..tostring(events_e))
					--g_EvenHooks[k]=nil
					break
				end
			end
		end
	end
end


function RegisterEvent(name, uid, func)
	assert(type(name) == "string" and type(uid) == "string" and type(func) == "function", "RegisterEvent used incorrectly!")
	
	if XLU_PLUGIN then
		XLU_CHECKPLUGIN(XLU_PLUGIN)
		table.insert(XLU_PLUGINS[XLU_PLUGIN].Hooks, uid)
	end
	
	g_EvenHooks[uid]={
		["name"]=name,
		["func"]=func,
	}
end


function RemoveEvent(uid)
	g_EvenHooks[uid]=nil
end


function RegisterThinkFunction(uid, func)
	--assert(type(uid) == "string" and type(func) == "function", "RegisterThinkFunction used incorrectly!")
	if XLU_PLUGIN then
		XLU_CHECKPLUGIN(XLU_PLUGIN)
		table.insert(XLU_PLUGINS[XLU_PLUGIN].Thinks, uid)
	end
	
	gLuaThinkFunctions[uid]=func
end


function RemoveThinkFunction(uid)
	gLuaThinkFunctions[uid]=nil
end


function RegisterTimer(uid, delay, reps, func, ...)
	--assert(type(uid) == "string" and type(delay) == "number" and type(reps) == "number" and type(func) == "function" and type(arg) == "table", "RegisterTimer used incorrectly!")
	if XLU_PLUGIN then
		XLU_CHECKPLUGIN(XLU_PLUGIN)
		table.insert(XLU_PLUGINS[XLU_PLUGIN].Timers, uid)
	end
	
	Timer[uid]={
		["delay"]=delay,
		["time"]=_CurTime(),
		["func"]=func,
		["arg"]=arg,
		["reps"]=reps,
	}
end


function RegisterTimerOnce(delay, func, ...)
	assert(type(delay) == "number" and type(func) == "function" and type(arg) == "table", "RegisterTimerOnce used incorrectly!")
	
	local uid=1
	while Timer[uid] do
		uid=uid + 1
	end
	
	Timer[uid]={
		["delay"]=delay,
		["time"]=_CurTime(),
		["func"]=func,
		["arg"]=arg,
		["reps"]=1,
	}
end


function RemoveTimer(uid)
	Timer[uid]=nil
end


-- for k,v in pairs(gLuaThinkFunctions) do if type(k) == "number" then gLuaThinkFunctions[k]=nil end end
-- for k,v in pairs(Timer) do if type(k) == "number" then Timer[k]=nil end end
-- for k,v in pairs(g_EvenHooks) do if type(k) == "number" then g_EvenHooks[k]=nil end end

--[[
RandomMessages mod by arsdragonfly.
arsdragonfly@gmail.com
6/19/2013
--]]
--Time between two subsequent messages.
local MESSAGE_INTERVAL = 0

math.randomseed(os.time())

random_messages = {}
random_messages.messages = {} --This table contains all messages.

function table.count( t ) -- luacheck: ignore
	local i = 0
	for k in pairs( t ) do i = i + 1 end
	return i
end

function table.random( t ) -- luacheck: ignore
	local rk = math.random( 1, table.count( t ) )
	local i = 1
	for k, v in pairs( t ) do
		if ( i == rk ) then return v, k end
		i = i + 1
	end
end

function random_messages.initialize() --Set the interval in minetest.conf.
	minetest.setting_set("random_messages_interval",60)
	minetest.setting_save();
	return 60
end

function random_messages.set_interval() --Read the interval from minetest.conf and set it if it doesn't exist
	MESSAGE_INTERVAL = tonumber(minetest.setting_get("random_messages_interval")) or random_messages.initialize()
end

function random_messages.check_params(name,func,params)
	local stat,msg = func(params)
	if not stat then
		minetest.chat_send_player(name,msg)
		return false
	end
	return true
end

function random_messages.read_messages()
	random_messages.messages = {
		"To talk to only your team, start your messages with /t. For example, /t Hello team!",
		"If you're interested in Kingdom simulation and warfare, check out Persistent Kingdoms.",
		"Check out my other server, Persistent Kingdoms.",
		"Healers can heal other players quickly with their bandages.",
		"Hammers do more damage than Swords, but you need to be closer, and they are slower.",
		"Spears have a longer range than Swords, but they are slower.",
		"Gain more score by killing more than you die, or by capturing the flag.",
		"You gain more score the better the opponent you defeat.",
		"If you move while loading a crossbow, loading will cancel.",
		"You cannot move while loading a crossbow.",
		"Flag carriers go 80% normal speed (regardless of armor) They also cannot use horses or grapple hooks.",
		"Flag carriers cannot use grapple hooks or horses, and they move slower.",
		"To change class or resupply, rightclick (or double tap for mobile users) the flag or use /class.",
		"Players are immune to attack for 15 seconds after they respawn.",
		"Builders can use team doors (steel) to stop the enemy walking into your base.",
		"Better armor makes you slower.",
		"You can ignite TNT by shooting it with a torch arrow.",
		"Like the server? Give feedback using /report. Thanks to rubenwardy for the base game.",
		"Map makers needed! Visit ctf.rubenwardy.com to get involved.",
		"Builders kit with a lot of building supplies.",
		"To report misbehaving players to moderators, please use /report NAME MESSAGE",
		"Swearing, trolling and being rude will not be tolerated and strict action will be taken.",
		"Trapping team mates on purpose is strictly against the rules and you will be kicked / banned.",
		"Help your team claim victory by staying together and/or working as a team.",
		"Note: Apples don't heal you anymore, only time or bandages do.",
		"Excessive spawn-killing is a direct violation of the rules - appropriate punishments will be given."
	}
end

function random_messages.display_message(message_number)
	local msg = random_messages.messages[message_number] or message_number
	if msg then
		minetest.chat_send_all(msg)
	end
end

function random_messages.show_message()
	random_messages.display_message(table.random(random_messages.messages))
end

function random_messages.list_messages()
	local str = ""
	for k,v in pairs(random_messages.messages) do
		str = str .. k .. " | " .. v .. "\n"
	end
	return str
end

function random_messages.remove_message(k)
	table.remove(random_messages.messages,k)
	random_messages.save_messages()
end

function random_messages.add_message(t)
	table.insert(random_messages.messages,table.concat(t," ",2))
	random_messages.save_messages()
end

function random_messages.save_messages()
	local output = io.open(minetest.get_worldpath().."/random_messages","w")
	for k,v in pairs(random_messages.messages) do
		output:write(v .. "\n")
	end
	io.close(output)
end

--When server starts:
random_messages.set_interval()
random_messages.read_messages()

local function step(dtime)
	random_messages.show_message()
	minetest.after(MESSAGE_INTERVAL, step)
end
minetest.after(MESSAGE_INTERVAL, step)

local register_chatcommand_table = {
	params = "viewmessages | removemessage <number> | addmessage <number>",
	privs = {server = true},
	description = "View and/or alter the server's random messages",
	func = function(name,param)
		local t = string.split(param, " ")
		if t[1] == "viewmessages" then
			minetest.chat_send_player(name,random_messages.list_messages())
		elseif t[1] == "removemessage" then
			if not random_messages.check_params(
			name,
			function (params)
				if not tonumber(params[2]) or
				random_messages.messages[tonumber(params[2])] == nil then
					return false,"ERROR: No such message."
				end
				return true
			end,
			t) then return end
			random_messages.remove_message(t[2])
		elseif t[1] == "addmessage" then
			if not t[2] then
				minetest.chat_send_player(name,"ERROR: No message.")
			else
				random_messages.add_message(t)
			end
		else
				minetest.chat_send_player(name,"ERROR: Invalid command.")
		end
	end
}

minetest.register_chatcommand("random_messages", register_chatcommand_table)
minetest.register_chatcommand("rmessages", register_chatcommand_table)

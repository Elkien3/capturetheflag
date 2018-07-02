local class = {}
local available_classes = {}
local usedistance = 4
local cansupply = {}
local supply_time = 120
local default_class = "Sword"
available_classes["Sword"] = {"default:sword_steel", "default:pick_steel", "default:ladder 6", "default:torch 4", "3d_armor:helmet_steel", "3d_armor:chestplate_steel", "xtraarmor:boots_leather_black", "shields:shield_steel"}
available_classes["Knight"] = {"default:sword_steel", "default:pick_steel", "default:ladder 6", "default:torch 4", "xtraarmor:helmet_leather_black", "xtraarmor:chestplate_studded", "xtraarmor:boots_leather_black", "shields:shield_steel", "whinny:horseh1"}
available_classes["Spear"] = {"lottweapons:steel_spear", "default:pick_steel", "default:ladder 6", "default:torch 4", "3d_armor:helmet_steel", "3d_armor:chestplate_steel", "xtraarmor:boots_leather_black", "shields:shield_steel"}
available_classes["Hammer"] = {"lottweapons:steel_warhammer", "default:pick_steel", "default:ladder 6", "default:torch 4", "3d_armor:helmet_steel", "3d_armor:chestplate_steel", "xtraarmor:boots_leather_black", "shields:shield_steel"}
available_classes["Bow"] = {"throwing:bow_composite", "throwing:arrow_stone 32", "throwing:arrow_torch 8", "shooter:grapple_hook", "default:pick_steel", "default:torch 4", "xtraarmor:helmet_leather_black", "xtraarmor:chestplate_leather_black", "xtraarmor:leggings_leather_black", "xtraarmor:boots_leather_black"}
available_classes["Crossbow"] = {"throwing:crossbow", "throwing:arrow_steel 32", "throwing:arrow_torch 8", "shooter:grapple_hook", "default:pick_steel", "default:torch 4", "xtraarmor:helmet_leather_brown", "xtraarmor:chestplate_studded", "xtraarmor:leggings_studded", "xtraarmor:boots_leather_brown"}
available_classes["Builder"] = {"default:pick_diamond", "default:stonebrick 99", "default:wood 99", "default:torch 4", "doors:door_steel", "default:ladder 16"}
available_classes["Healer"] = {"default:pick_steel", "bandages:bandage_2 50", "bandages:bandage_3 10", "default:torch 4", "default:ladder 4", "3d_armor:chestplate_bronze", "xtraarmor:boots_leather_black", "shields:shield_enhanced_wood"}
available_classes["Bomber"] = {"default:pick_steel", "tnt:tnt 2", "mesecons_pressureplates:pressure_plate_grass_off 2", "default:torch 4", "default:ladder 4", "shields:shield_wood"}

local world_path = minetest.get_worldpath()
local file = world_path .. "/classes.txt"

function classes_read()
	local input = io.open(file, "r")
	if input then
		repeat
		local name, classname = string.match(input:read("*l"), "(%D+) (%D+)")
		if name and classname then
			if available_classes[classname] then
				class[name] = classname
			else
				class[name] = default_class
			end
		end
		until input:read(0) == nil
		io.close(input)
	end
end

classes_read()

function classes_save()
	if not class then
		return
	end
	local data = {}
	local output = io.open(file, "w")
	for name, classname in pairs(class) do
		table.insert(data, string.format("%s %s\n", name, classname))
	end
	output:write(table.concat(data))
	io.close(output)
end

function classes_loadout(player, class)
	local playerclass = class or class[player:get_player_name()] or default_class
	if not player then
		return
	end
	--local armor_inv = minetest.get_inventory({type="detached", name=player:get_player_name().."_armor"})
	local name, armor_inv = armor:get_valid_player(player, "[on_supply]")
	clearinventory(player)
	local player_inv = player:get_inventory()
	for index, item in pairs(available_classes[playerclass]) do
		if string.match(item, "3d_armor:+.") or string.match(item, "shields:+.") or string.match(item, "xtraarmor:+.") then
			--player_inv:add_item('armor', item)
			armor_inv:add_item("armor", item)
		else
			player_inv:add_item('main', item)
		end
	end
	armor.set_player_armor(armor, player)
end

function clearinventory(player)
	local player_inv = player:get_inventory()
	--local armor_inv = minetest.get_inventory({type="detached", name=player:get_player_name().."_armor"})
	player_inv:set_list("main", {})
	player_inv:set_list("craft", {})
	local name, armor_inv = armor:get_valid_player(player, "[on_supply]")
	if not name then
		return
	end
	local drop = {}
	for i=1, armor_inv:get_size("armor") do
		local stack = armor_inv:get_stack("armor", i)
		if stack:get_count() > 0 then
			table.insert(drop, stack)
			armor_inv:set_stack("armor", i, nil)
			--player_inv:set_stack("armor", i, nil)
		end
	end
	armor.set_player_armor(armor, player)
end

minetest.register_on_respawnplayer(function(player)
	classes_loadout(player, class[player:get_player_name()])
	--player:setpos({x=0,y=0,z=0})
end)
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if cansupply[name] == nil or cansupply[name] then
		minetest.after(2, classes_loadout, player, class[name])
		--player:setpos({x=0,y=0,z=0})
	end
end)
minetest.register_on_dieplayer(function(player)
	clearinventory(player)
end)

local function supplytimer(name)
	cansupply[name] = true
	if minetest.get_player_by_name(name) then
		minetest.chat_send_player(name, "You may now resupply or change class again.")
	end
end

local function class_formspec(player)
	local size = { "size[10,4]" }
	local h = 0
	local v = 0
	for d, f in pairs(available_classes) do
		if h > 8 then
			h = 0
			v = v + 1
		end
		table.insert(size, "button["..h..","..v..";1.75,0.5;"..d..";"..d.."]")
		h = h + 2
	end
	return table.concat(size)
end

ctf_flag.on_rightclick = function(pos, node, clicker)
	local name = clicker:get_player_name()
	local flag = ctf_flag.get(pos)
	if not flag then
		return
	end
	minetest.show_formspec(name, "classes", class_formspec(name))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "classes" then return end
	local name = player:get_player_name()
	for data in pairs(available_classes) do
		if fields[data] then
			if data == class[name] then
				if cansupply[name] == nil or cansupply[name] then
					classes_loadout(minetest.get_player_by_name(name), data)
					cansupply[name] = false
					minetest.after(supply_time, supplytimer, name)
					minetest.chat_send_player(name, "Resupplied. You may Resupply again in "..tostring(supply_time/60).." minutes.")
					return
				else
					minetest.chat_send_player(name, "You cannot Resupply so soon.")
					return
				end
			else
				if cansupply[name] == nil or cansupply[name] then
					class[name] = data
					classes_save()
					classes_loadout(minetest.get_player_by_name(name), data)
					cansupply[name] = false
					minetest.after(supply_time, supplytimer, name)
					minetest.chat_send_player(name, "Class set to "..data.."! You may change class again in "..tostring(supply_time/60).." minutes.")
					return
				else
					minetest.chat_send_player(name, "You cannot change class again so soon.")
					return
				end
			end
		end
	end
end)

minetest.register_chatcommand("class", {
	params = "class",
	description = "Use near a flag to change class.",
	func = function(name, param)
	
		if param == "" then
			if class[name] then
				minetest.chat_send_player(name, "Your class is " .. class[name])
			else
				minetest.chat_send_player(name, "Your class is not set")
			end
			return
		end
		
		if param == "list" then
			local str = "Available classes:"
			for c in pairs(available_classes) do
				str = str.." "..c
			end
			minetest.chat_send_player(name, str)
			minetest.chat_send_player(name, "Use /class [classname] near a flag to pick one.")
			return
		end
		
		if not available_classes[param] then minetest.chat_send_player(name, "'"..param .. "' is not a valid class, use '/class list' to see all classes.") return end
		
		local userpos = minetest.get_player_by_name(name):get_pos()
		local flag = ctf_flag.get_nearest(userpos)
		if not flag then minetest.chat_send_player(name, "Must be ".. usedistance .. " blocks or closer from flag to change class or resupply!") return end
		
		local flagpos = {x = flag.x, y = flag.y, z = flag.z}
		local flagdistance = vector.distance(userpos, flagpos)
		if flagdistance > usedistance then minetest.chat_send_player(name, "Must be ".. usedistance .. " blocks or closer from flag to change class or resupply!") return end
		
		if param == class[name] then
			if cansupply[name] == nil or cansupply[name] then
				classes_loadout(minetest.get_player_by_name(name), param)
				cansupply[name] = false
				minetest.after(supply_time, supplytimer, name)
				minetest.chat_send_player(name, "Resupplied. You may Resupply again in "..tostring(supply_time/60).." minutes.")
				return
			else
				minetest.chat_send_player(name, "You cannot Resupply so soon.")
				return
			end
		else
			if cansupply[name] == nil or cansupply[name] then
				class[name] = param
				classes_save()
				classes_loadout(minetest.get_player_by_name(name), param)
				cansupply[name] = false
				minetest.after(supply_time, supplytimer, name)
				minetest.chat_send_player(name, "Class set to "..param.."! You may change class again in "..tostring(supply_time/60).." minutes.")
				return
			else
				minetest.chat_send_player(name, "You cannot change class again so soon.")
				return
			end
		end
	end
})
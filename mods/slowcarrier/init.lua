slowed_carrier = {}
ctf_flag.register_on_pick_up(function(attname, flag)
	if not attname then return end
	local player = minetest.get_player_by_name(attname)
	slowed_carrier[attname]=true
	if player:get_attach() then
	local obj = player:get_attach()
	minetest.chat_send_all(dump(obj))
	local playerpos = player:get_pos()
		if obj:get_properties().mesh == "horse.x" then
			player:set_detach()
			player:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
			obj:remove()
		end
	end
end)

ctf_flag.register_on_drop(function(attname, flag)
	slowed_carrier[attname]=nil
	local player = minetest.get_player_by_name(attname)
	if not player then return end
	player:set_physics_override({speed = 1})
end)

ctf_flag.register_on_capture(function(attname, flag)
	slowed_carrier[attname]=nil
	local player = minetest.get_player_by_name(attname)
	if not player then return end
	player:set_physics_override({speed = 1})
end)


minetest.register_globalstep(function(dtime)
	for name in pairs(slowed_carrier) do
		local player = minetest.get_player_by_name(name)
		if not player then return end
		player:set_physics_override({speed = .80})
	end
end)
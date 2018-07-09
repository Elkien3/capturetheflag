local exceptions = {"throwing:bow_wood_loaded", "throwing:longbow_loaded", "throwing:bow_composite_loaded", "throwing:crossbow_loaded"}
local function disable_drop()
	for itemstring, def in pairs(minetest.registered_items) do
		local doit = true
		for id, item in pairs(exceptions) do
			if itemstring == item then
				doit = false
			end 
		end
		if doit then
			minetest.override_item(itemstring, {
				on_drop = function(itemstack, dropper, pos)
					return nil
				end
			})
		end
	end
end

-- This is a minor hack to make sure our loop runs after all nodes have been registered
minetest.after(0, disable_drop)
--torches = {}


function check_attached_node_fdir(p, n)
	local def = minetest.registered_nodes[n.name]
	local d = {x=0, y=0, z=0}
	if def.paramtype2 == "facedir" then
		if n.param2 == 0 then
			d.z = 1
		elseif n.param2 == 1 then
			d.x = 1
		elseif n.param2 == 2 then
			d.z = -1
		elseif n.param2 == 3 then
			d.x = -1
		end
	end
	local p2 = {x=p.x+d.x, y=p.y+d.y, z=p.z+d.z}
	local nn = minetest.env:get_node(p2).name
	local def2 = minetest.registered_nodes[nn]
	if def2 and not def2.walkable then
		return false
	end
	return true
end

minetest.register_abm({
	nodenames = {"default:torch"},
	interval = 1,
	chance = 1,
	action = function(pos)
		default.add_fire(pos)
		if not check_attached_node_fdir(pos, minetest.env:get_node(pos)) then
			minetest.env:dig_node(pos)
		end
	end
})

minetest.register_abm({
	nodenames = {"default:torch_on_floor"},
	interval = 1,
	chance = 1,
	action = function(pos)
		default.add_fire(pos)
	pos.y = pos.y-1
	local nn = minetest.env:get_node(pos).name
	local def2 = minetest.registered_nodes[nn]
	if def2 and not def2.walkable then
		pos.y = pos.y+1
		minetest.env:dig_node(pos)
	end
	end
})

--help function
local function is_wall(wallparam)
	if wallparam == 0 then return false end
	local para2 = 0
	if wallparam == 2 then
		para2 = 1
	elseif wallparam == 3 then
		para2 = 3
	elseif wallparam == 4 then
		para2 = 0
	elseif wallparam == 5 then
		para2 = 2
	end
	return para2
end

--node_boxes
minetest.register_craftitem(":default:torch", {
	description = "Torch",
	inventory_image = "default_torch_inv.png",
	wield_image = "default_torch.png",
	wield_scale = {x=1,y=1,z=1+1/16},
	liquids_pointable = false,
   	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" or string.find(minetest.env:get_node(pointed_thing.above).name, "torch") then
			return itemstack
		end
		local above = pointed_thing.above
		local under = pointed_thing.under
		local wdir = minetest.dir_to_wallmounted({x = under.x - above.x, y = under.y - above.y, z = under.z - above.z})
		local u_n = minetest.get_node(under)
		if u_n and not minetest.registered_nodes[u_n.name].walkable then above = under end
		local u_n = minetest.get_node(above)
		if u_n and minetest.registered_nodes[u_n.name].walkable then return itemstack end
		if wdir == 1 then
			minetest.env:add_node(above, {name = "default:torch_on_floor"})		
		else
			minetest.env:add_node(above, {name = "default:torch", param2 = is_wall(wdir)})
		end
		if not wdir == 0 or not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
		end
		return itemstack

	end

})

minetest.register_node("default:torch_on_floor", {
	--description = "Fakel",
	inventory_image = "default_torch_inv.png",
	wield_image = "default_torch.png",
	wield_scale = {x=1,y=1,z=1+2/16},
	drawtype = "nodebox",
	tiles = {"default_torch.png^[transformfy", "default_wood.png", "default_torch.png",
		"default_torch.png^[transformfx", "default_torch.png", "default_torch.png"},
	paramtype = "light",
	paramtype2 = "none",
	sunlight_propagates = true,
	drop = "default:torch",
	walkable = false,
	light_source = 13,
	groups = {choppy=2,dig_immediate=3,flammable=1,not_in_creative_inventory=1},
	legacy_wallmounted = true,
	node_box = {
		type = "fixed",
		fixed = {-1/16, -0.5, -1/16, 1/16, 2/16, 1/16},
	},
	selection_box = {
		type = "fixed",
		fixed = {-1/16, -0.5, -1/16, 1/16, 2/16, 1/16},
	},
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		if not digger:is_player() then minetest.add_item(pos, {name="default:torch"}) end
	end,
})

local wall_ndbx = {
			{-1/16,-6/16, 6/16, 1/16, -5/16, 0.5},
			{-1/16,-5/16, 5/16, 1/16, -4/16, 7/16},
			{-1/16,-4/16, 4/16, 1/16, -3/16, 6/16},
			{-1/16,-3/16, 3/16, 1/16, -2/16, 5/16},
			{-1/16,-2/16, 2/16, 1/16, -1/16, 4/16},
			{-1/16,-1/16, 1/16, 1/16, 0, 3/16},
			{-1/16,0, 1/16, 1/16, 1/16, 2/16},
			{-1/16, 0, -1/16, 1/16, 2/16, 1/16},
}

minetest.register_node("default:torch", {
	--description = "Fakel",
	inventory_image = "default_torch_inv.png",
	wield_image = "default_torch.png",
	wield_scale = {x=1,y=1,z=1+1/16},
	drawtype = "nodebox",
	tiles = {"default_torch.png^[transformfy", "default_wood.png", "default_torch_side.png",
		"default_torch_side.png^[transformfx", "default_wood.png", "default_torch.png"},

	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	light_source = 13,
	groups = {choppy=2,dig_immediate=3,flammable=1,not_in_creative_inventory=1},
	legacy_wallmounted = true,
	drop = "default:torch",
	node_box = {
		type = "fixed",
		fixed =	wall_ndbx
	},
	selection_box = {
		type = "fixed",
		fixed =	{-1/16, -6/16, 7/16, 1/16, 2/16, 2/16},
	},
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		if not digger:is_player() then minetest.add_item(pos, {name="default:torch"}) end
	end,

})

minetest.register_alias("default:wand",  "default:torch")
minetest.register_alias("default:floor",  "default:torch_on_floor")
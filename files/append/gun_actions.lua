-- luacheck: globals actions ACTION_TYPE_OTHER
table.insert(actions, 
{
	id					= "BAD_APPLE",
	name				= "$action_badapple",
	description			= "$actiondesc_badapple",
	sprite				= "mods/badapple/files/apple.png",
	sprite_unidentified = "mods/badapple/files/apple.png",
	type				= ACTION_TYPE_OTHER,
	spawn_level         = "",
	spawn_probability   = "",
	price				= 10,
	mana				= 0,
	--max_uses			  = 1,
	action = function()
		-- luacheck: globals c reflecting
		c.fire_rate_wait = c.fire_rate_wait + 600
		current_reload_time = current_reload_time + 600
		if reflecting then return end
		local frame = GameGetFrameNum()
		GlobalsSetValue("badapple_run", tostring(1))
		GlobalsSetValue("badapple_trigger_frame", tostring(frame))
	end,
})

-- vim: set ts=4 sts=4 sw=4 noet nolist:

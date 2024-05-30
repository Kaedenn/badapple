table.insert(actions, 
	{
		id          = "BAD_APPLE",
		name 		= "$action_badapple",
		description = "$actiondesc_badapple",
		sprite 		= "mods/badapple/files/apple.png",
		sprite_unidentified = "mods/badapple/files/apple.png",
		type 		= ACTION_TYPE_OTHER,
		spawn_level                       = "5,6,10",
		spawn_probability                 = "0.1,0.2,1",
		price = 10,
		mana = 0,
		--max_uses = 25,
		--custom_xml_file = "data/entities/misc/custom_cards/rainbow_trail.xml",
		action = function()
			c.fire_rate_wait = c.fire_rate_wait + 600
			current_reload_time = current_reload_time + 600

			GamePrintImportant("The Gods are watching")

			if reflecting then return end

			local frame = GameGetFrameNum()
			local lifetime = 20 + c.lifetime_add

			local caster_entity = GetUpdatedEntityID()
			local wand_entity = find_the_wand_held( caster_entity )

			if wand_entity then
				local ability = EntityGetFirstComponentIncludingDisabled( wand_entity, "AbilityComponent" )
				if ability ~= nil then
					ComponentSetValue2( ability, "mNextFrameUsable", frame + lifetime + c.fire_rate_wait )
					ComponentSetValue2( ability, "mCastDelayStartFrame", frame + lifetime )
				end
			end

			local inventory = EntityGetFirstComponentIncludingDisabled( caster_entity, "InventoryGuiComponent" )
			if inventory ~= nil then
				ComponentSetValue2( inventory, "mDisplayFireRateWaitBar", true )
			end

			local platformshooter = EntityGetFirstComponentIncludingDisabled( caster_entity, "PlatformShooterPlayerComponent" )
			if platformshooter ~= nil then
				ComponentSetValue2( platformshooter, "mCessationDo", true )
				ComponentSetValue2( platformshooter, "mCessationLifetime", lifetime )
			end

			StartReload( current_reload_time )
		end,
	}
)

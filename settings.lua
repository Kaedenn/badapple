dofile_once("data/scripts/lib/utilities.lua")
dofile_once("data/scripts/lib/mod_settings.lua")

--function mod_setting_changed_callback(mod_id, gui, in_main_menu, setting, old_value, new_value)
--end

MOD_ID = "badapple"
mod_settings_version = 1
mod_settings = {
    {
        id = "delay",
        ui_name = "Extra Delay",
        ui_description = "Additional delay added between video frames (requires restart)",
        value_default = 0,
        scope = MOD_SETTING_SCOPE_RESTART,
    }
}

function ModSettingsUpdate(init_scope)
    local old_version = mod_settings_get_version(MOD_ID)
    mod_settings_update(MOD_ID, mod_settings, init_scope)
end

function ModSettingsGuiCount()
    return mod_settings_gui_count(MOD_ID, mod_settings)
end

function ModSettingsGui(gui, in_main_menu)
    mod_settings_gui(MOD_ID, mod_settings, gui, in_main_menu)
end

-- vim: set ts=4 sts=4 sw=4:

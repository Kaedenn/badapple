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
        scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
    },
    {
        category_id = "debug_settings",
        ui_name = "Debugging",
        foldable = true,
        settings = {
            {
                id = "debug",
                ui_name = "Debugging",
                ui_description = "Enable debugging and extra diagnostics",
                value_default = false,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "cutoff",
                ui_name = "Video Length Override",
                ui_description = "Override the length of the video in frames (0 for default) (requires restart)",
                value_default = 0,
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            }
        }
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

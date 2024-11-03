dofile_once("data/scripts/lib/utilities.lua")
dofile_once("data/scripts/lib/mod_settings.lua")
-- luacheck: globals MOD_SETTING_SCOPE_RUNTIME

--function mod_setting_changed_callback(mod_id, gui, in_main_menu, setting, old_value, new_value)
--end

MOD_ID = "badapple"
mod_settings_version = 2
mod_settings = {
    {
        category_id = "general_settings",
        ui_name = "General",
        foldable = true,
        settings = {
            {
                id = "delay",
                ui_name = "Extra Delay",
                ui_description = "Additional delay added between video frames",
                value_default = 0,
                value_min = 0,
                value_max = 10,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "white_pixels",
                ui_name = "White Pixel Material",
                ui_description = "Material to use for the white pixels (default: air)",
                value_default = "air",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "black_pixels",
                ui_name = "Black Pixel Material",
                ui_description = "Material to use for the black pixels (default: templebrick_static)",
                value_default = "templebrick_static",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "use_custom_materials",
                ui_name = "Use custom materials?",
                ui_description = "Should this mod use the two materials defined above or should it use the default materials?",
                value_default = false,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
        },
    },
    {
        category_id = "debug_settings",
        ui_name = "Diagnostics",
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
                value_min = 0,
                value_max = 1000,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
        }
    }
}

function ModSettingsUpdate(init_scope)
    -- luacheck: globals mod_settings_get_version mod_settings_update
    local old_version = mod_settings_get_version(MOD_ID)
    mod_settings_update(MOD_ID, mod_settings, init_scope)
end

function ModSettingsGuiCount()
    -- luacheck: globals mod_settings_gui_count
    return mod_settings_gui_count(MOD_ID, mod_settings)
end

function ModSettingsGui(gui, in_main_menu)
    -- luacheck: globals mod_settings_gui
    mod_settings_gui(MOD_ID, mod_settings, gui, in_main_menu)
end

-- vim: set ts=4 sts=4 sw=4:

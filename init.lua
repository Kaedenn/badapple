--[[
-- Bad Apple!! but it's Noita
--]]

function do_render_frame(x, y, framenr)
    local fimg = ("mods/badapple/files/downsample/badapple_%04d.png"):format(framenr)
    LoadPixelScene(fimg, "", x, y, "", true, true, {
        ["ffffffff"] = "magic_liquid_hp_regeneration_unstable",
        ["ff000000"] = "midas_precursor",
    })
end

function OnModPostInit()
    ModLuaFileAppend("data/scripts/gun/gun_actions.lua", "mods/badapple/files/append/gun_actions.lua")
    local translations = ModTextFileGetContent("data/translations/common.csv")
    local new_translations = ModTextFileGetContent("mods/badapple/append/translations.csv")
    translations = translations .. "\n" .. new_translations .. "\n"
    translations = translations:gsub("\r", ""):gsub("\n\n+", "\n")
    ModTextFileSetContent("data/translations/common.csv", translations)
end

function OnWorldPostUpdate()
    local player = get_players()[1]

    if GlobalsGetValue("badapple_test", "") == "1" then
        GlobalsSetValue("badapple_test", "")
        GamePrint("action_badapple: " .. GameTextGet("$action_badapple"))
        GamePrint("actiondesc_badapple: " .. GameTextGet("$actiondesc_badapple"))
    end

    local frame = GlobalsGetValue("badapple_draw_frame", "")
    if frame:match("^[0-9]+$") then
        GlobalsSetValue("badapple_draw_frame", "")
        local framenr = tonumber(frame)
        local px, py = EntityGetTransform(player)
        do_render_frame(px, py, framenr)
    end
end

-- vim: set ts=4 sts=4 sw=4 et:

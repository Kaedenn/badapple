--[[
-- Bad Apple!! but it's Noita
--]]

dofile_once("mods/badapple/files/timeline.lua")
-- luacheck: globals STAGES get_stage get_stage_named is_running get_trigger_frame

function OnModPostInit()
    ModLuaFileAppend("data/scripts/gun/gun_actions.lua", "mods/badapple/files/append/gun_actions.lua")
    local translations = ModTextFileGetContent("data/translations/common.csv")
    local new_translations = ModTextFileGetContent("mods/badapple/append/translations.csv")
    translations = translations .. "\n" .. new_translations .. "\n"
    translations = translations:gsub("\r", ""):gsub("\n\n+", "\n")
    ModTextFileSetContent("data/translations/common.csv", translations)
end

function OnPlayerSpawned()
    for _, stage in ipairs(STAGES) do
        stage.run_count = 0
    end

    local play_stage = get_stage_named("play")
    play_stage.delay = play_stage.delay + ModSettingGetNextValue("badapple.delay")
    local vid_length = ModSettingGetNextValue("badapple.cutoff")
    if vid_length > 0 then
        play_stage.count = vid_length
    end

    -- TODO: Spawn the new Bad Apple!! spell near the player
end

gui = nil
function _runner()
    if not is_running() then return end
    local trigger = get_trigger_frame()
    if trigger == -1 then
        print_error("is_running=true but trigger is -1")
        GlobalsSetValue("badapple_run", tostring(0))
        return
    end

    local curr = GameGetFrameNum()
    local offset = curr - trigger
    local stage = get_stage(offset)
    if stage.run_count < stage.count then
        stage.action(stage, curr)
        stage.run_count = stage.run_count + 1
    end

    local debugging = ModSettingGetNextValue("badapple.debug")
    if debugging then
        if not gui then gui = GuiCreate() end
        GuiStartFrame(gui)
        local sw, sh = GuiGetScreenDimensions(gui)
        local cw, ch = GuiGetTextDimensions(gui, "M")
        local linenr = 0
        local function draw_line(line)
            linenr = linenr + 1
            local liney = sh - ch * linenr - 2
            GuiText(gui, 2, liney, line)
        end
        draw_line(("Stage %s %d/%d:"):format(stage.name, stage.run_count, stage.count))
        draw_line(("Frame %d / %d (%2d%%)"):format(offset, stage.count * stage.delay,
            offset / (stage.count * stage.delay)))
    end

end

function OnWorldPostUpdate()
    _runner()
end

-- vim: set ts=4 sts=4 sw=4 et:

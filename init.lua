--[[
-- Bad Apple!! but it's Noita
--]]

dofile_once("mods/badapple/files/timeline.lua")
-- luacheck: globals STAGES get_stage get_stage_named is_running get_trigger_frame init_timeline

function spawn_spell()
    local player = get_players()[1]
    if not player then return end
    local px, py = EntityGetTransform(player)
    if not px or not py then return end
    CreateItemActionEntity("BAD_APPLE", px, py)
end

function OnModPostInit()
    ModLuaFileAppend("data/scripts/gun/gun_actions.lua", "mods/badapple/files/append/gun_actions.lua")
    local translations = ModTextFileGetContent("data/translations/common.csv")
    local new_translations = ModTextFileGetContent("mods/badapple/files/append/translations.csv")
    translations = translations .. "\n" .. new_translations .. "\n"
    translations = translations:gsub("\r", ""):gsub("\n\n+", "\n")
    ModTextFileSetContent("data/translations/common.csv", translations)
end

function OnPlayerSpawned()
    for _, stage in ipairs(STAGES) do
        stage.run_count = 0
        stage.frame_delay = 0
    end

    init_timeline()

    local play_stage = get_stage_named("play")
    play_stage.delay = play_stage.delay + ModSettingGetNextValue("badapple.delay")
    local vid_length = ModSettingGetNextValue("badapple.cutoff")
    if vid_length > 0 then
        play_stage.count = vid_length
    end

    --spawn_spell()
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
    if not stage then
        print_error(("No stage for offset %d"):format(offset))
        GlobalsSetValue("badapple_run", tostring(0))
        return
    end

    if not gui then gui = GuiCreate() end
    GuiStartFrame(gui)
    local sw, sh = GuiGetScreenDimensions(gui)
    local cw, ch = GuiGetTextDimensions(gui, "M")
    local linenr = 0
    local function draw_line(line)
        local debugging = ModSettingGetNextValue("badapple.debug")
        if debugging then
            linenr = linenr + 1
            local liney = sh - ch * linenr - 2
            GuiText(gui, 2, liney, line)
        end
    end
    draw_line(("Stage %s %d/%d:"):format(stage.name, stage.run_count, stage.count))
    draw_line(("Frame %d / %d (%2d%%)"):format(offset, stage.count * stage.delay,
        offset / (stage.count * stage.delay)))

    if stage.run_count < stage.count then
        if stage.frame_delay > 0 then
            stage.frame_delay = stage.frame_delay - 1
            draw_line(("Stage %s delay %d"):format(stage.name, stage.frame_delay))
        else
            stage.frame_delay = stage.delay
            stage.action(stage, curr)
            draw_line(("Stage %s action %d"):format(stage.name, stage.run_count))
        end
        stage.run_count = stage.run_count + 1
    end
end

function OnWorldPostUpdate()
    _runner()
end

-- vim: set ts=4 sts=4 sw=4 et:

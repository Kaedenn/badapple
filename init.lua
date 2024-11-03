--[[
-- Bad Apple!! but it's Noita
--]]

dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/badapple/files/timeline.lua")
dofile_once("mods/badapple/files/utility.lua")

gui = nil

function spawn_spell()
    local player = get_players()[1]
    if not player then return end
    local px, py = EntityGetTransform(player)
    if not px or not py then return end
    CreateItemActionEntity("BAD_APPLE", px, py)
end

function process_appends()
    ModLuaFileAppend(
        "data/scripts/gun/gun_actions.lua",
        "mods/badapple/files/append/gun_actions.lua")
    local translations = ModTextFileGetContent("data/translations/common.csv")
    local new_translations = ModTextFileGetContent("mods/badapple/files/append/translations.csv")
    translations = translations .. "\n" .. new_translations .. "\n"
    translations = translations:gsub("\r", ""):gsub("\n\n+", "\n")
    ModTextFileSetContent("data/translations/common.csv", translations)
end

local line_table = {}
function _runner()
    local run_mode = GlobalsGetValue("badapple_run")
    if run_mode == RUN_MODE_INIT then
        STAGES:init_timeline()
        run_mode = RUN_MODE_RUN
        GlobalsSetValue("badapple_run", run_mode)
    end

    if run_mode == RUN_MODE_END then
        STAGES:finish_timeline()
        run_mode = RUN_MODE_OFF
    end

    if run_mode ~= RUN_MODE_RUN then
        return
    end

    local trigger = get_trigger_frame()
    if trigger == -1 then
        print_error("is_running=true but trigger is -1")
        GlobalsSetValue("badapple_run", RUN_MODE_OFF)
        return
    end

    local curr = GameGetFrameNum()
    local offset = curr - trigger
    local stage, curr_offset = STAGES:get_stage(offset)
    if not stage then
        print_error(("No stage for offset %d"):format(offset))
        GlobalsSetValue("badapple_run", RUN_MODE_OFF)
        return
    end

    local player = get_players()[1]
    if player and player ~= 0 then
        EntitySetTransform(player, STAGES.root_x, STAGES.root_y + IMAGE_HEIGHT / 2)
    end
    if stage.lock_camera then
        GameSetCameraPos(STAGES.root_x, STAGES.root_y)
    end

    if not gui then gui = GuiCreate() end
    GuiStartFrame(gui)
    local sw, sh = GuiGetScreenDimensions(gui)
    local cw, ch = GuiGetTextDimensions(gui, "M")
    local linenr = 0
    local debugging = ModSettingGetNextValue("badapple.debug")
    local draw_line = function(line) end
    if debugging then
        draw_line = function(line)
            linenr = linenr + 1
            local liney = sh - ch * linenr - 2
            GuiText(gui, 2, liney, line)
        end
    end
    local stage_time = stage.count * (stage.delay + 1)
    draw_line(("Frame %d %d / %d (%2d%%)"):format(offset, curr_offset, stage_time,
        curr_offset / stage_time * 100))
    draw_line(("Count: %d, delay: %d"):format(stage.count, stage.delay))
    draw_line(("Stage %s %d/%d:"):format(stage.name, stage.run_count, stage.count))

    if stage.run_count < stage.count then
        if stage.frame_delay > 0 then
            stage.frame_delay = stage.frame_delay - 1
        else
            stage.run_count = stage.run_count + 1
            stage.frame_delay = stage.delay
            if stage.action then
                stage.action(STAGES, stage, stage.run_count)
            end
        end
        draw_line(("Stage %s delay %d count %d"):format(stage.name,
            stage.frame_delay, stage.run_count))
    end
end

function OnModPreInit()
    ModRegisterAudioEventMappings("mods/badapple/files/audio/GUIDS.txt")
end

function OnModPostInit()
    process_appends()
end

function OnPlayerSpawned()

end

function OnWorldPostUpdate()
    _runner()
end

-- vim: set ts=4 sts=4 sw=4 et:

--[[
-- Bad Apple!! but it's Noita
--]]

dofile_once("data/scripts/lib/utility.lua")
-- luacheck: globals get_players
dofile_once("mods/badapple/files/utility.lua")
-- luacheck: globals to_frames is_running get_stage get_trigger_frame

IMAGE_WIDTH = 722       -- Width of the video in pixels
IMAGE_HEIGHT = 520      -- Height of the video in pixels
FRAME_MAX = 6516        -- Last frame of video
BADAPPLE_FPS = 30       -- Frames per second of Bad Apple!!
BADAPPLE_DURATION = FRAME_MAX / BADAPPLE_FPS

EXTRA_DELAY = 0         -- Additional frame delay between video frames

FRAME = "mods/badapple/files/frames/badapple_%04d.png"

STAGES = {
    {
        name = "begin",
        action = function(stage, frame)
            GamePrintImportant("The Gods are watching closely.")
            do_begin(stage, frame)
        end,
        delay = to_frames(5),
        count = 1,
    },
    {
        name = "play",
        action = do_render_frame,
        delay = math.floor(BADAPPLE_FPS / 60),
        count = FRAME_MAX,
    },
    {
        name = "clear",
        action = do_clear_frame,
        delay = to_frames(2),
        count = 1,
    },
    {
        name = "amused",
        action = function(stage, frame) GamePrintImportant("The Gods are quite amused.") end,
        delay = to_frames(10),
        count = 1,
    },
    {
        name = "bored",
        action = function(stage, frame)
            GamePrintImportant("The Gods are now bored.")
            do_bored(stage, frame)
        end,
        delay = to_frames(10),
        count = 1,
    },
    {
        name = "death",
        action = function(stage, frame)
            do_kill_player(stage, frame)
            GlobalsSetValue("badapple_run", tostring(0))
        end,
        delay = 1,
        count = 1,
    },
}

--[[ Obtain the Stage table for the current offset (in frames) ]]
function get_stage(frame_offset)
    for stage_nr, stage in ipairs(STAGES) do
        local duration = stage.delay * stage.count
        frame_offset = frame_offset - duration
        if frame_offset < 0 then
            return stage
        end
    end
    return STAGES[#STAGES]
end

--[[ Obtain a stage by name ]]
function get_stage_named(stage_name)
    for _, stage in ipairs(STAGES) do
        if stage.name == stage_name then
            return stage
        end
    end
    print_error(("Invalid stage %s"):format(stage_name))
    return nil
end

--[[ Execute the "begin" action ]]
function do_begin(stage, frame)
    local player = get_players()[1]
    local comp = EntityGetFirstComponentIncludingDisabled(player, "PlatformShooterPlayerComponent")
    if comp ~= nil then
        local delay = 1
        for _, curr in ipairs(STAGES) do
            delay = delay + curr.delay * curr.count
        end
        print(("Delaying for %d frames (%.2f seconds)"):format(delay, delay/60))
        ComponentSetValue2(comp, "mCessationDo", true)
        ComponentSetValue2(comp, "mCessationLifetime", delay)
    end
end

--[[ Render a single frame ]]
function do_render_frame(stage, frame)
    local px, py = EntityGetTransform(get_players()[1])
    GameSetCameraPos(px + IMAGE_WIDTH/2, py - IMAGE_HEIGHT)
    LoadPixelScene(FRAME:format(frame), "", px, py, "", true, true, {
        ["ffffffff"] = "magic_liquid_hp_regeneration_unstable",
        ["ff000000"] = "midas_precursor",
    })
end

--[[ Execute the "bored" action ]]
function do_bored(stage, frame)
    local player = get_players()[1]
    local comp = EntityGetFirstComponentIncludingDisabled(player, "PlatformShooterPlayerComponent")
    if comp ~= nil then
        ComponentSetValue2(comp, "mCessationDo", false)
        ComponentSetValue2(comp, "mCessationLifetime", 0)
    end
end

--[[ Clear the area at the end of the video ]]
function do_clear_frame(stage, frame)
    local px, py = EntityGetTransform(get_players()[1])
    GameSetCameraPos(px + IMAGE_WIDTH/2, py - IMAGE_HEIGHT)
    LoadPixelScene(FRAME:format(1), "", px, py, "", true, true, {
        ["ff000000"] = "air",
    })
end

--[[ Polymorph, spawn enemy ]]
function do_kill_player(stage, frame)

end

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

    -- TODO: Spawn the new Bad Apple!! spell near the player
end

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
end

function OnWorldPostUpdate()
    _runner()
end

-- vim: set ts=4 sts=4 sw=4 et:

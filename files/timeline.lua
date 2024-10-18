dofile_once("data/scripts/lib/utilities.lua")
-- luacheck: globals get_players
dofile_once("mods/badapple/files/utility.lua")
-- luacheck: globals to_frames is_running get_stage get_trigger_frame get_image_size

-- TODO: fire + ominous liquid for white and black
--  $mat_fire 7fFF6060
--  rgba(255,255,246,127)
--  $mat_darkness 80563e66
--  rgba(5,86,99,128)
-- FIXME: cessation puzzle messages show up

IMAGE_WIDTH = nil       -- Width of the video in pixels
IMAGE_HEIGHT = nil      -- Height of the video in pixels
FRAME_MAX = 6516        -- Last frame of video
BADAPPLE_FPS = 30       -- Frames per second of Bad Apple!!
BADAPPLE_DURATION = FRAME_MAX / BADAPPLE_FPS

EXTRA_DELAY = 0         -- Additional frame delay between video frames

FRAME = "mods/badapple/files/frames/badapple_%04d.png"

--[[
-- stage structure:
--  name: string                         Name of the stage
--  action: fn(stage, frame:number)      Action function
--  delay: number (frames) (optional)    Frames to delay between actions
--  count: number (optional)             Max action count
--
--  run_count: number                    Number of times invoked
--  frame_delay: number                  Remaining delay frames
--]]
STAGES = {
    {
        name = "begin",
        action = function(stage, frame)
            GamePrintImportant(GameTextGet("$badapple_begin"))
            do_begin(stage, frame)
        end,
        delay = to_frames(5),
        count = 1,
    },
    {
        name = "play",
        action = do_render_frame,
        delay = math.floor(60 / BADAPPLE_FPS),
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
        action = function(stage, frame)
            GamePrintImportant(GameTextGet("$badapple_amused"))
        end,
        delay = to_frames(10),
        count = 1,
    },
    {
        name = "bored",
        action = function(stage, frame)
            GamePrintImportant(GameTextGet("$badapple_bored"))
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

function init_timeline()
    if not IMAGE_WIDTH or not IMAGE_HEIGHT then
        IMAGE_WIDTH, IMAGE_HEIGHT = get_image_size(FRAME:format(1))
    end
end

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
    ComponentSetValue2(
        EntityGetComponent(GameGetWorldStateEntity(), "WorldStateComponent")[1],
        "open_fog_of_war_everywhere", true)

    local player = get_players()[1]
    local comp = EntityGetFirstComponentIncludingDisabled(player, "PlatformShooterPlayerComponent")
    if comp ~= nil then
        local delay = 1
        for _, curr in ipairs(STAGES) do
            delay = delay + curr.delay * curr.count
        end
        print(("Delaying for %d frames (%.2f seconds)"):format(delay, delay/60))
        -- FIXME: This causes the cessation puzzle messages to appear
        -- FIXME: Polymorph the player instead of Cessation
        ComponentSetValue2(comp, "mCessationDo", true)
        ComponentSetValue2(comp, "mCessationLifetime", delay)
    end
end

--[[ Render a single frame ]]
function do_render_frame(stage, frame)
    do_clear_frame(stage, frame)
    local px, py = EntityGetTransform(get_players()[1])
    local fx, fy = px - IMAGE_WIDTH/2, py - IMAGE_HEIGHT/2
    GameSetCameraPos(px, py)
    LoadPixelScene(FRAME:format(frame), "", fx, fy, "", true, true, {
        ["ffffffff"] = "magic_liquid_hp_regeneration_unstable",
        ["ff000000"] = "midas_precursor",
    }, 50, true)
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
    local fx, fy = px - IMAGE_WIDTH/2, py - IMAGE_HEIGHT/2
    GameSetCameraPos(px, py)
    LoadPixelScene(FRAME:format(1), "", fx, fy, "", true, true, {
        ["ff000000"] = "air",
        ["ffffffff"] = "air",
    })
end

--[[ Polymorph, spawn enemy ]]
function do_kill_player(stage, frame)

end

--[[ Manually start the sequence ]]
function start_playback()
    local frame = GameGetFrameNum()
    GlobalsSetValue("badapple_run", tostring(1))
    GlobalsSetValue("badapple_trigger_frame", tostring(frame))
end

-- vim: set ts=4 sts=4 sw=4:

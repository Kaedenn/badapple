---@alias action_fn fun(stage: stage, frame: number)

---@class (exact) stage
---@field name string
---@field action fun(stage: stage, frame: number)
---@field delay number?
---@field count number?

-- stage structure:
--  name:               Name of the stage
--  action:             Action function
--  delay:              Frames to delay between actions
--  count:              Max action count
--
--  run_count:          Number of times invoked
--  frame_delay:        Remaining delay frames

dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/badapple/files/utility.lua")

IMAGE_WIDTH = nil       -- Width of the video in pixels; nil to compute
IMAGE_HEIGHT = nil      -- Height of the video in pixels; nil to compute
FRAME_MAX = 6516        -- Last frame of video
BADAPPLE_FPS = 30       -- Frames per second of Bad Apple!!
BADAPPLE_DURATION = FRAME_MAX / BADAPPLE_FPS

DELAY_BEGIN = to_frames(5)
DELAY_PLAY = math.floor(60 / BADAPPLE_FPS)
DELAY_CLEAR = to_frames(2)
DELAY_AMUSED = to_frames(3)
DELAY_BORED = to_frames(3)
DELAY_DEATH = 1

EXTRA_DELAY = 0         -- Additional frame delay between video frames

FRAME = "mods/badapple/files/frames/badapple_%04d.png"
FRAME_BLACK = "mods/badapple/files/frame_black.png"
FRAME_AIR = "mods/badapple/files/frame_air.png"

function enable_lighting()
    GameSetPostFxParameter("lighting_disable", 0, 0, 0, 0)
end

function disable_lighting()
    GameSetPostFxParameter("lighting_disable", 1, 1, 1, 1)
end

---Manually start the sequence
function start_playback()
    disable_lighting()
    local frame = GameGetFrameNum()
    GlobalsSetValue("badapple_run", tostring(1))
    GlobalsSetValue("badapple_trigger_frame", tostring(frame))
end

function stop_playback()
    enable_lighting()
    GlobalsSetValue("badapple_run", tostring(0))
end

---@type table<stage>
STAGES = {
    {
        name = "begin",
        action = function(stage, frame) do_stage_begin(stage, frame) end,
        delay = DELAY_BEGIN,
        count = 1,
    },
    {
        name = "play",
        action = function(stage, frame) do_stage_play(stage, frame) end,
        delay = DELAY_PLAY,
        count = FRAME_MAX,
    },
    {
        name = "clear",
        action = function(stage, frame) do_stage_clear(stage, frame) end,
        delay = DELAY_CLEAR,
        count = 1,
    },
    {
        name = "amused",
        action = function(stage, frame) do_stage_amused(stage, frame) end,
        delay = DELAY_AMUSED,
        count = 1,
    },
    {
        name = "bored",
        action = function(stage, frame) do_stage_bored(stage, frame) end,
        delay = DELAY_BORED,
        count = 1,
    },
    {
        name = "death",
        action = function(stage, frame) do_stage_death(stage, frame) end,
        delay = DELAY_DEATH,
        count = 1,
    },
}

---Perform one-time initialization
function init_timeline()
    if IMAGE_WIDTH == nil or IMAGE_HEIGHT == nil then
        IMAGE_WIDTH, IMAGE_HEIGHT = get_image_size(FRAME:format(1))
    end
end

---Determine the stage and relative offset for the given absolute offset
---@param frame_offset number
---@return stage
function get_stage(frame_offset)
    if not IMAGE_WIDTH or not IMAGE_HEIGHT then init_timeline() end
    for stage_nr, stage in ipairs(STAGES) do
        local duration = stage.delay * stage.count
        if frame_offset - duration < 0 then
            return stage, frame_offset
        end
        frame_offset = frame_offset - duration
    end
    return STAGES[#STAGES], 0
end

---Obtain a stage by name
---@param stage_name string
---@return stage
function get_stage_named(stage_name)
    if not IMAGE_WIDTH or not IMAGE_HEIGHT then init_timeline() end
    for _, stage in ipairs(STAGES) do
        if stage.name == stage_name then
            return stage
        end
    end
    print_error(("Invalid stage %s"):format(stage_name))
    return nil
end

--------------------------------------------------------------------------------
-- FRAME ACTIONS

---Execute the "begin" action
---@param stage stage
---@param frame number
function do_stage_begin(stage, frame)
    GamePrintImportant(GameTextGet("$badapple_begin"))
    disable_lighting()

    local wsc = EntityGetFirstComponent(GameGetWorldStateEntity(), "WorldStateComponent")
    ComponentSetValue2(wsc, "open_fog_of_war_everywhere", true)

    local player = get_players()[1]
    local comp = EntityGetFirstComponentIncludingDisabled(player, "PlatformShooterPlayerComponent")
    if comp ~= nil then
        local delay = 1
        for _, curr in ipairs(STAGES) do
            delay = delay + curr.delay * curr.count
        end
        print(("Delaying for %d frames (%.2f seconds)"):format(delay, delay/60))
        -- FIXME: This causes the cessation puzzle messages to appear
        --ComponentSetValue2(comp, "mCessationDo", true)
        --ComponentSetValue2(comp, "mCessationLifetime", delay)
    end
end

---Render a single frame
---@param stage stage
---@param frame number
function do_stage_play(stage, frame)
    do_stage_clear(stage, frame)
    local fx, fy = GameGetCameraPos()
    fx, fy = fx - IMAGE_WIDTH/2, fy - IMAGE_HEIGHT/2
    LoadPixelScene(FRAME:format(frame), "", fx, fy, "", true, true, {}, 50, true)
end

---Clear the area at the end of the video
---@param stage stage
---@param frame number
function do_stage_clear(stage, frame)
    local fx, fy = GameGetCameraPos()
    fx, fy = fx - IMAGE_WIDTH/2, fy - IMAGE_HEIGHT/2
    LoadPixelScene(FRAME_AIR, "", fx, fy, "", true, true, {})
end

---Execute the "amused" action
---@param stage stage
---@param frame number
function do_stage_amused(stage, frame)
    GamePrintImportant(GameTextGet("$badapple_amused"))
end

---Execute the "bored" action
---@param stage stage
---@param frame number
function do_stage_bored(stage, frame)
    GamePrintImportant(GameTextGet("$badapple_bored"))

    local player = get_players()[1]
    local comp = EntityGetFirstComponentIncludingDisabled(player, "PlatformShooterPlayerComponent")
    if comp ~= nil then
        ComponentSetValue2(comp, "mCessationDo", false)
        ComponentSetValue2(comp, "mCessationLifetime", 0)
    end
end

---Polymorph, spawn enemy
---@param stage stage
---@param frame number
function do_stage_death(stage, frame)
    enable_lighting()
    GlobalsSetValue("badapple_run", tostring(0))
end

-- vim: set ts=4 sts=4 sw=4:

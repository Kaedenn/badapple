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
DELAY_PLAY = math.max(math.floor(60 / BADAPPLE_FPS) - 1, 0)
DELAY_CLEAR = to_frames(2)
DELAY_AMUSED = to_frames(3)
DELAY_BORED = to_frames(3)
DELAY_DEATH = 1

EXTRA_DELAY = 0         -- Additional frame delay between video frames

RUN_MODE_OFF = "0"
RUN_MODE_INIT = "1"
RUN_MODE_RUN = "2"
RUN_MODE_END = "3"

FRAME = "mods/badapple/files/frames/badapple_%04d.png"
FRAME_BLACK = "mods/badapple/files/frame_black.png"
FRAME_AIR = "mods/badapple/files/frame_air.png"

PIXEL_WHITE = "ff000042" -- air
PIXEL_BLACK = "ff786c42" -- templebrick_static

MATERIAL_WHITE = "air"
MATERIAL_BLACK = "templebrick_static"

--[[ Re-enable the lighting system ]]
function enable_lighting()
    GameSetPostFxParameter("lighting_disable", 0, 0, 0, 0)
end

--[[ Disable the lighting system, thus making everything fullbright ]]
function disable_lighting()
    GameSetPostFxParameter("lighting_disable", 1, 1, 1, 1)
end

---@type table<stage>
STAGES = {
    {
        name = "begin",
        action = function(...) do_stage_begin(...) end,
        delay = DELAY_BEGIN,
        count = 1,
        lock_camera = true,
    },
    {
        name = "play",
        action = function(...) do_stage_play(...) end,
        delay = DELAY_PLAY,
        count = FRAME_MAX,
        lock_camera = true,
    },
    {
        name = "clear",
        action = function(...) do_stage_clear(...) end,
        delay = DELAY_CLEAR,
        count = 1,
        lock_camera = true,
    },
    {
        name = "amused",
        action = function(...) do_stage_amused(...) end,
        delay = DELAY_AMUSED,
        count = 1,
        lock_camera = true,
    },
    {
        name = "bored",
        action = function(...) do_stage_bored(...) end,
        delay = DELAY_BORED,
        count = 1,
        lock_camera = false,
    },
    {
        name = "death",
        action = function(...) do_stage_death(...) end,
        delay = DELAY_DEATH,
        count = 1,
        lock_camera = false,
    },
    gui = nil,
    screen_width = 427,
    screen_height = 242,
    root_x = nil,
    root_y = nil,
    use_custom_materials = false,
    material_white = MATERIAL_WHITE,
    material_black = MATERIAL_BLACK,
}

---Perform one-time initialization
function STAGES:init_timeline()
    if IMAGE_WIDTH == nil or IMAGE_HEIGHT == nil then
        IMAGE_WIDTH, IMAGE_HEIGHT = get_image_size(FRAME:format(1))
    end

    if self.gui ~= nil then
        GuiDestroy(self.gui)
    end
    self.gui = GuiCreate()
    self.screen_width, self.screen_height = GuiGetScreenDimensions(self.gui)

    for _, stage in ipairs(self) do
        stage.run_count = 0
        stage.frame_delay = 0
    end

    local player = get_players()[1]
    local player_x, player_y = EntityGetTransform(player)
    self.root_x = player_x
    self.root_y = player_y - IMAGE_HEIGHT / 2
    self.use_custom_materials = false
    self.material_white = MATERIAL_WHITE
    self.material_black = MATERIAL_BLACK

    if ModSettingGetNextValue("badapple.use_custom_materials") then
        self.use_custom_materials = true
        local mat_white = ModSettingGetNextValue("badapple.white_pixels")
        if CellFactory_GetType(mat_white) ~= -1 then
            self.material_white = mat_white
            print(("Using %s for white"):format(self.material_white))
        else
            print(("Invalid material %s; using %s"):format(mat_white, self.material_white))
        end
        local mat_black = ModSettingGetNextValue("badapple.black_pixels")
        if CellFactory_GetType(mat_black) ~= -1 then
            self.material_black = mat_black
            print(("Using %s for black"):format(self.material_black))
        else
            print(("Invalid material %s; using %s"):format(mat_black, self.material_black))
        end
    end

    local play_stage = self:get_stage_named("play")
    play_stage.delay = DELAY_PLAY + math.ceil(ModSettingGetNextValue("badapple.delay"))
    local vid_length = ModSettingGetNextValue("badapple.cutoff")
    if vid_length > 0 then
        play_stage.count = math.ceil(vid_length)
    end
end

---Called to clean up everything
function STAGES:finish_timeline()
    local entid = get_effect_entity(self.root_x, self.root_y)
    if entid ~= nil then
        effect_set_frames(entid, 10)
    end
    enable_lighting()
end

---Determine the stage and relative offset for the given absolute offset
---@param frame_offset number
---@return stage
function STAGES:get_stage(frame_offset)
    if not IMAGE_WIDTH or not IMAGE_HEIGHT then self:init_timeline() end
    for stage_nr, stage in ipairs(self) do
        local duration = (stage.delay + 1) * stage.count
        if frame_offset - duration < 0 then
            return stage, frame_offset
        end
        frame_offset = frame_offset - duration
    end
    return self[#self], 0
end

---Obtain a stage by name
---@param stage_name string
---@return stage
function STAGES:get_stage_named(stage_name)
    if not IMAGE_WIDTH or not IMAGE_HEIGHT then self:init_timeline() end
    for _, stage in ipairs(self) do
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
---@param stages table<stage>
---@param stage stage
---@param frame number
function do_stage_begin(stages, stage, frame)
    GamePrintImportant(GameTextGet("$badapple_begin"))
    disable_lighting()

    local player = get_players()[1]
    local delay = 1
    for _, curr in ipairs(STAGES) do
        delay = delay + (curr.delay + 1) * curr.count
    end
    print(("Delaying for %d frames (%.2f seconds)"):format(delay, delay/60))
    LoadGameEffectEntityTo(player, "mods/badapple/files/effects/effect_polymorph.xml")

    local entid = get_effect_entity(stages.root_x, stages.root_y)
    if entid ~= nil then
        effect_set_frames_once(entid, delay)
    end

    local screen_left = stages.root_x - stages.screen_width / 2
    local screen_right = stages.root_x + stages.screen_width / 2
    local screen_top = stages.root_y - stages.screen_height / 2
    local screen_bottom = stages.root_y + stages.screen_height / 2
    -- TODO: pre-fill the screen borders with the black material

    -- TODO: Perhaps play Bad Apple!! via in-game audio?
    --GamePlaySound("mods/badapple/files/audio/badapple.bank", "badapple/start",
    --    stages.root_x, stages.root_y)
end

---Render a single frame
---@param stages table<stage>
---@param stage stage
---@param frame number
function do_stage_play(stages, stage, frame)
    local fx = stages.root_x - IMAGE_WIDTH/2
    local fy = stages.root_y - IMAGE_HEIGHT/2
    local colortab = {
        [PIXEL_WHITE] = STAGES.material_white,
        [PIXEL_BLACK] = STAGES.material_black,
    }
    LoadPixelScene(FRAME:format(frame), "", fx, fy, "", true, true, colortab, 50, true)
end

---Clear the area at the end of the video
---@param stages table<stage>
---@param stage stage
---@param frame number
function do_stage_clear(stages, stage, frame)
    local fx = stages.root_x - IMAGE_WIDTH/2
    local fy = stages.root_y - IMAGE_HEIGHT/2
    local colortab = {
        [PIXEL_WHITE] = "air",
    }
    LoadPixelScene(FRAME_AIR, "", fx, fy, "", true, true, colortab, 50, true)
end

---Execute the "amused" action
---@param stages table<stage>
---@param stage stage
---@param frame number
function do_stage_amused(stages, stage, frame)
    GamePrintImportant(GameTextGet("$badapple_amused"))
end

---Execute the "bored" action
---@param stages table<stage>
---@param stage stage
---@param frame number
function do_stage_bored(stages, stage, frame)
    GamePrintImportant(GameTextGet("$badapple_bored"))
    enable_lighting()
    local entid = get_effect_entity(stages.root_x, stages.root_y)
    if entid ~= nil then
        effect_set_frames(entid, 10)
    end
end

---Polymorph, spawn enemy
---@param stages table<stage>
---@param stage stage
---@param frame number
function do_stage_death(stages, stage, frame)
    GlobalsSetValue("badapple_run", tostring(0))
end

-- vim: set ts=4 sts=4 sw=4:

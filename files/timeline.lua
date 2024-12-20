
---@class stage_type
---@field name string
---@field action fun(stages: stages_type, stage: stage_type, frame: number)
---@field delay number?
---@field count number?
---@field lock_camera boolean
---@field lock_player boolean

---@class stages_type
---@field screen_width number
---@field screen_height number
---@field effect_entity number?
---@field root_x number?
---@field root_y number?
---@field player_x number?
---@field player_y number?
---@field use_custom_materials boolean
---@field material_white string
---@field material_black string
---@field [number] stage_type

-- stage structure:
--  name:               Name of the stage
--  action:             Action function
--  delay:              Frames to delay between actions
--  count:              Max action count
--  lock_camera:        Lock the camera to root_x, root_y this stage?
--  lock_player:        Lock the player to prevent movement this stage?
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

ROOT_X_ADJUST_COEFF = 0 -- display centered on player
ROOT_Y_ADJUST_COEFF = 1 -- display IMAGE_HEIGHT above the player

DELAY_BEGIN = to_frames(5)
DELAY_PLAY = math.max(math.floor(60 / BADAPPLE_FPS) - 1, 0)
DELAY_CLEAR = to_frames(2)
DELAY_AMUSED = to_frames(5)
DELAY_BORED = to_frames(3)
DELAY_FINISH = 1

EXTRA_DELAY = 0         -- Additional frame delay between video frames

RUN_MODE_OFF = "0"
RUN_MODE_INIT = "1"
RUN_MODE_RUN = "2"
RUN_MODE_END = "3"

FRAME = "mods/badapple/files/frames/badapple_%04d.png"

PIXEL_WHITE = "ff000042" -- air
PIXEL_BLACK = "ff786c42" -- templebrick_static

MATERIAL_WHITE = "air"
MATERIAL_BLACK = "templebrick_static"

---The timeline: all of the stages, delays, run counts, and supporting data
---@type stages_type
STAGES = {
    {
        name = "begin",
        action = function(...) do_stage_begin(...) end,
        delay = DELAY_BEGIN,
        count = 1,
        lock_camera = true,
        lock_player = true,
    },
    {
        name = "play",
        action = function(...) do_stage_play(...) end,
        delay = DELAY_PLAY,
        count = FRAME_MAX,
        lock_camera = true,
        lock_player = true,
    },
    {
        name = "clear",
        action = function(...) do_stage_clear(...) end,
        delay = DELAY_CLEAR,
        count = 1,
        lock_camera = true,
        lock_player = true,
    },
    {
        name = "amused",
        action = function(...) do_stage_amused(...) end,
        delay = DELAY_AMUSED,
        count = 1,
        lock_camera = false,
        lock_player = false,
    },
    {
        name = "bored",
        action = function(...) do_stage_bored(...) end,
        delay = DELAY_BORED,
        count = 1,
        lock_camera = false,
        lock_player = false,
    },
    {
        name = "finish",
        action = function(...) do_stage_finish(...) end,
        delay = DELAY_FINISH,
        count = 1,
        lock_camera = false,
        lock_player = false,
    },
    screen_width = 427,
    screen_height = 242,
    effect_entity = nil,                -- entity ID of polymorph entity
    player_x = nil,
    player_y = nil,
    root_x = nil,                       -- camera center x
    root_y = nil,                       -- camera center y
    use_custom_materials = false,
    material_white = MATERIAL_WHITE,    -- "air"
    material_black = MATERIAL_BLACK,    -- "templebrick_static"
}

---Perform one-time initialization
function STAGES:init_timeline()
    if IMAGE_WIDTH == nil or IMAGE_HEIGHT == nil then
        IMAGE_WIDTH, IMAGE_HEIGHT = get_image_size(FRAME:format(1))
    end

    for _, stage in ipairs(self) do
        stage.run_count = 0
        stage.frame_delay = 0
    end

    self.screen_width = MagicNumbersGetValue("VIRTUAL_RESOLUTION_X")
    self.screen_height = MagicNumbersGetValue("VIRTUAL_RESOLUTION_Y")

    local player = get_players()[1]
    local player_x, player_y = EntityGetTransform(player)
    self.player_x = player_x
    self.player_y = player_y
    self.root_x = player_x - ROOT_X_ADJUST_COEFF * IMAGE_WIDTH
    self.root_y = player_y - ROOT_Y_ADJUST_COEFF * IMAGE_HEIGHT
    self.use_custom_materials = false
    self.material_white = MATERIAL_WHITE
    self.material_black = MATERIAL_BLACK

    -- If using custom materials, validate and apply those
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

    -- Initialize the stage delay and run counts
    local play_stage = self:get_stage_named("play")
    play_stage.delay = DELAY_PLAY + math.ceil(ModSettingGetNextValue("badapple.delay"))
    local vid_length = ModSettingGetNextValue("badapple.cutoff")
    if vid_length > 0 then
        play_stage.count = math.ceil(vid_length)
    end
end

---Called to clean up everything
function STAGES:finish_timeline()
    local framecount = effect_get_frames(self.effect_entity)
    if framecount ~= nil and framecount > 10 then
        effect_set_frames(self.effect_entity, 10)
    end
    enable_lighting()
end

---Determine the stage and relative offset for the given absolute offset
---@param frame_offset number
---@return stage_type, number
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
---@return stage_type? nil if no stage exists with that name
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
---@param stages stages_type
---@param stage stage_type
---@param frame number
function do_stage_begin(stages, stage, frame)
    GamePrintImportant(GameTextGet("$badapple_begin"))
    disable_lighting()

    local player = get_players()[1]
    local delay = 1
    for _, curr in ipairs(STAGES) do
        delay = delay + (curr.delay + 1) * curr.count
    end
    print(("Delaying for %d frames (%.2f seconds)"):format(delay, delay / 60))
    LoadGameEffectEntityTo(player, "mods/badapple/files/effects/effect_polymorph.xml")

    local entid = get_effect_entity(stages.root_x, stages.root_y)
    if entid ~= nil then
        stages.effect_entity = entid
        effect_set_frames_once(entid, delay)
    end

    local screen_w = stages.screen_width
    local screen_h = stages.screen_height
    local screen_x = stages.root_x - screen_w / 2
    local screen_y = stages.root_y - screen_h / 2

    fill_area_material(screen_x, screen_y, screen_w, screen_h, stages.material_black)

    -- TODO: Perhaps play Bad Apple!! via in-game audio?
    --GamePlaySound("mods/badapple/files/audio/badapple.bank", "badapple/start",
    --    stages.root_x, stages.root_y)
end

---Render a single frame
---@param stages stages_type
---@param stage stage_type
---@param frame number
function do_stage_play(stages, stage, frame)
    local fx = stages.root_x - IMAGE_WIDTH / 2
    local fy = stages.root_y - IMAGE_HEIGHT / 2
    local colortab = {
        [PIXEL_WHITE] = STAGES.material_white,
        [PIXEL_BLACK] = STAGES.material_black,
    }
    LoadPixelScene(FRAME:format(frame), "", fx, fy, "", true, true, colortab, 50, true)
end

---Fill the entire area with the default stone pattern at the end of the video
---@param stages stages_type
---@param stage stage_type
---@param frame number
function do_stage_clear(stages, stage, frame)
    enable_lighting()

    local framecount = effect_get_frames(stages.effect_entity)
    if framecount ~= nil and framecount > 10 then
        effect_set_frames(stages.effect_entity, 10)
    end

    local screen_w = stages.screen_width
    local screen_h = stages.screen_height
    local screen_x = stages.root_x - screen_w / 2
    local screen_y = stages.root_y - screen_h / 2

    fill_area_stone(screen_x, screen_y, screen_w, screen_h)

    fill_area_material(screen_x, stages.player_y - 29, screen_w, 32, "air")

    local fill_w, fill_h = 32 * 6, 32 * 3
    local fill_x = stages.player_x - fill_w / 2
    local fill_y = stages.player_y - fill_h
    fill_area_material(fill_x, fill_y, fill_w, fill_h, "air")
end

---Execute the "amused" action
---@param stages stages_type
---@param stage stage_type
---@param frame number
function do_stage_amused(stages, stage, frame)
    GamePrintImportant(GameTextGet("$badapple_amused"))

    local player = get_players()[1]
    LoadGameEffectEntityTo(player, "data/entities/misc/effect_polymorph.xml")
end

---Execute the "bored" action
---@param stages stages_type
---@param stage stage_type
---@param frame number
function do_stage_bored(stages, stage, frame)
    GamePrintImportant(GameTextGet("$badapple_bored"))

    local entx = stages.player_x
    local enty = stages.player_y - 64
    EntityLoad("data/entities/animals/necromancer_shop.xml", entx, enty)
end

---Called to finish the timeline
---@param stages stages_type
---@param stage stage_type
---@param frame number
function do_stage_finish(stages, stage, frame)
    GlobalsSetValue("badapple_run", RUN_MODE_OFF)
end

-- vim: set ts=4 sts=4 sw=4:

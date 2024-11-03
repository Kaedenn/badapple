
MaterialColorTable = dofile_once("mods/badapple/files/material_colors.lua")

-- Convert a number of seconds to a frame offset
function to_frames(seconds)
    return math.floor(60 * seconds)
end

-- Get the frame the playback was triggered
function get_trigger_frame()
    return tonumber(GlobalsGetValue("badapple_trigger_frame", "-1"))
end

-- Get the size of an image in pixels
function get_image_size(image_path)
    local gui = GuiCreate()
    GuiStartFrame(gui)
    local width, height = GuiGetImageDimensions(gui, image_path)
    GuiDestroy(gui)
    return width, height
end

-- Obtain the ID of the Bad Apple effect entity
function get_effect_entity(root_x, root_y)
    local entid = EntityGetClosestWithTag(root_x, root_y, "effect_badapple")
    if entid and entid ~= 0 then
        return entid
    end
    return nil
end

-- True if the effect entity is properly initialized
function effect_is_initialized(entid)
    local varcomp = EntityGetFirstComponent(entid, "VariableStorageComponent")
    if not varcomp or varcomp == 0 then
        print_error(("Entity %d lacks GameEffectComponent"):format(entid))
        return
    end
    return ComponentGetValue2(varcomp, "value_bool") == true
end

-- Get the number of frames remaining for the effect entity
function effect_get_frames(entid)
    local comp = EntityGetFirstComponent(entid, "GameEffectComponent")
    if not comp or comp == 0 then
        print_error(("Entity %d lacks GameEffectComponent"):format(entid))
        return
    end
    return ComponentGetValue2(comp, "frames")
end

-- Set the number of frames remaining for the effect entity
function effect_set_frames(entid, num_frames)
    local comp = EntityGetFirstComponent(entid, "GameEffectComponent")
    if not comp or comp == 0 then
        print_error(("Entity %d lacks GameEffectComponent"):format(entid))
        return
    end
    ComponentSetValue2(comp, "frames", num_frames)
    print(("Set %d effect %d frame count to %d"):format(entid, comp, num_frames))
end

-- Initialize the effect entity with the given duration in frames
function effect_set_frames_once(entid, num_frames)
    local varcomp = EntityGetFirstComponent(entid, "VariableStorageComponent")
    if not varcomp or varcomp == 0 then
        print_error(("Entity %d lacks GameEffectComponent"):format(entid))
        return
    end
    local init = ComponentGetValue2(varcomp, "value_bool")
    if not init then
        effect_set_frames(entid, num_frames)
        ComponentSetValue2(varcomp, "value_bool", true)
        print(("Initialized effect frame count to %d"):format(num_frames))
    end
end

-- Fill a 32x32 pixel area centered at the given coordinates with a material
function fill_material_32x32(fx, fy, material)
    local image = "mods/badapple/files/frame_air_32x32.png"
    print(("Applying %s to %d,%d"):format(material, fx-16, fy-16))
    LoadPixelScene(image, "", fx-16, fy-16, "", true, true, {
        ["ff000042"] = material,
    }, 50, true)
end

-- vim: set ts=4 sts=4 sw=4:

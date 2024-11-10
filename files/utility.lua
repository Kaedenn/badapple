
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

--[[ Functions relating to the polymorph effect entity ]]

---Determine the ID of the Bad Apple!! effect entity or nil
---Uses the camera if root_x or root_y are nil
---@param root_x number? x position to search from
---@param root_y number? y position to search from
---@return number? entity ID or nil if not found
function get_effect_entity(root_x, root_y)
    if not root_x or not root_y then
        local cx, cy = GameGetCameraPos()
        if not root_x then root_x = cx end
        if not root_y then root_y = cy end
    end
    local entid = EntityGetClosestWithTag(root_x, root_y, "effect_badapple")
    if entid and entid ~= 0 then
        return entid
    end
    return nil
end

---Obtain the effect entity's effect component
---@param entid number? entity ID of the effect entity
---@return number? component ID or nil
function get_effect_component(entid)
    if not entid then
        entid = get_effect_entity(nil, nil)
    end
    if not entid then
        print_error("No Bad Apple!! effect entity found")
        return nil
    end
    local comp = EntityGetFirstComponent(entid, "GameEffectComponent")
    if not comp or comp == 0 then
        print_error(("Entity %d lacks GameEffectComponent"):format(entid))
        return nil
    end
    return comp
end

---Obtain the effect entity's "initialized?" variable component
---@param entid number? entity ID of the effect entity
---@return number? component ID or nil
function get_effect_var_component(entid)
    if not entid then
        entid = get_effect_entity(nil, nil)
    end
    if not entid then
        print_error("No Bad Apple!! effect entity found")
        return nil
    end
    local varcomp = EntityGetFirstComponent(entid, "VariableStorageComponent")
    if not varcomp or varcomp == 0 then
        print_error(("Entity %d lacks VariableStorageComponent"):format(entid))
        return nil
    end
    return varcomp
end

---Determine if the effect entity is properly initialized
---@param entid number? entity ID of the effect entity
---@return boolean? true or false, or nil if not found
function effect_is_initialized(entid)
    local varcomp = get_effect_var_component(entid)
    if varcomp then
        return ComponentGetValue2(varcomp, "value_bool") == true
    end
    return nil
end

---Update the "initialized?" value for the effect entity
---@param entid number? entity ID of the effect entity
---@param value boolean new value
---@return boolean true on success, false otherwise
function effect_set_initialized(entid, value)
    local varcomp = get_effect_var_component(entid)
    if varcomp then
        ComponentSetValue2(varcomp, "value_bool", true)
        return true
    end
    return false
end

-- Get the number of frames remaining for the effect entity
---Determine how many frames are left in the effect entity
---@param entid number? entity ID of the effect entity
---@return number? frames remaining, or nil if not found
function effect_get_frames(entid)
    local comp = get_effect_component(entid)
    if comp then
        return ComponentGetValue2(comp, "frames")
    end
    return nil
end

---Set the number of frames remaining for the effect entity
---@param entid number? entity ID of the effect entity
---@param num_frames number frames remaining
---@return boolean true on success, false otherwise
function effect_set_frames(entid, num_frames)
    local comp = get_effect_component(entid)
    if comp then
        ComponentSetValue2(comp, "frames", num_frames)
        print(("Set %d effect %d frame count to %d"):format(entid, comp, num_frames))
        return true
    end
    return false
end

---Initialize the effect entity with the given duration in frames
---@param entid number? entity ID of the effect entity
---@param num_frames number frames remaining
---@return boolean true on success, false otherwise
function effect_set_frames_once(entid, num_frames)
    if effect_is_initialized(entid) == false then
        effect_set_frames(entid, num_frames)
        effect_set_initialized(entid, true)
        return true
    end
    return false
end

--[[ Functions relating to changing materials ]]

---Fill a 32x32 pixel area centered at the given coordinates with a material
---@param fx number X position of the area to cover
---@param fy number Y position of the area to cover
---@param material string name of material to use
function fill_material_32x32(fx, fy, material)
    local image = "mods/badapple/files/frame_air_32x32.png"
    print(("Applying %s to %d,%d"):format(material, fx-16, fy-16))
    LoadPixelScene(image, "", fx-16, fy-16, "", true, true, {
        ["ff000042"] = material,
    }, 50, true)
end

---Fill a rectangular area with a specific material
---@param frame_x number X position of the area to cover
---@param framw_y number Y position of the area to cover
---@param frame_w number width of the area to cover
---@param framw_h number height of the area to cover
---@param material string material to use to cover the area
function fill_area_32x32(frame_x, frame_y, frame_w, frame_h, material)
    for xoff = 0, math.ceil(frame_w/32)-1, 1 do
        for yoff = 0, math.ceil(frame_h/32)-1, 1 do
            local bxoff = math.min(xoff * 32, frame_w - 32)
            local byoff = math.min(yoff * 32, frame_h - 32)
            local bx = bxoff + frame_x
            local by = byoff + frame_y
            fill_material_32x32(bx+16, by+16, material)
        end
    end
end

-- vim: set ts=4 sts=4 sw=4:

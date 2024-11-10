--[[ Bad Apple!! public API ]]

RUN_MODE_OFF = "0"
RUN_MODE_INIT = "1"
RUN_MODE_RUN = "2"
RUN_MODE_END = "3"

function badapple_start()
    local frame = GameGetFrameNum()
    GlobalsSetValue("badapple_run", RUN_MODE_INIT)
    GlobalsSetValue("badapple_trigger_frame", tostring(frame))
end

function badapple_stop()
    GlobalsSetValue("badapple_run", RUN_MODE_END)
end

function badapple_set_materials(white_material, black_material)
    local abort = false
    if CellFactory_GetType(white_material) == -1 then
        print_error(("Invalid material for white: %s"):format(white_material))
        abort = true
    end
    if CellFactory_GetType(black_material) == -1 then
        print_error(("Invalid material for black: %s"):format(black_material))
        abort = true
    end
    if abort then
        print_error("Not changing Bad Apple!! materials due to invalid materials")
        return
    end

    ModSettingSetNextValue("badapple.white_pixels", white_material)
    ModSettingSetNextValue("badapple.black_pixels", black_material)
    ModSettingSetNextValue("badapple.use_custom_materials", true)
end

-- vim: set ts=4 sts=4 sw=4:

--[[ Bad Apple!! public API ]]

function badapple_start()
    local frame = GameGetFrameNum()
    GlobalsSetValue("badapple_run", tostring(1))
    GlobalsSetValue("badapple_trigger_frame", tostring(frame))
end

-- vim: set ts=4 sts=4 sw=4:

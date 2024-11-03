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

-- vim: set ts=4 sts=4 sw=4:


-- Convert a number of seconds to a frame offset
function to_frames(seconds)
    return math.floor(60 * seconds)
end

-- True if the playback is running
function is_running()
    return tonumber(GlobalsGetValue("badapple_run")) == 1
end

-- Get the frame the playback was triggered
function get_trigger_frame()
    return tonumber(GlobalsGetValue("badapple_trigger_frame", "-1"))
end

-- vim: set ts=4 sts=4 sw=4:

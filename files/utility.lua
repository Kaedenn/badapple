
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

-- DEBUGGING --

function test_translations()
    function test_one(ins)
        if not ins:match("^%$") then
            ins = "$" .. ins
        end
        local loc = GameTextGetTranslatedOrNot(ins)
        GamePrint(("%s -> %q"):format(ins, loc))
    end
    test_one("action_badapple")
    test_one("actiondesc_badapple")
    test_one("badapple_begin")
    test_one("badapple_amused")
    test_one("badapple_bored")
end

-- vim: set ts=4 sts=4 sw=4:

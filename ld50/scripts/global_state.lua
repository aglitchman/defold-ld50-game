local M = {}

function M.reset()
    -- Settings
    M.sounds = html5 and true or false
    M.music = html5 and true or false

    -- Global State
    M.window_focused = true
    M.audio_muted = false -- Usually paused by ads, etc.
    M.touch_control = false -- Set by main.script if the player has multitouch display, i.e. they play on a mobile phone/tablet.

    -- Serializable
    M.first_start = true
end

M.reset()

return M
local M = {}

function M.reset()
    -- Settings
    M.sounds = true
    M.music = true

    -- Global State
    M.window_focused = true
    M.audio_muted = false -- Usually paused by ads, etc.
end

M.reset()

return M
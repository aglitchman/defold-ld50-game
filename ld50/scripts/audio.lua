local global_state = require("ld50.scripts.global_state")

local M = {}

M.PLAY_SFX = hash("play_sfx")
M.PLAY_BGM = hash("play_bgm")

--
-- PRIVATE API
--

function M._init()
    M.audio_script = msg.url("#")
    M.bgm_obj = hash("/bgm")
    M.sfx_obj = hash("/sfx")
    M.socket = M.audio_script.socket

    M.bgm_volume = 0
    M.bgm_cur_level = 0
    M.stop_bgm_gain = {}

    M.sfx_volume = 0
    M.sfx_cur_level = 0
end

function M._update()
    local s = global_state

    --
    if not s.music or s.audio_muted or not s.window_focused then
        M.bgm_volume = 0
    else
        M.bgm_volume = 1
    end
    M.bgm_cur_level = vmath.lerp(0.1, M.bgm_cur_level, M.bgm_volume)
    sound.set_group_gain("bgm", M.bgm_cur_level * 0.6) --- TODO

    --
    if not s.sounds or s.audio_muted or not s.window_focused then
        M.sfx_volume = 0
    else
        M.sfx_volume = 1
    end
    if M.sfx_cur_level ~= M.sfx_volume then
        M.sfx_cur_level = vmath.lerp(0.4, M.sfx_cur_level, M.sfx_volume)
        -- sound.set_group_gain("sfx", M.sfx_cur_level * 1) --- TODO
    end

    -- Smooth fade out of music
    for id, volume in pairs(M.stop_bgm_gain) do
        local url = msg.url(M.socket, M.bgm_obj, id)
        sound.set_gain(url, volume)

        volume = vmath.lerp(0.2, volume, 0)
        M.stop_bgm_gain[id] = volume
        if volume < 0.001 then
            M.stop_bgm_gain[id] = nil
            sound.stop(url)
        end
    end
end

function M._final()
end

function M._play_bgm(id)
    if type(id) == "string" then
        id = hash(id)
    end
    local url = msg.url(M.socket, M.bgm_obj, id)

    if M.stop_bgm_gain[id] then
        sound.stop(url)
    end
    M.stop_bgm_gain[id] = nil

    -- print("play", url)
    sound.play(url, { gain = 1 })
end

function M._play_sfx(id, props)
    local s = app_state.t
    if not s.sounds or s.audio_muted or not s.window_focused then
        return
    end

    local sound_id = id
    if type(id) == "table" then
        sound_id = id[math.random(1, #id)]
    end
    sound.stop(msg.url(M.socket, M.sfx_obj, sound_id))

    sound.play(msg.url(M.socket, M.sfx_obj, sound_id), props)
end

--
-- PUBLIC API
--

function M.play_bgm(id)
    if not M.bgm_obj then
        print("Bgm collection is not loaded yet")
        return
    end

    msg.post(M.audio_script, M.PLAY_BGM, {
        id = id
    })
end

function M.stop_bgm(id)
    if not M.bgm_obj then
        print("Bgm collection is not loaded yet")
        return
    end

    if type(id) == "string" then
        id = hash(id)
    end

    M.stop_bgm_gain[id] = 1
end

function M.play_sfx(id, props)
    if not M.sfx_obj then
        print("Sounds collection is not loaded yet")
        return
    end

    msg.post(M.audio_script, M.PLAY_SFX, {
        id = id,
        props = props
    })
end

return M
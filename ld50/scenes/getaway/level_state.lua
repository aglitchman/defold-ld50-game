local M = {}

function M.reset()
    -- UI
    M.car_speed = 0
    M.car_accel_boost = 0
    M.car_accel_const = 0

    -- Score
    M.car_distance = 0

    -- Debug
    M.car_count = 0
    M.merge_count = 0

    -- FTUE
    M.ftue = false
    M.ftue_targets = 0
end

function M.calc_score()
    return math.floor(M.car_distance / 30)
end

M.reset()

return M
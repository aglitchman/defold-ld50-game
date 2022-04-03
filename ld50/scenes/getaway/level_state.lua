local M = {}

function M.reset()
    M.car_speed = 0
    M.car_count = 0
    M.car_distance = 0
end

function M.calc_score()
    return math.floor(M.car_distance / 30)
end

M.reset()

return M
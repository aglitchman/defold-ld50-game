local M = {}

-- TODO
local FX_DUST_URL = "/fx#fx_dust"

function M.road_dust(position, scale)
    msg.post(FX_DUST_URL, "road_dust", {
        position = position,
        scale = scale
    })
end

return M
local M = {}

-- TODO
local FX_DUST_URL = "/fx#fx_dust"
local ROAD_DUST = hash("road_dust")
local PUFF = hash("puff")

function M.road_dust(position, scale)
    msg.post(FX_DUST_URL, ROAD_DUST, {
        position = position,
        scale = scale
    })
end

function M.puff(position, parent_id)
    msg.post(FX_DUST_URL, PUFF, {
        position = position,
        parent_id = parent_id
    })
end

return M
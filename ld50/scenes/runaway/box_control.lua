local render3d = require("scene3d.render.render3d")
local math3d = require("scene3d.helpers.math3d")
local level_state = require("ld50.scenes.runaway.level_state")
local fx = require("ld50.fx.scripts.fx")

local PALETTE = {"#f94144","#f8961e","#43aa8b","#277da1"} -- ,"#f3722c","#f9844a","#f9c74f","#90be6d","#4d908e","#577590","#277da1"}

local function v4_equals(v1, v2)
    return v1.x == v2.x and v1.y == v2.y and v1.z == v2.z and v1.w == v2.w
end

local function color(str, mul)
    mul = mul or 1
    local r, g, b, a
    r, g, b = str:match("#(%x%x)(%x%x)(%x%x)")
    if r then
        r = tonumber(r, 16) / 0xff
        g = tonumber(g, 16) / 0xff
        b = tonumber(b, 16) / 0xff
        a = 1
    elseif str:match("rgba?%s*%([%d%s%.,]+%)") then
        local f = str:gmatch("[%d.]+")
        r = (f() or 0) / 0xff
        g = (f() or 0) / 0xff
        b = (f() or 0) / 0xff
        a = f() or 1
    else
        error(("bad color string '%s'"):format(str))
    end
    return r * mul, g * mul, b * mul, a * mul
end

local function kill(self)
    self.killed = true

    msg.post("#trigger", "disable")

    go.animate(".", "scale", go.PLAYBACK_ONCE_FORWARD, 0.001, go.EASING_OUTSINE, 0.5, 0, function (self)
        go.delete()
    end)
end

local M = {}

function M.init(self)
    self.last_position = go.get_position()

    self.box_color = vmath.vector4(color(PALETTE[math.random(1, #PALETTE)]))
    local mesh_url = msg.url(nil, nil, self.mesh_id)
    go.set(mesh_url, "tint", self.box_color)

    if self.keyboard_input then
        msg.post(".", "acquire_input_focus")

        go.set("/main#orbit_follow", "follow_object_id", go.get_id())
    end

    level_state.box_count = level_state.box_count + 1

    go.set_scale(1.5)
    go.animate(".", "scale", go.PLAYBACK_ONCE_FORWARD, 1, go.EASING_OUTBACK, 0.5, 0)

    self.default_velocity = self.velocity
    self.dust_accum = 0
end

function M.final(self)
    level_state.box_count = level_state.box_count - 1
end

function M.update(self, dt)
    local position = go.get_position()

    self.velocity = math3d.lerp(0.5, self.velocity, self.default_velocity, dt)

    self.total_speed = self.velocity + self.boost
    position = position + render3d.FORWARD * self.total_speed * dt

    self.boost = math3d.lerp(0.5, self.boost, 0, dt)

    local sz = 0
    local sx = 0
    if self.input_key_left then
        sx = sx - 1
    end
    if self.input_key_right then
        sx = sx + 1
    end

    position = position + vmath.vector3(sx * 4 * dt, 0, 0)

    go.set_position(position)

    local rotation = go.get_rotation()
    local position = go.get_position()
    local velocity = (go.get_position() - self.last_position) / dt
    local local_velocity = vmath.rotate(math3d.quat_inv(rotation), velocity)
    -- self.total_speed = -local_velocity.z

    -- render3d.debug_log(string.format("%.02f kmh", -local_velocity.z * 3.6))

    self.last_position = position

    if self.keyboard_input then
        level_state.car_speed = self.total_speed
    end

    if not self.killed then
        self.dust_accum = self.dust_accum + dt
        local dust_dt = 0.5 / math.abs(self.total_speed)
        -- if self.keyboard_input then
        --     render3d.debug_log(string.format("DUST DT %.02f", dust_dt))
        -- end
        while self.dust_accum >= dust_dt do
            fx.road_dust(position + vmath.vector3(0, -0.5, 0))
            self.dust_accum = self.dust_accum - dust_dt
        end
    end
end

function M.on_message(self, message_id, message, sender)
    if message_id == hash("trigger_response") then
        -- pprint(message)
        if message.other_group == hash("storm_line") then
            if message.enter then
                -- if self.keyboard_input then
                --     return
                -- end
                if self.killed then
                    return
                end

                kill(self)

                if self.keyboard_input then
                    go.set("/main#orbit_follow", "follow_object_id", hash(""))
                end
            end
        elseif message.other_group == hash("box") then
            if message.enter then
                if not self.can_merge then
                    return
                end
                if self.killed then
                    return
                end
                local other_box_script = msg.url(nil, message.other_id, "box")
                -- local other_box_killed = go.get(other_box_script, "killed")
                -- if self.other_box_killed then
                --     return
                -- end
                local other_box_color = go.get(other_box_script, "box_color")
                if not v4_equals(self.box_color, other_box_color) then
                    self.boost = 0
                    self.velocity = go.get(other_box_script, "velocity")

                    return
                end

                msg.post(message.other_id, "merge")
                kill(self)

                msg.post("/objects/box_generator#box_generator", "merge", {
                    position1 = go.get_position(),
                    position2 = go.get_position(message.other_id),
                    box_color = other_box_color,
                    can_merge = self.can_merge,
                    keyboard_input = self.keyboard_input,
                    velocity = self.velocity,
                    boost = self.boost,
                })
            end
        end
    elseif message_id == hash("merge") then
        if self.killed then
            return
        end

        kill(self)
    end
end

function M.on_input(self, action_id, action)
    if not self.keyboard_input then
        return
    end

    -- if action_id == self.key_forward then
    --     self.input_key_forward = not action.released
    -- elseif action_id == self.key_backward then
    --     self.input_key_backward = not action.released
    -- end
    if action_id == self.key_left then
        self.input_key_left = not action.released
    elseif action_id == self.key_right then
        self.input_key_right = not action.released
    end
end

function M.on_reload(self)
end

return M
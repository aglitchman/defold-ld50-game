local M = {}

M.list = {}

function M.register(physics_id, visuals_id, car_main, car_color, car_collection)
    table.insert(M.list, {
        physics_id = physics_id,
        visuals_id = visuals_id,
        car_main = car_main,
        car_color = car_color,
        collection = car_collection
    })
end

function M.find_by_physics(physics_id)
    for i, v in ipairs(M.list) do
        if v.physics_id == physics_id then
            return v
        end
    end

    return nil
end

function M.unregister(physics_id)
    for i, v in ipairs(M.list) do
        if v.physics_id == physics_id then
            table.remove(M.list, i)
            break
        end
    end
end

function M.delete(physics_id)
    for i, v in ipairs(M.list) do
        if v.physics_id == physics_id then
            go.delete(v.collection)
            break
        end
    end
end

function M.spawn(collectionfactory_url, position, rotation, is_police)
    local car = collectionfactory.create(collectionfactory_url, position, rotation, nil)

    local car_main = msg.url(nil, car[hash("/main")], "car_main")
    local car_merge = msg.url(nil, car[hash("/physics")], "car_merge")

    go.set(car_main, "car_physics_id",        car[hash("/physics")])
    go.set(car_main, "car_physics_wheel1_id", car[hash("/physics_wheel_fl")])
    go.set(car_main, "car_physics_wheel2_id", car[hash("/physics_wheel_fr")])
    go.set(car_main, "car_physics_wheel3_id", car[hash("/physics_wheel_rl")])
    go.set(car_main, "car_physics_wheel4_id", car[hash("/physics_wheel_rr")])
    go.set(car_main, "car_visuals_id",        car[hash("/visuals")])
    go.set(car_main, "car_visuals_body_id",   car[hash("/visuals_body")])
    go.set(car_main, "car_visuals_wheel1_id", car[hash("/visuals_wheel_fl")])
    go.set(car_main, "car_visuals_wheel2_id", car[hash("/visuals_wheel_fr")])
    go.set(car_main, "car_visuals_wheel3_id", car[hash("/visuals_wheel_rl")])
    go.set(car_main, "car_visuals_wheel4_id", car[hash("/visuals_wheel_rr")])

    if is_police then
        go.set(car_main, "is_police", true)
        go.set(car_main, "car_visuals_siren_left_id", car[hash("/visuals_siren_left")])
        go.set(car_main, "car_visuals_siren_right_id", car[hash("/visuals_siren_right")])
    end
    go.set(car_main, "car_visuals_ftue_target_id", car[hash("/visuals_ftue_target")])

    go.set(car_merge, "car_main_script", car_main)

    local car_color = go.get(car_main, "getaway_car_color")
    M.register(car[hash("/physics")], car[hash("/visuals")], car_main, car_color, car)

    return car_main, car[hash("/visuals")]
end

return M
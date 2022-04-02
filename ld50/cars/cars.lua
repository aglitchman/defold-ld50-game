local M = {}

function M.spawn(collectionfactory_url, position, rotation)
    local car = collectionfactory.create(collectionfactory_url, position, rotation, nil)

    local car_main = msg.url(nil, car[hash("/main")], "car_main")
    local car_control = msg.url(nil, car[hash("/main")], "car_control")

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

    go.set(car_control, "my_car_obj_url",       msg.url(nil, car[hash("/visuals")], nil))
    go.set(car_control, "my_car_collision_url", msg.url(nil, car[hash("/physics")], hash("collision")))

    return car_main, car_control, car[hash("/visuals")]
end

return M
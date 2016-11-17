os.loadAPI("turtle2")
os.loadAPI("standard")

local args = { ... }

if table.getn(args) ~= 1 then
    error("mine only takes 1 argument")
end

local size = tonumber(args[1])

function has_fuel_to_dig()
    local fuel_needed = size + 2 + turtle2.fuel_needed_to_move_to(standard.zero_vector3())
    return turtle.getFuelLevel() > fuel_needed
end

function try_to_refuel()
    local old_selected = turtle.getSelectedSlot()

    for i = 1, 16 do
        turtle.select(i)
        turtle.refuel(turtle.getItemCount(i))
    end

    turtle.select(old_selected)
end

function return_and_desosit()
    turtle2.move_to(standard.zero_vector3())
    turtle2.face_north()
    turtle2.drop_all_items_forward()
end

function return_deposit_and_come_back()
    local fuel_needed_to_continue = turtle2.fuel_needed_to_move_to(standard.zero_vector3()) + size + 2
    local facing_direction = turtle2.get_facing_direction()
    local previous_position = turtle2.get_position()

    return_and_desosit()

    fuel_needed_to_continue = fuel_needed_to_continue + turtle2.fuel_needed_to_move_to(previous_position)
    if fuel_needed_to_continue > turtle.getFuelLevel() then
        error("I don't have enough fuel to continue D:")
    end

    turtle2.move_to(previous_position)
    turtle2.face(facing_direction)
end

function check_inventory()
    if turtle2.are_all_slots_occupied() then
        try_to_refuel()

        if turtle2.are_all_slots_occupied() then
            return true
        end
    end
    return false
end

function dig_and_check_inventory(direction)
    turtle2.dig(direction)
    if check_inventory() then
        return_and_desosit()
    end
end

function dig_up_and_check_inventory()
    dig_and_check_inventory(turtle2.get_directions().up)
end

function dig_up_and_check_inventory()
    dig_and_check_inventory(turtle2.get_directions().down)
end

function dig_move_and_check_inventory()
    while not turtle2.move_forward() do
        turtle2.dig_forward()
    end

    if check_inventory() then
        return_deposit_and_come_back()
    end
end

function move_forward_and_dig_out()
    dig_move_and_check_inventory()
    dig_up_and_check_inventory()
    dig_down_and_check_inventory()
end

function dig_tunnel_check_inventory()
    if not has_fuel_to_dig() then
        try_to_refuel()

        if not has_fuel_to_dig() then
            turtle2.move_to(standard.zero_vector3())
            turtle2.face_north()
            turtle2.drop_all_items_forward()
            error("I don't have enough fuel to continue D:")
        end
    end

    dig_up_and_check_inventory()
    dig_down_and_check_inventory()
    for i=1, size-1 do
        move_forward_and_dig_out()
    end
end

function main()
    local success, data = turtle.inspect()
    if data.name ~= "minecraft:chest" then
        error("the turtle has to be placed facing a chest before running 'excavate2'")
    end

    turtle2.face_south()

    local running = true
    local mining_west = true
    while running do
        for i=1, size-1 do
            dig_tunnel_check_inventory()

            local mining_south = turtle2.facing_south()

            if mining_west then
                turtle2.face_east()
            else
                turtle2.face_west()
            end
            
            move_forward_and_dig_out()

            if mining_south then
                turtle2.face_north()
            else
                turtle2.face_south()
            end
        end

        dig_tunnel_check_inventory()

        turtle2.turn_around()
        dig_down_and_check_inventory()
        running = turtle2.move_down()
        dig_down_and_check_inventory()
        turtle2.move_down()
        dig_down_and_check_inventory()
        turtle2.move_down()
        mining_west = not mining_west
    end

    return_and_desosit()
    print("Done :)")
end



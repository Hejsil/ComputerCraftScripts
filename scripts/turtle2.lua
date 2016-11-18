os.loadAPI("standard")

local cardinal_directions = {
    north = 1,
    east  = 2,
    south = 3,
    west  = 4
}

local directions = {
    left     = 1,
    right    = 2,
    up       = 3,
    down     = 4,
    forward  = 5,
    backward = 6
}

local turning_table = {{},{},{},{}}

turning_table[cardinal_directions.north][cardinal_directions.north] = { direction = directions.right, times = 0 }
turning_table[cardinal_directions.north][cardinal_directions.east]  = { direction = directions.right, times = 1 }
turning_table[cardinal_directions.north][cardinal_directions.south] = { direction = directions.right, times = 2 }
turning_table[cardinal_directions.north][cardinal_directions.west]  = { direction = directions.left,  times = 1 }

turning_table[cardinal_directions.east][cardinal_directions.north]  = { direction = directions.left,  times = 1 }
turning_table[cardinal_directions.east][cardinal_directions.east]   = { direction = directions.right, times = 0 }
turning_table[cardinal_directions.east][cardinal_directions.south]  = { direction = directions.right, times = 1 }
turning_table[cardinal_directions.east][cardinal_directions.west]   = { direction = directions.right, times = 2 }

turning_table[cardinal_directions.south][cardinal_directions.north] = { direction = directions.right, times = 2 }
turning_table[cardinal_directions.south][cardinal_directions.east]  = { direction = directions.left,  times = 1 }
turning_table[cardinal_directions.south][cardinal_directions.south] = { direction = directions.right, times = 0 } 
turning_table[cardinal_directions.south][cardinal_directions.west]  = { direction = directions.right, times = 1 }

turning_table[cardinal_directions.west][cardinal_directions.north]  = { direction = directions.right, times = 1 }
turning_table[cardinal_directions.west][cardinal_directions.east]   = { direction = directions.right, times = 2 }
turning_table[cardinal_directions.west][cardinal_directions.south]  = { direction = directions.left,  times = 1 }
turning_table[cardinal_directions.west][cardinal_directions.west]   = { direction = directions.right, times = 0 }

local turtle_info = {
    position = standard.zero_vector3(),
    facing_direction = cardinal_directions.north
}

function facing_north()
    return turtle_info.facing_direction == cardinal_directions.north
end

function facing_south()
    return turtle_info.facing_direction == cardinal_directions.south
end

function facing_east()
    return turtle_info.facing_direction == cardinal_directions.east
end

function facing_west()
    return turtle_info.facing_direction == cardinal_directions.west
end

function get_facing_direction()
    return turtle_info.facing_direction
end

function get_x()
    return turtle_info.position.x
end

function get_y()
    return turtle_info.position.y
end

function get_z()
    return turtle_info.position.z
end

function get_position()
    return standard.clone(turtle_info.position)
end

function get_turtle_info()
    return standard.clone(turtle_info)
end

function get_directions()
    return standard.clone(directions)
end

function get_cardinal_directions()
    return standard.clone(cardinal_directions) 
end

function dig(direction)
    if direction == directions.up then
        turtle.digUp()
    elseif direction == directions.down then
        turtle.digDown()
    elseif direction == directions.forward then
        turtle.dig()
    else
        error("wrong input to 'dig'")
    end
end

function dig_forward()
    dig(directions.forward)
end

function dig_up()
    dig(directions.up)
end

function dig_down()
    dig(directions.down)
end

function turn(direction) 
    if direction == directions.left then
        turtle.turnLeft()
        turtle_info.facing_direction = turtle_info.facing_direction - 1
    elseif direction == directions.right then
        turtle.turnRight()
        turtle_info.facing_direction = turtle_info.facing_direction + 1
    else   
        error("wrong input to 'turn'")
    end

    if turtle_info.facing_direction < 1 then
        turtle_info.facing_direction = 4
    elseif turtle_info.facing_direction > 4 then
        turtle_info.facing_direction = 1
    end
end

function turn_left()
    turn(directions.left) 
end

function turn_right()
    turn(directions.right) 
end

function turn_around()
    turn(directions.right) 
    turn(directions.right) 
end

function face(cardinal_direction)
    if cardinal_direction > 4 or cardinal_direction < 1 then
        error("wrong input to 'face'")
    end

    local turning_info = turning_table[turtle_info.facing_direction][cardinal_direction]

    for i=1, turning_info.times do
        turn(turning_info.direction)
    end
end

function face_north()
    face(cardinal_directions.north)
end

function face_south()
    face(cardinal_directions.south)
end

function face_east()
    face(cardinal_directions.east)
end

function face_west()
    face(cardinal_directions.west)
end

function move_forward()
    local res = turtle.forward()
    if res then
        if turtle_info.facing_direction == cardinal_directions.east then
            turtle_info.position.x = turtle_info.position.x + 1
        elseif turtle_info.facing_direction == cardinal_directions.west then
            turtle_info.position.x = turtle_info.position.x - 1
        elseif turtle_info.facing_direction == cardinal_directions.south then
            turtle_info.position.z = turtle_info.position.z + 1
        elseif turtle_info.facing_direction == cardinal_directions.north then
            turtle_info.position.z = turtle_info.position.z - 1
        end
    end

    return res
end

function move_back()
    local res = turtle.back()
    if res then
        if turtle_info.facing_direction == cardinal_directions.east then
            turtle_info.position.x = turtle_info.position.x - 1
        elseif turtle_info.facing_direction == cardinal_directions.west then
            turtle_info.position.x = turtle_info.position.x + 1
        elseif turtle_info.facing_direction == cardinal_directions.south then
            turtle_info.position.z = turtle_info.position.z - 1
        elseif turtle_info.facing_direction == cardinal_directions.north then
            turtle_info.position.z = turtle_info.position.z + 1
        end
    end

    return res
end

function move_up()
    local res = turtle.up()
    if res then
        turtle_info.position.y = turtle_info.position.y + 1
    end

    return res
end

function move_down()
    local res = turtle.down()
    if res then
        turtle_info.position.y = turtle_info.position.y - 1
    end

    return res
end

function are_all_slots_occupied()
    for i = 1, 16 do
        if turtle.getItemCount(i) == 0 then
            return false
        end
    end
    
    return true
end

function dig_tunnel(length)
    turtle.digUp()
    turtle.digDown()

    for i=1, length do
        while not move_forward() do
            turtle.dig()
        end

        turtle.digUp()
        turtle.digDown()
    end
end

function drop_all_items(direction)
    local old_selected = turtle.getSelectedSlot()

    for i = 1, 16 do
        turtle.select(i)

        if direction == directions.up then
            turtle.dropUp()
        elseif direction == directions.down then
            turtle.dropDown()
        elseif direction == directions.forward then
            turtle.drop()
        else
            error("wrong input to 'drop_all_items'")
        end
    end

    turtle.select(old_selected)
end

function drop_all_items_down()
    drop_all_items(directions.down)
end

function drop_all_items_up()
    drop_all_items(directions.up)
end

function drop_all_items_forward()
    drop_all_items(directions.forward)
end

function move_to_x(to_x)
    if turtle_info.position.x > to_x then
        face_west()
    elseif turtle_info.position.x < to_x then
        face_east()
    end

    while turtle_info.position.x ~= to_x do
        if not move_forward() then
            return false
        end
    end

    return true
end

function move_to_y(to_y)
    if turtle_info.position.y > to_y then
        while turtle_info.position.y ~= to_y do
            if not move_down() then
                return false
            end
        end
    elseif turtle_info.position.y < to_y then
        while turtle_info.position.y ~= to_y do
            if not move_up() then
                return false
            end
        end
    end

    return true
end

function move_to_z(to_z)
    if turtle_info.position.z > to_z then
        face_north()
    elseif turtle_info.position.z < to_z then
        face_south()
    end

    while turtle_info.position.z ~= to_z do
        if not move_forward() then
            return false
        end
    end

    return true
end

function move_to(position)
    local previous_position = get_position()

    while turtle_info.position.x ~= position.x or turtle_info.position.y ~= position.y or turtle_info.position.z ~= position.z do
        move_to_x(position.x)
        move_to_y(position.y)
        move_to_z(position.z)

        if previous_position.x == turtle_info.position.x and previous_position.y == turtle_info.position.y and previous_position.z == turtle_info.position.z then
            return false
        end

        previous_position = get_position()
    end 

    return true
end

function fuel_needed_to_move_to(position)
    return math.abs(turtle_info.position.x - position.x) + math.abs(turtle_info.position.y - position.y) + math.abs(turtle_info.position.z - position.z)
end



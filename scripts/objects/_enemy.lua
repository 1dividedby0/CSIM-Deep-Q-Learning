local csim_enemy = require "scripts.objects.csim_object"
local _vector = require "scripts.csim_vector"

function csim_enemy.enter_move_state(state, enemy)
end

function csim_enemy.exit_move_state(state, enemy)
end

function csim_enemy.update_move_state(dt, state, enemy)
    -- TODO: Move enemy to its current direction and flip it after 1 second
    local tile_x = math.floor(enemy.pos.x/16)+1
    local tile_y = math.floor(enemy.pos.y/16)+1

    if enemy.turns_in_direction >= 30 then
      enemy.direction = math.random(8)
      enemy.turns_in_direction = 0
    end
    enemy.turns_in_direction = enemy.turns_in_direction + 1
    if enemy.direction == 1 then
      -- right
      ok = true
      for i=tile_y-2,tile_y+2 do
        for j=tile_x-2, tile_x+2 do
    			if (i >= 1 and i <= #game_map and j >= 1 and j <= #game_map[i] and not game_map[i][j].isPath and game_map[i][j].x - enemy.pos.x <= 16 and game_map[i][j].x - enemy.pos.x >= 0 and math.abs(game_map[i][j].y - enemy.pos.y) <= 14) then
            enemy.direction = math.random(8)
            ok = false
          end
        end
      end
      if(ok) then
        enemy:getComponent("rigidbody"):applyForce(_vector:new(1, 0))
      end
    elseif enemy.direction == 2 then
      ok = true
      -- left
      for i=tile_y-2,tile_y+2 do
        for j=tile_x-2, tile_x+2 do
    			if (i >= 1 and i <= #game_map and j >= 1 and j <= #game_map[i] and not game_map[i][j].isPath and enemy.pos.x - game_map[i][j].x <= 16 and enemy.pos.x - game_map[i][j].x >= 0 and math.abs(game_map[i][j].y - enemy.pos.y) <= 14) then
            enemy.direction = math.random(8)
            ok = false
          end
  			end
  		end
  		if(ok) then
        enemy:getComponent("rigidbody"):applyForce(_vector:new(-1, 0))
      end
    elseif enemy.direction == 3 then
      -- down
      ok = true
      for i=tile_y-2,tile_y+2 do
        for j=tile_x-2, tile_x+2 do
    			if (i >= 1 and i <= #game_map and j >= 1 and j <= #game_map[i] and not game_map[i][j].isPath and game_map[i][j].y - enemy.pos.y <= 16 and game_map[i][j].y - enemy.pos.y >= 0 and math.abs(game_map[i][j].x - enemy.pos.x) <= 13) then
            enemy.direction = math.random(8)
            ok = false
          end
  			end
  		end
  		if(ok) then
        enemy:getComponent("rigidbody"):applyForce(_vector:new(0, 1))
      end
    elseif enemy.direction == 4 then
      -- up
      ok = true
      for i=tile_y-2,tile_y+2 do
        for j=tile_x-2, tile_x+2 do
    			if (i >= 1 and i <= #game_map and j >= 1 and j <= #game_map[i] and not game_map[i][j].isPath and enemy.pos.y - game_map[i][j].y <= 16 and enemy.pos.y - game_map[i][j].y >= 0 and math.abs(game_map[i][j].x - enemy.pos.x) <= 13) then
            enemy.direction = math.random(8)
            ok = false
          end
  			end
  		end
  		if(ok) then
        enemy:getComponent("rigidbody"):applyForce(_vector:new(0, -1))
      end
    elseif enemy.direction == 5 then
      -- up-right
      ok = true
      for i=tile_y-2,tile_y+2 do
        for j=tile_x-2, tile_x+2 do
    			if (i >= 1 and i <= #game_map and j >= 1 and j <= #game_map[i] and not game_map[i][j].isPath and enemy.pos.y - game_map[i][j].y <= 16 and enemy.pos.y - game_map[i][j].y >= 0 and math.abs(game_map[i][j].x - enemy.pos.x) <= 13) then
            ok = false
          end
  			end
  		end
      ok2 = true
      for i=tile_y-2,tile_y+2 do
        for j=tile_x-2, tile_x+2 do
    			if (i >= 1 and i <= #game_map and j >= 1 and j <= #game_map[i] and not game_map[i][j].isPath and game_map[i][j].x - enemy.pos.x <= 16 and game_map[i][j].x - enemy.pos.x >= 0 and math.abs(game_map[i][j].y - enemy.pos.y) <= 14) then
            ok2 = false
          end
        end
      end

      if(not ok and not ok2) then enemy.direction = math.random(8) end

  		if(ok and ok2) then
        enemy:getComponent("rigidbody"):applyForce(_vector:new(1, -1))
      end
    elseif enemy.direction == 6 then
      -- up-left
      ok = true
      for i=tile_y-2,tile_y+2 do
        for j=tile_x-2, tile_x+2 do
    			if (i >= 1 and i <= #game_map and j >= 1 and j <= #game_map[i] and not game_map[i][j].isPath and enemy.pos.y - game_map[i][j].y <= 16 and enemy.pos.y - game_map[i][j].y >= 0 and math.abs(game_map[i][j].x - enemy.pos.x) <= 13) then
            ok = false
          end
        end
      end
      ok2 = true
      for i=tile_y-2,tile_y+2 do
        for j=tile_x-2, tile_x+2 do
    			if (i >= 1 and i <= #game_map and j >= 1 and j <= #game_map[i] and not game_map[i][j].isPath and enemy.pos.x - game_map[i][j].x <= 16 and enemy.pos.x - game_map[i][j].x >= 0 and math.abs(game_map[i][j].y - enemy.pos.y) <= 14) then
            ok2 = false
          end
        end
      end

      if(not ok and not ok2) then enemy.direction = math.random(8) end

      if(ok and ok2) then
        enemy:getComponent("rigidbody"):applyForce(_vector:new(-1, -1))
      end
    elseif enemy.direction == 7 then
      -- down-right
      ok = true
      for i=tile_y-2,tile_y+2 do
        for j=tile_x-2, tile_x+2 do
    			if (i >= 1 and i <= #game_map and j >= 1 and j <= #game_map[i] and not game_map[i][j].isPath and game_map[i][j].y - enemy.pos.y <= 16 and game_map[i][j].y - enemy.pos.y >= 0 and math.abs(game_map[i][j].x - enemy.pos.x) <= 13) then
            ok = false
          end
        end
      end
      ok2 = true
      for i=tile_y-2,tile_y+2 do
        for j=tile_x-2, tile_x+2 do
    			if (i >= 1 and i <= #game_map and j >= 1 and j <= #game_map[i] and not game_map[i][j].isPath and game_map[i][j].x - enemy.pos.x <= 16 and game_map[i][j].x - enemy.pos.x >= 0 and math.abs(game_map[i][j].y - enemy.pos.y) <= 14) then
            ok2 = false
          end
        end
      end

      if(not ok and not ok2) then enemy.direction = math.random(8) end

      if(ok and ok2) then
        enemy:getComponent("rigidbody"):applyForce(_vector:new(1, 1))
      end
    elseif enemy.direction == 8 then
      -- down-left
      ok = true
      for i=tile_y-2,tile_y+2 do
        for j=tile_x-2, tile_x+2 do
    			if (i >= 1 and i <= #game_map and j >= 1 and j <= #game_map[i] and not game_map[i][j].isPath and game_map[i][j].y - enemy.pos.y <= 16 and game_map[i][j].y - enemy.pos.y >= 0 and math.abs(game_map[i][j].x - enemy.pos.x) <= 13) then
            ok = false
          end
        end
      end
      ok2 = true
      for i=tile_y-2,tile_y+2 do
        for j=tile_x-2, tile_x+2 do
    			if (i >= 1 and i <= #game_map and j >= 1 and j <= #game_map[i] and not game_map[i][j].isPath and enemy.pos.x - game_map[i][j].x <= 16 and enemy.pos.x - game_map[i][j].x >= 0 and math.abs(game_map[i][j].y - enemy.pos.y) <= 14) then
            ok2 = false
          end
        end
      end

      if(not ok and not ok2) then enemy.direction = math.random(8) end

      if(ok and ok2) then
        enemy:getComponent("rigidbody"):applyForce(_vector:new(-1, 1))
      end
    end
end

return csim_enemy

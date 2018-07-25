-- Loading external libraries
local sti = require "lib.sti"
local _math = require "scripts._math"
local _object = require "scripts.objects.csim_object"
local _vector = require "scripts.csim_vector"
local _rigidbody = require "scripts.components.csim_rigidbody"
local _fsm = require "scripts.components.csim_fsm"
local _inspect = require "scripts.inspect"
local _enemy = require "scripts.objects._enemy"
local _nnlearner = require "scripts.nnlearner"
local _animator = require "scripts.components.csim_animator"

require 'torch'

local _game = {}

function _game.load()
  step_size = 3

  wins = 0
  losses = 0
  total_coins_collected = 0
  current_action = 'up'

  -- Load player sprite
  sprite_sheet = love.graphics.newImage("sprites/PlayerAnimation.png")
  player_sprite = love.graphics.newImage("sprites/player_sprite.png")
  player = _object:new(0, 0, 0, player_sprite)
  player.dead = false

  agent = _nnlearner.create({"left", "right", "up", "down", "stay"}, {hiddenLayers=1})

  num_enemies = 0

  -- Create player rigid body
	local player_rigid_body = _rigidbody:new(player, 1)
	player:addComponent(player_rigid_body)

  -- Create player animator
  local player_animator = _animator:new(sprite_sheet, 16, 16)
  player_animator:addClip("move", {2, 3, 4, 5}, 3, true)
  player_animator:addClip("idle", {1}, 1, false)
  player:addComponent(player_animator)
  player:getComponent("animator"):play("idle")

	-- Load enemy sprites
  enemies = {}
  for i = 1, num_enemies do
    enemy = _object:new(0,0,0, love.graphics.newImage("sprites/enemy.png"))
    enemy.turns_in_direction = 0
    enemy.direction = math.random(8)

    local enemy_rigid_body = _rigidbody:new(enemy, 1)

    enemy:addComponent(enemy_rigid_body)

    local states = {}
		states["move"] = _fsm:newState("move", _enemy.update_move_state, _enemy.enter_move_state, _enemy.exit_move_state)
		local enemy_fsm = _fsm:new(states, "move")
		enemy:addComponent(enemy_fsm)

    table.insert(enemies, enemy)
  end

  _game.drawMap()

	-- Load step sound
	step_sfx = love.audio.newSource("sounds/sound.wav", "static")
	hit_sound = love.audio.newSource("sounds/sound.wav", "static")

  _game.printMap(game_map)
	-- Load map
	map = sti("map/map.lua")
end

function _game.printMap(mapToPrint)
  for i=1, 10 do
    local mapString = ""
    for j=1, 10 do
      if mapToPrint[i][j].isPath then
        mapString = mapString..", 0"
      end
      if not mapToPrint[i][j].isPath then
        mapString = mapString..", 1"
      end
    end
    print(mapString)
  end
end

-- Clears a random vertical path through the map of walls
function _game.clearPathVertical()
  local map = {}
  for i = 1, 10 do
    table.insert(map, {})
    for j = 1, 10 do
      local w = {}
      w.x = (j-1) * 16
      w.y = (i-1) * 16
      w.isPath = false
      table.insert(map[i], w)
    end
  end


  current_x = math.random(10)

  current_y = 1

  while current_y ~= 11 do
    map[current_x][current_y].isPath = true
    direction = math.random(3)

    -- left
    if(direction == 1 and current_x > 2) then
      current_x = current_x - 1

    -- right
    elseif (direction == 2 and current_x < 9) then
      current_x = current_x + 1

    -- forward
    elseif (direction == 3 and current_y < 11) then
      current_y = current_y + 1
    end
  end
  return map

end

function _game.clearPathHorizontal()
  local map = {}
  for i = 1, 10 do
    table.insert(map, {})
    for j = 1, 10 do
      local w = {}
      w.x = (j-1) * 16
      w.y = (i-1) * 16
      w.isPath = false
      table.insert(map[i], w)
    end
  end

  current_x = 1

  current_y = math.random(10)

  while current_x ~= 11 do
    map[current_x][current_y].isPath = true
    direction = math.random(3)

    -- up
    if(direction == 1 and current_y > 2) then
      current_y = current_y - 1

    -- down
    elseif (direction == 2 and current_y < 9) then
      current_y = current_y + 1

    -- right
    elseif (direction == 3 and current_x < 11) then
      current_x = current_x + 1
    end
  end
  return map

end

function _game.drawMap()
  -- Load a coin
	coins_amount = 3
	coins = {}

  game_map = _game.clearPathVertical()
  path = {}

  for i=2,#game_map-1 do
    for j=2, #game_map[i]-1 do
      if(game_map[i][j].isPath) then
        w = {}
        w.x = (j - 1) * 16
        w.y = (i - 1) * 16
        w.spr = love.graphics.newImage("map/wood.png")
        table.insert(path, w)
      end
    end
  end

  for i=2, #game_map-1 do
    for j=2, #game_map-1 do
      w = {}
      w.x = (j - 1) * 16
      w.y = (i - 1) * 16
      w.spr = love.graphics.newImage("map/wood.png")
      table.insert(path, w)
      game_map[i][j].isPath = true
    end
  end

  walls = {}
  for i=1, #game_map do
    for j=1, #game_map[i] do
      if not game_map[i][j].isPath then
        w = {}
        w.x = (j-1) * 16
        w.y = (i-1) * 16
        w.spr = love.graphics.newImage("map/wall.png")
        table.insert(walls, w)
      end
    end
  end

  for i=1, 10 do
    w = {}
    w.x = (i - 1) * 16
    w.y = 0
    w.spr = love.graphics.newImage("map/wall.png")
    game_map[1][i].isPath = false
    table.insert(walls, w)
  end

  for i=1, 10 do
    w = {}
    w.x = (i - 1) * 16
    w.y = 144
    w.spr = love.graphics.newImage("map/wall.png")
    game_map[10][i].isPath = false
    table.insert(walls, w)
  end

  for i=1, 10 do
    w = {}
    w.x = 144
    w.y = (i - 1) * 16
    w.spr = love.graphics.newImage("map/wall.png")
    game_map[i][10].isPath = false
    table.insert(walls, w)
  end

  for i=1, 10 do
    w = {}
    w.x = 0
    w.y = (i - 1) * 16
    w.spr = love.graphics.newImage("map/wall.png")
    game_map[i][1].isPath = false
    table.insert(walls, w)
  end

  player_pos = math.random(1, 10)
  player.pos.x = path[player_pos].x
  player.pos.y = path[player_pos].y

  for i=1, #enemies do
    p = path[math.random(10, #path-1)]
    enemies[i].pos.x = p.x
    enemies[i].pos.y = p.y
  end

  for i=1,coins_amount do
		c = {}
    p = path[math.random(10, #path-1)]
		c.x = p.x
		c.y = p.y
		c.spr = love.graphics.newImage("sprites/egg.png")
		table.insert(coins, c)
	end
end

function _game.observe()
  -- local observation_tensor_matrix = torch.zeros(10,10)
  --
  -- for i=1, #path do
  --   local path_tile_x = math.floor(path[i].x/16)+1
  --   local path_tile_y = math.floor(path[i].y/16)+1
  --
  --   observation_tensor_matrix[path_tile_y][path_tile_x] = 0
  -- end
  --
  -- for i=1, #walls do
  --   local wall_tile_x = math.floor(walls[i].x/16)+1
  --   local wall_tile_y = math.floor(walls[i].y/16)+1
  --
  --   observation_tensor_matrix[wall_tile_y][wall_tile_x] = 1
  -- end
  --
  -- for i=1, #enemies do
  --   local enemy_tile_x = math.floor(enemies[i].pos.x/16)+1
  --   local enemy_tile_y = math.floor(enemies[i].pos.y/16)+1
  --
  --   observation_tensor_matrix[enemy_tile_y][enemy_tile_x] = 3
  -- end
  --
  -- for i=1, #coins do
  --   local coin_tile_x = math.floor(coins[i].x/16)+1
  --   local coin_tile_y = math.floor(coins[i].y/16)+1
  --
  --   observation_tensor_matrix[coin_tile_y][coin_tile_x] = 4
  -- end
  --
  -- local player_tile_x = math.floor(player.pos.x/16)+1
  -- local player_tile_y = math.floor(player.pos.y/16)+1
  --
  -- observation_tensor_matrix[player_tile_y][player_tile_x] = 2

  local observation_tensor = torch.zeros(100)

  for i=1, #path do
    local path_tile_x = math.floor(path[i].x/16)+1
    local path_tile_y = math.floor(path[i].y/16)+1

    observation_tensor[((path_tile_y-1)*10) + path_tile_x] = 0
  end

  for i=1, #walls do
    local wall_tile_x = math.floor(walls[i].x/16)+1
    local wall_tile_y = math.floor(walls[i].y/16)+1

    observation_tensor[((wall_tile_y-1)*10) + wall_tile_x] = 1
  end

  local player_tile_x = math.floor(player.pos.x/16)+1
  local player_tile_y = math.floor(player.pos.y/16)+1

  observation_tensor[((player_tile_y-1)*10) + player_tile_x] = 2

  for i=1, #enemies do
    local enemy_tile_x = math.floor(enemies[i].pos.x/16)+1
    local enemy_tile_y = math.floor(enemies[i].pos.y/16)+1

    observation_tensor[((enemy_tile_y-1)*10) + enemy_tile_x] = 3
    print("Enemy: "..observation_tensor[((enemy_tile_y-1)*10) + enemy_tile_x])
  end

  for i=1, #coins do
    local coin_tile_x = math.floor(coins[i].x/16)+1
    local coin_tile_y = math.floor(coins[i].y/16)+1

    observation_tensor[((coin_tile_y-1)*10) + coin_tile_x] = 4
  end

  print("Map:")
  str = ""
  for i=1, 100 do
    str = str..", "..observation_tensor[i]
    -- if(i%10 == 0) then
    --   print(str)
    --   str = ""
    -- end
  end
  print(str)

  -- print("Map:")
  -- for i=1, 10 do
  --   str = ""
  --   for j=1, 10 do
  --     str = str..", "..observation_tensor_matrix[i][j]
  --   end
  --   print(str)
  -- end

  return observation_tensor
end

function _game.act(action)
  local ok = true

  local start_coins = #coins

  local tile_x = math.floor(player.pos.x/16)+1
  local tile_y = math.floor(player.pos.y/16)+1

  reward = 0
  -- left
	if (action == 'left') then
    for i=tile_y-2,tile_y+2 do
      for j=tile_x-2, tile_x+2 do
  			if (i >= 1 and i <= #game_map and j >= 1 and j <= #game_map[i] and not game_map[i][j].isPath and player.pos.x - game_map[i][j].x <= 16 and player.pos.x - game_map[i][j].x >= 0 and math.abs(game_map[i][j].y - player.pos.y) <= 14) then
  				ok = false
  			end
      end
		end
    if(not ok) then reward = reward - 0.3 end
		if(ok) then
      player:getComponent("rigidbody"):applyForce(_vector:new(-3,0))
			-- love.audio.play(step_sfx)
		end

  -- right
  elseif(action == 'right') then
		ok = true
    for i=tile_y-2,tile_y+2 do
      for j=tile_x-2, tile_x+2 do
  			if (i >= 1 and i <= #game_map and j >= 1 and j <= #game_map[i] and not game_map[i][j].isPath and game_map[i][j].x - player.pos.x <= 16 and game_map[i][j].x - player.pos.x >= 0 and math.abs(game_map[i][j].y - player.pos.y) <= 14) then
  				ok = false
  			end
      end
		end
    if(not ok) then reward = reward - 0.3 end
		if(ok) then
      player:getComponent("rigidbody"):applyForce(_vector:new(3,0))
			-- love.audio.play(step_sfx)
		end
	end

	-- Move on y axis
  -- up
	if (action == 'up') then
		ok = true
    for i=tile_y-2,tile_y+2 do
      for j=tile_x-2, tile_x+2 do
        if (i >= 1 and i <= #game_map and j >= 1 and j <= #game_map[i] and not game_map[i][j].isPath and player.pos.y - game_map[i][j].y <= 17 and player.pos.y - game_map[i][j].y >= 0 and math.abs(game_map[i][j].x - player.pos.x) <= 13) then
          ok = false
        end
      end
		end
    if(not ok) then reward = reward - 0.3 end
		if(ok) then
      player:getComponent("rigidbody"):applyForce(_vector:new(0,-3))
			-- love.audio.play(step_sfx)
		end

  -- down
  elseif(action == 'down') then
		ok = true
    for i=tile_y-2,tile_y+2 do
      for j=tile_x-2, tile_x+2 do
  			if (i >= 1 and i <= #game_map and j >= 1 and j <= #game_map[i] and not game_map[i][j].isPath and game_map[i][j].y - player.pos.y <= 17 and game_map[i][j].y - player.pos.y >= 0 and math.abs(game_map[i][j].x - player.pos.x) <= 13) then
  				ok = false
  			end
      end
		end
    if(not ok) then reward = reward - 0.3 end
		if(ok) then
      player:getComponent("rigidbody"):applyForce(_vector:new(0,3))
			-- love.audio.play(step_sfx)
		end
  else
    reward = reward - 0.2
  end

  for i = 1, #enemies do
    local enemy = enemies[i]
    if _math.distance(enemy.pos.x, enemy.pos.y, player.pos.x, player.pos.y) <= 13 then
      player.dead = true
    end
  end

  coins_won_this_round = 0

  for i=1,#coins do
    if (coins[i] ~= nil and _math.distance(coins[i].x, coins[i].y, player.pos.x, player.pos.y) <= 13) then
      table.remove(coins, i)
      total_coins_collected = total_coins_collected + 1
      coins_won_this_round = coins_won_this_round + 1
      love.audio.play(hit_sound)
    end
  end

  -- problem is that the reward is the same even if a coin is not collected
  reward = reward + coins_won_this_round * 1

  for j=1, #enemies do
    if(_math.distance(enemies[j].pos.x, enemies[j].pos.y, player.pos.x, player.pos.y) < 30) then
      reward = reward - 0.2
    end
  end

  for j=1, #coins do
    if(_math.distance(coins[j].x, coins[j].y, player.pos.x, player.pos.y) < 30) then
      reward = reward + 0.3
    end
  end

  local terminal = false
  if(player.dead) then
    reward = reward - 0.5
    losses = losses + 1
    terminal = true
  end

  if(#coins == 0) then terminal = true end

  if(reward == 0) then reward = -0.1 end

  print("Reward: "..reward)
  return reward, terminal
end

function _game.runAgent()
  local terminal = false

  local observation = _game.observe()
  local action = agent:act(observation)
  current_action = action
  print("Action: "..action)
  reward, terminal = _game.act(action)
  if(terminal) then
    local time_elapsed = os.clock() - agent.start_time
    file = io.open("runtimes.txt", "a")
    io.output(file)
    io.write(time_elapsed.."\n")
    io.close(file)
    agent.start_time = os.clock()
  end
  local new_observation = _game.observe()
  agent:store(observation, action, new_observation, reward, terminal)

  -- reset the accumulation of the gradients
  agent.mlp:zeroGradParameters()

  for i=1, math.min(60, #memory) do
    agent:learn()
  end
  -- update parameters into target network
  agent.mlp:updateParameters(agent.learningRate)
end

function _game.update(dt)
  _game.runAgent()

  if not player.dead then
    _camera.setPosition(player.pos.x - _game.game_width/2, player.pos.y - _game.game_height/2)
  end

  for i=1, #enemies do
    enemies[i]:update(dt)
  end

  if #coins == 0 then
    wins = wins + 1
    print("Congrats you finally won, Ishan!")
    _game.reset()
  end

end

function _game.reset()
  print("reset")
  -- if(explorationRate > 0) then
  --    explorationRate = explorationRate - 0.02
  -- end
  coins = {}
  for i=1,coins_amount do
    c = {}
    p = path[math.random(10, #path-1)]
    c.x = p.x
    c.y = p.y
    c.spr = love.graphics.newImage("sprites/egg.png")
    table.insert(coins, c)
  end

  enemies = {}
  for i = 1, num_enemies do
    enemy = _object:new(0,0,0, love.graphics.newImage("sprites/enemy.png"))
	  enemy.spr = love.graphics.newImage("sprites/enemy.png")
    enemy.turns_in_direction = 0
    enemy.direction = math.random(8)
    p = path[math.random(10, #path-1)]
    enemy.pos.x = p.x
    enemy.pos.y = p.y

    local enemy_rigid_body = _rigidbody:new(enemy, 1)

    enemy:addComponent(enemy_rigid_body)

    local states = {}
		states["move"] = _fsm:newState("move", _enemy.update_move_state, _enemy.enter_move_state, _enemy.exit_move_state)
		local enemy_fsm = _fsm:new(states, "move")
		enemy:addComponent(enemy_fsm)

    table.insert(enemies, enemy)
  end

  player_pos = math.random(1, #path)
  player.pos.x = path[player_pos].x
  player.pos.y = path[player_pos].y
  love.graphics.draw(player.spr, player.pos.x, player.pos.y)
  player.dead = false
end

function _game.draw()
  -- Draw map
	map:draw(-_camera.x, -_camera.y)

  for i=1,#path do
    love.graphics.draw(path[i].spr, path[i].x, path[i].y)
  end

  for i=1,#walls do
		love.graphics.draw(walls[i].spr, walls[i].x, walls[i].y)
	end

	-- Draw the player sprite
  if not player.dead then
    love.graphics.draw(player.spr, player.pos.x, player.pos.y)
  else
    _game.reset()
  end

	-- Draw the enemy sprites
  for i=1, #enemies do
	   love.graphics.draw(enemies[i].spr, enemies[i].pos.x, enemies[i].pos.y)
  end

	-- Draw coins
	for i=1,#coins do
		love.graphics.draw(coins[i].spr, coins[i].x, coins[i].y)
	end
end

return _game

-- Loading external libraries
math.randomseed(os.time())

local push = require "lib.push"

_game = require "scripts._game"
_debug = require "scripts._debug"
_camera = require "scripts.csim_camera"
_hud = require('scripts.csim_hud')

-- Setting values of global variables
_game.game_width = 260
_game.game_height = 260

local window_width, window_height, flags = love.window.getMode()

function love.keypressed(key, scancode, isrepeat)
	if (key == "-") then
		if (_debug.isShowing() == true) then
			_debug.hideConsole()
		else
			_debug.showConsole()
		end
	end

	if (key == "=") then
		if (_debug.isShowing() == true) then
			_debug.state = (_debug.state + 1) % 3
		end
	end
end

function love.load()
	-- Set love's default filter to "nearest-neighbor".
	love.graphics.setDefaultFilter('nearest', 'nearest')

	 -- Initialize retro text font
	font = love.graphics.newFont('fonts/font.ttf', 8)
	love.graphics.setFont(font)

	-- Initialize virtual resolution
	push:setupScreen(_game.game_width, _game.game_height, window_width, window_height, {fullscreen = false})

	_hud.init("fonts/font.ttf", 8)

	_debug.init(_game.game_width, _game.game_height, 30)

	_game.load()
end

function love.update(dt)
	if(_debug.state == 0) then
		_game.update(dt)
	elseif (_debug.state == 1) then
		if (love.keyboard.isDown("]")) then
			_game.update(dt)
			love.timer.sleep(0.5)
		end
	elseif (_debug.state == 2) then
		_game.update(dt)
		love.timer.sleep(0.1)
	end
end

function love.draw()
	push:start()

	_camera.start()

	_game.draw()

	_camera.finish()

	_hud.draw()

	_debug.draw()

	push:finish()
end

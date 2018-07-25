
local _debug = {}
debug_text = {}


function _debug.init(screen_width, screen_height, console_height)
    _debug.width = screen_width
    _debug.height = console_height
    _debug.x = 0
    _debug.y = screen_height - console_height
    _debug.show_console = false
    _debug.state = 0
    _debug.font = love.graphics.newFont('fonts/font.ttf', 4)
end

function _debug.showConsole()
    _debug.show_console = true
    _debug.state = 0
end

function _debug.hideConsole()
    _debug.show_console = false
    _debug.state = 0
end

function _debug.isShowing()
    return _debug.show_console
end

function _debug.rect(x1, y1, w, h)
  love.graphics.rectangle("fill", x1, y1, w, h)
end

function _debug.text(msg)
  table.insert(debug_text, msg)

end

function _debug.game_stats()
  love.graphics.printf("MEM: " .. love.graphics.getStats().texturememory, 0, 2, 50)
  love.graphics.printf("FPS: " .. love.timer.getFPS(), 55, 2, 40)
end

function _debug.draw()
    if (_debug.show_console == true) then
        -- Save graphics state
        r,g,b,a = love.graphics.getColor()
        prev_font = love.graphics.getFont()

        -- Draw grey console
        love.graphics.setColor(0.2, 0.2, 0.2)
        _debug.rect(_debug.x, _debug.y, _debug.width, _debug.height)

        -- Draw console label
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(_debug.font)
        _debug.text("Console")
        _debug.text("Dog")
        for i=1, #debug_text do
          love.graphics.printf(debug_text[#debug_text-i+1], _debug.x + 2, _debug.y + 2 + (5 * (i-1)), _debug.width)
        end
        -- Draw current mode
        local mode = ""
        if (_debug.state == 0) then
            mode = ""
        elseif (_debug.state == 1) then
            mode = "single step"
        elseif (_debug.state == 2) then
            mode = "slow motion"
        end

        love.graphics.printf(mode, _debug.width - 45, _debug.y, _debug.width)

        -- Draw game stats
        _debug.game_stats()

        -- Reset graphics state
        love.graphics.setColor(r,g,b,a)
        love.graphics.setFont(prev_font)
        debug_text = {}
    end
end

return _debug

--[[
    CSIM 2018
    Lecture 1

    -- Game Conf. --
    Author: Lucas N. Ferreira
    lferreira@ucsc.edu
]]

function love.conf(t)
    t.title = "DEEP Q"	        	-- The title of the window the game is in (string)
    t.author = "Dhruv N. Mangtani"	-- The author of the game (string)
    t.window.width = 350			-- The window width (number)
    t.window.height = 350			-- The window height (number)
    t.window.fullscreen = false		-- Enable fullscreen (boolean)
    t.window.vsync = 1			    -- Enable vertical sync (boolean)
end

local csim_hud = {}

function csim_hud.init(font_path, font_size)
  csim_hud.font = love.graphics.newFont(font_path, font_size)
end

function csim_hud.draw()
  love.graphics.setFont(csim_hud.font)
  love.graphics.print("Memories: "..#memory, 8, 165)
  love.graphics.print("Reward: "..reward, 8, 185)
  love.graphics.print("Coins: "..3 - #coins, 8, 205)
  love.graphics.print("Wins: "..wins, 8, 225)
  love.graphics.print("Losses: "..losses, 8, 245)
  love.graphics.print("Action: "..current_action, 125, 185)
  love.graphics.print("Epsilon: "..explorationRate, 125, 205)
  love.graphics.print("Total Coins: "..total_coins_collected, 125, 225)
end

return csim_hud

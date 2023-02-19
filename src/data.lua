local global_data_str --[[remove]]
--[[json global_data_str ../data.json]]

function reset()
  global_data_table = unpack_table(global_data_str)
  gradient = GradientSlider:new(
    Vec:new(global_data_table.tension_bar.position), 
    Vec:new(global_data_table.tension_bar.size), 
    global_data_table.tension_bar.gradient,
    unpack(global_data_table.tension_bar.settings)
  )
  stages = {
    [8] = "fail",
    [9] = "almost",
    [10] = "good",
    [11] = "perfect"
  }
  -- fish = Fish:new(unpack(global_data_table.fishes[1]))
end
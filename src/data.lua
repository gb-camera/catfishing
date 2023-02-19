local global_data_str --[[remove]]
--[[json global_data_str ../data.json]]

function reset()
  global_data_table = unpack_table(global_data_str)
  bar = ProgressBar:new(
    global_data_table.progressBar.fill_color, 
    global_data_table.progressBar.max_val, 
    global_data_table.progressBar.rect_data
  )
  fish = Fish:new(unpack(global_data_table.fishes[1]))
end
local global_data_str --[[remove]]
--[[json global_data_str ../data.json]]

function reset()
  global_data_table = unpack_table(global_data_str)
  fishing_area = FishingArea:new(0, Vec:new(8, 90))
end
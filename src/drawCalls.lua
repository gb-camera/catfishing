function draw_map()
  print_with_outline("placeholder :D", 5, 40, 7, 1)
  print_with_outline("area select [shop | fishing]", 5, 50, 7, 1)
  print_with_outline("press ❎ to select", 1, 114, 7, 1)
end

function draw_shop()
  print_with_outline("cash: "..cash, 1, 1, 7, 1)
  print_with_outline("not fully implemented :D", 5, 40, 7, 1)
  print_with_outline("only: sell fish, profit?", 5, 50, 7, 1)
  if get_active_menu() ~= nil then 
    print_with_outline("press ❎ to select", 1, 114, 7, 1)
  end
  print_with_outline("press 🅾️ to open option menu", 1, 120, 7, 1)
end

function draw_fishing()
  if get_active_menu() ~= nil then 
    print_with_outline("press ❎ to select", 1, 114, 7, 1)
  elseif not FishingArea.is_box_open(fishing_areas[loaded_area]) then
    print_with_outline("press ❎ to fish", 1, 114, 7, 1)
    print_with_outline("press 🅾️ to open option menu", 1, 120, 7, 1)
    print_with_outline("wip: imagine cat here", 5, 40, 7, 1)
  end
  FishingArea.draw(fishing_areas[loaded_area])
end
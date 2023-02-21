function draw_map()
  print_text_center("not implemented :D", 40, 7, 1)
  print_text_center("area select [shop | fishing area]", 50, 7, 1)
  print_with_outline("press ❎ to select", 1, 114, 7, 1)
end

function draw_shop()
  print_text_center("not implemented :D", 40, 7, 1)
  print_with_outline("buy bait, sell fish, profit?", 5, 50, 7, 1)
  if get_active_menu() ~= nil then 
    print_with_outline("press ❎ to select", 1, 114, 7, 1)
  end
  print_with_outline("press 🅾️ to open option menu", 1, 120, 7, 1)
end

function draw_fishing()
  if get_active_menu() ~= nil then 
    print_with_outline("press ❎ to select", 1, 114, 7, 1)
  else
    print_with_outline("press ❎ to fish", 1, 114, 7, 1)
    print_with_outline("press 🅾️ to open option menu", 1, 120, 7, 1)
  end
  FishingArea.draw(fishing_areas[loaded_area])
end
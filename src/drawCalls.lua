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
  elseif (fishing_areas[loaded_area].state ~= "detail") then
    print_with_outline("press ❎ to fish", 1, 114, 7, 1)
    print_with_outline("press 🅾️ to open option menu", 1, 120, 7, 1)
    print_with_outline("wip: imagine cat here", 5, 40, 7, 1)
  end
  FishingArea.draw(fishing_areas[loaded_area])
end

function draw_compendium(name)
  Inventory.draw(fishpedia)
  -- BorderRect.draw(compendium_rect)
  -- BorderRect.draw(compendium_sprite_rect)
  -- local fish_entry = get_array_entry(compendium, name)
  -- local sprite_pos = compendium_sprite_rect.position + Vec:new(4, 4)
  -- spr(
  --   fish_entry.sprite, 
  --   combine_and_unpack(
  --     {Vec.unpack(sprite_pos)},
  --     {2, 2}
  --   )
  -- )
  -- local detail_pos = compendium_sprite_rect.position.x + compendium_sprite_rect.size.x + 2
  -- print_with_outline(
  --   fish_entry.name, 
  --   detail_pos, compendium_sprite_rect.position.y,
  --   7, 0
  -- )
  -- print_with_outline(
  --   "weight: "..fish_entry.weight..fish_entry.units[2], 
  --   detail_pos, compendium_sprite_rect.position.y + 12,
  --   7, 0
  -- )
  -- print_with_outline(
  --   "size: "..fish_entry.size..fish_entry.units[1], 
  --   detail_pos, compendium_sprite_rect.position.y + 19,
  --   7, 0
  -- )
  -- local lines = split(pretty_print(
  --   fish_entry.description,
  --   compendium_rect.size.x - 8 
  -- ), "\n")
  -- local y_offset = compendium_sprite_rect.position.y + compendium_sprite_rect.size.y
  -- for i, line in pairs(lines) do 
  --   print_with_outline(
  --     line, 
  --     compendium_rect.position.x + 4,
  --     y_offset + (i-1) * 7,
  --     7, 0
  --   )
  -- end
end
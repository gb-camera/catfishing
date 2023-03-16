function draw_title()
  foreach(boid_array, Boid.draw)
  Animator.draw(cat, 64, 50)
end

function draw_credits()
  print_with_outline("credits", 47, credit_y_offsets[1], 7, 1)
  print_with_outline("project developers", 25, credit_y_offsets[2], 7, 1)
  print_with_outline("micheal:\n  • game director\n  • game designer", 10, credit_y_offsets[3], 7, 1)
  print_with_outline("jeren:\n  • programmer\n  • fish artist", 10, credit_y_offsets[4], 7, 1)
  print_with_outline("kaoushik:\n  • programmer\n  • rod artist", 10, credit_y_offsets[5], 7, 1)
  print_with_outline("nick:\n  • background artist", 10, credit_y_offsets[6], 7, 1)
  print_with_outline("siyuan:\n  • fish art designer", 10, credit_y_offsets[7], 7, 1)
  print_with_outline("alex:\n  • sound engineer", 10, credit_y_offsets[8], 7, 1)
  print_with_outline("katie:\n  • music engineer", 10, credit_y_offsets[9], 7, 1)
  print_with_outline("external developers", 25, credit_y_offsets[10], 7, 1)
  print_with_outline("jihem:\n  • created the rotation\n    sprite draw function", 10, credit_y_offsets[11], 7, 1)
end

function draw_map()
  print_with_outline("placeholder :D", 5, 40, 7, 1)
  print_with_outline("area select [shop | fishing]", 5, 50, 7, 1)
  print_with_outline("press ❎ to select", 1, 114, 7, 1)
end

function draw_shop()
  print_with_outline("cash: "..cash, 1, 1, 7, 1)
  spr(shopkeeper.sprite, 15, 50, 2, 2)
  if show_rod_shop then
    draw_rod_shop()
    if get_active_menu() ~= nil then
      get_active_menu().enable = false
    end
  end
  if get_active_menu() ~= nil then 
    print_with_outline("press ❎ to select", 1, 114, 7, 1)
  end
end

function draw_fishing()
  map(0, 0, 29, 24)
  Animator.draw(cat, 60, 55)
  
  local border_rect = BorderRect:new(
    Vec:new(4, 44),
    Vec:new(18,18),
    7, 14, 2)
  BorderRect.draw(border_rect)
    
  spr(current_rod.spriteID, 7, 46, 2, 2)

  if get_active_menu() ~= nil then 
    print_with_outline("press ❎ to select", 1, 114, 7, 1)
  elseif (fishing_areas[loaded_area].state ~= "detail") then
    print_with_outline("press ❎ to fish", 1, 114, 7, 1)
    print_with_outline("press 🅾️ to open option menu", 1, 120, 7, 1)
  end
  FishingArea.draw(fishing_areas[loaded_area])
end

function draw_compendium()
  if show_fish_details then 
    draw_fish_compendium_entry(fishpedia.data[fishpedia.pos])
  else
    Inventory.draw(fishpedia)
  end
end

function draw_fish_compendium_entry(fish_entry)
  BorderRect.draw(compendium_rect)
  BorderRect.draw(compendium_sprite_rect)
  local sprite_pos = compendium_sprite_rect.position + Vec:new(4, 4)
  spr(
    fish_entry.sprite_id, 
    combine_and_unpack(
      {Vec.unpack(sprite_pos)},
      {2, 2}
    )
  )
  local detail_pos = compendium_sprite_rect.position.x + compendium_sprite_rect.size.x + 2
  print_with_outline(
    fish_entry.name, 
    detail_pos, compendium_sprite_rect.position.y,
    7, 0
  )
  print_with_outline(
    "weight: "..fish_entry.data.weight..fish_entry.data.units[2], 
    detail_pos, compendium_sprite_rect.position.y + 12,
    7, 0
  )
  print_with_outline(
    "size: "..fish_entry.data.size..fish_entry.data.units[1], 
    detail_pos, compendium_sprite_rect.position.y + 19,
    7, 0
  )
  local stars = ""
  for i=1, fish_entry.data.rarity do 
    stars ..= "★"
  end
  local lines = split(pretty_print(
    fish_entry.data.description,
    compendium_rect.size.x - 8 
  ), "\n")
  local y_offset = compendium_sprite_rect.position.y + compendium_sprite_rect.size.y
  print_with_outline(
    stars,
    compendium_rect.position.x + 4,
    y_offset-8,
    10, 7
  )
  for i, line in pairs(lines) do 
    print_with_outline(
      line, 
      compendium_rect.position.x + 4,
      y_offset + (i-1) * 7,
      7, 0
    )
  end
end

function draw_rod_shop()
  Inventory.draw(rod_shop)
  rod_description(rod_shop.pos + 1)
end

function rod_description(pos, draw_pos)
  local rod = global_data_table.rods[pos]
  if(rod == nil) return
  description_pos = Vec:new(3, 75)
  local border_rect = BorderRect:new(
    description_pos,
    Vec:new(122, 50),
    7, 8, 2)
  BorderRect.draw(border_rect)
  print_with_outline(rod.name..": "..(Inventory.check_if_disabled(rod_shop) and "(owned)" or ""), description_pos.x + 2, description_pos.y + 2, 7, 0)

  local color = 3
  if Inventory.check_if_disabled(rod_shop) or rod.cost > cash then 
    color = 2
  end
  print_with_outline("cost: "..rod.cost, description_pos.x + 2, description_pos.y + 12, color, 0)
  
  print_with_outline("power: "..rod.power, description_pos.x + 80, description_pos.y + 12, 7, 0)
  print_with_outline(pretty_print(rod.description, 140), description_pos.x + 2, description_pos.y + 22, 7, 0)
end
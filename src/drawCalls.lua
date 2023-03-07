function draw_map()
  print_with_outline("placeholder :D", 5, 40, 7, 1)
  print_with_outline("area select [shop | fishing]", 5, 50, 7, 1)
  print_with_outline("press ❎ to select", 1, 114, 7, 1)
end

function draw_shop()
  print_with_outline("cash: "..cash, 1, 1, 7, 1)
  print_with_outline("not fully implemented :D", 5, 40, 7, 1)
  print_with_outline("only: sell fish, profit?", 5, 50, 7, 1)
  if show_rod_shop then
    printh("rod shop condition pass")
    draw_rod_shop()
    if get_active_menu() ~= nil then
      get_active_menu().enable = false
    end
  end
  if get_active_menu() ~= nil then 
    print_with_outline("press ❎ to select", 1, 114, 7, 1)
  end
  print_with_outline("press 🅾️ to open option menu", 1, 120, 7, 1)
end

function draw_fishing()
  map(0, 0, 29, 24)
  Animator.draw(cat, 60, 55)

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
    Vec:new(122, 35),
    7, 8, 2)
  BorderRect.draw(border_rect)
  print_with_outline(rod.name..":\n\n"..rod.description.."\n\ncost: "..rod.cost.."        power: "..rod.power,
  description_pos.x + 2, description_pos.y + 2, 7, 0)
end
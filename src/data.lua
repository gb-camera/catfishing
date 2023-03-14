local global_data_str --[[remove]]
--[[json global_data_str ../data.json]]

function reset()
  global_data_table = unpack_table(global_data_str)
  -- debug_printh_table(global_data_table, "")
  fish_inventory = {}
  current_rod = global_data_table.rods[1]
  rod_inventory = {current_rod}
  compendium_rect = BorderRect:new(
    Vec:new(8, 8), Vec:new(111, 111),
    7, 5, 3
  )
  compendium_sprite_rect = BorderRect:new(
    compendium_rect.position + Vec:new(5, 5),
    Vec:new(24, 24), 
    7, 0, 2
  )
  opened_fish_page = nil
  menus = {}
  for data in all(global_data_table.menu_data) do 
    add(menus, Menu:new(
      data.name,
      data.prev,
      Vec:new(data.position),
      parse_menu_content(data.content),
      data.hint,
      unpack(global_data_table.palettes.menu)
    ))
  end
  fishing_areas = {}
  for area in all(global_data_table.areas) do
    add(fishing_areas, FishingArea:new(area))
  end
  
  show_fish_details, fish_detail_flag = false
  show_rod_shop, show_rod_details, rod_detail_flag = false
  fishpedia = Inventory:new(34, 36, 
    Vec:new(5, 5), 30, 
    { Vec:new(8, 8), Vec:new(111, 111), 7, 5, 3 }
  )
  for i, area in pairs(global_data_table.areas) do 
    for j, fish in pairs(area.fishes) do 
      Inventory.add_entry(
        fishpedia, 
        j-1 + (i-1) * 5, 
        fish.stats[2], 
        fish.stats[1], 
        {
          description = fish.description,
          units = fish.units,
          rarity = fish.stats[5]
        }, 
        true
      )
    end
  end

  cat = Animator:new(global_data_table.animation_data.cat, true)

  shopkeeper = global_data_table.shopkeeper
  rod_shop = Inventory:new(34, 36,
      Vec:new(2, 2), 4, 
      { Vec:new(75, 11), Vec:new(45, 45), 5, 4, 3}, Vec:new(60,-4)
  )
  for i, rod in pairs(global_data_table.rods) do
    Inventory.add_entry(rod_shop, i-1, rod.spriteID, rod.cost, {}, false)
  end

  credit_y_offsets = {}
  for y in all(global_data_table.credit_offsets) do 
    add(credit_y_offsets, y)
  end

  cash = 5000
  loaded_area = -3
  get_menu("title").enable = true
end
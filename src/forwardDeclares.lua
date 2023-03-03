-- Menu Related
function get_active_menu()
  for menu in all(menus) do
    if (menu.enable) return menu
  end
end

function get_menu(name)
  for menu in all(menus) do
    if (menu.name == name) return menu
  end
end

function swap_menu_context(name)
  if (name == nil) return
  get_active_menu().enable = false
  get_menu(name).enable = true
end

function longest_menu_str(data)
  local len = 0
  for str in all(data) do
    len = max(len, #str.text)
  end
  return len
end

function load_area(area_id)
  get_active_menu().enable = false
  loaded_area = area_id 
  if (area_id > 0) FishingArea.reset(global_data_table.areas[loaded_area])
end

-- fishing
function sell_all_fish()
  for fish in all(inventory) do 
    local weight, size, rarity = unpack(fish)
    cash += 
      flr((weight * global_data_table.sell_weights.per_weight_unit + 
      size * global_data_table.sell_weights.per_size_unit) * rarity)
    del(inventory, fish)
  end
end
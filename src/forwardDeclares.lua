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
  get_active_menu().enable = false
  if (name == nil) return
  get_menu(name).enable = true
end

function longest_menu_str(data)
  local len = 0
  for str in all(data) do
    len = max(len, #str.text)
  end
  return len
end

-- fishing
function sell_all_fish()
  for fish in all(inventory) do 
    cash += 
      flr(fish.weight) * global_data_table.sell_weights.per_weight_unit + 
      flr(fish.size) * global_data_table.sell_weights.per_size_unit
    del(inventory, fish)
  end
end
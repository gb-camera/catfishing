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

-- fishing
function sell_all_fish()
  for fish in all(inventory) do 
    local weight, size = unpack(fish)
    printh(weight.." | "..size)
    cash += 
      flr(weight) * global_data_table.sell_weights.per_weight_unit + 
      flr(size) * global_data_table.sell_weights.per_size_unit
    del(inventory, fish)
  end
end

function display_all_fish()
  local fishes = {}
  for fish in all(compendium) do 
    add(fishes, {
      text=fish.name, color={7, 0},
      callback=function()
        get_active_menu().enable = false
        loaded_area = -2
        opened_fish_page = fish.name
      end
    }) 
  end
  return fishes
end
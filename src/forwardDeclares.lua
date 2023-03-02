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
    local weight, size, rarity = unpack(fish)
    cash += 
      flr((weight * global_data_table.sell_weights.per_weight_unit + 
      size * global_data_table.sell_weights.per_size_unit) * rarity)
    del(inventory, fish)
  end
end

function buy_rods_menu()
  local menu_list = {}
  for rod in all(global_data_table.rods) do
    local name = rod.name
    local power = rod.power
    local description = rod.description
    local cost = rod.cost
    local spriteID = rod.spriteID

    add(menu_list, {
      text = name,
      color = {7,0}
    })
  end
  return menu_list
end

function rod_description(pos, menu_pos)
  local rod = global_data_table.rods[pos]
  local description_box_height = 9*5
  local description_pos = menu_pos - Vec:new(0, description_box_height)
  local asdf = BorderRect:new(
    description_pos,
    Vec:new(100, 38),
    7, 8, 2)
  BorderRect.draw(asdf)
  print_with_outline(rod.name..":\n\n"..rod.description.."\n\ncost: "..rod.cost.."        power: "..rod.power,
  description_pos.x + 2, description_pos.y + 2, 7, 0)
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
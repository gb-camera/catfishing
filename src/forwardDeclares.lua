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

function load_area(area_id)
  get_active_menu().enable = false
  loaded_area = area_id 
  if (area_id > 0) FishingArea.reset(global_data_table.areas[loaded_area])
end

function load_area_state(name, id)
  if id == -3 then 
    reset()
  else
    swap_menu_context(name)
    if (loaded_area > 0) FishingArea.reset(global_data_table.areas[loaded_area])   
    loaded_area = id
  end
end

function parse_menu_content(data)
  if type(data) == "string" then
    return _ENV[data]()
  else
    local content = {}
    for dat in all(data) do 
      add(content, {
        text = dat.text,
        color = dat.color or {7, 0},
        callback = _ENV[dat.callback],
        args = dat.args
      })
    end
    return content
  end
end

-- fishing
function sell_all_fish()
  for fish in all(fish_inventory) do 
    local weight, size, rarity = unpack(fish)
    cash += 
      flr((weight * global_data_table.sell_weights.per_weight_unit + 
      size * global_data_table.sell_weights.per_size_unit) * rarity)
    del(fish_inventory, fish)
  end
end

function switch_rods_menu()
  local menu_list = {}
  for index, rod in pairs(rod_inventory) do
    printh("MENU::"..rod.name)
    add(menu_list, {
      text=rod.name.." (power "..rod.power..")",
      color={7,0},
      callback=select_rod,
      args={index}
    })
  end
  return menu_list
end

function select_rod(index)
  current_rod = rod_inventory[index]
  -- Add print statement / visual indicator that the rod was selected
  printh(current_rod.name.." was selected")
end

function enable_rod_shop()
  show_rod_shop = true
end

-- save/load
function save()
  -- start
  local address = 0x5e00
  -- cash
  address = save_byte2(address, cash)
  -- rod inventory
  address = save_byte(address, encode_rod_inventory())
end

function load()
  -- start
  local address = 0x5e00
  local cash, rods = 0, {}
  -- cash
  cash = %address
  address += 2
  -- rod inventory
  rods = decode_rod_inventory(@address)
  address += 1

  for rod in all(rods) do 
    add(rod_inventory, rod)
  end
  Menu.update_content(get_menu("switch_rods"), switch_rods_menu())

  load_area_state("main", -1)
end
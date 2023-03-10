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
end

function enable_rod_shop()
  show_rod_shop = true
end

-- save/load
function save_and_quit()
  save()
  load_area_state("title", -3)
end

function save()
  -- start
  local address = 0x5e00
  -- cash
  address = save_byte2(address, cash)
  -- rod inventory
  address = save_byte(address, encode_rod_inventory())
  -- selected rod
  for i, rod in pairs(rod_inventory) do 
    if rod.name == current_rod.name then 
      address = save_byte(address, i)
      break
    end
  end
  -- caught fishes
  local fishes = Inventory.get_data(fishpedia)
  address = save_byte(address, #fishes)
  for fish_data in all(fishes) do 
    -- id
    address = save_byte(address, fish_data.id)
    -- weight
    address = save_byte2(address, round_to(fish_data.data.weight * 100))
    -- size
    address = save_byte2(address, round_to(fish_data.data.size * 100))
  end
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
  -- selected rod
  local selected_rod_id = @address
  address += 1
  -- caught fishes
  local fish_count = @address
  address += 1
  for i=1, fish_count do 
    -- id
    local id = @address 
    address += 1
    -- weight
    local weight_ = %address
    address += 2
    -- size 
    local size_ = %address
    address += 2

    -- update game states
    local entry = Inventory.get_entry(fishpedia, id)
    entry.data = {
      description=entry.data.description,
      weight=weight_ / 100,
      size=size_ / 100,
      units=entry.data.units,
      rarity = entry.data.rarity
    }
    entry.is_hidden = false
  end

  -- update game states
  for rod in all(rods) do 
    add(rod_inventory, rod)
  end
  select_rod(selected_rod_id)
  Menu.update_content(get_menu("switch_rods"), switch_rods_menu())
  load_area_state("main", -1)
end
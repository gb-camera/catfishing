function title_loop()
  run(boid_array)
  Animator.update(cat)

  if btnp(❎) then
    Menu.invoke(get_active_menu())
  end
end

function credits_loop()
  if btnp(🅾️) then
    load_area_state("title", -3)
  end

  for i=1, #credit_y_offsets do 
    credit_y_offsets[i] -= 1
    if credit_y_offsets[i] <= -15 then 
      credit_y_offsets[i] = 320
    end
  end
end

function map_loop()
  if btnp(🅾️) then
    local menu = get_active_menu()
    if menu and menu.prev then 
      swap_menu_context(menu.prev)
    end
  end

  if btnp(❎) then
    Menu.invoke(get_active_menu())
  end
end

function shop_loop()
  local menu = get_active_menu()

  if show_rod_shop then
    rod_shop_loop()
  end

  if btnp(🅾️) then
    if show_rod_shop then
      show_rod_shop = false
      get_menu("shop").enable = true
    else 
      load_area_state("main", -1)
    end
  end

  if btnp(❎) and not show_rod_details then
    Menu.invoke(menu)
  end
end

function fish_loop()
  Animator.update(cat)

  if btnp(🅾️) then
    if (fishing_areas[loaded_area].state == "detail") return
    if get_active_menu() == nil then 
      get_menu("fishing").enable = true
    else
      swap_menu_context(get_active_menu().prev)
    end
  end
  
  if get_active_menu() == nil then
    FishingArea.update(fishing_areas[loaded_area])
  elseif btnp(❎) then
    Menu.invoke(get_active_menu())
  end
end

function compendium_loop()
  if btnp(🅾️) then
    if show_fish_details then 
      show_fish_details, fish_detail_flag = false
    else 
      loaded_area = -1
      get_menu("main").enable, fish_detail_flag = true
    end
    return
  end
  if not show_fish_details then
    if btnp(❎) and not Inventory.check_if_hidden(fishpedia) and fish_detail_flag then
      show_fish_details = true
      return
    end
    fish_detail_flag = true
    Inventory.update(fishpedia)
  end
end

function rod_shop_loop()
  if (show_rod_details) return

  if btnp(❎) and not Inventory.check_if_disabled(rod_shop) then
    local rod = global_data_table.rods[rod_shop.pos + 1]
    -- don't have enough cash
    if (rod.cost > cash) return
    -- buy the rod
    add(rod_inventory, rod)
    Inventory.get_entry(rod_shop, rod_shop.pos).is_disabled = true
    Menu.update_content(get_menu("switch_rods"), switch_rods_menu())
    cash -= rod.cost
    return
  end

  Inventory.update(rod_shop)
end
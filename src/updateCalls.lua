function shop_loop()
  if show_rod_shop then
    rod_shop_loop()
  end
  if btnp(🅾️) then
    if get_active_menu() == nil then 
      get_menu("shop").enable = true
    else
      swap_menu_context(get_active_menu().prev)
    end
  end
end

function fish_loop()
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
  printh("rod shop function called")
  if btnp(🅾️) then
    printh("recognized 🅾️ button press")
    show_rod_shop = false
    loaded_area = -1
    get_menu("main").enable = true
  end
  if not show_rod_details then
    printh("recognized ❎ button press")
    if btnp(❎) and not Inventory.check_if_hidden(rod_shop) then
      printh("bought rod")
      return
    end
    Inventory.update(rod_shop)
  end
end
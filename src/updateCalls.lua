function shop_loop()
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
      show_fish_details = false
      return 
    elseif loaded_area == -2 then 
      loaded_area = -1
      get_menu("main").enable = true
      return
    end
  end
  if not show_fish_details then
    if btnp(❎) and fishpedia.data[fishpedia.pos] then
      show_fish_details = true
      return
    end
    Inventory.update(fishpedia)
  end
end
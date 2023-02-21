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
  if get_active_menu() == nil then
    if fishing_areas[loaded_area].enable == false then
      fishing_areas[loaded_area].enable = true
    end
    FishingArea.update(fishing_areas[loaded_area])
  end

  if btnp(🅾️) then
    if (FishingArea.is_box_open(fishing_areas[loaded_area])) return
    if get_active_menu() == nil then 
      get_menu("fishing").enable = true
    else
      swap_menu_context(get_active_menu().prev)
    end
  end
end
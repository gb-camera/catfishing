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
  -- if btnp(🅾️) then
  --   get_menu("compendium").enable = true
  --   loaded_area = -1
  --   opened_fish_page = nil
  -- end
  Inventory.update(fishpedia)
end
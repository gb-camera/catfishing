-- [[Method Only Scripts At Bottom | Debugger Script At Bottom]]
#include src/forwardDeclares.lua
-- Data
#include src/data.lua
-- Classes
#include src/borderRect.lua
#include src/gradientSlider.lua
#include src/fish.lua
#include src/fishingArea.lua
#include src/vec.lua
#include src/menu.lua
#include src/animator.lua
#include src/inventory.lua
#include src/boids.lua

function _init()
  reset()
end

function _draw()
  cls()

  if loaded_area == -4 then 
    draw_credits()
  elseif loaded_area == -3 then 
    draw_title()
  elseif loaded_area == -2 then 
    draw_compendium()
  elseif loaded_area == -1 then 
    draw_map()
  elseif loaded_area == 0 then 
    draw_shop()
  elseif loaded_area > 0 then
    draw_fishing()
  end
  foreach(menus, Menu.draw)
end

function _update()
  foreach(menus, Menu.update)
  foreach(menus, Menu.move)

  if loaded_area == -4 then 
    credits_loop()
  elseif loaded_area == -3 then 
    title_loop()
  elseif loaded_area == -2 then 
    compendium_loop()
  elseif loaded_area == -1 then
    map_loop()
  elseif loaded_area == 0 then 
    get_menu("shop").enable = true
    shop_loop()
  elseif loaded_area > 0 then
    fish_loop()
  end
end

#include src/helpers.lua
#include src/serialization.lua
#include src/updateCalls.lua
#include src/drawCalls.lua
-- #include src/debug.lua

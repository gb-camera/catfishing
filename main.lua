-- [[Method Only Scripts At Bottom | Debugger Script At Bottom]]
-- Data
#include src/data.lua
-- Classes
#include src/borderRect.lua
#include src/gradientSlider.lua
#include src/fish.lua
#include src/fishingArea.lua
#include src/vec.lua

function _init()
  reset()
end

function _draw()
  cls()
  FishingArea.draw(fishing_area)
end

function _update()
  FishingArea.update(fishing_area)
end

#include src/helpers.lua
#include src/serialization.lua
-- #include src/debug.lua

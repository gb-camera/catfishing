-- [[Method Only Scripts At Bottom | Debugger Script At Bottom]]
-- Data
#include src/data.lua
-- Classes
#include src/borderRect.lua
#include src/progressBar.lua
#include src/fishing.lua

function _init()
  reset()
end

function _draw()
  cls()
  ProgressBar.draw(bar)
  if fish.state == "caught" then 
    print_with_outline("caught", unpack(global_data_table.text))
  elseif Fish.is_lost(fish) then 
    print_with_outline("lost", unpack(global_data_table.text))
  end
  if fish.state ~= "caught" then
    print_with_outline(Fish.progress(fish).."%", unpack(global_data_table.text))
    print_with_outline("state: "..fish.state, 5, 20, 7, 1)
  end
end

function _update()
  Fish.update(fish)
  ProgressBar.change_value(bar, fish.ticks)

  if btn(❎) then
    Fish.pull(fish)
  end
end

#include src/helpers.lua
#include src/serialization.lua
-- #include src/debug.lua
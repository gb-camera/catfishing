-- [[Method Only Scripts At Bottom | Debugger Script At Bottom]]
-- Data
#include src/data.lua
-- Classes
#include src/borderRect.lua
#include src/progressBar.lua
#include src/fishing.lua

function _init()
  table_data = unpack_table(global_data_str)
  bar = ProgressBar:new(
    table_data.progressBar.fill_color, 
    table_data.progressBar.max_val, 
    table_data.progressBar.rect_data
  )
  fish = Fish:new(unpack(table_data.fishes[1]))
end

function _draw()
  cls()
  ProgressBar.draw(bar)
  if fish.state == "caught" then 
    print_with_outline("caught", unpack(table_data.text))
  elseif Fish.is_lost(fish) then 
    print_with_outline("lost", unpack(table_data.text))
  end
  if fish.state ~= "caught" then
    print_with_outline(Fish.progress(fish).."%", unpack(table_data.text))
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
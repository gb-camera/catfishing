-- [[Method Only Scripts At Bottom | Debugger Script At Bottom]]
-- Classes
#include lua_src/progressBar.lua
#include lua_src/fishing.lua

function _init()
  table_str = "fishes={{foo,0,1,2,50,100,100}},progressBar={2,200,{5,5,50,5,8,6,2}},text={60,5,7,1}"
  table_data = unpack_table(table_str)
  debug_print_table(table_data, "")
  printh("------fish[1] --------")
  debug_print_table(table_data.fishes[1], "")
  printh("------progress bar--------")
  debug_print_table(table_data.progressBar, "")
  printh("------text--------")
  debug_print_table(table_data.text, "")
  bar = ProgressBar:new(unpack(table_data.progressBar))
  fish = Fish:new(unpack(table_data.fishes[1]))
end

function _draw()
  cls()
  ProgressBar.draw(bar)
  if Fish.is_caught(fish) then 
    print_with_outline("caught", unpack(table_data.text))
  elseif Fish.is_lost(fish) then 
    print_with_outline("lost", unpack(table_data.text))
  end
  print_with_outline(Fish.progress(fish).."%", unpack(table_data.text))
  print_with_outline("state: "..fish.state, 5, 20, 7, 1)
end

function _update()
  Fish.update(fish)
  ProgressBar.change_value(bar, fish.ticks)

  if btn(❎) then
    Fish.pull(fish)
  end
end

#include lua_src/helpers.lua
#include lua_src/debug.lua
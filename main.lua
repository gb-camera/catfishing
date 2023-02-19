-- [[Method Only Scripts At Bottom | Debugger Script At Bottom]]
-- Data
#include src/data.lua
-- Classes
#include src/borderRect.lua
#include src/gradientSlider.lua
#include src/fishing.lua
#include src/vec.lua

function _init()
  reset()
  tapped_stage = 0
end

function _draw()
  cls()
  GradientSlider.draw(gradient)
  if tapped_stage > 0 then 
    local color = gradient.colors[tapped_stage]
    local text = stages[color]
    rectfill(8, 20, #text*5+8, 30, 1)
    print_with_outline(text, 12, 23, color, 1)
  end
  for i, text in pairs(stages) do
    print_with_outline(text, 12, 35 + (i*7), i, 1)
  end
end

function _update()
  GradientSlider.update(gradient)
  if btn(❎) then
    tapped_stage = GradientSlider.get_stage(gradient)
  end
end

#include src/helpers.lua
#include src/serialization.lua
-- #include src/debug.lua
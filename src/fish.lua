Fish = {}
function Fish:new(fishID_, fish_name, spriteID, weight, fish_size, units_, gradient)
  local string_len = longest_string({
    "name: "..fish_name,
    "weight: "..weight..units_[2],
    "size: "..fish_size..units_[1]
  })*5-5
  local box_size = Vec:new(string_len, 32)
  local gauge_data = global_data_table.gauge_data
  obj = {
    name=fish_name,
    sprite = spriteID,
    lb = weight,
    size = fish_size,
    fishID = fishID_,
    units = units_,
    -- Internal
    tension_slider = GradientSlider:new(
      Vec:new(gauge_data.position), Vec:new(gauge_data.size), 
      gradient, unpack(gauge_data.settings)
    ),
    description_box = BorderRect:new(
      Vec:new((128-box_size.x-6) \ 2, 90), box_size, 
      7, 1, 3
    )
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Fish:update()
  GradientSlider.update(self.tension_slider)
end
function Fish:draw_tension()
  GradientSlider.draw(self.tension_slider)
end
function Fish:draw_details()
  line(62, 0, 62, 48, 7)
  draw_sprite_rotated(self.sprite, Vec:new(55, 48), 16, 90)
  local text = "name: "..self.name.."\n\nweight: "..self.lb..self.units[2].."\nsize: "..self.size..self.units[1]
  BorderRect.draw(self.description_box)
  print_with_outline(text, self.description_box.position.x + 5, 95, 7, 0)
end
function Fish:draw_lost()
  local name = "the fish got away"
  BorderRect.draw(self.description_box)
  print_with_outline(name, 20, 95, 7, 0)
end
function Fish:catch()
  return table_contains(
    global_data_table.fishes[self.fishID].successIDs, 
    self.tension_slider.colors[GradientSlider.get_stage(self.tension_slider)]
  )
end

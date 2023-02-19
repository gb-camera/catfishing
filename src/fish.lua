Fish = {}
function Fish:new(fishID_, position_, fish_name, spriteID, weight, fish_size)
  obj = {
    name=fish_name,
    sprite = spriteID,
    lb = weight,
    size = fish_size,
    fishID = fishID_,
    position = position_,
    -- Internal
    tension_slider = GradientSlider:new(
      Vec:new(global_data_table.gauge_data.position), 
      Vec:new(global_data_table.gauge_data.size), 
      global_data_table.fishes[fishID_].gradient,
      unpack(global_data_table.gauge_data.settings)
    ),
    description_box = BorderRect:new(position_, Vec:new(#("name: "..fish_name)*5, 30), 7, 1, 3),
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
  local text = "name: "..self.name.."\n\nweight: "..self.lb.."\nsize: "..self.size
  BorderRect.draw(self.description_box)
  print_with_outline(text, 20, 95, 7, 0)
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

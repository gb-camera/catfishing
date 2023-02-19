FishingArea = {}
function FishingArea:new(mapID_)
  obj = {
    mapID = mapID_,
    -- internal
    power_gauge = GradientSlider:new(
      Vec:new(global_data_table.gauge_data.position), 
      Vec:new(global_data_table.gauge_data.size), 
      global_data_table.power_gauge_colors,
      unpack(global_data_table.gauge_data.settings)
    ),
    state = "none",
    fish = nil
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function FishingArea:draw()
  if self.state == "none" then 
    print_text_center("press ❎ to cast line", 60, 7, 1)
  elseif self.state == "casting" then 
    GradientSlider.draw(self.power_gauge)
  elseif self.state == "fishing" then 
    Fish.draw_tension(self.fish)
  elseif self.state == "detail" then 
    Fish.draw_details(self.fish)
  elseif self.state == "lost" then 
    Fish.draw_lost(self.fish)
  end
end
function FishingArea:update()
  if btnp(❎) then
    if self.state == "none" then 
      self.state = "casting"
    elseif self.state == "casting" then 
      local fishID = flr(rnd(#global_data_table.fishes))+1
      local fish = global_data_table.fishes[fishID]
      local name, spriteID, weight, size = unpack(fish.stats)
      size = generate_stat_with_bias(size, global_data_table.biases.size)
      weight *= size * 0.3 * global_data_table.biases.weight
      weight = round_to(weight, 2)
      self.fish = Fish:new(fishID, name, spriteID, weight, size)
      GradientSlider.reset(self.power_gauge)
      self.state = "fishing"
    elseif self.state == "fishing" then 
      if Fish.catch(self.fish) then 
        self.state = "detail"
      else
        self.state = "lost"
      end
      GradientSlider.reset(self.fish.tension_slider)
    elseif self.state == "detail" then 
      self.fish = nil
      self.state = "none"
      -- reward
    elseif self.state == "lost" then 
      self.fish = nil
      self.state = "none"
    end
  end
  
  if self.state == "none" then 
  elseif self.state == "casting" then 
    GradientSlider.update(self.power_gauge)
  elseif self.state == "fishing" then 
    Fish.update(self.fish)
  end
end

function generate_stat_with_bias(stat, bias)
  local val = mid(stat + rnd(bias) - (bias/2), 0.1, stat + bias)
  return round_to(val, 2)
end
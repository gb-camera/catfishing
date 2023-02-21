FishingArea = {}
function FishingArea:new(area_data_)
  local lost_text_len = #"the fish got away"*5-5
  obj = {
    area_data = area_data_,
    -- internal
    power_gauge = GradientSlider:new(
      Vec:new(global_data_table.gauge_data.position), 
      Vec:new(global_data_table.gauge_data.size), 
      global_data_table.power_gauge_colors,
      unpack(global_data_table.gauge_data.settings)
    ),
    lost_box = BorderRect:new(
      Vec:new((128-lost_text_len-6)\2, 48),
      Vec:new(lost_text_len, 16),
      7, 1, 3
    ),
    state = "none",
    fish = nil
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function FishingArea:draw()
  if self.state == "casting" then 
    GradientSlider.draw(self.power_gauge)
  elseif self.state == "fishing" then 
    Fish.draw_tension(self.fish)
  elseif self.state == "detail" then 
    Fish.draw_details(self.fish)
  elseif self.state == "lost" then 
    FishingArea.draw_lost(self)
  end
end
function FishingArea:draw_lost()
  BorderRect.draw(self.lost_box)
  print_with_outline(
    "the fish got away", 
    self.lost_box.position.x + 5, self.lost_box.position.y+6, 7, 0
  )
end
function FishingArea:update()
  if btnp(❎) then
    if self.state == "none" then 
      self.state = "casting"
    elseif self.state == "casting" then 
      self.fish = generate_fish(self.area_data, GradientSlider.get_stage(self.power_gauge))
      GradientSlider.reset(self.power_gauge)
      if self.fish == nil then 
        self.state = "lost"
      else
        self.state = "fishing"
      end
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
  
  if self.state == "casting" then 
    GradientSlider.update(self.power_gauge)
  elseif self.state == "fishing" then 
    Fish.update(self.fish)
  end
end

function generate_fish(area, stage)
  local possible_fishes = {}
  local stage_gauge = stage -- + bait bonus
  for fish in all(area.fishes) do
    if stage_gauge <= fish.max_gauge_requirement and stage_gauge >= fish.min_gauge_requirement then 
      add(possible_fishes, fish)
    end
  end
  if (#possible_fishes == 0) return nil
  local fish =possible_fishes[flr(rnd(#possible_fishes))+1]
  local name, spriteID, weight, size = unpack(fish.stats)
  size, weight = generate_weight_size_with_bias(weight, size)
  return Fish:new(
    name, spriteID, weight, size, fish.units, fish.gradient, fish.successIDs
  )
end

-- formula in desmos [https://www.desmos.com/calculator/glmnwyjhkl]
-- size influences weight but not the other way around
function generate_weight_size_with_bias(weight, size)
  local bias = global_data_table.biases.size
  local new_size = round_to(mid(size + rnd(bias) - (bias/2), 0.1, size + bias), 2)
  local new_weight = round_to(weight * new_size * 0.3 * global_data_table.biases.weight, 2)
  return new_size, new_weight
end
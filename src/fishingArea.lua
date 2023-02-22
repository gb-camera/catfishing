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
      Vec:new(lost_text_len, 24),
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
    "the fish got away\n\npress ❎ to close", 
    self.lost_box.position.x + 5, self.lost_box.position.y+6, 7, 0
  )
end
function FishingArea:update()
  if not self.flag then 
    self.flag = true
    self.started = false
    return 
  end

  if btnp(❎) and self.state ~= "casting" then
    if self.state == "none" then 
      self.started = true
      self.state = "casting"
    elseif self.state == "lost" then 
      FishingArea.reset(self)
    elseif self.state == "detail" then 
      add(inventory, {self.fish.lb, self.fish.size})
      local entry = get_array_entry(compendium, self.fish.name)
      if entry == nil then 
        add(compendium, {
          name=self.fish.name,
          description=self.fish.description,
          sprite=self.fish.sprite,
          weight=self.fish.lb,
          size=self.fish.size,
          units=self.fish.units
        })
      else 
        update_compendium_entry(self.fish.name, self.fish.lb, self.fish.size)
      end
      FishingArea.reset(self)
    end
  end

  if btn(❎) then 
    if self.state == "casting" and self.started then
      GradientSlider.update(self.power_gauge)
    elseif self.state == "fishing" then 
      self.started = true
      Fish.update(self.fish)
      if self.fish.timer <= 0 then 
        self.state = "lost"
      end
    end
  else
    if self.state == "fishing" and self.started then
      GradientSlider.reduce(self.fish.tension_slider)
    elseif self.state == "casting" then 
      self.state = "fishing"
      self.started = false
      self.fish = generate_fish(
        self.area_data, 
        GradientSlider.get_stage(self.power_gauge)
      )
      if (self.fish == nil) self.state = "lost" 
      GradientSlider.reset(self.power_gauge)
    end
  end

  if self.state == "fishing" and self.fish.ticks >= global_data_table.gauge_data.req_tension_ticks then 
    self.state = "detail" 
    GradientSlider.reset(self.fish.tension_slider)
  end
end
function FishingArea:reset()
  self.started = false
  self.fish = nil 
  self.state = "none"
  self.flag = false
end

function generate_fish(area, stage)
  local possible_fishes = {}
  local stage_gauge = stage -- + rod bonus
  for fish in all(area.fishes) do
    if stage_gauge >= fish.min_gauge_requirement and stage_gauge < fish.max_gauge_requirement then 
      add(possible_fishes, fish)
    end
  end
  if (#possible_fishes == 0) return nil
  local fish =possible_fishes[flr(rnd(#possible_fishes))+1]
  local name, spriteID, weight, size = unpack(fish.stats)
  size, weight = generate_weight_size_with_bias(weight, size)
  return Fish:new(
    name, fish.description, spriteID, weight, size, fish.units, fish.gradient, fish.successIDs
  )
end

-- formula in desmos [https://www.desmos.com/calculator/glmnwyjhkl]
-- size influences weight but not the other way around
function generate_weight_size_with_bias(weight, size)
  local bias = global_data_table.biases.size
  local new_size = round_to(mid(size + rnd(bias) - bias/2, 0.1, size + bias), 2)
  local new_weight = round_to(weight * new_size * 0.3 * global_data_table.biases.weight, 2)
  return new_size, new_weight
end
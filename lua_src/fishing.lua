Fish = {}
function Fish:new(
  fish_name, spriteID, weight, fish_size,
  bite_ticks, fight_ticks, success_limit)
  obj = {
    fish_name,
    sprite = spriteID,
    lb = weight,
    size = fish_size,
    ticks = bite_ticks,
    fight_max_ticks = fight_ticks,
    success_ceil = success_limit + fight_ticks,
    state = "lure"
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Fish:update()
  if (Fish.is_lost(self) or Fish.is_caught(self)) return
  self.ticks -= 1
end
function Fish:is_lost()
  return self.ticks <= 0
end
function Fish:is_caught()
  return self.ticks >= self.success_ceil
end
function Fish:progress()
  if (self.state ~= "fight") return 0
  return (self.ticks) / self.success_ceil
end
function Fish:pull()
  if self.state == "lure" then 
    self.state = "fight"
    self.ticks = self.fight_max_ticks
  elseif self.state == "fight" then 
    self.ticks += 2
  end
end


Inventory = {}
function Inventory:new(selector_spr_id, unknown_spr_id, size_, max_entries, border_rect_data, offset_)
  obj = {
    selector_id = selector_spr_id,
    unknown_id = unknown_spr_id,
    size = size_,
    entry_amount = max_entries,
    rect = BorderRect:new(unpack(border_rect_data)),
    -- internals
    data = {},
    spacing = 4,
    pos = 0,
    min_pos = 0,
    max_pos = size_.x*size_.y,
    grid_size = size_.x*size_.y,
    offset = offset_ or Vec:new(-4,-4),
    disabled_icon = 198
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Inventory:draw(asdf)
  BorderRect.draw(self.rect)
  for y=1, self.size.y do
    for x=1, self.size.x do
      local position = Vec:new(x*16+self.spacing*x, y*16+self.spacing*y) + self.offset
      local index = self.min_pos + (x-1) + (y-1)*self.size.x
      local entry = self.data[index]
      if entry == nil or entry.is_hidden then 
        entry = self.unknown_id
      else
        entry = entry.sprite_id
      end
      rectfill(position.x-1, position.y-1, position.x + 16, position.y + 16, 0)
      spr(entry, position.x, position.y, 2, 2)
      if self.data[index] and self.data[index].is_disabled then 
        spr(self.disabled_icon, position.x, position.y, 2, 2)
      end
    end
  end
  local pos_offset = self.pos - self.min_pos
  local x = pos_offset%self.size.x
  local y = pos_offset\self.size.x
  local pos = Vec:new(x*16+self.spacing*x, y*16+self.spacing*y)+Vec:new(20, 20)+self.offset
  spr(self.selector_id, pos.x, pos.y, 2, 2)
end
function Inventory:update()
  local dx, dy = controls()
  self.pos += dx
  self.pos += dy*self.size.x
  if self.pos >= self.entry_amount then
    self.pos -= self.entry_amount
    self.min_pos = 0
    self.max_pos = self.grid_size
  elseif self.pos < 0 then 
    self.pos += self.entry_amount
    self.min_pos = self.entry_amount-self.grid_size
    self.max_pos = self.entry_amount
  else
    if self.pos >= self.max_pos then 
      self.min_pos += self.size.x
      self.max_pos += self.size.x
    elseif self.pos <= self.min_pos then
      self.min_pos -= self.size.x
      self.max_pos -= self.size.x
    end
    self.max_pos = mid(self.max_pos, self.grid_size, self.entry_amount)
    self.min_pos = mid(self.min_pos, 0, self.entry_amount-self.grid_size)
  end
end
function Inventory:add_entry(index, sprite, name_, extra_data, hidden)
  self.data[index] = {is_hidden=hidden, is_disabled=false, sprite_id = sprite, name = name_, data = extra_data}
end
function Inventory:get_entry(name)
  if type(name) == "string" then 
    for i=0, #self.data do 
      if (self.data[i].name == name) return self.data[i]
    end
  else
    return self.data[name]
  end
end
function Inventory:get_data()
  local data = {}
  for i=0, #self.data do 
    local entry = self.data[i]
    if entry and not entry.is_hidden then 
      add(data, {
        id = i,
        data = entry.data
      })
    end
  end
  return data
end
function Inventory:check_if_disabled()
  return self.data[self.pos].is_disabled
end
function Inventory:check_if_hidden()
  local entry = self.data[self.pos]
  return entry == nil or entry.is_hidden
end
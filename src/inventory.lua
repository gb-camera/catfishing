Inventory = {}
function Inventory:new(selector_spr_id, unknown_spr_id, size_, max_entries, border_rect_data)
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
    grid_size = size_.x*size_.y
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Inventory:draw()
  BorderRect.draw(self.rect)
  for y=1, self.size.y do
    for x=1, self.size.x do
      local position = Vec:new(x*16+self.spacing*x, y*16+self.spacing*y) - Vec:new(4, 4)
      local index = self.min_pos + (x-1) + (y-1)*self.size.x
      local sprite = self.data[index]
      if sprite == nil or sprite.is_hidden then 
        sprite = self.unknown_id
      else
        sprite = sprite.sprite_id
      end
      rectfill(position.x, position.y, position.x + 15, position.y + 15, 0)
      spr(sprite, position.x, position.y, 2, 2)
    end
  end
  local pos_offset = self.pos - self.min_pos
  local x = pos_offset%self.size.x
  local y = pos_offset\self.size.x
  local pos = Vec:new(x*16+self.spacing*x, y*16+self.spacing*y)+Vec:new(16, 16)
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
function Inventory:add_entry(index, sprite, name_, extra_data)
  self.data[index] = {is_hidden=true, sprite_id = sprite, name = name_, data = extra_data}
end
function Inventory:get_entry(name)
  for data in all(self.data) do 
    if (data.name == name) return data
  end
end
function Inventory:check_if_hidden()
  local entry = self.data[self.pos]
  return entry == nil or entry.is_hidden
end
-- Classes
#include borderRect.lua

ProgressBar = {}
function ProgressBar:new(fill_color, max_val, rect_data)
  obj = {
    val = 0,
    max_value = max_val,
    color = fill_color,
    rect = BorderRect:new(unpack(rect_data))
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function ProgressBar:draw()
  BorderRect.draw(self.rect)
  if (self.val == 0) return
  rectfill(self.rect.x, self.rect.y, self.rect.x+self.val, self.rect.h, self.color)
end
function ProgressBar:change_value(value)
  self.val = mid(value / self.max_value, 0, 1) * (self.rect.w - self.rect.x)
end
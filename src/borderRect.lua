BorderRect = {}
function BorderRect:new(dx, dy, dw, dh, border_color, background_color, thickness_size)
  obj = {
    x = dx, y = dy, w = dx + dw, h = dy + dh,
    border = border_color, background = background_color,
    thickness = thickness_size
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function BorderRect:draw()
  rectfill(
    self.x-self.thickness, self.y-self.thickness, 
    self.w+self.thickness, self.h+self.thickness, self.border)
  rectfill(self.x, self.y, self.w, self.h, self.background)
end

pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
global_data_str="palettes={transparent_color_id=0},fishes={{placeholder name,0,1,2,50,100,100}},text={60,5,7,1},tension_bar={position={10,10},size={100,5},gradient={8,9,10,11,11,11,10,9,8},settings={4,7,2,3}}"
function reset()
  global_data_table = unpack_table(global_data_str)
  gradient = GradientSlider:new(
    Vec:new(global_data_table.tension_bar.position), 
    Vec:new(global_data_table.tension_bar.size), 
    global_data_table.tension_bar.gradient,
    unpack(global_data_table.tension_bar.settings)
  )
  stages = {
    [8] = "fail",
    [9] = "almost",
    [10] = "good",
    [11] = "perfect"
  }
end
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
GradientSlider = {}
function GradientSlider:new(
  position_, size_, gradient_colors, handle_color, outline_color, thickness_, speed_)
  obj = {
    position=position_, 
    size=size_, 
    colors=gradient_colors,
    handle=handle_color,
    outline=outline_color,
    thickness=thickness_,
    speed=speed_,
    handle_size=Vec:new(3, size_.y+4),
    pos=0,
    dir=1
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function GradientSlider:draw()
  local rect_size = self.position + self.size
  rectfill(
    self.position.x-self.thickness, self.position.y-self.thickness, 
    rect_size.x+self.thickness, rect_size.y+self.thickness, 
    self.outline
  )
  for y=0, self.size.y do
    for x=0, self.size.x do
      local pixel_coord = Vec:new(x, y) + self.position 
      pset(pixel_coord.x, pixel_coord.y, self.colors[GradientSlider.get_stage(self, x)])
    end
  end
  local handle_pos = self.position + Vec:new(self.pos, -2)
  local handle_size = handle_pos + self.handle_size
  rectfill(
    handle_pos.x-self.thickness, handle_pos.y-self.thickness,
    handle_size.x+self.thickness, handle_size.y+self.thickness,
    self.outline
  )
  rectfill(
    handle_pos.x, handle_pos.y,
    handle_size.x, handle_size.y,
    self.handle
  )
end
function GradientSlider:update()
  self.pos += self.dir * self.speed
  if self.pos >= self.size.x or self.pos <= 0 then 
    self.dir *= -1
  end
end
function GradientSlider:get_stage(x)
  local p = x or self.pos
  local rate = flr((p / self.size.x) * 100)
  local range = self.size.x \ #self.colors
  return mid(rate \ range + 1, 1, #self.colors)
end
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
  if (Fish.is_lost(self) or self.state == "caught") return
  self.ticks -= 1
end
function Fish:is_lost()
  return self.ticks <= 0
end
function Fish:progress()
  if (self.state ~= "fight") return 0
  return flr(self.ticks / self.success_ceil * 100)
end
function Fish:pull()
  if self.state == "lure" then 
    self.state = "fight"
    self.ticks = self.fight_max_ticks
  elseif self.state == "fight" and Fish.progress(self) <= 100 then 
    self.ticks += 2
    if self.ticks >= self.success_ceil then 
      self.state = "caught"
    end
  end
end
Vec = {}
function Vec:new(dx, dy)
  local obj = nil
  if type(dx) == "table" then 
    obj = {x=dx[1],y=dx[2]}
  else
    obj={x=dx,y=dy}
  end
  setmetatable(obj, self)
  self.__index = self
  self.__add = function(a, b)
    return Vec:new(a.x+b.x,a.y+b.y)
  end
  self.__sub = function(a, b)
    return Vec:new(a.x-b.x,a.y-b.y)
  end
  self.__mul = function(a, scalar)
    return Vec:new(a.x*scalar,a.y*scalar)
  end
  self.__div = function(a, scalar)
    return Vec:new(a.x/scalar,a.y/scalar)
  end
  self.__eq = function(a, b)
    return (a.x==b.x and a.y==b.y)
  end
  self.__tostring = function(vec)
    return "("..vec.x..", "..vec.y..")"
  end
  self.__concat = function(vec, other)
    return (type(vec) == "table") and Vec.__tostring(vec)..other or vec..Vec.__tostring(other)
  end
  return obj
end
function Vec:unpack()
  return self.x, self.y
end
function Vec:clamp(min, max)
  self.x, self.y = mid(self.x, min, max), mid(self.y, min, max)
end
function normalize(val)
  return (type(val) == "table") and Vec:new(normalize(val.x), normalize(val.y)) or flr(mid(val, -1, 1))
end
function lerp(start, last, rate)
  if type(start) == "table" then 
    return Vec:new(lerp(start.x, last.x, rate), lerp(start.y, last.y, rate))
  else
    return start + (last - start) * rate
  end
end
function _init()
  reset()
  tapped_stage = 0
end
function _draw()
  cls()
  GradientSlider.draw(gradient)
  if tapped_stage > 0 then 
    local color = gradient.colors[tapped_stage]
    local text = stages[color]
    rectfill(8, 20, #text*5+8, 30, 1)
    print_with_outline(text, 12, 23, color, 1)
  end
  for i, text in pairs(stages) do
    print_with_outline(text, 12, 35 + (i*7), i, 1)
  end
end
function _update()
  GradientSlider.update(gradient)
  if btn(❎) then
    tapped_stage = GradientSlider.get_stage(gradient)
  end
end
function print_with_outline(text, dx, dy, text_color, outline_color)
  ?text,dx-1,dy,outline_color
  ?text,dx+1,dy
  ?text,dx,dy-1
  ?text,dx,dy+1
  ?text,dx,dy,text_color
end
function controls()
  if btnp(⬆️) then return 0, -1
  elseif btnp(⬇️) then return 0, 1
  elseif btnp(⬅️) then return -1, 0
  elseif btnp(➡️) then return 1, 0
  end
  return 0, 0
end
function draw_sprite_rotated(sprite_id, position, size, theta, is_opaque)
  local sx, sy = (sprite_id % 16) * 8, (sprite_id \ 16) * 8 
  local sine, cosine = sin(theta / 360), cos(theta / 360)
  local shift = size\2 - 0.5
  for mx=0, size-1 do 
    for my=0, size-1 do 
      local dx, dy = mx-shift, my-shift
      local xx = flr(dx*cosine-dy*sine+shift)
      local yy = flr(dx*sine+dy*cosine+shift)
      if xx >= 0 and xx < size and yy >= 0 and yy <= size then
        local id = sget(sx+xx, sy+yy)
        if id ~= global_data_table.palettes.transparent_color_id or is_opaque then 
          pset(position.x+mx, position.y+my, id)
        end
      end
    end
  end
end
function unpack_table(str)
  local table,start,stack,i={},1,0,1
  while i <= #str do
    if str[i]=="{" then 
      stack+=1
    elseif str[i]=="}"then 
      stack-=1
      if(stack>0)goto unpack_table_continue
      insert_key_val(sub(str,start,i), table)
      start=i+1
      if(i+2>#str)goto unpack_table_continue
      start+=1
      i+=1
    elseif stack==0 then
      if str[i]=="," then
        insert_key_val(sub(str,start,i-1), table)
        start=i+1
      elseif i==#str then 
        insert_key_val(sub(str, start), table)
      end
    end
    ::unpack_table_continue::
    i+=1
  end
  return table
end
function insert_key_val(str, table)
  local key, val = split_key_value_str(str)
  if key == nil then
    add(table, val)
  else  
    local value
    if val[1] == "{" and val[-1] == "}" then 
      value = unpack_table(sub(val, 2, #val-1))
    elseif val == "True" then 
      value = true 
    elseif val == "False" then 
      value = false 
    else
      value = tonum(val) or val
    end
    table[key] = value
  end
end
function convert_to_array_or_table(str)
  local internal = sub(str, 2, #str-1)
  if (str_contains_char(internal, "{")) return unpack_table(internal) 
  if (not str_contains_char(internal, "=")) return split(internal, ",", true) 
  return unpack_table(internal)
end
function split_key_value_str(str)
  local parts = split(str, "=")
  local key = tonum(parts[1]) or parts[1]
  if str[1] == "{" and str[-1] == "}" then 
    return nil, convert_to_array_or_table(str)
  end
  local val = sub(str, #(tostr(key))+2)
  if val[1] == "{" and val[-1] == "}" then 
    return key, convert_to_array_or_table(val)
  end
  return key, val
end
function str_contains_char(str, char)
  for i=1, #str do
    if (str[i] == char) return true
  end
end
__gfx__
11221122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11221122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22112211000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22112211000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11221122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11221122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22112211000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22112211000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

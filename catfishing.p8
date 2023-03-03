pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
function get_active_menu()
  for menu in all(menus) do
    if (menu.enable) return menu
  end
end
function get_menu(name)
  for menu in all(menus) do
    if (menu.name == name) return menu
  end
end
function swap_menu_context(name)
  if (name == nil) return
  get_active_menu().enable = false
  get_menu(name).enable = true
end
function longest_menu_str(data)
  local len = 0
  for str in all(data) do
    len = max(len, #str.text)
  end
  return len
end
function sell_all_fish()
  for fish in all(inventory) do 
    local weight, size, rarity = unpack(fish)
    cash += 
      flr((weight * global_data_table.sell_weights.per_weight_unit + 
      size * global_data_table.sell_weights.per_size_unit) * rarity)
    del(inventory, fish)
  end
end
global_data_str="palettes={transparent_color_id=0,menu={4,7,7,3}},text={60,5,7,1},gauge_data={position={10,10},size={100,5},settings={4,7,2,3},req_tension_ticks=20,tension_timer=30},power_gauge_colors={8,9,10,11,3},biases={weight=8,size=3},sell_weights={per_weight_unit=3,per_size_unit=2},animation_data={menu_selector={data={{sprite=32,offset={0,0}},{sprite=32,offset={-1,0}},{sprite=32,offset={-2,0}},{sprite=32,offset={-3,0}},{sprite=32,offset={-2,0}},{sprite=32,offset={-1,0}}},ticks_per_frame=3},up_arrow={data={{sprite=33,offset={0,0}},{sprite=33,offset={0,-1}},{sprite=33,offset={0,-2}},{sprite=33,offset={0,-1}}},ticks_per_frame=3},down_arrow={data={{sprite=49,offset={0,0}},{sprite=49,offset={0,1}},{sprite=49,offset={0,2}},{sprite=49,offset={0,1}}},ticks_per_frame=3}},areas={{name=home,mapID=0,music={},fishes={{gradient={8,9,10,11,11,11,10,9,8},successIDs={11},min_gauge_requirement=1,max_gauge_requirement=3,stats={goldfish,2,2.7,12.5,1},units={cm,g},description=now what's a goldfish doing here},{gradient={8,9,10,11,10,9,8},successIDs={11},min_gauge_requirement=4,max_gauge_requirement=inf,stats={yellow fin tuna,4,32,2.25,4},units={m,kg},description=yummy},{gradient={8,9,10,10,10,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=3,max_gauge_requirement=5,stats={pufferfish,6,0.08,60,3},units={cm,kg},description=doesn't it look so cuddley? you should hug it!},{gradient={8,9,10,11,11,11,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={triggerfish,8,0.04,71,2},units={cm,kg},description=hol up is that a gun?!?!}}}}"
function reset()
  global_data_table = unpack_table(global_data_str)
  inventory = {}
  compendium_rect = BorderRect:new(
    Vec:new(8, 8), Vec:new(111, 111),
    7, 5, 3
  )
  compendium_sprite_rect = BorderRect:new(
    compendium_rect.position + Vec:new(5, 5),
    Vec:new(24, 24), 
    7, 0, 2
  )
  opened_fish_page = nil
  local menu_palette = global_data_table.palettes.menu
  menu_data = {
    {
      "main", nil,
      5, 70,
      {
        {
          text="shop", color={7, 0},
          callback=function()
            get_active_menu().enable = false
            loaded_area = 0
          end
        },
        { 
          text="fishing", color={7, 0}, 
          callback=function()
            get_active_menu().enable = false
            loaded_area = 1 --temp
            FishingArea.reset(global_data_table.areas[loaded_area])
          end
        },
        {
          text="compendium", color={7, 0},
          callback=function()
            get_active_menu().enable = false
            loaded_area = -2
          end
        }
      },
      nil,
      unpack(menu_palette)
    },
    {
      "fishing", nil,
      5, 70,
      {
        {
          text="return to map", color={7, 0},
          callback=function()
            swap_menu_context("main")
            FishingArea.reset(global_data_table.areas[loaded_area])      
            loaded_area = -1
          end
        }
      },
      nil,
      unpack(menu_palette)
    },
    {
      "shop", nil,
      5, 70,
      {
        {
          text="return to map", color={7, 0},
          callback=function()
            swap_menu_context("main")
            loaded_area = -1
          end
        },
        { text="sell all fish", color={7, 0}, callback=sell_all_fish }
      },
      nil,
      unpack(menu_palette)
    }
  }
  menus = {}
  for data in all(menu_data) do 
    add(menus, Menu:new(unpack(data)))
  end
  fishing_areas = {}
  for area in all(global_data_table.areas) do
    add(fishing_areas, FishingArea:new(area))
  end
  
  show_fish_details, fish_detail_flag = false
  fishpedia = Inventory:new(34, 36, 
    Vec:new(5, 5), 30, 
    { Vec:new(8, 8), Vec:new(111, 111), 7, 5, 3 }
  )
  for i, area in pairs(global_data_table.areas) do 
    for j, fish in pairs(area.fishes) do 
      Inventory.add_entry(fishpedia, j-1 + (i-1) * 5, fish.stats[2], fish.stats[1], {})
    end
  end
  cash = 0
  loaded_area = -1
  get_menu("main").enable = true
end
BorderRect = {}
function BorderRect:new(position_, size_, border_color, base_color, thickness_size)
  obj = {
    position = position_, 
    size = position_ + size_,
    border = border_color, 
    base = base_color,
    thickness = thickness_size
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function BorderRect:draw()
  rectfill(
    self.position.x-self.thickness, self.position.y-self.thickness, 
    self.size.x+self.thickness, self.size.y+self.thickness, 
    self.border
  )
  rectfill(self.position.x, self.position.y, self.size.x, self.size.y, self.base)
end
function BorderRect:resize(position_, size_)
  if (self.position ~= position_) self.position = position_
  if (self.size ~= size_ + position_) self.size = size_ + position_ 
end
function BorderRect:reposition(position_)
  if (self.position == position_) return
  local size = self.size - self.position
  self.position = position_
  self.size = self.position + size
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
  self.pos = mid(self.pos + self.speed, 0, self.size.x)
end
function GradientSlider:reduce()
  self.pos = mid(self.pos - self.speed, 0, self.size.x)
end
function GradientSlider:get_stage(x)
  local p = x or self.pos
  local rate = flr((p / self.size.x) * 100)
  local range = self.size.x \ #self.colors
  return mid(rate \ range + 1, 1, #self.colors)
end
function GradientSlider:reset()
  self.pos = 0
  self.dir = 1
end
Fish = {}
function Fish:new(fish_name, description_, spriteID, weight, fish_size, fish_rarity, units_, gradient, successIDs)
  local star_string = fish_rarity .. "★"
  local string_len = longest_string({
    "name: "..fish_name.." "..star_string,
    "weight: "..weight..units_[2],
    "size: "..fish_size..units_[1],
    "press ❎ to close"
  })*5-5
  local box_size = Vec:new(string_len, 40)
  local gauge_data = global_data_table.gauge_data
  obj = {
    name=fish_name,
    sprite = spriteID,
    lb = weight,
    size = fish_size,
    rarity = fish_rarity,
    units = units_,
    description=description_,
    success_stage_ids = successIDs,
    tension_slider = GradientSlider:new(
      Vec:new(gauge_data.position), Vec:new(gauge_data.size), 
      gradient, unpack(gauge_data.settings)
    ),
    description_box = BorderRect:new(
      Vec:new((128-box_size.x-6) \ 2, 80), box_size, 
      7, 1, 3
    ),
    ticks = 0,
    timer = global_data_table.gauge_data.tension_timer
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Fish:update()
  if (self.ticks >= global_data_table.gauge_data.req_tension_ticks) return
  if Fish.catch(self) then
    self.ticks += 1
    self.timer = min(self.timer+1, global_data_table.gauge_data.tension_timer)
  else
    self.timer = max(self.timer-1, 0)
  end
  GradientSlider.update(self.tension_slider)
end
function Fish:draw_tension()
  local thickness = self.tension_slider.thickness
  local pos = self.tension_slider.position-Vec:new(thickness, 0)
  local size = self.tension_slider.size
  local y = pos.y+size.y+thickness+1
  line(pos.x, y, pos.x + (self.ticks/global_data_table.gauge_data.req_tension_ticks)*size.x+thickness, y, 11)
  line(pos.x, y+1, pos.x + (self.timer/global_data_table.gauge_data.tension_timer)*size.x+thickness, y+1, 8)
  GradientSlider.draw(self.tension_slider)
end
function Fish:draw_details()
  line(62, 0, 62, 48, 7)
  draw_sprite_rotated(self.sprite, Vec:new(55, 48), 16, 90)
  BorderRect.draw(self.description_box)
  local star_string = self.rarity .. "★"
  print_with_outline(
    "name: "..self.name.." "..star_string.."\n\nrweight: "..self.lb..self.units[2].."\nsize: "..self.size..self.units[1].."\n\npress ❎ to close", 
    self.description_box.position.x + 5, self.description_box.position.y + 4, 7, 0
  )
end
function Fish:catch()
  return table_contains(
    self.success_stage_ids, 
    self.tension_slider.colors[GradientSlider.get_stage(self.tension_slider)]
  )
end
FishingArea = {}
function FishingArea:new(area_data_)
  local lost_text_len = #"the fish got away"*5-5
  obj = {
    area_data = area_data_,
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
      add(inventory, {self.fish.lb, self.fish.size, self.fish.rarity})
      local entry = Inventory.get_entry(fishpedia, self.fish.name)
      entry.data = {
        description=self.fish.description,
        weight=max(entry.data.weight, self.fish.lb),
        size=max(entry.data.weight, self.fish.size),
        units=self.fish.units,
        rarity = max(entry.data.rarity, self.fish.rarity)
      }
      entry.is_hidden = false
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
  local fish = possible_fishes[flr(rnd(#possible_fishes))+1]
  local name, spriteID, weight, size, rarity = unpack(fish.stats)
  size, weight = generate_weight_size_with_bias(weight, size)
  return Fish:new(
    name, fish.description, spriteID, weight, size, rarity, fish.units, fish.gradient, fish.successIDs
  )
end
function generate_weight_size_with_bias(weight, size)
  local bias = global_data_table.biases.size
  local new_size = round_to(mid(size + rnd(bias) - bias/2, 0.1, size + bias), 2)
  local new_weight = round_to(weight * new_size * 0.3 * global_data_table.biases.weight, 2)
  return new_size, new_weight
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
Menu = {}
function Menu:new(
  menu_name, previous_menu, dx, dy, 
  menu_content, menu_info_draw_call, 
  base_color, border_color, text_color, menu_thickness)
  obj = {
    name = menu_name,
    prev = previous_menu,
    position = Vec:new(dx, dy),
    selector = Animator:new(global_data_table.animation_data.menu_selector, true),
    up_arrow = Animator:new(global_data_table.animation_data.up_arrow, true),
    down_arrow = Animator:new(global_data_table.animation_data.down_arrow, true),
    content = menu_content,
    content_draw = menu_info_draw_call,
    rect = BorderRect:new(
      Vec:new(dx, dy), 
      Vec:new(10 + 5*longest_menu_str(menu_content), 38),
      border_color,
      base_color,
      menu_thickness
    ),
    text = text_color,
    pos = 1,
    enable = false,
    ticks = 5,
    max_ticks = 5,
    dir = 0
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Menu:draw()
  if (not self.enable) return
  local top, bottom = self.pos-1, self.pos+1
  if (top < 1) top = #self.content 
  if (bottom > #self.content) bottom = 1
  if (self.content_draw) self.content_draw(self.pos, self.position, self.content[self.pos].color)
  BorderRect.draw(self.rect)
  Animator.draw(self.selector, Vec.unpack(self.position + Vec:new(2, 15)))
  Animator.draw(self.up_arrow, self.rect.size.x/2, self.position.y-self.rect.thickness)
  Animator.draw(self.down_arrow, self.rect.size.x/2, self.rect.size.y-self.rect.thickness)
  local base_pos_x = self.position.x+10
  local menu_scroll_data = {self.dir, self.ticks / self.max_ticks, self.position}
  if self.ticks < self.max_ticks then 
    if self.dir > 0 then 
      print_with_outline(
        self.content[top].text, 
        combine_and_unpack(menu_scroll(12, 10, 7, unpack(menu_scroll_data)), 
        self.content[top].color)
      )
    elseif self.dir < 0 then 
      print_with_outline(
        self.content[bottom].text, 
        combine_and_unpack(menu_scroll(12, 10, 27, unpack(menu_scroll_data)), 
        self.content[bottom].color)
      )
    end 
  else
    print_with_outline(self.content[top].text, base_pos_x, self.position.y+7, unpack(self.content[top].color))
    print_with_outline(self.content[bottom].text, base_pos_x, self.position.y+27, unpack(self.content[bottom].color))
  end
  print_with_outline(
    self.content[self.pos].text, 
    combine_and_unpack(menu_scroll(10, 12, 17, unpack(menu_scroll_data)), 
    self.content[self.pos].color)
  )
end
function Menu:update()
  if (not self.enable) return
  Animator.update(self.selector)
  Animator.update(self.up_arrow)
  Animator.update(self.down_arrow)
  if (self.ticks >= self.max_ticks) return
  self.ticks += 1
end
function Menu:move()
  if (not self.enable) return
  if (self.ticks < self.max_ticks) return
  local _, dy = controls()
  if (dy == 0) return
  self.pos += dy 
  self.dir = dy
  if (self.pos < 1) self.pos = #self.content 
  if (self.pos > #self.content) self.pos = 1
  self.ticks = 0
end
function Menu:invoke()
  if (self == nil) return
  local cont = self.content[self.pos]
  if (cont.callback == nil) return
  if cont.args then
    cont.callback(unpack(cont.args))
  else
    cont.callback()
  end
end
function Menu:update_content(content)
  self.content = content 
  BorderRect.resize(
    self.rect,
    self.rect.position, 
    Vec:new(10+5*longest_menu_str(content), 38)
  )
end
function menu_scroll(dx1, dx2, dy, dir, rate, position)
  local dy1, dy3 = dy-10, dy+10
  local lx = lerp(position.x+dx1, position.x+dx2, rate)
  local ly = position.y + dy
  if dir < 0 then 
    ly = lerp(position.y + dy1, ly, rate)
  elseif dir > 0 then 
    ly = lerp(position.y + dy3, ly, rate)
  end
  return {lx, ly}
end
Animator = {} -- updated from tower_defence
function Animator:new(animation_data, continuous_)
  obj = {
    data = animation_data.data,
    sprite_size = animation_data.size or 8,
    spin_enable = animation_data.rotation,
    theta = 0,
    animation_frame = 1,
    frame_duration = animation_data.ticks_per_frame,
    tick = 0,
    continuous = continuous_
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Animator:update()
  self.tick = (self.tick + 1) % self.frame_duration
  self.theta = (self.theta + 5) % 360
  if (self.tick ~= 0) return false
  if Animator.finished(self) then 
    if (self.continuous) Animator.reset(self)
    return true
  end
  self.animation_frame += 1
  return false
end
function Animator:finished()
  return self.animation_frame >= #self.data
end
function Animator:draw(dx, dy)
  local position,frame = Vec:new(dx, dy),self.data[self.animation_frame]
  if (frame.offset) position += Vec:new(frame.offset)
  if self.spin_enable then 
    draw_sprite_rotated(frame.sprite, position, self.sprite_size, self.theta)
  else
    spr(Animator.get_sprite(self),Vec.unpack(position))
  end
end
function Animator:get_sprite()
  return self.data[self.animation_frame].sprite
end
function Animator:reset()
  self.animation_frame = 1
end
Inventory = {}
function Inventory:new(selector_spr_id, unknown_spr_id, size_, max_entries, border_rect_data)
  obj = {
    selector_id = selector_spr_id,
    unknown_id = unknown_spr_id,
    size = size_,
    entry_amount = max_entries,
    rect = BorderRect:new(unpack(border_rect_data)),
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
function _init()
  reset()
end
function _draw()
  cls()
  if loaded_area == -2 then 
    draw_compendium()
  elseif loaded_area == -1 then 
    draw_map()
  elseif loaded_area == 0 then 
    draw_shop()
  elseif loaded_area > 0 then
    draw_fishing()
  end
  foreach(menus, Menu.draw)
end
function _update()
  foreach(menus, Menu.update)
  foreach(menus, Menu.move)
  if btnp(❎) then
    Menu.invoke(get_active_menu())
  end
  if loaded_area == 0 then 
    shop_loop()
  elseif loaded_area == -2 then 
    compendium_loop()
  elseif loaded_area > 0 then
    fish_loop()
  end
end
function print_with_outline(text, dx, dy, text_color, outline_color)
  ?text,dx-1,dy,outline_color
  ?text,dx+1,dy
  ?text,dx,dy-1
  ?text,dx,dy+1
  ?text,dx,dy,text_color
end
function print_text_center(text, dy, text_color, outline_color)
  print_with_outline(text, 64-(#text*5)\2, dy, text_color, outline_color)
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
function longest_string(strings)
  local len = 0
  for string in all(strings) do 
    len = max(len, #string)
  end
  return len
end
function round_to(value, places)
  local places = 10 * places
  local val = value * places
  val = flr(val)
  return val / places
end
function table_contains(table, val)
  for obj in all(table) do 
    if (obj == val) return true
  end
end
function get_array_entry(table, name)
  for entry in all(table) do 
    if (entry.name == name) return entry
  end
end
function combine_and_unpack(data1, data2)
  local data = {}
  for dat in all(data1) do
    add(data, dat)
  end
  for dat in all(data2) do
    add(data, dat)
  end
  return unpack(data)
end
function pretty_print(text_data, width)
  local max_len= flr(width/5)
  local counter, buffer = max_len, ""
  for _, word in pairs(split(text_data, " ")) do
    if #word + 1 <= counter then 
      buffer ..= word.." "
      counter -= #word + 1
    elseif #word <= counter then 
      buffer ..= word
      counter -= #word 
    else
      buffer ..= "\n"..word.." "
      counter = max_len - #word + 1 
    end
  end
  return buffer
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
    if value == "inf" then 
      value = 32767
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
function shop_loop()
  if btnp(🅾️) then
    if get_active_menu() == nil then 
      get_menu("shop").enable = true
    else
      swap_menu_context(get_active_menu().prev)
    end
  end
end
function fish_loop()
  if btnp(🅾️) then
    if (fishing_areas[loaded_area].state == "detail") return
    if get_active_menu() == nil then 
      get_menu("fishing").enable = true
    else
      swap_menu_context(get_active_menu().prev)
    end
  end
  
  if get_active_menu() == nil then
    FishingArea.update(fishing_areas[loaded_area])
  end
end
function compendium_loop()
  if btnp(🅾️) then
    if show_fish_details then 
      show_fish_details, fish_detail_flag = false
    else 
      loaded_area = -1
      get_menu("main").enable, fish_detail_flag = true
    end
    return
  end
  if not show_fish_details then
    if btnp(❎) and not Inventory.check_if_hidden(fishpedia) and fish_detail_flag then
      show_fish_details = true
      return
    end
    fish_detail_flag = true
    Inventory.update(fishpedia)
  end
end
function draw_map()
  print_with_outline("placeholder :D", 5, 40, 7, 1)
  print_with_outline("area select [shop | fishing]", 5, 50, 7, 1)
  print_with_outline("press ❎ to select", 1, 114, 7, 1)
end
function draw_shop()
  print_with_outline("cash: "..cash, 1, 1, 7, 1)
  print_with_outline("not fully implemented :D", 5, 40, 7, 1)
  print_with_outline("only: sell fish, profit?", 5, 50, 7, 1)
  if get_active_menu() ~= nil then 
    print_with_outline("press ❎ to select", 1, 114, 7, 1)
  end
  print_with_outline("press 🅾️ to open option menu", 1, 120, 7, 1)
end
function draw_fishing()
  if get_active_menu() ~= nil then 
    print_with_outline("press ❎ to select", 1, 114, 7, 1)
  elseif (fishing_areas[loaded_area].state ~= "detail") then
    print_with_outline("press ❎ to fish", 1, 114, 7, 1)
    print_with_outline("press 🅾️ to open option menu", 1, 120, 7, 1)
    print_with_outline("wip: imagine cat here", 5, 40, 7, 1)
  end
  FishingArea.draw(fishing_areas[loaded_area])
end
function draw_compendium()
  if show_fish_details then 
    draw_fish_compendium_entry(fishpedia.data[fishpedia.pos])
  else
    Inventory.draw(fishpedia)
  end
end
function draw_fish_compendium_entry(fish_entry)
  BorderRect.draw(compendium_rect)
  BorderRect.draw(compendium_sprite_rect)
  local sprite_pos = compendium_sprite_rect.position + Vec:new(4, 4)
  spr(
    fish_entry.sprite_id, 
    combine_and_unpack(
      {Vec.unpack(sprite_pos)},
      {2, 2}
    )
  )
  local detail_pos = compendium_sprite_rect.position.x + compendium_sprite_rect.size.x + 2
  print_with_outline(
    fish_entry.name, 
    detail_pos, compendium_sprite_rect.position.y,
    7, 0
  )
  print_with_outline(
    "weight: "..fish_entry.data.weight..fish_entry.data.units[2], 
    detail_pos, compendium_sprite_rect.position.y + 12,
    7, 0
  )
  print_with_outline(
    "size: "..fish_entry.data.size..fish_entry.data.units[1], 
    detail_pos, compendium_sprite_rect.position.y + 19,
    7, 0
  )
  local stars = ""
  for i=1, fish_entry.data.rarity do 
    stars ..= "★"
  end
  local lines = split(pretty_print(
    fish_entry.data.description,
    compendium_rect.size.x - 8 
  ), "\n")
  local y_offset = compendium_sprite_rect.position.y + compendium_sprite_rect.size.y
  print_with_outline(
    stars,
    compendium_rect.position.x + 4,
    y_offset-8,
    10, 7
  )
  for i, line in pairs(lines) do 
    print_with_outline(
      line, 
      compendium_rect.position.x + 4,
      y_offset + (i-1) * 7,
      7, 0
    )
  end
end
__gfx__
11221122112211220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
112211221122112200000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000000000000
22112211221122110000000000000000000000000000000000000a440a0000000000000000000000000000000000000000000000000000000000000000000000
22112211221122110000004888000000000000999000000000a444a44400a0000000000111000000000000000000000000000000000000000000000000000000
112211221122112200004888800000480000999000000000004a444a444a000000000091f0000000000000000000000000000000000000000000000000000000
11221122112211220048889900004889000555555000009904144a44dd440004000019ffff100010000000000000000000000000000000000000000000000000
221122112211221108a899999008899000555599555009704114444d554a4014006711fff1110611000000000000000000000000000000000000000000000000
22112211221122118a5a9999998899005509999999959700444a44d55444a1441111111111111771000000000000000000000000000000000000000000000000
112211221122112288a9999999999000999777777777700044a44455544444441115555551171171000000000000000000000000000000000000000000000000
112211221122112288999999999999000677777776009700a944a445554a4094dd76666661711771000000000000000000000000000000000000000000000000
221122112211221109999999aa0999900006667990000970099994a45544a00900ddd71667dd0711000000000000000000000000000000000000000000000000
2211221122112211009999aaa00099aa0000990099900099a0f999999a9000000000dd766d000010000000000000000000000000000000000000000000000000
112211221122112200099aaa00000099000000000000000000affaff99a00000000000dd70000000000000000000000000000000000000000000000000000000
1122112211221122000000000000000000000000000000000000ffaf0a0000000000000000000000000000000000000000000000000000000000000000000000
22112211221122110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22112211221122110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07770000000000008880000000000888000007777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000
74447700000770008000000000000008000076666667000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07444470007447008000000000000008000766666666700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00744447074444700000000000000000000766666666670000000000000000000000000000000000000000000000000000000000000000000000000000000000
00744447744444470000000000000000000766667666670000000000000000000000000000000000000000000000000000000000000000000000000000000000
07444470744774470000000000000000000076677666670000000000000000000000000000000000000000000000000000000000000000000000000000000000
74447700077007700000000000000000000007700766670000000000000000000000000000000000000000000000000000000000000000000000000000000000
07770000000000000000000000000000000000007666700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000076667000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077007700000000000000000000000766670000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000744774470000000000000000000000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000744444470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000074444700000000000000000000000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007447008000000000000008000000766670000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000770008000000000000008000000766670000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000008880000000000888000000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000cccccccc0000cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000cccccccccc000cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cccccccccccc00cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000cccccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

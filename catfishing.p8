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
function load_area(area_id)
  get_active_menu().enable = false
  loaded_area = area_id 
  if (area_id > 0) FishingArea.reset(global_data_table.areas[loaded_area])
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
global_data_str="palettes={transparent_color_id=0,menu={4,7,7,3}},text={60,5,7,1},gauge_data={position={10,10},size={102,5},settings={4,7,2,3},req_tension_ticks=20,tension_timer=30},power_gauge_colors={8,9,10,11,3},biases={weight=8,size=3},sell_weights={per_weight_unit=3,per_size_unit=2},animation_data={cat={data={{sprite=232},{sprite=234}},size=16,ticks_per_frame=5},menu_selector={data={{sprite=32,offset={0,0}},{sprite=32,offset={-1,0}},{sprite=32,offset={-2,0}},{sprite=32,offset={-3,0}},{sprite=32,offset={-2,0}},{sprite=32,offset={-1,0}}},ticks_per_frame=3},up_arrow={data={{sprite=33,offset={0,0}},{sprite=33,offset={0,-1}},{sprite=33,offset={0,-2}},{sprite=33,offset={0,-1}}},ticks_per_frame=3},down_arrow={data={{sprite=49,offset={0,0}},{sprite=49,offset={0,1}},{sprite=49,offset={0,2}},{sprite=49,offset={0,1}}},ticks_per_frame=3}},areas={{name=home,mapID=0,music={},fishes={{gradient={8,9,10,11,11,11,10,9,8},successIDs={11},min_gauge_requirement=1,max_gauge_requirement=3,stats={goldfish,2,2.7,12.5,1},units={cm,g},description=now what's a goldfish doing here.},{gradient={8,9,10,11,10,9,8},successIDs={11},min_gauge_requirement=4,max_gauge_requirement=inf,stats={yellow fin tuna,4,32,2.25,4},units={m,kg},description=yummy},{gradient={8,9,10,10,10,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=3,max_gauge_requirement=5,stats={pufferfish,6,0.08,60,3},units={cm,kg},description=doesn't it look so cuddley? you should hug it!},{gradient={8,9,10,11,11,11,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={triggerfish,8,0.04,71,2},units={cm,kg},description=hol up is that a gun?!?!},{gradient={8,9,10,11,11,11,10,9,8},successIDs={11},min_gauge_requirement=1,max_gauge_requirement=3,stats={carp,10,0.12,122,1},units={cm,kg},description=oh carp!},{gradient={8,9,10,11,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={salmon,12,14.6,1.5,2},units={m,kg},description=not to be confused with salmonella.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={largemouth bass,14,0.01,45,2},units={cm,kg},description=it climbs up all the rocks and trees and slides down on its hands and knees.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={rainbow trout,38,0.013,110,2},units={cm,kg},description=it's so shiny!},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={smallmouth bass,40,0.02,45,2},units={cm,kg},description=always left in the shadow of the superior largemouth bass.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={crappie,42,0.02,38,2},units={cm,kg},description=whoever named this one was mean.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={bluegill,44,0.04,25,2},units={cm,kg},description=the gills aren't even blue, kinda lame.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={walleye,46,0.046,80,2},units={cm,kg},description=aye aye walleye!},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={alligator gar,64,9.8,1.8,2},units={m,kg},description=lots of scary teeth.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={sunfish,66,2.2,1,2},units={m,kg},description=the sun is a deadly laser.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={sturgeon,68,30.7,4.8,2},units={m,kg},description=he had to go to medical school.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={koi,70,0.076,60,2},units={cm,kg},description=they're so relaxing to watch swim. hopefully they're tasty too!},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={clownfish,72,0.007,15,2},units={cm,kg},description=there's a joke somewhere in here},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={bonefish,74,2.7,12.5,1},units={cm,g},description=ok - i have a bone to pick with nature},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={killifish,76,3,7.6,2},units={cm,g},description=killer fish. killer fish from san diego.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={pond smelt,78,1.9,11,2},units={cm,g},description=he who smelt it dealt it.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={angelfish,96,0.015,25,2},units={cm,kg},description=not the biblically accurate one.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={angle fish,98,0.015,25,2},units={cm,kg},description=the math one.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={arcangelfish,100,0.015,25,2},units={cm,kg},description=be not afraid.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={arowana,102,2.18,1.2,2},units={m,kg},description=snoop dogg's favorite fish.},{gradient={8,9,11,11,11,11,11,11,11,9,8},successIDs={11},min_gauge_requirement=1,max_gauge_requirement=5,stats={plastic fish,104,2.7,12.5,1},units={cm,g},description=hey! a different colored goldfis- wait! this is a plasic fish.},{gradient={8,9,11,11,11,11,11,11,11,9,8},successIDs={11},min_gauge_requirement=1,max_gauge_requirement=5,stats={cat...fish,234,0.07,25,1},units={cm,g},description=one of your own kind. not to be confused with catfish.},{gradient={8,9,11,11,11,11,11,11,11,9,8},successIDs={11},min_gauge_requirement=1,max_gauge_requirement=5,stats={catfish,106,0.03,72,1},units={cm,kg},description=he's got a funny looking mustache. not to be confused with a cat...fish...},{gradient={8,9,11,11,11,11,11,11,11,9,8},successIDs={11},min_gauge_requirement=1,max_gauge_requirement=5,stats={anchovy,108,1.02,20,1},units={cm,g},description=oh look! an anchovy...but why is there a pizza here?},{gradient={8,9,11,11,11,11,11,11,11,9,8},successIDs={11},min_gauge_requirement=1,max_gauge_requirement=5,stats={squid,110,2.76,30,1},units={cm,g},description=are there any other squidwards i should know about?},{gradient={8,9,11,11,11,11,11,11,11,9,8},successIDs={11},min_gauge_requirement=1,max_gauge_requirement=5,stats={trashcan,230,0.02,68,1},units={cm,g},description=ok i've heard another cat's trash is another cat's treasure but how did i reel in an whole trashcan?}}}}"
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
          text="shop", color={7, 0}, callback=load_area, args={0}
        },
        { 
          text="fishing", color={7, 0}, callback=load_area, args={1}
        },
        {
          text="fishapedia", color={7, 0}, callback=load_area, args={-2}
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
  cat = Animator:new(global_data_table.animation_data.cat, true)
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
      printh(self.fish.name)
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
    spr(Animator.get_sprite(self),combine_and_unpack({Vec.unpack(position)}, {self.sprite_size\8, self.sprite_size\8}))
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
      rectfill(position.x-1, position.y-1, position.x + 16, position.y + 16, 0)
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
  for i=0, #self.data do 
    if (self.data[i].name == name) return self.data[i]
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
  Animator.update(cat)
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
  map(0, 0, 29, 24)
  Animator.draw(cat, 60, 55)
  if get_active_menu() ~= nil then 
    print_with_outline("press ❎ to select", 1, 114, 7, 1)
  elseif (fishing_areas[loaded_area].state ~= "detail") then
    print_with_outline("press ❎ to fish", 1, 114, 7, 1)
    print_with_outline("press 🅾️ to open option menu", 1, 120, 7, 1)
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
22112211221122110000000000000000000000000000000000000a440a0000000000000000000000000000000000000000000000000000000000000044400000
22112211221122110000004888000000000000999000000000a444a44400a0000000000111000000000000666600000000000000770000000000004444000000
112211221122112200004888800000480000999000000000004a444a444a000000000091f0000000000066666660005500000007660000000000055555400000
11221122112211220048889900004889000555555000009904144a44dd440004000019ffff10001000dd55555600055500000111111000060005555555540044
221122112211221108a899999008899000555599555009704114444d554a4014006711fff11106110d1555555550555000111666661100660555666665550444
22112211221122118a5a9999998899005519999999959700444a44d55444a1441111111111111771d55555555595550011d66666666617765516677776664440
112211221122112288a9999999999000999777777777700044a44455544444441115555551171171665995559966550067777766667777776677777777776444
112211221122112288999999999999000677777776009700a944a445554a4094dd76666661711771666699996600d55000777777777700770747777777740044
221122112211221109999999aa0999900006667990000970099994a45544a00900ddd71667dd07110066666665000dd500066777776600070044477774444000
2211221122112211009999aaa00099aa0000990099900099a0f999999a9000000000dd766d00001000055500d55000dd00006600066000000004400000440000
112211221122112200099aaa00000099000000000000000000affaff99a00000000000dd70000000000055000dd0000000000000000000000000000000000000
1122112211221122000000000000000000000000000000000000ffaf0a0000000000000000000000000000000000000000000000000000000000000000000000
22112211221122110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22112211221122110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07770000000000008880000000000888000007777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000
74447700000770008000000000000008000076666667000000000000000000000000000000000000000000000000000000000000000000000000000000000000
074444700074470080000000000000080007666666667000000000000000000000000000dd60000000000000336000000000000bbbbb00000000000000000000
0074444707444470000000000000000000076666666667000000000000000000000000d6660000000000003366600000000000b3333300000000000000000000
00744447744444470000000000000000000766667666670000000000000000000000015151600000000011116630000000001111133000000000055550000000
0744447074477447000000000000000000007667766667000000004440000000000515515556002d001113311100033600113111110000000000555500000001
7444770007700770000000000000000000000770076667000005555555400044015515555551022d01133f6333003366111b3133131001bb0001111111550114
077700000000000000000000000000000000000076667000555222222255544055855515515122d01433f66f6f333360b4b331311331133b11d44444444441d0
00000000000000000000000000000000000000076667000061eeeeeee6ddd40066255155515512dd33366666666f33606bb3133333ff33309999ffffffff11d0
0000000007700770000000000000000000000076667000006ff6666666fff440027771551776002d733777666670336666611313fff003330000fffffff00114
000000007447744700000000000000000000000777000000009fffffff900044006667777666600007777666770003360fffffffff600bbb0000000000000004
00000000744444470000000000000000000000000000000000009900999000000006600000660000007777777f3000000fffffff666300000000000000000000
000000000744447000000000000000000000000777000000000000000000000000000000000000000000007f663000000033600633bb00000000000000000000
00000000007447008000000000000008000000766670000000000000000000000000000000000000000000063000000000633600000000000000000000000000
00000000000770008000000000000008000000766670000000000000000000000000000000000000000000000000000000063b00000000000000000000000000
00000000000000008880000000000888000000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000088880000000000000000000000000000000000000000000000000000000000
00000000000000000000000056600000000000000000000000000000000000000899998880000000000000000000000000000000000000000000000000000000
000000000000000000000000066600000000000000000000000000000000000089aaaa9980000000000000000000000000000000000000000000000000000000
0000000000000000000000000566600000000000000000000000000000000000aa3333aa8800000000000000000000000000002cc00000000000000000000000
00000000000000000000655500556600000000000000000000000a616000000033dd333aa0000048000000000000000000000cc2200000900000000000000000
000000000000000f0006666655556600000061616555000500089961960001779111ddd3000048890066606006000660009c999c900009990000066600000000
00000dffff0000fd006165666666660000055555115006650819a7711988677701a11113900889900665605605606600919c9c9c9900c9900000444440000600
dfff1fffdfffdfff0666656666666660551ddddddd55655008977777199877708a5a9919998899000666666666666000999c9c9999c2c9000044999944406600
66666666666600fd07766666666666607755555555575500066119997aa7167788a99999999990000666600600606600999c9c99c99c29000461666699ff6000
0000ff6666ff000d007766666677776000067676767055500009998877000167889999999999990000666060060006600999c999c900c9900ffff666ff006600
00000ff0000ff00000077777777776000000550005500000000680006660000009999999aa099990000000000000000000c9c992c2000999000ffffff0000600
0000000000000000000077770055660000000000000000000000000000000000009999aaa00099aa000000000000000000cc000c2cc000900000660000000000
000000000000000000000000056660000000000000000000000000000000000000099aaa000000990000000000000000000000002cc000000000000000000000
00000000000000000000000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000056600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006600000000000000000000000000066000000000000000000000000000000000000000000000000000000000044444444440000000000000000000
000000006667000000000000000000000000066677000000000000000000000000000000000000000000000000000000004aaaaaaaaaa4000000000000000000
000aa006677700000000000000000000000066777700666000000000000000000000000000000000000000000000000004aaaaaaaaaaaa400000000000000000
0aaaa04888770660000000488800000000006748866777700000000000000000000000dddd00000000000000000000004aaa88aa88aaaaa40000000000000000
aa004888866666780000488885150048000668866777777800000000000000000000ddddd00000dd00000055000000004aaa88aa88aaa884009ff90000000fff
0048889667777779055588995555588900a8889677777779000000002222000000ddddcc0000dddd00000555000000554aaccccccccaa5840ff990000000f000
08a899667777777058a85999455559900a5a99677777779000055555555200220dadccccc00ddcc000011115511005554ac9cccccccc55a4ff9f09ff1f0f9990
8a5a9677777777705a5a555444855900a515a999977799005555222555555220da5accccccddcc005115555555511f504a77777777775aa4999ffff999f00000
88a999777777977058a9544599999000a515a999999990002152222222222200ddacccccccccc0005256655555555f504aa66677776655a4999999999fffffff
889999999999990085554499999999008a5a9999999999002252222222255220ddcccccccccccc004446555555fff5504aaaaaaa88aaa5a49ff90ff91f0f0000
09999999aa09999007944919aa09999009a999966a09999000eeeeeee55000220cccccccdd0cccc000f4ffffffd005554aaaaaaa88aa88a409fff0000000fff0
009999aaa00099aa00449111a00099aa009999a7660099aa000022002220000000ccccddd000ccdd0000dd00ddd000554a88a88aaaaa88a40099ff00000000ff
00099aaa00000099000911a11000009900099aa7766000990000000000000000000ccddd000000dd00000000000000004a88a88aaaaaaaa40000000000000000
00000000000000000000100010000000000060007766000000000000000000000000000000000000000000000000000004aaaaaaa88aaa400000000000000000
000000000000000000000000000000000000760077760000000000000000000000000000000000000000000000000000004aaaaaa88aa4000000000000000000
00000000000000000000000000000000000077600070000000000000000000000000000000000000000000000000000000044444444440000000000000000000
9999999999999999999999999999999999999999999999999999999999999999771111111111cccc77111111111111ccc77111111ccc77ffffffffffffffffff
999999999999999999999999999999999999999999999999999999999999999911111111111ccc7711111111111111cc77111111ccc77fffffffffffffffff4f
999999999999999999999999999999999999999999999999999999999999999911111111cccc771111111111111111c71111111cccc7ffffff4ffffffff4ffff
999999999999999999999999999999999999999999999999999999999999999911111111cc77711111111111111111771111111ccc7fffffffffffffffffffff
999999999999999999999999999999999999999999999999999999999999999911111111777111111111111111111111111111ccc77fffff4fffffffffffffff
999999999999999999999999999999999999999999999999999999999999999911111111111111111111111111111111111111ccc7ffffffffffffffffffffff
99999999999999999999999999999999999999999999999999999999999999991111111111111111111111111111111111111cccc7ffffffffff4fffffffffff
99999999999999999999999999999999999999999999999999999999999999991111111111111111c7111111111111111111cccc77ff4fffffffffffffffffff
9999999999999999999999999999999999999999999999999999999999999999111111111111111cc7111111111111111111ccc77ffffffffffffffffff4ffff
999999999999999999999999999999999999999999999999999999999999999911111111111111ccc711111111111111111cccc7ffffffffffffffffffffffff
99999999999999999999999999999999999999999999999999999999999999991111111111111ccc7711111111111111111ccc77ffffffffffff4fffffffffff
9999999999999999999999999999999999999999999999999999999999999999111111111111ccc771111111111111111cccc77fffffffffffffffffffffffff
999999999999999999999999999999999999999999999999999999999999999911111111111cccc711111111111111cccccc77fff4ffffffffffffffffffffff
9999999999999999999999999999999999999999999999999999999999999999111111111ccccc7711111111111ccccccc777fffffffffffffffffffffffffff
9999999999999999999999999999999999999999999999999999999999999999111ccccccccc7771111111111cccccc7777ffffffffffffffffffffffffff4ff
999999999999999999999999999999999999999999999999999999999999999911ccccccc777711111111111ccccc77fffffffffffffffffffffffffffffffff
9999999999aaaaaa9999999999999999999999999999999999999999999999991ccc7777771111111111111ccccc77ffffffffffffffffffffffffffffffffff
99999999aaaaaaaaaa9999999999999999999999999999999999999999999999ccc77111111111111111111cccc77ffffffffffffffffffff4ffffffffffffff
9999999aaaaaaaaaaaa999999999999999999999999999999999999999999999cc77111111111111111111cccc7fffffffffffffffffffffffffffffffffffff
9e9e9eaaaaaaaaaaaaaa9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e777111111111111111111cccc77fffffffffffffffffffffffffffffffffffff
e9e9eaaaaaaaaaaaaaaaa9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e911111111111111111111cccc77ffffffffffffffffffffffffffffffffffffff
9e9e9aaaaaaaaaaaaaaaae9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e1111111111111111111cccc77fffffffff4fffffffffffffffffffffffffffff
eeeeaaaaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee111111111111cccccccccc77ffffffffffffffffffffffffffffffffffffffff
e2e2aaaaaaaaaaaaaaaaaae2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e21111111111cccccccccc777fffffffffffffffffffffffffffffffff4fffffff
2e2eaaaaaaaaaaaaaaaaaa2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e11111111cccccc7777777fffffff4fffffffffff4fffffffffffffffffffffff
2222aaaaaaaaaaaaaaaaaa222222222222222222222222222222222222222222111111cccccc777fffffffffffffffffffffffffffffffffffffffffffffffff
11111111111111111111111111111111111111cc711111ccc7fff4ffffffffffccccccccc7777fffffffffffffffffffffffffffffffffffffffffffffffffff
1111cc7111111111111111111111111111111ccc71111ccc77ffffff4fffffffccccccc777ffffffffffffffffffffffffffffffffffffffffffffffffffffff
111ccc7111111111111111cc711111111111ccc77111cccc7f4ff4ffffff4fff77777777ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
11cc77111111111111cccccc7111111111cccc77111cccc77ffffff4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ccc771111111111ccccccc7771111111cccc777111ccc77ff4ffffffff4ffffffff4fffffffffffffffffffffffff4ffffffffffffffffffffffffffffff4fff
cc771111111111cccc7777711111111ccc77711111ccc7ffffff4ffffffffffffffffffffffffff4ffffffffffffffffffffffffffffffffff4fffffffffffff
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000007700000000050000500000000005000050000000000000000000000000060000600000000
00000000000000000000000000000000000000000000000000000776666000000565005650000000056500565000000000000000000000000676006760000000
00000000000000000000000000000000000000000000000000066665555663300566556650000000056655665000000000000000000000000677667760000000
00000000000000000000000000000000000000000000000000335555555555305666666665000000566666666500000000000000000000006777077776000000
000000000000000000000000000000000000000000000000003366666ddddd005666666665000000566666666500000000000000000000006777707776000000
0000000000000000000000000000000000000000000000000033d665566533005c6666c6650000005c6666c66500000000000000000000006797770076000000
000000000000000000000000000000000000000000000000003d36655665d3305c6666c6650000005c6666c66500000000000000000000006797770076000000
000000000000000000000000000000000000000000000000003d33655665d3305e66666e650055005e66666e6500055000000000000000006777777706006600
000000000000000000000000000000000000000000000000000d33355665d3000556666550056650055566655000566500008080000000000667777660067760
000000000000000000000000000000000000000000000000000d56655665d000000666666505665056655666650056650080080000a0a0a00067777776067760
000000000000000000000000000000000000000000000000000d56655665d000566556666650566505566666665005650008000000a0a0a00067777777606776
000000000000000000000000000000000000000000000000000d56655665d000055666556650566500055566665055650080088000a0a0a00067676677606776
000000000000000000000000000000000000000000000000000d56655665d0000005556656556665000005556655666500000800000000000067667767667776
000000000000000000000000000000000000000000000000000d566556653000000005666656665000000566565666500000000000a0a0a00067667777677760
000000000000000000000000000000000000000000000000000d5665566533000000566666565500000056666656550000000000000000000067677777676600
00000000000000000000000000000000000000000000000000055665566553000000555555550000000055555555000000000000000000000006666666660000
__map__
8080808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9091929292929292000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a1a2a3a4a5a6a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b0b1b2b3b4b5b6b7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88898a8b8c8d8e8f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
98999a9b9c9d9e9f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a8a9aaabacadaeaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b8b9babbbcbdbebf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

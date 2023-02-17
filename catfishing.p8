pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
global_data_str = "fishes={{placeholder name,0,1,2,50,100,100}},progressBar={fill_color=2,max_val=200,rect_data={5,5,50,5,8,6,2}},text={60,5,7,1}"
BorderRect = {}
function BorderRect:new(dx, dy, dw, dh, border_color, background_color, thickness_size)
obj={
x=dx,y=dy,w=dx+dw,h=dy+dh,
border = border_color, background = background_color,
thickness=thickness_size
}
setmetatable(obj,self)
self.__index=self
return obj
end
function BorderRect:draw()
rectfill(
self.x-self.thickness,self.y-self.thickness,
self.w+self.thickness, self.h+self.thickness, self.border)
rectfill(self.x,self.y,self.w,self.h,self.background)
end
ProgressBar={}
function ProgressBar:new(fill_color, max_val, rect_data)
obj={
val=0,
max_value=max_val,
color = fill_color,
rect = BorderRect:new(unpack(rect_data))
}
setmetatable(obj,self)
self.__index=self
return obj
end
function ProgressBar:draw()
BorderRect.draw(self.rect)
if (self.val == 0) return
rectfill(self.rect.x, self.rect.y, self.rect.x+self.val, self.rect.h, self.color)
end
function ProgressBar:change_value(value)
self.val=mid(value/self.max_value,0,1)*(self.rect.w-self.rect.x)
end
Fish={}
function Fish:new(
fish_name,spriteID,weight,fish_size,
bite_ticks,fight_ticks,success_limit)
obj={
fish_name,
sprite=spriteID,
lb=weight,
size=fish_size,
ticks=bite_ticks,
fight_max_ticks=fight_ticks,
success_ceil=success_limit+fight_ticks,
state = "lure"
}
setmetatable(obj,self)
self.__index=self
return obj
end
function Fish:update()
if (Fish.is_lost(self) or self.state == "caught") return
self.ticks-=1
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
self.ticks=self.fight_max_ticks
elseif self.state == "fight" and Fish.progress(self) <= 100 then 
self.ticks+=2
if self.ticks >= self.success_ceil then 
self.state = "caught"
end
end
end
function _init()
table_data=unpack_table(global_data_str)
bar=ProgressBar:new(
table_data.progressBar.fill_color, 
table_data.progressBar.max_val,
table_data.progressBar.rect_data
)
fish=Fish:new(unpack(table_data.fishes[1]))
end
function _draw()
cls()
ProgressBar.draw(bar)
if fish.state == "caught" then 
print_with_outline("caught", unpack(table_data.text))
elseif Fish.is_lost(fish) then 
print_with_outline("lost", unpack(table_data.text))
end
if fish.state ~= "caught" then
print_with_outline(Fish.progress(fish).."%", unpack(table_data.text))
print_with_outline("state: "..fish.state, 5, 20, 7, 1)
end
end
function _update()
Fish.update(fish)
ProgressBar.change_value(bar,fish.ticks)
if btn(❎) then
Fish.pull(fish)
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
if btnp(⬆️) then
return 0, -1
elseif btnp(⬇️) then
return 0, 1
elseif btnp(⬅️) then
return -1, 0
elseif btnp(➡️) then
return 1, 0
else
return 0, 0
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
insert_key_val(sub(str,start,i),table)
start=i+1
if(i+2>#str)goto unpack_table_continue
start+=1
i+=1
elseif stack==0 then
if str[i]=="," then
insert_key_val(sub(str,start,i-1),table)
start=i+1
elseif i==#str then 
insert_key_val(sub(str,start),table)
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
add(table,val)
else
local value
if val[1] == "{" and val[-1] == "}" then 
value=unpack_table(sub(val,2,#val-1))
elseif val == "True" then 
value=true
elseif val == "False" then 
value=false
else
value = tonum(val) or val
end
table[key]=value
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

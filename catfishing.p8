pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
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
state="lure"
}
setmetatable(obj,self)
self.__index=self
return obj
end
function Fish:update()
if (Fish.is_lost(self) or Fish.is_caught(self)) return
self.ticks-=1
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
self.state="fight"
self.ticks=self.fight_max_ticks
elseif self.state == "fight" then 
self.ticks+=2
end
end
function _init()
table_str="fishes={{foo,0,1,2,50,100,100}},progressBar={2,200,{5,5,50,5,8,6,2}},text={60,5,7,1}"
table_data=unpack_table(table_str)
debug_print_table(table_data,"")
printh("------fish[1]--------")
debug_print_table(table_data.fishes[1],"")
printh("------progressbar--------")
debug_print_table(table_data.progressBar,"")
printh("------text--------")
debug_print_table(table_data.text,"")
bar=ProgressBar:new(unpack(table_data.progressBar))
fish=Fish:new(unpack(table_data.fishes[1]))
end
function _draw()
cls()
ProgressBar.draw(bar)
if Fish.is_caught(fish) then 
print_with_outline("caught",unpack(table_data.text))
elseif Fish.is_lost(fish) then 
print_with_outline("lost",unpack(table_data.text))
end
print_with_outline(Fish.progress(fish).."%",unpack(table_data.text))
print_with_outline("state:"..fish.state,5,20,7,1)
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
insert_str_as_table_entry(sub(str,start,i),table)
start=i+1
if(i+2>#str)goto unpack_table_continue
start+=1
i+=1
elseif stack==0 then
if str[i]=="," then
insert_str_as_table_entry(sub(str,start,i-1),table)
start=i+1
elseif i==#str then 
insert_str_as_table_entry(sub(str,start),table)
end
end
::unpack_table_continue::
i+=1
end
return table
end
function insert_str_as_table_entry(str, table)
local key,val
for i=1,#str do
if (str[i]~="=") goto insert_str_as_table_entry_continue
key,val=sub(str,0,i-1),sub(str,i+1)
if (val[1]~="{") goto insert_str_as_table_entry_continue 
local sub_str=sub(val,2,#val-1)
if not str_contains(val, "=") then 
local internal_array = sub(val, 2, #val-1)
if str_contains(internal_array, "{") then
val,_=parse_nested_array(internal_array)
else
val=split(internal_array)
end
else
val=unpack_table(sub_str)
end
break
::insert_str_as_table_entry_continue::
end
if key == nil then
add(table,val)
return
end
if val == "false" then 
table[key]=false
elseif val == "true" then 
table[key]=true
else
table[key]=tonum(val) or val
end
end
function str_contains(str, identifier)
for i=1, #str do if (str[i] == identifier) return true end
end
function parse_nested_array(str, pos)
local array = {}
local buffer = ""
local i = 1
while i <= #str do 
if str[i] == "{" then
local data, index = parse_nested_array(sub(str, i+1), i)
add(array,data)
i=index
elseif str[i] == "}" then 
local val = tonum(buffer) and tonum(buffer) or buffer
add(array,val)
return array, i + (pos and pos or 0)
elseif str[i] == "," then 
local val = tonum(buffer) and tonum(buffer) or buffer
add(array,val)
buffer=""
else
buffer..=str[i]
end
i+=1
end
return array
end
function debug_print_table(table, prefix)
for k, v in pairs(table) do 
if type(v) == "table" then 
printh(prefix.."["..type(v).."]"..k.."={")
debug_print_table(v,"__"..prefix)
printh(prefix.."}")
else
printh(prefix.."["..type(v).."]"..k.."="..v)
end
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

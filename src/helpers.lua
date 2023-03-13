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

-- https://www.lexaloffle.com/bbs/?pid=52525 [modified for this game]
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

function save_byte(address, value)
  poke(address, value)
  return address + 1
end

function save_byte2(address, value)
  poke2(address, value)
  return address + 2
end

function save_byte4(address, value)
  poke4(address, value)
  return address + 4
end

function encode_rod_inventory()
  local bits = 0
  for i, rod in pairs(global_data_table.rods) do 
    if table_contains(rod_inventory, rod) then 
      bits |= (1 << (i-1))
    end
  end
  printh("ENCODED::"..bits)
  return bits
end

function decode_rod_inventory(bits)
  printh("DECODING::"..bits)
  local rods = {}
  for i, rod in pairs(global_data_table.rods) do 
    if (bits & (1 << (i-1))) > 0 then 
      printh(rod.name)
      add(rods, rod)
    end
  end
  return rods
end

function encode(a, b, a_w)
  return (a << a_w) | b
end

function decode(data, a_w, b_mask)
  return flr(data >>> a_w), data & b_mask
end
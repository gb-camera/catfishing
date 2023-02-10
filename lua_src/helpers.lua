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
        val, _ = parse_nested_array(internal_array)
      else
        val = split(internal_array)
      end
    else
      val = unpack_table(sub_str)
    end
    break 
    ::insert_str_as_table_entry_continue::
  end

  if key == nil then
    add(table, val)
    return
  end

  if val == "false" then 
    table[key] = false
  elseif val == "true" then 
    table[key] = true
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
      add(array, data)
      i = index
    elseif str[i] == "}" then 
      local val = tonum(buffer) and tonum(buffer) or buffer
      add(array, val)
      return array, i + (pos and pos or 0)
    elseif str[i] == "," then 
      local val = tonum(buffer) and tonum(buffer) or buffer
      add(array, val)
      buffer = ""
    else
      buffer ..= str[i]
    end
    i += 1
  end
  return array
end
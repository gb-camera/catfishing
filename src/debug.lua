function debug_print_table(table, prefix, log_to_file)
  for k, v in pairs(table) do 
    local key = tonum(k) and "["..k.."]" or k
    if type(v) == "table" then 
      printh(prefix.."["..type(v).."] "..key.." = {", log_to_file)
      debug_print_table(v, "__"..prefix, log_to_file)
      printh(prefix.."}", log_to_file)
    else
      printh(prefix.."["..type(v).."] "..key.." = "..v, log_to_file)
    end
  end
end
function debug_printh_table(table, prefix)
  for k, v in pairs(table) do 
    local key = tonum(k) and "["..k.."]" or k
    if type(v) == "table" then 
      printh(prefix.."["..type(v).."] "..key.." = {")
      debug_printh_table(v, "__"..prefix)
      printh(prefix.."}")
    else
      printh(prefix.."["..type(v).."] "..key.." = "..v)
    end
  end
end

function debug_list(list, log_to_file)
  printh("--------------", log_to_file, true)
  for i, data in pairs(list) do
    printh("["..i.."] "..data, log_to_file)
  end
end
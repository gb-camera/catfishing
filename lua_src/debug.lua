function debug_print_table(table, prefix)
  for k, v in pairs(table) do 
    if type(v) == "table" then 
      printh(prefix.."["..type(v).."]"..k.." = {")
      debug_print_table(v, "__"..prefix)
      printh(prefix.."}")
    else
      printh(prefix.."["..type(v).."]"..k.." = "..v)
    end
  end
end
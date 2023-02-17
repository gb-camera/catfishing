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
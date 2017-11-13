function math.clamp(val, min, max)
    if min - val > 0 then
        return min
    end
    if max - val < 0 then
        return max
    end
    return val
end

function reset_colour()
	love.graphics.setColor(255, 255, 255, 255)
end

function random_string(l)
  if l < 1 then return nil end
  local stringy=""
  for i=1,l do
    stringy=stringy..random_letter()
  end
  return stringy
end

function random_letter()
    return string.char(math.random(97, 122));
end

function round_to_nth_decimal(num, n)
  local mult = 10^(n or 0)
  return math.floor(num * mult + 0.5) / mult
end

function print_table(table, name)
  if name then print("Printing table: " .. name) end
  for k, v in pairs(table) do
    if type(v) == "table" then
      print("[table]: " .. tostring(k))
      for key, val in pairs(v) do
        print(" *[key]: " .. tostring(key) .. " | [value]: " .. tostring(val))
      end
      print("--")
    else
      print("[key]: " .. tostring(k) .. " | [value]: " .. tostring(v))
    end
  end
  print("--")
end

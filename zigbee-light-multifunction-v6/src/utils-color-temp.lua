-- utils-color-temp.lua
local utils = {}

function utils.kelvin_to_xy(kelvin)
  local temp = kelvin / 100
  local r, g, b

  -- 1. Red Calculation (Usually fine at 255 for warm temps)
  if temp <= 66 then
    r = 255
  else
    r = temp - 60
    r = 329.698727446 * (r ^ -0.1332047592)
  end

  -- 2. Green Calculation (Dampened for warmth)
  if temp <= 66 then
    g = 99.4708025861 * math.log(temp) - 161.1195681661
    -- DAMPENER: Reduce green if we are in the yellow/orange zone (below 4000K)
    if temp < 40 then g = g * 0.88 end 
  else
    g = temp - 60
    g = 288.1221695283 * (g ^ -0.0755148492)
  end

  -- 3. Blue Calculation (The "Blue Killer" for Warm Whites)
  if temp >= 66 then
    b = 255
  elseif temp <= 19 then
    b = 0
  else
    b = 138.5177312231 * math.log(temp - 10) - 305.0447927307
    -- DAMPENER: IKEA bulbs need significantly less blue to look "Warm"
    if temp < 30 then 
      b = b * 0.30 -- Massive reduction for 2000-3000K
    elseif temp < 45 then
      b = b * 0.60 -- Significant reduction for 3000-4500K
    end
  end

  -- 4. Clamp and Normalize
  local function clamp(val)
    if not val or val < 0 then return 0 end
    if val > 255 then return 255 end
    return val / 255
  end

  r, g, b = clamp(r), clamp(g), clamp(b)

  -- 5. RGB to XY (CIE 1931)
  local X = r * 0.4124 + g * 0.3576 + b * 0.1805
  local Y = r * 0.2126 + g * 0.7152 + b * 0.0722
  local Z = r * 0.0193 + g * 0.1192 + b * 0.9505

  local sum = X + Y + Z
  if sum == 0 then return 0.3127, 0.3290 end -- D65 white fallback

  return X / sum, Y / sum
end

return utils
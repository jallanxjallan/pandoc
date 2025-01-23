-- boxout.lua
-- A Pandoc filter to wrap level 3 headers and their content in a styled "box" div.

local box_open = false
local temp_box = {}

-- Create a box div wrapper
local function wrap_in_box(elements)
  return pandoc.Div(elements, {class = "boxout"})
end

-- Process headers
function Header(el)
  if el.level == 3 then
    if box_open then
      -- If a box is already open, wrap it up
      box_open = false
      local box = wrap_in_box(temp_box)
      temp_box = {el}
      return box
    else
      -- Start a new box
      box_open = true
      temp_box = {el}
      return nil
    end
  elseif box_open and el.level <= 3 then
    -- Close the box if a higher-level header is encountered
    box_open = false
    local box = wrap_in_box(temp_box)
    temp_box = {}
    return box, el
  else
    return el
  end
end

-- Collect other block elements into the box
function Block(el)
  if box_open then
    table.insert(temp_box, el)
    return nil
  else
    return el
  end
end

-- Finalize the document by closing any open box
function Pandoc(doc)
  local blocks = doc.blocks
  if box_open then
    table.insert(blocks, wrap_in_box(temp_box))
    box_open = false
    temp_box = {}
  end
  return pandoc.Pandoc(blocks, doc.meta)
end


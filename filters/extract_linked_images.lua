-- Pandoc Lua filter to replace paragraphs containing an image element
-- with text based on the image's attributes, using the Pandoc path module.

local path = require "pandoc.path"

local function format_image(image)
  local src = image.src
  local alt = pandoc.utils.stringify(image.caption)

  -- Handle empty src or alt arguments
  if src == "" then
    src = "Image needed"
    if alt == "" then
      alt = "Image"
    end
  else
    -- Extract only the immediate parent directory and filename using the path module
    local parent_dir = path.directory(src)
    local filename = path.filename(src)
    if parent_dir ~= "." then
      src = parent_dir .. "/" .. filename
    else
      src = filename
    end
  end

  if alt == "" then
    alt = "Image"
  end

  return string.format("%s (%s)", alt, src)
end

return {
  {
    Para = function(elem)
      -- Check if the paragraph contains an image
      for i, item in ipairs(elem.content) do
        if item.t == "Image" then
          -- Replace paragraph with formatted image arguments
          return pandoc.Para({pandoc.Str(format_image(item))})
        end
      end
      return nil -- Keep paragraph unchanged if no image
    end
  }
}

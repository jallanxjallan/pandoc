-- check if a link points to a local markdown file
local function is_local_md_link(link)
  return not link:match("^https?://") and link:match("%.md$")
end

-- read the markdown file and return its content as Pandoc blocks
local function read_blocks_from_file(filepath)
  local file = io.open(filepath, "r")
  if not file then
    io.stderr:write("Warning: could not open file: " .. filepath .. "\n")
    return {}
  end
  file:close()
  local json = pandoc.pipe("pandoc", {"-f", "markdown", "-t", "json", filepath}, "")
  local doc = pandoc.read(json, "json")
  return doc.blocks
end

-- process each paragraph to extract image + caption pairs
function Para(el)
  local result_blocks = {}
  local i = 1
  while i <= #el.content do
    local item = el.content[i]
    local next_item = el.content[i + 1]

    if item and item.t == "Image" and next_item and next_item.t == "Link" then
      local md_target = next_item.target
      if is_local_md_link(md_target) then
        local caption_blocks = read_blocks_from_file(md_target)

        table.insert(result_blocks, pandoc.Div(
          { pandoc.Para({item}), table.unpack(caption_blocks) },
          pandoc.Attr("", {"figure-block"})
        ))

        i = i + 2 -- skip over image and link
      else
        i = i + 1
      end
    else
      -- ignore non-matching elements; could optionally preserve
      i = i + 1
    end
  end

  -- If any pairs were processed, return them as a list of Divs
  if #result_blocks > 0 then
    return result_blocks
  else
    return nil -- keep the original paragraph untouched if nothing matched
  end
end

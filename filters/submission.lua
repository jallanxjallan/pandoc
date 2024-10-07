function main(doc, meta)
  local function process_paragraph(p)
    local new_content = {}
    for _, c in ipairs(p.content) do
      if c.tag == "Link" then
        local url = c.url
        if string.match(url, "^%s*%S+%s*$") then -- Ensure URL is a single word
          local contents = pandoc.read_file(url, pandoc.reader.markdown)
          table.insert(new_content, contents)
        end
      else
        table.insert(new_content, c)
      end
    end
    p.content = new_content
  end

  doc = pandoc.walk(doc, function(x)
    if x.tag == "Para" then
      process_paragraph(x)
    end
    return x
  end)

  return doc
end


-- Lua filter for Pandoc to replace paragraph text with the contents of linked markdown files

-- Lua filter for Pandoc to replace paragraph text with the contents of linked markdown files, ignoring metadata

local function read_markdown_file(filepath)
  -- Read the file content
  local file = io.open(filepath, "r")
  if not file then
    return pandoc.Para({pandoc.Str("[Error: Unable to read file '" .. filepath .. "']")})
  end
  local content = file:read("*all")
  file:close()

  -- Parse the markdown content into a Pandoc document (ignoring metadata)
  local parsed_content = pandoc.read(content, "markdown")

  -- Return only the document's content (ignoring the metadata)
  return parsed_content.blocks
end

function Para(elem)
  local new_blocks = {}

  -- Iterate over inline elements of the paragraph to find links
  for _, inline in pairs(elem.content) do
    if inline.t == "Link" then
      local target = inline.target
      -- Check if the link points to a markdown file
      if target:match("%.md$") then
        -- Read the markdown file and append its contents to the new blocks
        local blocks_from_file = read_markdown_file(target)
        for _, block in pairs(blocks_from_file) do
          table.insert(new_blocks, block)
        end
      end
    end
  end

  -- If no markdown file links were found, return the paragraph as is
  if #new_blocks == 0 then
    return elem
  end

  -- Return the new content (blocks from the markdown file)
  return new_blocks
end


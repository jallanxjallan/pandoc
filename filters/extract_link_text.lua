

-- Helper function to read a file and return its content without metadata
local function read_markdown_file(filepath)
  local file = io.open(filepath, "r")
  if not file then
    io.stderr:write("Error: Could not open file: " .. filepath .. "\n")
    return nil
  end

  local content = file:read("*all")
  file:close()

  -- Use Pandoc to parse the markdown file content, ignoring metadata
  local parsed_content = pandoc.read(content, "markdown").blocks
  return parsed_content
end

-- The filter for paragraphs
function BulletList(el)
  local concatenated_content = {}
  local contains_link = false

  for _, elem in ipairs(el.content) do
    if elem.t == "Link" then
      local target = elem.target

      -- Check if the link is to a local markdown file
      -- load file list if one exists in local directory
      -- generate file list by grepping "stutus: submit:
      if target:match("%.md$") then
        contains_link = true
        -- Attempt to read the file
        local file_content = read_markdown_file(target)
        if file_content then
          -- Append content without metadata
          for _, block in ipairs(file_content) do
            table.insert(concatenated_content, block)
          end
        else
          -- If reading fails, report an error and continue
          io.stderr:write("Error: Could not read markdown file: " .. target .. "\n")
        end
      end
    end
  end

  -- If links were found and processed, replace paragraph with concatenated blocks
  if contains_link and #concatenated_content > 0 then
    return concatenated_content  -- Return as a list of blocks
  else
    -- If no links were found, return the paragraph unchanged
    return el
  end
end

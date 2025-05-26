-- Helper function to determine if a link points to a local .md file
local function is_local_markdown(link_target)
  return not link_target:match("^https?://") and link_target:match("%.md$")
end

-- Read and parse a Markdown file into Pandoc blocks using pandoc.pipe
local function read_blocks_from_file(filepath)
  local file = io.open(filepath, "r")
  if not file then
    io.stderr:write("Warning: could not open file '" .. filepath .. "'\n")
    return {}
  end
  file:close()

  local json = pandoc.pipe("pandoc", {"-f", "markdown", "-t", "json", filepath}, "")
  local parsed = pandoc.read(json, "json")
  return parsed.blocks
end

-- Replace a paragraph with the blocks from any linked local .md files
function Para(el)
  local new_blocks = {}

  for _, inline in ipairs(el.content) do
    if inline.t == "Link" then
      local target = inline.target
      if is_local_markdown(target) then
        local blocks = read_blocks_from_file(target)
        for _, block in ipairs(blocks) do
          table.insert(new_blocks, block)
        end
      end
    end
  end

  -- If we found one or more valid local .md links, return the combined blocks
  if #new_blocks > 0 then
    return new_blocks
  else
    return el
  end
end

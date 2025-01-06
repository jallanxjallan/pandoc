-- Pandoc Lua Filter to generate a directory tree from a markdown document
-- luarocks install luafilesystem

local lfs = require("lfs")
local current_path = {}

-- Function to create a directory
local function create_directory(path)
  if not lfs.attributes(path, "mode") then
    assert(lfs.mkdir(path), "Failed to create directory: " .. path)
  end
end

-- Function to write content to a file
local function write_to_file(path, content)
  local file = assert(io.open(path, "w"), "Failed to open file: " .. path)
  file:write(content)
  file:close()
end

-- Handle each header and its content
local function process_header_and_content(el)
  local level = el.level
  local title = pandoc.utils.stringify(el.content)

  -- Trim the path to the current heading level
  while #current_path >= level do
    table.remove(current_path)
  end

  -- Sanitize the folder name
  local sanitized_title = title:gsub("[^%w%s%-_]", ""):gsub("%s+", "_")
  table.insert(current_path, sanitized_title)

  -- Create the directory
  local dir_path = table.concat(current_path, "/")
  create_directory(dir_path)

  -- Return the path to be used for saving text content later
  return dir_path
end

-- Filter for Blocks
local function filter_blocks(blocks)
  local current_dir = nil
  local content_buffer = {}

  local function save_content()
    if current_dir and #content_buffer > 0 then
      local content = table.concat(content_buffer, "\n")
      write_to_file(current_dir .. "/content.txt", content)
      content_buffer = {}
    end
  end

  local new_blocks = {}
  for _, block in ipairs(blocks) do
    if block.t == "Header" then
      -- Save content of the previous heading
      save_content()
      -- Process new heading
      current_dir = process_header_and_content(block)
    else
      -- Collect text content
      if block.t == "Para" or block.t == "Plain" then
        table.insert(content_buffer, pandoc.utils.stringify(block))
      end
    end
    table.insert(new_blocks, block)
  end

  -- Save remaining content at the end
  save_content()

  return new_blocks
end

-- Main filter entry points
return {
  {
    Blocks = filter_blocks
  }
}


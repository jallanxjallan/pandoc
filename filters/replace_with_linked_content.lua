-- Load workflow symbol table
local function load_symbols(group, filepath)
  local symbols = {}
  local in_group = false
  for line in io.lines(filepath) do
    line = line:match("^%s*(.-)%s*$")
    if line:match("^#%s*" .. group) then
      in_group = true
    elseif line:match("^#") then
      in_group = false
    elseif in_group and line:match(" = ") then
      local sym = line:match("^(.-)%s*=")
      if sym then
        symbols[sym] = true
      end
    end
  end
  return symbols
end

local workflow_symbols = load_symbols("submit", "/home/jeremy/.workflow_symbols")

-- Check if a string starts with a workflow symbol
local function is_prefixed_by_symbol(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Str" then
      for symbol, _ in pairs(workflow_symbols) do
        if el.text:find("^" .. symbol) then
          print('found'..symbol)
          return true
        end
      end
    end
    if el.t == "Emph" or el.t == "Strong" or el.t == "Span" then
      if is_prefixed_by_symbol(el.c) then return true end
    end
  end
  return false
end

-- Check if the link points to a local .md file
local function is_local_markdown(link_target)
  return not link_target:match("^https?://") and link_target:match("%.md$")
end

-- Read a markdown file and return its Pandoc blocks
local function read_blocks_from_file(filepath)
  local file = io.open(filepath, "r")
  if not file then error("Could not open file: " .. filepath) end
  file:close()

  local json = pandoc.pipe("pandoc", {"-f", "markdown", "-t", "json", filepath}, "")
  if not json or json == "" then
    error("Empty JSON returned from pandoc for file: " .. filepath)
  end

  local success, parsed = pcall(pandoc.read, json, "json")
  if not success or not parsed or not parsed.blocks then
    error("Failed to parse pandoc JSON from file: " .. filepath)
  end

  if #parsed.blocks == 0 then
    error("Parsed file has no content blocks: " .. filepath)
  end

  return parsed.blocks
end

-- Only process paragraphs that start with a workflow symbol,
-- and return only the content of any linked .md files
function Para(el)
  if not is_prefixed_by_symbol(el.content) then
    return el
  end

  local blocks = {}

  for _, inline in ipairs(el.content) do
    if inline.t == "Link" and is_local_markdown(inline.target) then
      local linked_blocks = read_blocks_from_file(inline.target)
      for _, b in ipairs(linked_blocks) do
        table.insert(blocks, b)
      end
    end
  end

  return (#blocks > 0) and blocks or {}
end


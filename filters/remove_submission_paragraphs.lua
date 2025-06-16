-- Pandoc Lua filter to remove paragraphs starting with specified symbols based on the "submission" metadata field
-- Usage: pandoc --lua-filter=remove_submission_paragraphs.lua input.md -o output.md

-- Load a symbol table from a file, grouping entries by heading
function load_symbols(group, filepath)
  local loaded = {}
  local in_group = false
  for line in io.lines(filepath) do
    line = line:match("^%s*(.-)%s*$")
    if line:match("^#%s*" .. group) then
      in_group = true
    elseif line:match("^#") then
      in_group = false
    elseif in_group and line:match(" = ") then
      local sym, desc = line:match("^(.-)%s*=\s*(.+)$")
      if sym and desc then
        loaded[sym] = desc
      end
    end
  end
  return loaded
end

-- Configuration: adjust these to point to your symbol file and group name
local symbol_group = "submit"
local symbol_file  = "/home/jeremy/.workflow_symbols""

-- Helper to extract metadata values into a Lua list of strings
local function get_meta_list(meta_val)
  local out = {}
  if not meta_val then return out end
  if meta_val.t == "MetaList" then
    for _, item in ipairs(meta_val) do
      table.insert(out, pandoc.utils.stringify(item))
    end
  else
    table.insert(out, pandoc.utils.stringify(meta_val))
  end
  return out
end

-- Main Pandoc callback
return {
  {
    Pandoc = function(doc)
      -- Load symbols for this run
      local symbols = load_symbols(symbol_group, symbol_file)
      -- Read the "submission" metadata field into a list
      local submission_items = get_meta_list(doc.meta.submission)

      -- Filter function for paragraphs
      local function filter_para(elem)
        local txt = pandoc.utils.stringify(elem)
        for sym, _ in pairs(symbols) do
          if txt:sub(1, #sym) == sym then
            -- If this symbol appears in metadata.submission, drop the paragraph
            for _, v in ipairs(submission_items) do
              if v == sym then
                return {}  -- remove this Para
              end
            end
          end
        end
        return elem  -- keep Para unchanged
      end

      -- Walk all blocks, applying our paragraph filter
      doc.blocks = pandoc.walk_block(pandoc.Div(doc.blocks), { Para = filter_para }).content
      return doc
    end
  }
}

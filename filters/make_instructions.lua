-- make_instruction.lua
-- Pandoc filter to collect command line input file paths in metadata and output only metadata

function Pandoc(doc)
  -- Collect the input file paths from the Pandoc state
  local input_files = pandoc.List()
  
  -- PANDOC_STATE.input_files contains the list of input files passed via command line
  for _, file in ipairs(PANDOC_STATE.input_files) do
    input_files:insert(pandoc.Str(file))
  end
  
  -- Add the file paths to the document's metadata under 'input_files'
  doc.meta.parents = input_files
  
  -- Return a Pandoc document with empty body and the modified metadata
  return pandoc.Pandoc({}, doc.meta)
end


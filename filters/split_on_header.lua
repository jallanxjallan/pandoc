  --!/usr/local/bin/lua


local source
local source_directory
local target_directory
local target_basename 
local metadata

local function padInteger(number, width)
  return string.format("%0"..width.."d", number)
end

local function tchelper(first, rest)
    title = first:upper()..rest:lower()
    return title:gsub('_', ' ').gsub("[^%w%s]", "")
end
  -- Add extra characters to the pattern if you need to. _ and ' are
  --  found in the middle of identifiers and English words.
  -- We must also put %w_' into [%w_'] to make it handle normal stuff
  -- and extra stuff the same.
  -- This also turns hex numbers into, eg. 0Xa7d4
  -- str = str:gsub("(%a)([%w_']*)", tchelper)

function export_section(sequence, section)
  local sequence_string = padInteger(sequence, 3)
  local target_filename = target_basename..'_'..sequence_string..'.md'
  local section_filepath = pandoc.path.join({target_directory, target_filename})
  
  local section_metadata
  if metadata ~= nil then
    section_metadata = metadata
  else
    section_metadata = {}
  end
  
  section_metadata['sequence'] = tostring(sequence)

  local section_doc = pandoc.Pandoc(section.content, section_metadata)

  local tempFileName = os.tmpname() 
  pandoc.utils.run_json_filter(section_doc, 'tee', {tempFileName})
  
  local args = {
    '--standalone',
    '--from=json',
    '--to=markdown',
    '--template=edit_document',
    '--lua-filter=header_to_title.lua',
    '--lua-filter=set_creation_date.lua',
    '--output='..section_filepath,
    tempFileName
  }

  rs = pandoc.pipe("pandoc", args, '') 
  
  return section_filepath
end

function Pandoc(doc) 
  local source_filepath = PANDOC_STATE['input_files'][1]
  local source_filename = pandoc.path.filename(source_filepath) 
  local target_filepath = PANDOC_STATE['output_file'] 
  local target_filename = pandoc.path.filename(source_filepath)
  target_directory = pandoc.path.directory(target_filepath) 
  metadata = doc.meta 
  target_basename = pandoc.path.split_extension(target_filename) 
  

--  td = pandoc.path.join({source_directory, basename})
--  target_directory = pandoc.path.normalize(td)
  local cmd_string = "mkdir -p "..target_directory
  os.execute(cmd_string)
  local sections = pandoc.utils.make_sections(false, 1, doc.blocks)
  if #sections == 1 then
    return doc
  else
    for sequence, section in pairs(sections) do
      if section.identifier ~= nil then
        rs = export_section(sequence, section) 
        print(rs)
      end
    end
    os.exit()
  end
end

  --!/usr/local/bin/lua


local source
local directory
local basename 
local metadata

local function padInteger(number, width)
  return string.format("%0"..width.."d", number)
end

local function tchelper(first, rest)
     return first:upper()..rest:lower()
end
  -- Add extra characters to the pattern if you need to. _ and ' are
  --  found in the middle of identifiers and English words.
  -- We must also put %w_' into [%w_'] to make it handle normal stuff
  -- and extra stuff the same.
  -- This also turns hex numbers into, eg. 0Xa7d4
  -- str = str:gsub("(%a)([%w_']*)", tchelper)

function export_section(sequence, section)

  local sequence_string = padInteger(sequence, 3)
  local stem = basename..'_'..sequence_string
  local section_filepath = pandoc.path.join({directory, stem..'.md'})
  
  local section_metadata
  if metadata ~= nil then
    section_metadata = metadata
  else
    section_metadata = {}
  end

  section_metadata['source'] = source
  section_metadata['sequence'] = tostring(sequence)
  section_metadata['name'] = stem:gsub("(%a)([%w_']*)", tchelper)


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
  source = PANDOC_STATE['input_files'][1]
  local filepath = PANDOC_STATE['output_file'] 
  local filename = pandoc.path.filename(filepath) 
  directory = pandoc.path.directory(filepath) 
  basename = pandoc.path.split_extension(filename) 
  metadata = doc.meta
  
  
  local sections = pandoc.utils.make_sections(false, 1, doc.blocks)
  if #sections == 1 then
    return doc
  else
    for sequence, section in pairs(sections) do
      if section.identifier ~= nil then
        rs = export_section(sequence, section) 
        
      end
    end
    os.exit()
  end
end

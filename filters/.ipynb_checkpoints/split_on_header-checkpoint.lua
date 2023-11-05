  --!/usr/local/bin/lua
local identifier = require 'identifier'

local tempdir
local input_filepath
local output_filepath
local input_filename
local output_dir
local output_filename
local output_extention
local output_stem
local input_stem
local input_meta

local function tchelper(first, rest)
     return first:upper()..rest:lower()
end
  -- Add extra characters to the pattern if you need to. _ and ' are
  --  found in the middle of identifiers and English words.
  -- We must also put %w_' into [%w_'] to make it handle normal stuff
  -- and extra stuff the same.
  -- This also turns hex numbers into, eg. 0Xa7d4
  -- str = str:gsub("(%a)([%w_']*)", tchelper)


remove_header = {
    Header = function(el)
      if el.level == 1 then
        return {}
      end
    end
}

function export_section(sequence, section)
  -- local section_filename = output_filename:gsub('.md', '_'..section.identifier)

  local file_id = identifier.uuid()
  local json_filepath = tempdir..'/'..file_id..'.json'
  local section_filepath = output_dir.."/"..output_stem.."-"..tostring(sequence).."-"..section.identifier.."."..output_extention
  local section_metadata
  if input_meta ~= nil then
    section_metadata = input_meta
  else
    section_metadata = {}
  end

  section_metadata['source'] = input_stem
  section_metadata['sequence'] = tostring(sequence)
  section_metadata['title'] = section.identifier:gsub("-", " "):gsub("(%a)([%w_']*)", tchelper)


  local sub_doc = pandoc.Pandoc(section.content, section_metadata)

  -- local div = pandoc.Div(sub_doc.blocks)
  -- local sub_blocks = pandoc.walk_block(div.content, remove_header)

  pandoc.utils.run_json_filter(sub_doc, 'tee', {json_filepath})

  local args = {
    '--standalone',
    '--lua-filter=strip_headers.lua',
    '--output='..section_filepath,
    json_filepath
  }

  rs = pandoc.pipe("pandoc", args, '')

  return section_filepath
end

function Pandoc(doc)
  input_meta = doc.meta
  tempdir = pandoc.pipe('mktemp', {"-d"}, ''):gsub('\n', '')
  input_filepath = PANDOC_STATE['input_files'][1]
  input_filename = input_filepath:match( "([^/]+)$")
  input_extention = input_filename:match("[^.]+$")
  input_stem = input_filename:gsub("."..input_extention, '')
  output_filepath = PANDOC_STATE['output_file']
  output_filename = output_filepath:match( "([^/]+)$")
  output_dir = output_filepath:match("(.-)([^\\/]-%.?([^%.\\/]*))$")
  output_extention = output_filename:match("[^.]+$")
  output_stem = output_filename:gsub("."..output_extention, '')

  -- namespace = input_meta['namespace']
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

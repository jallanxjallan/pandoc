  --!/usr/local/bin/lua 

local tempdir
local editdir
local edit_filename_template
local token_limit = 2000
local token_count = 0
local tokens = {}
local sequence = 1

function unique_string(length)
  local characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  local str = ""
  
  for i = 1, length do
      local randomIndex = math.random(1, #characters)
      str = str .. string.sub(characters, randomIndex, randomIndex)
  end
  
  return str
end


function make_edit_filepath() 
  local edit_filename = edit_filename_template.."_"..tostring(sequence)..'.md'
  local edit_filepath = pandoc.path.join({editdir, edit_filename})
  
  local f=io.open(edit_filepath,"r") 
  if f == nil then 
    sequence = sequence + 1
    return edit_filepath 
  else 
    io.close(f)
    print(edit_filepath..' already exists') 
    return false
  end 
end


function export_edit_doc() 
  edit_filepath = make_edit_filepath()
  if edit_filepath ~= false then 
    local json_filename = unique_string(16)..'.json'
    local json_filepath = pandoc.path.join({tempdir, json_filename})
    
    pandoc.utils.run_json_filter(pandoc.Pandoc(tokens), 'tee', {json_filepath})

    local args = {
      '--standalone',
      '--output='..edit_filepath,
      json_filepath
    }

    rs = pandoc.pipe("pandoc", args, '') 
  end

end

-- Define a function to count tokens and call export
tokencount = {
  Inline = function(el) 
      table.insert(tokens, el) 
      if #tokens > token_limit then 
        export_edit_doc()
        tokens = {}
      end
  end
}
  

-- Main function for the Pandoc Lua filter
function Pandoc(doc) 
  tempdir = pandoc.pipe('mktemp', {"-d"}, ''):gsub('\n', '') 
  editdir = pandoc.path.directory(PANDOC_STATE['output_file']) 
  local edit_filename =  pandoc.path.filename(PANDOC_STATE['input_files'][1])
  parts = pandoc.path.split_extension(edit_filename)
  edit_filename_template = parts
    -- Traverse the Pandoc document and process tokens
  pandoc.walk_block(pandoc.Div(doc.blocks), tokencount) 
  if #tokens > 0 then 
      export_edit_doc()
  end
  os.exit()
end

  



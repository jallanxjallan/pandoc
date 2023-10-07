
local words = 0
local status = 'No Status'
local name

wordcount = {
  Str = function(el)
    -- we don't count a word if it's entirely punctuation:
    if el.text:match("%P") then
        words = words + 1
    end
  end
}

function Meta(meta) 
  for k,v in pairs(meta) do 
    if k == 'status' then 
      status = pandoc.utils.stringify(v) 
    end 
    if k == 'name' then 
      name = pandoc.utils.stringify(v) 
    end
  end 
end

function Pandoc(el)

    -- skip metadata, just count body:
    pandoc.walk_block(pandoc.Div(el.blocks), wordcount) 
    local filename = pandoc.path.filename(PANDOC_STATE['input_files'][1])
    print(name..': status: '..status..' - words: '..words)
    os.exit()
    
end

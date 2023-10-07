local function title_case(first, rest)
    return first:upper()..rest:lower()
end

function Pandoc(doc) 
    local filepath = PANDOC_STATE['output_file']
    local directory = pandoc.path.directory(filepath) 
    local filename = pandoc.path.filename(filepath) 
    local basename = pandoc.path.split_extension(filename) 
    local file = io.open (filepath) 
    if file ~= nil then 
        print(filepath..' already exists') 
        io.close(file) 
        os.exit() 
    end 
    doc.meta['name'] = basename:gsub("_", " "):gsub("(%a)([%w_']*)", title_case)
    return doc
end


  

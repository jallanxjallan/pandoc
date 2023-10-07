local comments 
local doc_name

function RawInline(elem) 
    comments.insert(#comments +1, elem.text)
end 

function Meta(meta) 
    for key, value in pairs(meta) do 
        if key == 'name' then 
            doc_name = pandoc.util.stringify(value) 
        end 
    end

function Pandoc(doc) 
    if #comments > 0 then 
        


    ip = PANDOC_STATE['input_files'][1]
    dir =  pandoc.path.directory(ip)
    stem, ext = pandoc.path.split_extension(ip)
    print(pandoc.path.join({dir, stem, ext}))
end
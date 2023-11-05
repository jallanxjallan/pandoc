--!/usr/local/bin/lua
local header_text 

extract_header = {
    Header = function(el)  
        if el.level == 1 then 
            header_text = el.content 
            return {} 
        end
    end
}


function Pandoc(doc) 
    pandoc.walk_block(pandoc.Div(doc.blocks), extract_header) 
    if header_text ~= nil then 
        doc.meta['title'] = pandoc.MetaInlines(header_text) 
    end 
    return doc
end

        

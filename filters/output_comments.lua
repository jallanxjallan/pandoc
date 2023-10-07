local comments = {}

function Span(elem) 
    for k,v in pairs(elem.attributes) do 
        if k == 'q' then 
            table.insert(comments, #comments+1,  pandoc.Para(v))
        end      
    end 
end 

function Pandoc(doc) 
    if #comments == 0 then 
        os.exit() 
    else 
        return pandoc.Pandoc(comments, doc.meta)
    end
end
        

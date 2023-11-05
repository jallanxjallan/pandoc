
local note_refs = {}

extract_notes = {
    Code = function (elem) 
        table.insert(note_refs, pandoc.Str(elem.text:gsub('node: ', '')))
    end
}

function Pandoc(doc)
    pandoc.walk_block(pandoc.Div(doc.blocks), extract_notes) 
    print(#note_refs)
    return pandoc.Pandoc(note_refs, doc.meta)
end

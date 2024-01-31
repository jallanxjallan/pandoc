
local note_refs = {}

extract_notes = {
    CodeBlock = function (elem) 
        for note_ref in elem.text:gmatch("[\n]+") do
            table.insert(note_refs, pandoc.Str(note_ref:gsub('node: ', '')))
        end
    end
}

function Pandoc(doc)
    pandoc.walk_block(pandoc.Div(doc.blocks), extract_notes) 
    print(#note_refs)
    return pandoc.Pandoc(note_refs, doc.meta)
end

function Pandoc(doc)
    local new_blocks = {}
    for _, block in ipairs(doc.blocks) do
        if block.t == "BlockQuote" then
            table.insert(new_blocks, pandoc.Para({pandoc.Strong({pandoc.Str("This is a standalone text box")})}))
        end
        table.insert(new_blocks, block)
        if block.t == "BlockQuote" then
            table.insert(new_blocks, pandoc.HorizontalRule())
        end
    end
    return pandoc.Pandoc(new_blocks, doc.meta)
end


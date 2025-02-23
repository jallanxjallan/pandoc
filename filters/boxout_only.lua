function Pandoc(doc)
    local new_blocks = {}
    for i, block in ipairs(doc.blocks) do
        if block.t == "Header" or block.t == "BlockQuote" then
            if block.t == "BlockQuote" then
                table.insert(new_blocks, pandoc.HorizontalRule())
                table.insert(new_blocks, pandoc.Para({pandoc.Strong({pandoc.Str("This is a standalone text box")})}))
            end
            table.insert(new_blocks, block)
            if block.t == "BlockQuote" then
                table.insert(new_blocks, pandoc.HorizontalRule())
            end
        end
    end
    return pandoc.Pandoc(new_blocks, doc.meta)
end


function Pandoc(doc)
    local new_blocks = {}
    local capturing = false
    local hrule_count = 0

    for _, blk in ipairs(doc.blocks) do
        if blk.t == "HorizontalRule" then
            hrule_count = hrule_count + 1
            if hrule_count == 1 then
                capturing = true  -- Start capturing after the first HR
            elseif hrule_count == 2 then
                break  -- Stop capturing after the second HR
            end
        elseif capturing then
            table.insert(new_blocks, blk)
        end
    end
    
    return pandoc.Pandoc(new_blocks, doc.meta)
end


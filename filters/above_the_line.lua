function Pandoc(doc)
    local hblocks = {}
    local found_rule = 0
    for i,el in pairs(doc.blocks) do
        if el.t == "HorizontalRule" then
          found_rule = 1
        end
        if found_rule == 0 then
          table.insert(hblocks, el)
        end
    end
    return pandoc.Pandoc(hblocks, doc.meta)
end

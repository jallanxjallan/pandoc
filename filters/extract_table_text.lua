-- This script saves the contents of the second column of all tables in a separate markdown file.

function Table (table)
    local column2 = {}
    for i, row in ipairs(table['head']['rows']) do
        -- Extract the content from the cells in the second column.
        for j, cell in ipairs(row) do
            if j == 2 then
                -- The text in the cell is assumed to be a paragraph. 
                -- We extract the text from the first (and presumably only) element.
                table.insert(column2, pandoc.utils.stringify(cell.contents[1]))
            end
        end
    end

    -- Write the contents of the second column to a markdown file.
    local file = io.open("column2.md", "w")
    for i, text in ipairs(column2) do
        file:write("* ", text, "\n")
    end
    file:close()

    return table
end

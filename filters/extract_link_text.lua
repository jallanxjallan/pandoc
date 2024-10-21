-- A table to hold the text of the referenced markdown files and headers
local collected_texts = {}

-- Helper function to read the content of a markdown file
local function read_markdown_file(file_path)
    local file = io.open(file_path, "r")
    if not file then
        io.stderr:write("Error: Cannot open file: " .. file_path .. "\n")
        return nil
    end
    local content = file:read("*all")
    file:close()
    return content
end

-- Process paragraphs and inline elements
function Para(elem)
    local new_content = ""
    
    -- Iterate over the inline elements inside the paragraph
    for _, inline in pairs(elem.content) do
        -- Check if the inline element is a link
        if inline.t == "Link" then
            local file_path = inline.target  -- The target file referenced by the link
            
            -- Read the markdown file content
            local file_content = read_markdown_file(file_path)
            
            if file_content then
                -- Append the content to our output table
                table.insert(collected_texts, file_content)
            end
        end
    end
end


-- After all the paragraphs have been processed, output only headers and the referenced text
function Pandoc(doc)
    -- Output only the headers and the collected linked markdown file content
    local output = table.concat(collected_texts, "\n")
    
    -- Create a new Pandoc document with just the referenced text
    return pandoc.Pandoc({pandoc.RawBlock("markdown", output)})
end

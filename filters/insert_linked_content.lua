-- Function to check if a file exists
local function file_exists(filename)
    local file = io.open(filename, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

-- Function to read a file
local function read_file(filename)
    local file = io.open(filename, "r")
    if not file then
        error("Error: Could not open file " .. filename)
    end
    local content = file:read("*all")
    file:close()
    return content
end

-- Function to parse markdown content while ignoring metadata
local function parse_markdown(content, filename)
    local parsed = pandoc.read(content, "markdown")
    if not parsed then
        error("Error: " .. filename .. " is not a valid markdown file.")
    end
    return parsed.blocks -- Ensure only body content is returned
end

-- Filter function
function Link(el)
    local target = el.target

    -- Check if the link points to a local markdown file
    if target:match("%.md$") and file_exists(target) then
        local content = read_file(target)
        local parsed_blocks = parse_markdown(content, target)

        -- If the link appears inline, replace it with formatted text, not raw escaped text
        if el.content then
            return parsed_blocks
        end

        -- Otherwise, return the full parsed document without metadata
        return parsed_blocks
    end

    return el -- return the original link if it's not a local markdown file
end

return {
    { Link = Link }
}


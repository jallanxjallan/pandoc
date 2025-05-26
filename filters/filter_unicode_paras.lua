-- Symbol table: maps Unicode char to { key = short ID, label = long label }
local symbols = {
  ["⧉"]  = { key = "Boxout", label = "This is a Text Box Placed in the running text" },
  ["▌"]  = { key = "Sidebar", label = "This is a Sidebar on the page margin" },
  ["❝ ❞"] = { key = "PullQuote", label = "This is Pull Quote inside the running text" },
  ["⬖"] = { key = "Spread", label = "This is a standalone page or spread" }
}

-- Extract first UTF-8 character
local function get_first_utf8_char(str)
  return str:match("^[%z\1-\127\194-\244][\128-\191]*")
end

-- Detect if character is alphanumeric (letter or digit)
local function is_alnum(char)
  return char:match("^%w$") ~= nil
end

-- Recursively find first plain string
local function find_first_str(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Str" then
      return el
    elseif el.t == "Emph" or el.t == "Strong" or el.t == "Span" then
      local nested = find_first_str(el.c)
      if nested then return nested end
    end
  end
  return nil
end

-- Main paragraph processor
function Para (elem)
    local head = elem.content[1]
    if head and (head.t == "Code" or head.t == "Quoted") then
      return elem
    end

    local first = find_first_str(elem.content)
    if not first then return elem end

    local char = get_first_utf8_char(first.text)
    local sym = symbols[char]

    if sym then
      local before = pandoc.Para({ pandoc.Str("==== " .. sym.label .. " ====") })
      local after = pandoc.Para({ pandoc.Str("-- end " .. sym.key .. " --") })
      return { before, elem, after }
    else
      return elem
    end
  end


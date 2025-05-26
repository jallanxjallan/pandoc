-- Symbol table: maps Unicode char to { key = metadata_key, label = marker label }
local symbols = {
  ["⧉"]  = { key = "Boxout", label = "Boxout" },
  ["▌"]  = { key = "Sidebar", label = "Sidebar" },
  ["❝ ❞"] = { key = "PullQuote", label = "Pull quote" },
  ["⬖⬘"] = { key = "TwoPageSpread", label = "Two-page spread" }
}

local function get_first_utf8_char(str)
  return str:match("^[%z\1-\127\194-\244][\128-\191]*")
end

local function is_alnum(char)
  return char:match("^%w$") ~= nil
end

-- Finds the first Str and returns its object and index (and parent if nested)
local function find_first_str_with_context(inlines)
  for i, el in ipairs(inlines) do
    if el.t == "Str" then
      return el, i, inlines
    elseif el.t == "Emph" or el.t == "Strong" or el.t == "Span" then
      local nested_str, idx, container = find_first_str_with_context(el.c)
      if nested_str then return nested_str, idx, container end
    end
  end
  return nil
end

return {
  Para = function(elem)
    local head = elem.content[1]
    if head and (head.t == "Code" or head.t == "Quoted") then
      return elem
    end

    local first_str, index, container = find_first_str_with_context(elem.content)
    if not first_str then return elem end

    local char = get_first_utf8_char(first_str.text)
    local sym = symbols[char]

    if sym then
      -- Modify the paragraph's inline content by replacing the first string
      local stripped = first_str.text:sub(#char + 1):gsub("^%s*", "")
      container[index] = pandoc.Str(stripped)

      local before = pandoc.Para({ pandoc.Str("==== " .. sym.label .. " ====") })
      local after = pandoc.Para({ pandoc.Str("-- end " .. sym.label .. " --") })
      return { before, elem, after }
    else
      return elem
    end
  end
}

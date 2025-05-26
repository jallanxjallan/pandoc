local meta = {}

-- Individual layout handlers — stubs for now
local function handle_caption(elem)
  local before = pandoc.Para({ pandoc.Str("==== Photo caption ====") })
  local after = pandoc.Para({ pandoc.Str("-- end Photo caption --") })
  return before, elem, after
end

local function handle_boxout(elem)
  local before = pandoc.Para({ pandoc.Str("==== Boxout ====") })
  local after = pandoc.Para({ pandoc.Str("-- end Boxout --") })
  return before, elem, after
end

local function handle_sidebar(elem)
  local before = pandoc.Para({ pandoc.Str("==== Sidebar ====") })
  local after = pandoc.Para({ pandoc.Str("-- end Sidebar --") })
  return before, elem, after
end

local function handle_quote(elem)
  local before = pandoc.Para({ pandoc.Str("==== Pull quote ====") })
  local after = pandoc.Para({ pandoc.Str("-- end Pull quote --") })
  return before, elem, after
end

local function handle_page(elem)
  local before = pandoc.Para({ pandoc.Str("==== Standalone Page ====") })
  local after = pandoc.Para({ pandoc.Str("-- end Standalone Page --") })
  return before, elem, after
end

-- Symbol table: maps Unicode prefix to metadata key + handler function
local symbols = {
  ['🖼️'] = { key = "caption", handler = handle_caption },
  ['⧉']  = { key = "boxout",  handler = handle_boxout },
  ['▌']  = { key = "sidebar", handler = handle_sidebar },
  ['❝ ❞'] = { key = "quote",  handler = handle_quote },
  ['⬖']  = { key = "page",    handler = handle_page }
}

-- Utility: extract the first UTF-8 character
local function match_symbol(first_str)
  if not first_str or not first_str.text then return nil end
  for symbol, data in pairs(symbols) do
    if first_str.text:find("^" .. symbol) then
      return data
    end
  end
  return nil
end

-- Utility: find first Str in a paragraph, even nested
local function find_first_str_with_context(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Str" then
      return el
    elseif el.t == "Emph" or el.t == "Strong" or el.t == "Span" then
      local nested = find_first_str_with_context(el.c)
      if nested then return nested end
    end
  end
  return nil
end

-- Paragraph filter
local function filter_para(elem)
  local head = elem.content[1]

  if head then
    if head.t == "Code" then
      if meta["code"] == true then return elem else return {} end
    elseif head.t == "Quoted" then
      if meta["quote"] == true then return elem else return {} end
    end
  end

  local first_str = find_first_str_with_context(elem.content)
  if not first_str then
    if meta["text"] == true then return elem else return {} end
  end

  local sym = match_symbol(first_str)

  if sym and meta[sym.key] == true then
    local before, middle, after = sym.handler(elem)
    local result = {}
    if before then table.insert(result, before) end
    table.insert(result, middle)
    if after then table.insert(result, after) end
    return result
  elseif sym then
    return {}
  else
    if meta["text"] == true then return elem else return {} end
  end
end


-- Main entry point
function Pandoc(doc)
  meta = doc.meta
  local walked = pandoc.walk_block(pandoc.Div(doc.blocks), {
    Para = filter_para
  })
  return pandoc.Pandoc(walked.content, meta)
end
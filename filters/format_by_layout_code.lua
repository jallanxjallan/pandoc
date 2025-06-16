local meta = {}
local symbols = {}

-- Load symbol table from shared file
function load_symbols(group, filepath)
  local loaded = {}
  local in_group = false
  for line in io.lines(filepath) do
    line = line:match("^%s*(.-)%s*$")
    if line:match("^#%s*" .. group) then
      in_group = true
    elseif line:match("^#") then
      in_group = false
    elseif in_group and line:match(" = ") then
      local sym, desc = line:match("^(.-)%s*=%s*(.+)$")
      if sym and desc then
        loaded[sym] = desc
      end
    end
  end
  return loaded
end

-- Creates a page divider like: ==== Section Title ====
function page_divider(label, total_width, border_char)
  label = " " .. label .. " "
  total_width = total_width or 80
  border_char = border_char or "="

  local remaining = total_width - #label
  local left = math.floor(remaining / 2)
  local right = remaining - left

  return string.rep(border_char, left) .. label .. string.rep(border_char, right)
end

-- notes to designer
local function handle_note(elem)
  -- 1) Build the NOTE: strong label correctly (it wants a list of inlines)
  local label = pandoc.Strong({ pandoc.Str("LAYOUT NOTE:") })
  local spacer = pandoc.Space()

  -- 2) Remove the first inline (your Unicode “flag”) from the original para
  table.remove(elem.content, 1)

  -- 3) Assemble a *single* list of inlines: { NOTE:, space, rest… }
  local inlines = { label, spacer }
  for _, inline in ipairs(elem.content) do
    table.insert(inlines, inline)
  end

  -- 4) Wrap that inlines list in a Para
  local new_para = pandoc.Para(inlines)

  -- 5) Create your custom-style Attr
  local attr = pandoc.Attr("", {}, { ["custom-style"] = "layout_note" })

  -- 6) Div expects a *list* of blocks
  return pandoc.Div({ new_para }, attr)
end

-- Individual layout handlers
local function handle_running(elem)
  local before = pandoc.Div(
    { pandoc.Para({ pandoc.Str(page_divider('Running Text', 60, '=')) }) },
    pandoc.Attr("", {}, {["custom-style"] = "break_before"})
  )

  local after = pandoc.Div(
    { pandoc.Para({ pandoc.Str(page_divider('End Text', 60, '-')) }) },
    pandoc.Attr("", {}, {["custom-style"] = "break_after"})
  )

  return before, elem, after
end


local function handle_caption(elem)
 local before = pandoc.Div(
    { pandoc.Para({ pandoc.Str(page_divider('Photo Caption', 60, '=')) }) },
    pandoc.Attr("", {}, {["custom-style"] = "before_wrapper"})
  )

  local after = pandoc.Div(
    { pandoc.Para({ pandoc.Str(page_divider('end caption', 60, '=')) }) },
    pandoc.Attr("", {}, {["custom-style"] = "after_wrapper"})
  )

  return before, elem, after
end

local function handle_boxout(elem)
  local before = pandoc.Div(
    { pandoc.Para({ pandoc.Str(page_divider('Text Box', 60, '=')) }) },
    pandoc.Attr("", {}, {["custom-style"] = "break_before"})
  )

  local after = pandoc.Div(
    { pandoc.Para({ pandoc.Str(page_divider('end boxout', 60, '=')) }) },
    pandoc.Attr("", {}, {["custom-style"] = "break_after"})
  )

  return before, elem, after
end

local function handle_sidebar(elem)
  local before = pandoc.Div(
    { pandoc.Para({ pandoc.Str(page_divider('Sidebar', 60, '=')) }) },
    pandoc.Attr("", {}, {["custom-style"] = "before_wrapper"})
  )

  local after = pandoc.Div(
    { pandoc.Para({ pandoc.Str(page_divider('end sidebar', 60, '=')) }) },
    pandoc.Attr("", {}, {["custom-style"] = "after_wrapper"})
  )

  return before, elem, after
end

local function handle_quote(elem)
  local before = pandoc.Div(
    { pandoc.Para({ pandoc.Str(page_divider('Pull Quote', 60, '=')) }) },
    pandoc.Attr("", {}, {["custom-style"] = "before_wrapper"})
  )

  local after = pandoc.Div(
    { pandoc.Para({ pandoc.Str(page_divider('end quote', 60, '=')) }) },
    pandoc.Attr("", {}, {["custom-style"] = "after_wrapper"})
  )

  return before, elem, after
end

local function handle_page(elem)

  local before = pandoc.Div(
    { pandoc.Para({ pandoc.Str(page_divider('Standalone Page', 60, '=')) }) },
    pandoc.Attr("", {}, {["custom-style"] = "break_before"})
  )

  local after = pandoc.Div(
    { pandoc.Para({ pandoc.Str(page_divider('end page', 60, '=')) }) },
    pandoc.Attr("", {}, {["custom-style"] = "break_after"})
  )

  return before, elem, after
end

-- Handler map: assign known handlers to symbols
local handlers = {
  ["¶"] = { key = "running",  handler = handle_running },
  ["🖼️"] = { key = "caption", handler = handle_caption },
  ["⧉"]  = { key = "boxout",  handler = handle_boxout },
  ["▌"]  = { key = "sidebar", handler = handle_sidebar },
  ["❝ ❞"] = { key = "quote",  handler = handle_quote },
  ["⬖"]  = { key = "page",    handler = handle_page },
  ["📐"] = { key = "note",    handler = handle_note }
}

-- Utility: find first Str in a paragraph
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

-- Match symbol only if defined in the loaded table
local function match_symbol(first_str)
  if not first_str or not first_str.text then return nil end
  for sym, _ in pairs(symbols) do
    if first_str.text:find("^" .. sym) then
      return sym
    end
  end
  return nil
end

local function filter_para(elem)
  local first_str = find_first_str_with_context(elem.content)
  local symbol = match_symbol(first_str)

  if not symbol then
    return elem -- unchanged if no symbol
  end

  local before, middle, after = handlers[symbol].handler(elem)
  return { before, middle, after }
end


-- Main entry point
function Pandoc(doc)
  meta = doc.meta
  symbols = load_symbols("submit", "/home/jeremy/.workflow_symbols")
  local walked = pandoc.walk_block(pandoc.Div(doc.blocks), {
    Para = filter_para
  })
  return pandoc.Pandoc(walked.content, meta)
end

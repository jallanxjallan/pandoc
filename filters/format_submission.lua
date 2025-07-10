local meta = {}
local symbols = {}
local mode = nil

-- ANSI color codes for logging
local function color_text(level, msg)
  local colors = {
    INFO = "\27[36m",
    WARN = "\27[33m",
    ERROR = "\27[31m",
    RESET = "\27[0m"
  }
  return string.format("%s[%s] %s%s\n", colors[level], level, msg, colors.RESET)
end

local function log_info(msg) io.stderr:write(color_text("INFO", msg)) end
local function log_warn(msg) io.stderr:write(color_text("WARN", msg)) end
local function log_error(msg) io.stderr:write(color_text("ERROR", msg)) end

-- Optional: load symbols from file (no longer required)
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

-- Layout handlers
local function layout_handle_note(elem)
  table.remove(elem.content, 1)
  local label = pandoc.Strong({ pandoc.Str("LAYOUT NOTE:") })
  local spacer = pandoc.Space()
  local inlines = { label, spacer }
  for _, inline in ipairs(elem.content) do
    table.insert(inlines, inline)
  end
  local new_para = pandoc.Para(inlines)
  local attr = pandoc.Attr("", {}, { ["custom-style"] = "layout_note" })
  return pandoc.Div({ new_para }, attr)
end

local function layout_handle_running(elem)
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

local function layout_handle_caption(elem)
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

local function layout_handle_boxout(elem)
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

local function layout_handle_sidebar(elem)
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

local function layout_handle_quote(elem)
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

local function layout_handle_page(elem)
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

-- Review (content) handlers
local function content_handle_note(elem) return elem end
local function content_handle_running(elem) return nil, elem, nil end
local function content_handle_caption(elem) return nil, elem, nil end
local function content_handle_boxout(elem) return nil, elem, nil end
local function content_handle_sidebar(elem) return nil, elem, nil end
local function content_handle_quote(elem) return nil, elem, nil end
local function content_handle_page(elem) return nil, elem, nil end

-- Fallback handler
local no_op_handler = function(elem)
  log_warn("No handler found for input: " .. pandoc.utils.stringify(elem))
  return nil
end

-- Mode and handler setup
function Pandoc(doc)
  meta = doc.meta
  symbols = load_symbols("submit", "/home/jeremy/.workflow_symbols") -- optional
  mode = pandoc.utils.stringify(meta.mode or ""):lower()
  if mode ~= "review" and mode ~= "layout" then
    mode = os.getenv("PANDOC_HANDLER_MODE") or "layout"
  end
  log_info("Using mode: " .. tostring(mode))
  return doc
end

local mode_handlers = {
  layout = {
    running = { layout_handle_running },
    caption = { layout_handle_caption },
    boxout  = { layout_handle_boxout },
    sidebar = { layout_handle_sidebar },
    quote   = { layout_handle_quote },
    page    = { layout_handle_page },
    note    = { layout_handle_note },
  },
  review = {
    running = { content_handle_running },
    caption = { content_handle_caption },
    boxout  = { content_handle_boxout },
    sidebar = { content_handle_sidebar },
    quote   = { content_handle_quote },
    page    = { content_handle_page },
    note    = { content_handle_note },
  }
}

local function default(name)
  return (mode_handlers[mode] and mode_handlers[mode][name]) or { no_op_handler }
end

local handler_definitions = {
  ["¶"]   = { key = "running",  handlers = default("running") },
  ["🖼️"]  = { key = "caption",  handlers = default("caption") },
  ["⧉"]   = { key = "boxout",   handlers = default("boxout")  },
  ["▌"]   = { key = "sidebar",  handlers = default("sidebar") },
  ["❝ ❞"] = { key = "quote",    handlers = default("quote")   },
  ["⬖"]   = { key = "page",     handlers = default("page")    },
  ["📐"]  = { key = "note",     handlers = default("note")    },
}

local handlers = setmetatable(handler_definitions, {
  __index = function(_, key_symbol)
    log_warn("Unknown symbol: '" .. tostring(key_symbol) .. "'")
    return { key = "unknown", handlers = { no_op_handler } }
  end
})

-- Use handler symbols, not symbols from external file
local function match_known_symbol(text)
  for sym, _ in pairs(handlers) do
    if text:find("^%s*" .. sym) then
      return sym
    end
  end
  return nil
end

-- Paragraph handler
function Para(elem)
  local ok, result = pcall(function()
    local text = pandoc.utils.stringify(elem)
    local sym = match_known_symbol(text)
    if not sym then return nil end
    local entry = handlers[sym]
    local before, middle, after

    for _, fn in ipairs(entry.handlers) do
      local handler_ok, b, m, a = pcall(fn, middle or elem)
      if not handler_ok then
        log_error("Handler failed for '" .. entry.key .. "': " .. tostring(b))
        return elem
      end
      before, middle, after = b, m, a
    end

    return { before, middle, after }
  end)

  if ok then return result else
    log_error("Unexpected error in Para: " .. tostring(result))
    return elem
  end
end

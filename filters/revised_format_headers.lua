
-- Pandoc Lua filter to transform headers by prefixing parsed segments
function Header(el)
  -- Ensure pandoc.meta is not nil
  local heading_prefixes = {}
  if PANDOC_DOCUMENT and PANDOC_DOCUMENT.meta then
    for key, value in pairs(PANDOC_DOCUMENT.meta.heading_prefixes) do
      heading_prefixes[key] = value
    end
  end

  -- Convert header content to a string
  local header_text = pandoc.utils.stringify(el.content)

  -- Split the header by dots and store the segments in a table (list)
  local segments = {}
  for segment in header_text:gmatch("([^.]+)") do
    table.insert(segments, segment)
  end

  -- Initialize an empty table to store the prefixed segments
  local prefixed_segments = {}

  -- Iterate over the segments and prefix them with the corresponding prefix from the metadata
  for i, segment in ipairs(segments) do
    local prefix = heading_prefixes[i] or ""  -- Get the prefix from metadata, or use an empty string if not available
    table.insert(prefixed_segments, prefix .. segment)
  end

  -- Join the prefixed segments back into a single header text
  local new_header_text = table.concat(prefixed_segments, ".")

  -- Set the new header content
  el.content = { pandoc.Str(new_header_text) }

  return el
end

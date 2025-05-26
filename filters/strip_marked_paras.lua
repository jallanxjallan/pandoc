-- strip_if_starts_with_symbol.lua
function is_symbol(cp)
  -- Exclude basic Latin, punctuation, and bracket ranges
  if cp < 0x2000 then return false end

  -- Include graphical symbol ranges
  return (
    (cp >= 0x2190 and cp <= 0x21FF) or  -- Arrows
    (cp >= 0x2300 and cp <= 0x23FF) or  -- Misc Technical
    (cp >= 0x25A0 and cp <= 0x25FF) or  -- Geometric Shapes
    (cp >= 0x2600 and cp <= 0x26FF) or  -- Misc Symbols
    (cp >= 0x2700 and cp <= 0x27BF) or  -- Dingbats
    (cp >= 0x1F000 and cp <= 0x1FFFF)   -- Emojis, pictographs
  )
end

function Para(el)
  local first = el.content[1]
  if first and first.t == "Str" then
    local cp = utf8.codepoint(first.text, 1)
    if is_symbol(cp) then
      return {}  -- Strip paragraph
    end
  end
end

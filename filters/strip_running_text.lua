-- keep_if_starts_with_symbol.lua
function is_symbol(cp)
  -- Exclude ASCII/brackets/punctuation/etc.
  if cp < 0x2000 then return false end

  return (
    (cp >= 0x2190 and cp <= 0x21FF) or
    (cp >= 0x2300 and cp <= 0x23FF) or
    (cp >= 0x25A0 and cp <= 0x25FF) or
    (cp >= 0x2600 and cp <= 0x26FF) or
    (cp >= 0x2700 and cp <= 0x27BF) or
    (cp >= 0x1F000 and cp <= 0x1FFFF)
  )
end

function Para(el)
  local first = el.content[1]
  if first and first.t == "Str" then
    local cp = utf8.codepoint(first.text, 1)
    if not is_symbol(cp) then
      return {}  -- Strip paragraph
    end
  end
end

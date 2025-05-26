function Para(elem)
  local first = elem.content[1]
  if first and first.t == "Str" then
    local char = first.text:match("^[%z\1-\127\194-\244][\128-\191]*")
    if char and utf8.codepoint(char) > 127 then
      return {}
    end
  end
end

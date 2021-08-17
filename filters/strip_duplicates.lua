local prev_header
local prev_para
local prev_span


function Span(elem)
  local text = pandoc.utils.stringify(elem)
  print(text, prev_para)
  if text == prev_para then
    return {}
  else
    prev_para = text
    return elem
  end
end

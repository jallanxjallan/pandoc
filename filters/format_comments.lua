local comment_id = 0
local comment, header
local comment_types = {qst='Question', cmt='Comment', sgn='Suggestion'}

function Span(elem)
  for key, value in pairs(comment_types) do
    comment = elem.attributes[key]
    if comment ~= nil then
      header = value
      break
    end
  end
  if comment == nil then
    return elem
  end
  comment_id = comment_id + 1
  start = pandoc.Span(comment)
  start.attr = {class='comment-start', id=comment_id, author="Jeremy", date="2020-11-25T09:42:33Z"}
  finish=pandoc.Span('')
  finish.attr = {class='comment-end', id=comment_id}
  new = {}
  table.insert(new, start)
  table.insert(new, pandoc.Str(pandoc.utils.stringify(elem.content)))
  table.insert(new, finish)
  return new
end

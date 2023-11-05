function CodeInline(elem)
  if elem.t == "Code" then
    return pandoc.Str(elem.text)
  end
end

return {
  { Inline = CodeInline }
}

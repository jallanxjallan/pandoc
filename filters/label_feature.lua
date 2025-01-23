local function Div(el)
  if el.classes:includes("feature") then
    local boilerplate = pandoc.Para{
      pandoc.Span{
        "This is the boilerplate text for features.",
        attributes = { style = "font-size: 70%;" }
      }
    }
    el.content:insert(1, boilerplate)
  end
  return el
end

return {
  { Div = Div }
}
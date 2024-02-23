-- hr-to-header.lua
function HorizontalRule()
    return pandoc.Header(1, pandoc.Str("Some default text"))
end
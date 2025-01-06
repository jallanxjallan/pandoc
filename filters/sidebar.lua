function Div(el)
  -- Check if the div has the class 'sidebar'
  if el.classes:includes("sidebar") then
    -- Add inline styling for the HTML div
    local style = [[
     style="border-top: 1px solid; border-bottom: 1px solid; 
       font-variant: small-caps; font-weight: bold; 
       font-size: 0.9em; padding: 5px; margin: 5px auto; 
       text-align: center;"
    ]]
    return pandoc.RawBlock("html", '<div ' .. style .. '>' .. pandoc.utils.stringify(el) .. '</div>')
  end
  -- If not 'sidebar', return the element unchanged
  return el
end


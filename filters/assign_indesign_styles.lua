function Paragraph(elem)
    -- Check if paragraph has a "custom-style" attribute
    if elem.attributes["custom-style"] then
      local style = elem.attributes["custom-style"]
      
      -- Wrap paragraph content with InDesign paragraph tag with style applied
      return pandoc.Para({
        content = { pandoc.RawBlock("idml", "<ParaStyle:" .. style .. ">") },
        content = elem.content,
        content = { pandoc.RawBlock("idml", "</ParaStyle>") }
      })
    else
      -- No custom style, return unmodified paragraph
      return elem
    end
  end
  
  
    
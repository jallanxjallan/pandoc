local boilerplate_texts = {
	feature = "This is a double spread feature.",
	boxout = "This is a standalone box independent of chapter text flow.",
	aside = "This is the boilerplate for asides." -- Example of adding more
  }
  
  local function Div(el)
	for _, class_name in ipairs(el.classes) do -- Iterate through classes
	  local boilerplate_text = boilerplate_texts[class_name]
	  if boilerplate_text then
		if boilerplate_text then
			local boilerplate = pandoc.RawInline("html", '<span class="boilerplate-text" style="font-size: 70%; font-weight: bold; font-variant: small-caps;">' .. boilerplate_text .. '</span>')
			table.insert(el.content, 1, boilerplate) -- Insert directly into the div's content
			break
		end
		el.content:insert(1, boilerplate)
		break -- Important: Stop after finding the first match
	  end
	end
	return el
  end
  
  return {
	{ Div = Div }
  }
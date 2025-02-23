local boilerplate_texts = {
    feature = "This is a double spread feature.",
    boxout = "This is a standalone page independent of chapter text flow.",
    aside = "This is the boilerplate for asides."
}

function Div(el)
    for _, class_name in ipairs(el.classes) do
        local boilerplate_text = boilerplate_texts[class_name]
        if boilerplate_text then
            -- Insert the boilerplate text as a supertitle
            local supertitle = pandoc.RawBlock("html", '<p style="text-align: center; font-weight: bold; font-variant: small-caps; font-size: .75em;">' ..
                boilerplate_text .. '</p>')
            
            -- Wrap the content in a styled div
            local textbox_start = pandoc.RawBlock("html", '<div style="border: 1px solid black; background-color: #f0f0f0; padding: 10px; margin: 10px;">')
            local textbox_end = pandoc.RawBlock("html", '</div>')
            
            -- Remove the div container and return just the HTML blocks with the content
            local new_content = {textbox_start, supertitle}
            for _, v in ipairs(el.content) do
                table.insert(new_content, v)
            end
            table.insert(new_content, textbox_end)
            
            return new_content
        end
    end
    return el
end


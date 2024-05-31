local current_section
local sections = {}
local target_directory


function create_target_directory()
  local filepath = PANDOC_STATE['output_file'] 
  target_directory, __ = pandoc.path.split_extension(filepath) 
  pandoc.system.make_directory (target_directory, true)
end

function Header(elem)
    if elem.level == 1 then
        if current_section then
            table.insert(sections, current_section)
        end
        current_section = {title = pandoc.utils.stringify(elem), blocks = {}}
    end
    return elem
end

function Block(elem)
    if current_section then
        table.insert(current_section.blocks, elem)
    end
    return elem
end

function Pandoc(doc)
    create_target_directory() 
    if current_section then
        table.insert(sections, current_section)
    end
    for i, section in ipairs(sections) do 
        local new_doc = pandoc.Pandoc(section.blocks, doc.meta)
        local filepath = pandoc.path.join({target_directory, section.title})
        pandoc.pipe("pandoc", {"-o", filepath..".md"}, pandoc.write(new_doc, "markdown"))
    end
    os.exit()
end




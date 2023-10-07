--!/usr/local/bin/lua

local metadata = {}

function metaerror(err)
  print(err..'setting metaspan for'..PANDOC_STATE['input_files'][1])
end

function set_metadata_span()
  metaspan = pandoc.Span('METADATA', metadata)
end

function Pandoc(doc)
  input_file = PANDOC_STATE['input_files'][1]
  if doc.meta  == nil then
    print(input_file..' has no metadata ')
    return {}
  end
  metadata['input_file'] = input_file
  for k,v in pairs(doc.meta) do
    metadata[k] = pandoc.utils.stringify(v)
  end
  if xpcall(set_metadata_span, metaerror) then
    content_block = doc.blocks[1].content
    if content_block == nil then
      print(input_file..'has no content ')
      return {}
    end
    table.insert (content_block, 1, metaspan)
  end
  return pandoc.Pandoc(doc.blocks, doc.meta)
end

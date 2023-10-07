local content = ''

extract_content = {
  Para = function(el)
    content = content..pandoc.utils.stringify(el)
  end
}

function Pandoc(doc) 
  local namespace = pandoc.utils.stringify(doc.meta['namespace'])
  local document_key = namespace..":content:"..PANDOC_STATE['input_files'][1] 
  pandoc.walk_block(pandoc.Div(doc.blocks), extract_content)
  pandoc.pipe("redis-cli", {'set', document_key, content}, '')
  pandoc.pipe("redis-cli", {'expire', document_key, 60}, '')
  end

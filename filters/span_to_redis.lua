local span_key_template  
local span_id = 1

extract_span = {
  Span = function(elem)
    local span_key = span_key_template:gsub("0", span_id) 
  
    for k,v in pairs(elem.attributes) do 
      pandoc.pipe("redis-cli", {'hset', span_key, k, pandoc.utils.stringify(v) }, '')
    end 
    pandoc.pipe("redis-cli", {'expire', span_key, 60}, '')
    span_id = span_id + 1
    end
}

function Pandoc(doc) 
  namespace = pandoc.utils.stringify(doc.meta['namespace'])
  span_key_template = namespace..":span:"..PANDOC_STATE['input_files'][1]..':0'
  pandoc.walk_block(pandoc.Div(doc.blocks), extract_span)  
end


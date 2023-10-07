
function Meta(meta) 
  namespace = pandoc.utils.stringify(meta['namespace'])
  local document_key = namespace..":metadata:"..PANDOC_STATE['input_files'][1]
  
  for k,v in pairs(meta) do 
    pandoc.pipe("redis-cli", {'hset', document_key, k, pandoc.utils.stringify(v) }, '')
  end 
  
  pandoc.pipe("redis-cli", {'expire', document_key, 60}, '')
end

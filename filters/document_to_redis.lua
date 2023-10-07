local content = ''

function Identifier(length)
	local res = ""
	for i = 1, length do
		res = res .. string.char(math.random(97, 122))
	end
	return res
end

extract_content = {
  Para = function(el)
    content = content..pandoc.utils.stringify(el)
  end
}

function Pandoc(doc) 
  local document_key = Identifier(16) 
  local document_index_key = doc.meta['document_index_key']
  local filename = pandoc.path.filename(PANDOC_STATE['input_files'][1]) 

  
  for k,v in pairs(doc.meta) do 
    pandoc.pipe("redis-cli", {'hset', document_key, k, pandoc.utils.stringify(v) }, '')
  end 
  

  pandoc.walk_block(pandoc.Div(doc.blocks), extract_content)
  
  pandoc.pipe("redis-cli", {'hset', document_key, 'content', content}, '')
  pandoc.pipe("redis-cli", {'expire', document_key, 600}, '')
  pandoc.pipe("redis-cli", {'hset', document_index_key, filename, document_key}, '')
  os.exit()
end

sredis = {}

function sredis.expire(key, time)
  pandoc.pipe("redis-cli", {'expire', key, time}, '')
end

function sredis.query(args)
  return pandoc.pipe("redis-cli", args, '')
end

function sredis.inode(filepath)
  local line = pandoc.pipe("stat", {'--terse', filepath}, '')
  local stat = {}
  for substring in line:gmatch("%S+") do
    table.insert(stat, substring)
  end
  return(stat[8])
end

function sredis.document_data_key(meta)
  local index_key = meta['index_key']
  local filepath = PANDOC_STATE['input_files'][1]
  local document_key = 'document:data:'..sredis.inode(filepath)
  sredis.query({'hsetnx', index_key, filepath, document_key})
  sredis.query({'hsetnx', document_key, 'filepath', filepath})
  sredis.expire(document_key, 600)
  sredis.expire(index_key, 600)
  return document_key
end

return sredis

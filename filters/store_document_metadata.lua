local sredis = require "sredis"

function Meta(meta)
  local document_data_key = sredis.document_data_key(meta, filepath)
  for key, value in pairs(meta) do
    sredis.query({'hset', document_data_key, key, pandoc.utils.stringify(value)})
  end
end

local sredis = require "sredis"
local content = ''

extract_content = {
  Para = function(el)
    content = content..pandoc.utils.stringify(el)
  end
}

function Pandoc(el)
  local document_data_key = sredis.document_data_key(el.meta)
  pandoc.walk_block(pandoc.Div(el.blocks), extract_content)
  sredis.query({'hset', document_data_key, 'content', content})
end

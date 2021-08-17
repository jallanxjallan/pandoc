local sredis = require "sredis"
local words = 0

wordcount = {
  Str = function(el)
    -- we don't count a word if it's entirely punctuation:
    if el.text:match("%P") then
        words = words + 1
    end
  end
}

function Pandoc(el)
  local document_data_key = sredis.document_data_key(el.meta)
  pandoc.walk_block(pandoc.Div(el.blocks), wordcount)
  sredis.query({'hset', document_data_key, 'wordcount', words})
end

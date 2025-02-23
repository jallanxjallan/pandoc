function Para(el)
  return {}  -- Remove all paragraph elements
end

function BulletList(el)
  return {}  -- Remove all bulleted lists
end

function OrderedList(el)
  return {}  -- Remove all ordered lists
end

function BlockQuote(el)
  return {}  -- Remove all block quotes
end

function Plain(el)
  return {}  -- Remove plain text elements
end

return {
  { Para = Para, BulletList = BulletList, OrderedList = OrderedList, BlockQuote = BlockQuote, Plain = Plain }
}


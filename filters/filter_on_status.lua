

function Meta(meta)
  status_filter = meta['status_filter']
  status = meta['status']
  if status_filter ~= nil and status ~= nil then
    if pandoc.utils.stringify(status) ~= pandoc.utils.stringify(status_filter) then
      meta['placeholder'] = true
    end
  end
  return meta
end

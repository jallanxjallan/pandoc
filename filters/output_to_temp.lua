
function Pandoc(doc) 
  local tempfile = pandoc.pipe('mktemp', {"tmp.XXXXXXX.json"}, ''):gsub('\n', '')
  pandoc.utils.run_json_filter(doc, 'tee', {json_filepath})

  local args = {
    '--output='..tempfile,
    json_filepath
  } 
  rs = pandoc.pipe("pandoc", args, '')
  print(tempfile)
end

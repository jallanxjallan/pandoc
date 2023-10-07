


local output_dir
local output_stem
local output_ext
local basename
local row_doc_template
local table_num = 0
local table_header = {}
local document_metadata = {}

function export_row_data(row_num, row)
    local row_data = parse_row(row) 
    local row_doc_metadata = {} 

    for k,v in pairs(document_metadata) do 
        row_doc_metadata[k] = v 
    end
    
     
    for k,v in pairs(row_data) do 
        row_doc_metadata[table_header[k]] = v
    end 

    for k,v in pairs(row_doc_metadata) do 
        print(k, v) 
    end
    
    local row_output_filename = output_stem..'_'..table_num..'_'..row_num..output_ext
    local row_output_filepath = pandoc.path.join({output_dir, row_output_filename}) 
    
  
    local row_doc = pandoc.Pandoc(pandoc.Str('content'), row_doc_metadata)
  
    
    local json_filepath = os.tmpname()..'.json'
    pandoc.utils.run_json_filter(row_doc, 'tee', {json_filepath})
    
  
    local row_doc_args = {
      '--standalone',
      '--output='..row_output_filepath,
      json_filepath
    }

    if row_doc_template ~= nil then 
        table.insert(row_doc_args, 1, '--template='..row_doc_template)
    end 
    
    
    rs = pandoc.pipe("pandoc", row_doc_args, '')
  
  end

function parse_row(row) 
    row_args = {}
    for cell_key, cell_cont in pairs(row) do 
        if cell_key == 'cells' then 
            for cell_num, cell in ipairs(cell_cont) do 
                row_args[cell_num] = pandoc.utils.stringify(cell.contents) 
            end
        end
    end
    return row_args
end

function get_table_rows(table) 
    table_num = table_num + 1 
    for i, row in ipairs(table['head']['rows']) do 
        for i, cell in ipairs(row.cells) do 
            table_header[i] = pandoc.utils.stringify(cell.contents)
        end
    end
    
    for i, body in pairs(table['bodies']) do
        for k, rows in pairs(body) do 
            if k == 'body' then 
                for rownum, row in ipairs(rows) do 
                    export_row_data(rownum, row)
                end 
            end
        end 
    end
end

function get_doc_meta(meta) 
    output_filepath = PANDOC_STATE['output_file'] 
    output_dir = pandoc.path.directory(output_filepath) 
    local output_filename = pandoc.path.filename(output_filepath) 

    output_stem, output_ext = pandoc.path.split_extension(output_filename) 
    document_metadata['basename'] = output_stem
    
    for key, value in pairs(meta) do 
        document_metadata[key] = pandoc.utils.stringify(value)
        if key == 'row_doc_template' then 
            row_doc_template = pandoc.utils.stringify(value)
        end 
    end 
end

return {{Meta = get_doc_meta}, {Table = get_table_rows}}

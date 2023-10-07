


local output_dir
local output_stem
local output_ext
local basename
local row_doc_template
local table_header = {}
local table_rows = {}
local document_metadata = {}

function export_row_data(row_num, row_data) 
    row_doc_metadata = {}
    
    for k,v in pairs(document_metadata) do 
        row_doc_metadata[k] = v 
    end
    
     
    for k,v in pairs(row_data) do 
        row_doc_metadata[table_header[k]] = v
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
    print(row)
    row_data = {}
    for i, cell in ipairs(row.cells) do 
        print(cell)
        row_data[i] = pandoc.utils.stringify(cell.contents) 
    end
    return row_data  
end 

function Table(table) 
    print(table.head)
    for i, row in ipairs(table['head']['rows']) do 
        table_header[i] = parse_row(row) 
    end 

    for k,v in pairs(table_header) do 
        print(k, v) 
    end 
    os.exit()
    
    for i, body in pairs(table['bodies']) do
        for k, rows in pairs(body) do 
            if k == 'body' then 
                for rownum, row in ipairs(rows) do 
                    table_rows[#table_rows + 1] = parse_row(row)
                end 
            end 
        end
    end
end 

function Meta(meta) 
    for key, value in pairs(meta) do 
        if key == 'row_doc_template' then 
            row_doc_template = pandoc.utils.stringify(value)
        else 
            document_metadata[key] = pandoc.utils.stringify(value)
        end 
    end 
end    


function Pandoc(doc) 
    output_filepath = PANDOC_STATE['output_file'] 
    output_dir = pandoc.path.directory(output_filepath) 
    local output_filename = pandoc.path.filename(output_filepath) 

    output_stem, output_ext = pandoc.path.split_extension(output_filename) 
    document_metadata['basename'] = output_stem 
    for row_num, row_data in ipairs(table_rows) do 
        export_row_data(row_num, row_data) 
    end 
    os.exit() 
end
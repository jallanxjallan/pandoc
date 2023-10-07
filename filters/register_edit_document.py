




def action(elem, doc):
    pass
   

def finalize(doc):
    meta = doc.get_metadata()
    # json_content = write_chunk_file(doc)
    # doc.content = [] 
    doc.chunk_bounds[-1]['end'] = len(doc.content) + 1 
    for i, bounds in enumerate(doc.chunk_bounds):
        start = bounds['start'] + 1 
        end = bounds['end']
        chunk = pf.Doc(*doc.content[start:end])
        write_chunk_file(chunk, i)
   

def main(doc=None):
    return pf.run_filter(action, finalize=finalize, doc=doc) 

if __name__ == '__main__':
    main()
#!/home/jeremy/Python3.10Env/bin/python

import panflute as pf
from document import write_chunk_files
    
   
def prepare(doc):
    doc.chunk_bounds = [dict(start=-1, name='Document')]
  
def action(elem, doc):
    if isinstance(elem, pf.HorizontalRule):
        doc.chunk_bounds[-1]['end'] = elem.index
        doc.chunk_bounds.append(dict(start=elem.index))

    elif isinstance(elem, pf.Header) and elem.level == 1:
    return elem

def finalize(doc):
    doc.metadata['source'] = doc.metadata['inputfile']
    write_chunk_files(doc)

def main(doc=None):
    return pf.run_filter(action, prepare=prepare, finalize=finalize, doc=doc) 

if __name__ == '__main__':
    main()
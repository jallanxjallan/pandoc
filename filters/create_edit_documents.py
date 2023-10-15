#!/home/jeremy/Python3.10Env/bin/python

import panflute as pf

def prepare(doc):
  meta = doc.get_metadata()
  doc.max_tokens_per_chunk = 1500 
  doc.chunk_number = 0 
  doc.chunks = [] 
  doc.input_filename = Path(meta['input_file']).stem 
  doc.output_dir = Path(meta['output_file']).parent
                            

def action(elem, doc):
  doc.chunks.append(pf.stringify(elem)) 
  if len(doc.chunks) > doc.max_tokens_per_chunk: 
    text = ' '.join(doc.chunks)
    write_chunk_file(doc) 
    # Update variables for the next chunk.
    doc.chunk_number += 1 
    doc.chunks = []


def finalize(doc):
   write_chunk_file(doc)
   doc.content = [] 
   return doc
   

def main(doc=None):
    return pf.run_filter(action, prepare=prepare, finalize=finalize, doc=doc) 

if __name__ == '__main__':
    main()
#!/home/jeremy/Python3.10Env/bin/python

import datetime
from pathlib import Path
from utility import title_case, make_identifier
import panflute as pf


def write_chunk_file(doc):
    chunk_filepath = doc.output_dir.joinpath(f"{doc.input_filename}_{doc.chunk_number}").with_suffix('.md')
    if chunk_filepath.exists():
      pf.debug(f"{chunk_filepath} already exists")
    else:
        text = ' '.join(doc.chunks) 
        metadata = dict(name=title_case(chunk_filepath.stem), 
                            source=doc.input_filename,
                            created=datetime.datetime.now().isoformat(),
                            rkey=f'edit:{make_identifier()}:new'
                            ) 
        args = [f'--metadata={k}:{v}' for k,v in metadata.items()] 
        args.append('--template=edit_document') 
        args.append(f'--output={chunk_filepath}') 
        try:
            pf.run_pandoc(text=text, args=args)
        except Exception as e:
            pf.debug(e)
    

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
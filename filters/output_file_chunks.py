#!/home/jeremy/Python3.10Env/bin/python

from tempfile import NamedTemporaryFile 
import io
from pathlib import Path
import tiktoken
from utility import title_case
import panflute as pf 

enc = tiktoken.get_encoding("cl100k_base")

def write_chunk_file(chunk, outputfile):
    tfile = Path(NamedTemporaryFile(prefix='chk_', suffix='.json', delete=False).name)
    with io.StringIO() as f:
        pf.dump(chunk, f) 
        tfile.write_text(f.getvalue())
        args = [f'--output={outputfile}',
                '-s',
                '--template=edit_document',
                str(tfile)]
        pf.run_pandoc(args=args) 


def set_filepath(filepath, sequence):
   fp = Path(filepath) 
   sequenced = fp.with_stem(f'{fp.stem}_{sequence:02d}') 
   if sequenced.exists():
       raise FileExistsError(f'{sequenced} already exists') 
   return sequenced

def write_chunk_files(doc):
    doc.chunk_bounds[-1]['end'] = len(doc.content) + 1 
    meta = doc.get_metadata().copy()
    for i, bs in enumerate(doc.chunk_bounds):
        filepath = set_filepath(meta['outputfile'], i)
        meta['sequence'] = str(i)
        try:
            meta['name'] = pf.MetaString(bs['header'])
        except Exception as e:
            meta['name'] = title_case(filepath.stem)
        chunk = pf.Doc(*doc.content[bs['start']:bs['end']], metadata=meta)
        write_chunk_file(chunk, filepath)
   
def prepare(doc):
    doc.chunk_bounds = [dict(start=0, header=None)] 
    doc.token_count = 0

def action(elem, doc):
    if isinstance(elem, pf.HorizontalRule):
        doc.chunk_bounds[-1]['end'] = elem.index 
        doc.chunk_bounds.append(dict(start=elem.index + 1))
        doc.token_count = 0

    elif isinstance(elem, pf.Header) and elem.level == 1:
        doc.chunk_bounds[-1]['end'] = elem.index -1
        doc.chunk_bounds.append(dict(start=elem.index + 1, header=pf.stringify(elem))) 
        doc.token_count = 0

    elif isinstance(elem, pf.Para):
        doc.token_count += len(enc.encode(pf.stringify(elem))) 
        if doc.token_count > 2500:
            doc.chunk_bounds[-1]['end'] = elem.index -1  
            doc.chunk_bounds.append(dict(start=elem.index)) 
            doc.token_count = 0
    return elem    

def finalize(doc):
    doc.metadata['source'] = doc.metadata['inputfile']
    write_chunk_files(doc)

def main(doc=None):
    return pf.run_filter(action, prepare=prepare, finalize=finalize, doc=doc) 

if __name__ == '__main__':
    main()
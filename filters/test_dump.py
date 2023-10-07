from panflute import Doc, Para, Str, dump, run_filter, run_pandoc
from tempfile import NamedTemporaryFile 
import sys 
import os
import io
from pathlib import Path
from storage import rd, RedisKey 
import pypandoc

def action(elem, doc):
    if isinstance(elem, )
    

def finalize(doc):
    tfile = Path(NamedTemporaryFile(prefix='chk_', suffix='.json', delete=False).name)
    with io.StringIO() as f:
        dump(doc, f) 
        tfile.write_text(f.getvalue())
        run_pandoc(args=['--output=output/test_dump2.docx', str(tfile)] )
        # pypandoc.convert_text(f.getvalue(), 'markdown', format='native', outputfile='test_dump.docx')
        
        
    
         

def main(doc=None):
    return run_filter(action, finalize=finalize, doc=doc) 

if __name__ == '__main__':
    main()
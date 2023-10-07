#!/home/jeremy/Python3.10Env/bin/python

import panflute as pf
from pathlib import Path

def prepare(doc):
    doc.cell_id = 0
    doc.para_id = 0
    doc.spans = []

def extract_para(elem, doc):
    if isinstance(elem, pf.Para):
        doc.para_id += 1
        doc.spans.append(pf.Span(pf.Str(pf.stringify(elem).strip()), attributes=dict(cell_id=str(doc.cell_id), para_id=str(doc.para_id))))

def action(elem, doc):
    if isinstance(elem, pf.TableCell):
        doc.cell_id += 1
        elem.attributes['id'] = str(doc.cell_id) 
        doc.para_id = 0
        elem.walk(extract_para)

    return elem
        
        
def finalize(doc):
    meta = doc.get_metadata()
    json_path = Path(meta['output_file']).with_suffix('.json')
    with json_path.open('w', encoding='utf-8') as f:
        pf.dump(doc, f) 

    sorted_spans = sorted([s for s in doc.spans], key=lambda x: x.attributes['cell_id'])
    doc.content = [pf.Para(s) for s in sorted_spans]
    return doc    
    

def main(doc=None):
    return pf.run_filter(action, prepare=prepare, finalize=finalize, doc=doc) 


if __name__ == '__main__':
    main()
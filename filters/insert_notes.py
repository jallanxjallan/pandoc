#!/home/jeremy/Python3.10Env/bin/python

import panflute as pf 
from storage import CherryTree  
import regex

def extract_notes(line, doc):
    if (node := doc.ct.find_node_by_name(line.strip())):
        if (notes := node.notes('numbered')):
            for note in notes:
                yield pf.ListItem(pf.Plain(pf.Str(regex.sub('\d*\.\s', '', note))))
    else:
        yield None

        
    

def prepare(doc):
    meta = doc.get_metadata()
    doc.ct = CherryTree(meta['notes_file'])
    doc.note_count = 1

def action(elem, doc):
    if isinstance(elem, pf.CodeBlock):
        notes = list(filter(None, [n for l in elem.text.split('\n') for n in extract_notes(l, doc)]))
#        note_start = doc.note_count
#        doc.note_count += len(notes)
        return pf.OrderedList(*notes, start=1)
    elif isinstance(elem, pf.Code):
        return elem
 
    else:
        return elem

def main(doc=None):
    return pf.run_filter(action, prepare=prepare, doc=doc) 

if __name__ == '__main__':
    main()

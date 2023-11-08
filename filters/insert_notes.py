#!/home/jeremy/Python3.10Env/bin/python

import panflute as pf 
from storage import CherryTree  
import regex

def prepare(doc):
    meta = doc.get_metadata()
    doc.ct = CherryTree(meta['notes_file'])
    doc.note_count = 1

def action(elem, doc):
    if isinstance(elem, pf.Code):
        try: 
            node = doc.ct.find_node_by_name(elem.text)
        except Exception as e:
            pf.debut(e)
            return elem 
        
        notes = node.notes(numbered=True) 
        if notes is not None:
            note_items = [pf.ListItem(pf.Para(pf.Str(regex.sub('\d*\.\s', '', n)))) for n in notes] 
            doc.content.append(pf.OrderedList(*note_items, start=doc.note_count))
            doc.note_count += len(note_items)

    return elem

def main(doc=None):
    return pf.run_filter(action, prepare=prepare, doc=doc) 

if __name__ == '__main__':
    main()

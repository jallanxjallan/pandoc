#!/home/jeremy/Python3.10Env/bin/python

import panflute as pf 
from storage import CherryTree  
import regex

def prepare(doc):
    meta = doc.get_metadata()
    doc.ct = CherryTree(meta['notes_file'])
    doc.item_count = 0

def action(elem, doc):
    
    elif isinstance(elem, pf.CodeBlock):
        
        note_lines = []
        
        for node_ref in [l.strip().lstrip('node: ') for l in elem.text.split('\n') if l.startswith('node')]:
            if not (node := doc.ct.find_node_by_name(node_ref)): 
                pf.debug(f'node not found for {node_ref}') 
                continue 
            
            for note in node.notes(numbered=True):
                line = regex.sub('^(1)\.', str(doc.item_count), note)
                note_lines.append(pf.ListItem(line))    
                doc.item_count += 1
        return pf.LineBlock(*note_lines)

    return elem

def main(doc=None):
    return pf.run_filter(action, prepare=prepare, doc=doc) 

if __name__ == '__main__':
    main()

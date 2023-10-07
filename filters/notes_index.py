#!/home/jeremy/Python3.10Env/bin/python

import panflute as pf 
from storage import CherryTree

def prepare(doc):
    meta = doc.get_metadata() 
    doc.ct = CherryTree(meta['notes_file'])
    
    
def action(elem, doc):
    if isinstance(elem, pf.Para):
        try:
            node = doc.ct.find_node_by_name(elem.content[0].text[6:]) 
        except Exception as e:
            return pf.Para(pf.Str(node.content) 

def main(doc=None):
    return pf.run_filter(action, prepare=prepare, doc=doc) 


if __name__ == '__main__':
    main()
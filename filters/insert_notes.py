#!/home/jeremy/Python3.10Env/bin/python

import panflute as pf 
from storage import CherryTree  

def prepare(doc):
    doc.ct = CherryTree(doc.meta['notes_file'])

def action(elem, doc):
    if isinstance(elem, pf.CodeBlock) or isinstance(elem, pf.Code):
        text = elem.text 
        try:
            node = doc.ct.find_node_by_name(text[6:]) 
        except ValueError:
            return elem 
        
        if isinstance(elem, pf.CodeBlock):  
                return pf.Para(pf.Str(node.content)) 
        else:
            return pf.Str(node.content) 

    return elem

def main(doc=None):
    return pf.run_filter(action, prepare=prepare, doc=doc) 

if __name__ == '__main__':
    main()
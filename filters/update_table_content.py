#!/home/jeremy/Python3.10Env/bin/python

import panflute as pf

def prepare(doc):
    doc.cell_id = 0
    # doc.table = 0
    # doc.row = 0
    # doc.cell = 0 
    # doc.para = 0
    # doc.spans = []
    
# def extract_row(elem, doc):
#     if isinstance(elem, pf.TableRow):
#         doc.row += 1
#         doc.cell = 0
#         elem.walk(extract_cell) 

# def extract_cell(elem, doc):
#     if isinstance(elem, pf.TableCell):
#         doc.cell += 1
#         doc.para = 0
#         elem.walk(extract_para) 

# def extract_para(elem, doc):
#     if isinstance(elem, pf.Para):
#         doc.para += 1
#         doc.spans.append(pf.Span(pf.Str(pf.stringify(elem).strip()), 
#                                  attributes=dict(table=str(doc.table), row=str(doc.row), cell=str(doc.cell), para=str(doc.para))))

def action(elem, doc):
    if isinstance(elem, pf.TableCell):
        pf.debug(elem.attributes['id'])
        elem.attributes['id']
    return elem
        

        
def finalize(doc):
    pass
    
    

def main(doc=None):
    return pf.run_filter(action, prepare=prepare, finalize=finalize, doc=doc) 


if __name__ == '__main__':
    main()
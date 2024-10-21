import panflute as pf


def prepare(doc):
    doc.part_no = 0
    doc.chapter_no = 0
    doc.feature_no = 0

def action(elem, doc):
    if isinstance(elem, pf.Header):
        if elem.level == 1:
            doc.part_no += 1 
            elem.content.insert(0, pf.Str(f'Part {doc.part_no}: ')) 
            
        elif elem.level == 2:
            doc.chapter_no += 1 
            elem.content.insert(0, pf.Str(f'Chapter {doc.chapter_no}: ')) 
            
        elif elem.level == 3:
            doc.feature_no += 1
            # Create horizontal rule and explanatory text
            hrule = pf.HorizontalRule()
            explanation = pf.Para(pf.Strong(pf.Str(f"Feature no {doc.feature_no} to be placed in or after Chapter {doc.chapter_no}")))
            
            # Return a list containing the horizontal rule, the explanation, and the modified header
            return [hrule, explanation, elem]
    
    return elem

def main(doc=None):
    pf.run_filter(action, prepare=prepare, doc=doc)

if __name__ == '__main__':
    main()

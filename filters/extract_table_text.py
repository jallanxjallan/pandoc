#!/home/jeremy/Python3.10Env/bin/python

import panflute as pf

def action(elem, doc):
    if isinstance(elem, pf.Table):
        # Extract text from the second column
        text_elements = [cell.content[0] for row in elem.content for cell in row.content[2::3]]

        # Create a list of paragraphs from the text elements
        paragraphs = [pf.Para(pf.Str(pf.stringify(te))) for te in text_elements]

        # Replace the table with the paragraphs
        return paragraphs

def main(doc=None):
    return pf.run_filter(action, doc=doc)

if __name__ == '__main__':
    main()

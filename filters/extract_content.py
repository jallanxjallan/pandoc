import panflute as pf
from pathlib import Path
from document import Document  # Assuming Document is defined in your_document_module


   

def extract_link_text(link):
    
    url = link.url
    path = Path(url)  # Use pathlib to handle paths

    # Check if the link points to a markdown file and if the file exists
    if url.endswith('.md') and path.exists():
        # Use Document class to read the markdown file
        markdown_doc = Document.read_file(path)

        # Convert markdown content to native pandoc elements using convert_text
        return pf.convert_text(markdown_doc.content, input_format='markdown')
    return link
    
def prepare(doc):
    doc.new_doc = []
    doc.current_heading = []

def action(elem, doc):
    if isinstance(elem, pf.Header):
        level = elem.level
        doc.current_heading = elem
        doc.new_doc.append(elem) 
 

    elif isinstance(elem, pf.Link):
        link_text = extract_link_text(elem)
        is_quote = False
        parent = elem.parent
        while parent is not None:
            if isinstance(parent, pf.BlockQuote):
                is_quote = True
                break
            parent = parent.parent  # Move up the tree
        if is_quote:
            if (no_paras := sum(1 for block in link_text if isinstance(block, pf.Para))) > 1:
                caption = "This is a standalone page or spread outside of chapter text flow"
            else:
                caption = "This is a text block to be placed somewhere in this chapter"
                

            doc.new_doc.append(pf.HorizontalRule) 
            doc.new_doc.append(pf.Para(pf.Strong(pf.Str(caption)))) 
            doc.new_doc.extend(link_text)
            doc.new_doc.append(pf.HorizontalRule) 
        else:
            doc.new_doc.extend(link_text)            

def finalize(doc):
    doc.content = doc.new_doc
    return doc

def main(doc=None):
    pf.run_filter(action, prepare=prepare, finalize=finalize, doc=doc)

if __name__ == '__main__':
    main()


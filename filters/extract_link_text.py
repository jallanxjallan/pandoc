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

    elif  isinstance(elem, pf.Para):
        for link in [i for i in elem.content if isinstance(i, pf.Link)]:
            doc.new_doc.extend(extract_link_text(link)) 


def finalize(doc):
    doc.content = doc.new_doc
    return doc

def main(doc=None):
    pf.run_filter(action, prepare=prepare, finalize=finalize, doc=doc)

if __name__ == '__main__':
    main()


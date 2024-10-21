import panflute as pf
from pathlib import Path
from document import Document  # Assuming Document is defined in your_document_module


   

def extract_link_text(link, doc):
    
    url = link.url
    path = Path(url)  # Use pathlib to handle paths

    # Check if the link points to a markdown file and if the file exists
    if url.endswith('.md') and path.exists():
        # Use Document class to read the markdown file
        markdown_doc = Document.read_file(path)
        
        # Get the content of the document (without metadata)
        file_content = markdown_doc.content

        # Convert markdown content to native pandoc elements using convert_text
        pandoc_content = pf.convert_text(file_content, input_format='markdown')

        # Append the native pandoc content to the new content list
        doc.new_doc.extend(pandoc_content)

    
def prepare(doc):
    doc.new_doc = []
    doc.current_heading = []

def action(elem, doc):
    # Rule 1: Prepend a prefix to headers based on their level
    if isinstance(elem, pf.Header):
        level = elem.level
        doc.current_heading = elem
        doc.new_doc.append(elem) 
       

    # Rule 2: Flag as Feature
    elif isinstance(elem, pf.BulletList):
        current_heading_level = doc.current_heading.level
        feature_elem = pf.Header(pf.Strong(pf.Str('Feature')), level=current_heading_level + 1)
        doc.new_doc.append(feature_elem)
        for block in elem.content:
            # Traverse each inline element inside the block (if it's a block with inlines like Para or Plain)
            
            for inline in block.content:
                for item in inline.content:
                    if isinstance(item, pf.Link):
                        extract_link_text(item, doc)
                    

    # Rule 3: Replace paragraphs containing links to Markdown files with file content
    elif  isinstance(elem, pf.Para):
        for link in [i for i in elem.content if isinstance(i, pf.Link)]:
            extract_link_text(link, doc)

def finalize(doc):
    doc.content = doc.new_doc
    return doc

def main(doc=None):
    pf.run_filter(action, prepare=prepare, finalize=finalize, doc=doc)

if __name__ == '__main__':
    main()


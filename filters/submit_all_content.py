import panflute as pf
from pathlib import Path
from document import Document  # Assuming Document is defined in your_document_module

def get_linked_text(link):
    filepath = link.url
    try:
        story = Document.read_file(filepath)
        return pf.convert_text(story.content, input_format='markdown')
    except FileNotFoundError:
        return [pf.Str(f'Missing File: {filepath}')]
    except Exception as e:
        return [pf.Str(f'Error reading {filepath}: {str(e)}')]

def prepare(doc):
    # Attach a temporary container to the doc
    doc.new_doc_elements = []

def action(elem, doc):
    if isinstance(elem, pf.Para):
        inline = elem.content
        new_elems = []
        previous_image = None

        for subelem in inline:
            if isinstance(subelem, pf.Image):
                previous_image = subelem
                new_elems.append(subelem)

            elif isinstance(subelem, pf.Link) and subelem.url.endswith('.md'):
                new_elems.extend(get_linked_text(subelem))
            else:
                new_elems.append(subelem)
        
        if len(new_elems) > 0:
            
            doc.new_doc_elements.append(pf.Para(*new_elems))
        else:
            doc.new_doc_elements.append(elem)
   

def finalize(doc):
    # Replace the document content
    doc.content = doc.new_doc_elements

def main(doc=None):
    pf.run_filter(action, prepare=prepare, finalize=finalize, doc=doc)

if __name__ == '__main__':
    main()

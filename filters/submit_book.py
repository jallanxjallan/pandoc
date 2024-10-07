import panflute as pf
from pathlib import Path
from document import Document  # Assuming Document is defined in your_document_module


# Define prefixes for each heading level
prefixes = {
    1: "Level 1: ",
    2: "Level 2: ",
    3: "Level 3: ",
    4: "Level 4: ",
    5: "Level 5: ",
    6: "Level 6: ",
}



def format_heading(elem, doc):
    level = elem.level
    prefix = prefixes.get(level, "")
    if prefix:
        header_content = pf.stringify(elem)
        new_content = pf.Header(pf.Str(prefix + header_content), level=elem.level)
        doc.new_doc.append(new_content)

def extract_link_text(elem, doc):
    for item in elem.content:
        # Check if the item is a link
        if isinstance(item, pf.Link):
            url = item.url
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

def action(elem, doc):
    # Rule 1: Prepend a prefix to headers based on their level
    if isinstance(elem, pf.Header):
       format_heading(elem, doc) 
       return []

    # Rule 2: Replace paragraphs containing links to Markdown files with file content
    if isinstance(elem, pf.Para):
        extract_link_text(elem, doc)
        return []
        
def finalize(doc):
    # pf.debug(doc.new_content)
    doc.content = doc.new_doc
    return doc
    # return pf.Doc(*doc.new_doc)

def main(doc=None):
    pf.run_filter(action, prepare=prepare, finalize=finalize, doc=doc)

if __name__ == '__main__':
    main()


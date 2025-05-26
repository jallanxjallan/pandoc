import panflute as pf
import subprocess
from pathlib import Path
from document import Document  # Assuming Document is defined in your_document_module

def get_modified_files(story_dir="stories"):
    try:
        out = subprocess.check_output(
            ["git", "status", "--porcelain", story_dir],
            universal_newlines=True
        )
    except subprocess.CalledProcessError:
        return set()

    modified = set()
    for line in out.splitlines():
        path = line[3:]
        if path.endswith('.md'):
            modified.add(path)
    return modified

def format_content_with_git(link, doc):
    filepath = link.url
    try:
        story = Document.read_file(filepath)
        elements = pf.convert_text(story.content, input_format='markdown')
    except FileNotFoundError:
        return [pf.Para(pf.Str(f'Missing File: {filepath}'))]
    except Exception as e:
        return [pf.Para(pf.Str(f'Error reading {filepath}: {str(e)}'))]

    if filepath not in getattr(doc, 'modified_files', set()):
        return [pf.Div(*elements, attributes={"class": "story-unchanged"})]

    return elements

def prepare(doc):
    doc.new_doc = []
    doc.modified_files = get_modified_files('stories')

def action(elem, doc):
    if isinstance(elem, pf.Image) and not isinstance(elem.parent, pf.Para):
        doc.new_doc.append(pf.Para(elem))
        return []

    if isinstance(elem, pf.Para):
        inline = elem.content
        new_elems = []
        previous_image = None

        for subelem in inline:
            if isinstance(subelem, pf.Image):
                previous_image = subelem
                new_elems.append(subelem)

            elif isinstance(subelem, pf.Link) and subelem.url.endswith('.md'):
                label = pf.stringify(subelem)

                if previous_image and (previous_image.alternative or "") == label:
                    new_elems.append(pf.Para(pf.Str("Caption:"), pf.Space(), pf.Str(label)))
                    previous_image = None

                new_elems.extend(format_content_with_git(subelem, doc))

            else:
                new_elems.append(subelem)
                previous_image = None

        doc.new_doc.append(pf.Para(*new_elems))
        return []

    doc.new_doc.append(elem)
    return []

def finalize(doc):
    try:
        doc.content = doc.new_doc
    except Exception as e:
        pf.debug(f"Finalization error: {e}")

def main(doc=None):
    pf.run_filter(action, prepare=prepare, finalize=finalize, doc=doc)

if __name__ == '__main__':
    main()

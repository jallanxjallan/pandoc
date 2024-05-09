import panflute as pf

def convert_tags(elem, doc):
  if elem.tag == "span" and "data-designer-name" in elem.attributes:
    designer_name = elem.attributes["data-designer-name"]
    content = elem.content[0]  # Assuming one child element
    elem.content = [pf.Str(f"<[INDD:{designer_name}]>{content.text}<[/INDD:{designer_name}]>")]

def main(doc):
  return pf.walk(convert_tags, doc)

if __name__ == "__main__":
  pf.run_filter(main)

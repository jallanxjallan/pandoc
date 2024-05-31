#!/home/jeremy/Python3.10Env/bin/python
# -*- coding: utf-8 -*-
#
#  module.py
#
#  Copyright 2023 Jeremy Allan <jeremy@jeremyallan.com>
import panflute as pf
from pathlib import Path



def set_vars(doc):
  metadata = doc.get_metadata()
  doc.source = Path(metadata['inputfile'])
  doc.parent = Path(metadata['outputfile'])
  doc.sections = []


def load_sections(elem, doc):
  if isinstance(elem, pf.Header) and elem.level == 1:
    doc.sections.append(dict(header=elem, content=[])) 
  else:
    try:
      doc.sections[-1]['content'].append(elem)
    except:
      pass
  return elem

def write_sections(doc):
  """Writes each section content to a separate markdown file.

  This function assumes `doc.sections` is populated with section content lists.
  """
  for section in doc.sections:
    doc.parent.mkdir(parents=True, exist_ok=True)
    filepath = doc.parent.joinpath(pf.stringify(section['header'])).with_suffix('.md')
    args = [f'--output={filepath}']
    pf.run_pandoc('This is a test', args=args)
    # with filepath.open('w') as fp:
    #   fp.writelines(pf.stringify(section['content']))

def main(doc=None):
  return pf.run_filter(load_sections, prepare=set_vars, finalize=write_sections, doc=doc) 
 

if __name__ == '__main__':
  main()
 
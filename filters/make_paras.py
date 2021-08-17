#!/home/jeremy/Python3.6Env/bin/python
# -*- coding: utf-8 -*-
#
#  script.py
#
#  Copyright 2019 Jeremy Allan <jeremy@jeremyallan.com>

"""
Pandoc filter using panflute
"""

import panflute as pf
from pathlib import Path

# def output_section(doc):
#     text = ' '.join(doc.section_content)
#     title = doc.current_heading
#     filepath = Path(doc.file_prefix + title.lower().replace(' ', '_')
#     filepath = filename.with_suffix('.md')
#     pf.run_pandoc(text=text, args=[f'--metadata=title:{title}',
#                                    f'--metadata=seq:{doc.seq}',
#                                    f'--metadata=project:{doc.project}',
#                                    f'-o {str(filename)}',
#                                    '--defaults=create_document'])


def action(elem, doc):
    pass


def finalize(doc):
    content = doc.content
    pf.debug(content)
    # for key, text in [(k,v) for k,v in meta.items() if k.startswith("section_")]:
    #     print(text)
    doc.content = []


def main(doc=None):
    return pf.run_filter(action,
                         finalize=finalize,
                         doc=doc)

if __name__ == '__main__':
    main()

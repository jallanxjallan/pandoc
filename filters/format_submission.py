#!/usr/bin/env python3

import panflute as pf
from pathlib import Path

symbol_map = {}
mode = 'layout'


def load_symbols(group='submit', path=Path.home() / '.workflow_symbols'):
    current = None
    mapping = {}
    try:
        with open(path, encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line.startswith('#'):
                    current = line.lstrip('#').strip()
                elif current == group and ' = ' in line:
                    sym, name = map(str.strip, line.split('=', 1))
                    mapping[sym] = name
    except Exception as e:
        pf.debug(f"Could not load symbols: {e}")
    return mapping


def prepare(doc):
    global symbol_map, mode
    symbol_map = load_symbols()
    mode = str(doc.get_metadata('mode', 'layout')).lower()
    pf.debug(f"Using mode: {mode}")
    pf.debug(f"Loaded symbols: {symbol_map}")


def page_divider(label, width=60, border='='):
    label = f" {label} "
    total = width - len(label)
    left = total // 2
    right = total - left
    return border * left + label + border * right


def build_div(key, para, kind):
    """
    kind: 'before', 'after', or 'wrap'
    """
    classes = {
        'layout': {
            'running': {'before': 'break_before', 'after': 'break_after'},
            'caption': {'before': 'before_wrapper', 'after': 'after_wrapper'},
            'boxout':  {'before': 'break_before', 'after': 'break_after'},
            'sidebar': {'before': 'before_wrapper', 'after': 'after_wrapper'},
            'quote':   {'before': 'before_wrapper', 'after': 'after_wrapper'},
            'page':    {'before': 'break_before', 'after': 'break_after'},
            'note':    {'wrap': 'layout_note'},
        },
        'review': {
            'default': {'wrap': key},
        }
    }

    class_map = classes.get(mode, {}).get(key, classes['review']['default'])
    cstyle = class_map.get(kind)
    if not cstyle:
        return None
    return pf.Div(*para, attributes={'custom-style': cstyle})



def action(elem, doc):
    if not isinstance(elem, pf.Para):
        return

    text = pf.stringify(elem).strip()
    if not text:
        return

    sym = text.split()[0]
    key = symbol_map.get(sym)

    if key is None:
        return None

    content = elem.content  
    middle = pf.Para(*content)

    if mode == 'review':
        return build_div(key, [middle], 'wrap')

    before = build_div(key, [pf.Para(pf.Str(page_divider(key.title())))], 'before')
    after = build_div(key, [pf.Para(pf.Str(page_divider(f'end {key}')))], 'after')

    return [b for b in [before, middle, after] if b is not None]


def main(doc=None):
    return pf.run_filter(action, prepare=prepare, doc=doc)


if __name__ == "__main__":
    main()
 

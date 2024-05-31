import panflute as pf

def action (el, doc):
  if isinstance(el, pf.Para):
    span = pf.Span(pf.Str("Test Para"), classes=["extreme_outdent"])
    return pf.Para(span)
  return el


def main(doc=None):
    return pf.run_filter(action, doc=doc)

if __name__ == '__main__':
    main()

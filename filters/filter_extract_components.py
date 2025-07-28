import panflute as pf
from pathlib import Path
from typing import Optional, Dict, List, Tuple
import attr
import re
import sys
from document import Document


@attr.define
class SymbolSpec:
    symbol: str
    key: str
    layout: Dict[str, str] = attr.field(factory=dict)
    review: Dict[str, str] = attr.field(factory=dict)

    def get_style(self, mode: str, kind: str) -> Optional[str]:
        return getattr(self, mode, {}).get(kind)


class SubmitSymbolRegistry:
    _registry: Dict[str, SymbolSpec] = {
        '¶': SymbolSpec(
            symbol='¶', key='running',
            layout={'before': 'break_before', 'after': 'break_after'},
            review={'wrap': 'running_review'}
        ),
        '🖼️': SymbolSpec(
            symbol='🖼️', key='caption',
            layout={'before': 'before_wrapper', 'after': 'after_wrapper'},
            review={'wrap': 'caption_review'}
        ),
        '⧉': SymbolSpec(
            symbol='⧉', key='boxout',
            layout={'before': 'boxout_start', 'after': 'boxout_end'},
            review={'wrap': 'boxout_review'}
        ),
        '▌': SymbolSpec(
            symbol='▌', key='sidebar',
            layout={'before': 'sidebar_start', 'after': 'sidebar_end'},
            review={'wrap': 'sidebar_review'}
        ),
        '❝ ❞': SymbolSpec(
            symbol='❝ ❞', key='pull_quote',
            layout={'before': 'quote_intro', 'after': 'quote_outro'},
            review={'wrap': 'quote_review'}
        ),
        '⬖': SymbolSpec(
            symbol='⬖', key='standalone_page',
            layout={'before': 'standalone_start', 'after': 'standalone_end'},
            review={'wrap': 'standalone_review'}
        ),
        '📐': SymbolSpec(
            symbol='📐', key='layout_note',
            layout={'before': 'note_intro', 'after': 'note_outro'},
            review={'wrap': 'layoutnote_review'}
        ),
        '⌘': SymbolSpec(
            symbol='⌘', key='page_title',
            layout={'before': 'title_start', 'after': 'title_end'},
            review={'wrap': 'title_review'}
        ),
        '📖': SymbolSpec(
            symbol='📖', key='pdf_page',
            layout={'before': 'pdf_marker', 'after': 'pdf_marker'},
            review={'wrap': 'pdfpage_review'}
        )
    }

    _symbol_pattern: str = '|'.join(re.escape(sym) for sym in _registry)
    _symbol_line_regex = re.compile(rf'^({_symbol_pattern}) ?(.*)', re.UNICODE)

    @classmethod
    def parse_symbol_line(cls, line: str) -> Tuple[Optional[str], str]:
        match = cls._symbol_line_regex.match(line)
        if match:
            return match.group(1), match.group(2)
        return None, line

    @classmethod
    def get(cls, symbol: str) -> SymbolSpec:
        if symbol not in cls._registry:
            raise ValueError(f"Unrecognized symbol prefix: {symbol!r}")
        return cls._registry[symbol]

    @classmethod
    def all_symbols(cls) -> List[str]:
        return list(cls._registry.keys())

    @classmethod
    def resolve_components(cls, meta_list: List[str]) -> List[str]:
        if not meta_list or '*' in meta_list:
            return cls.all_symbols()

        key_to_symbol = {spec.key: sym for sym, spec in cls._registry.items()}
        result = []

        for item in meta_list:
            if item in cls._registry:
                result.append(item)
            elif item.lower() in key_to_symbol:
                result.append(key_to_symbol[item.lower()])
            else:
                raise ValueError(f"Unrecognized component in metadata: {item!r}")

        return result


@attr.define
class BaseFilter:
    mode: str = "layout"
    components: List[str] = attr.field(factory=list)
    errors: List[str] = attr.field(factory=list)

    def prepare(self, doc: pf.Doc):
        self.mode = str(doc.get_metadata('mode', 'layout')).lower()
        raw = doc.get_metadata('components', [])
        self.components = SubmitSymbolRegistry.resolve_components(raw)
        self.errors.clear()
        pf.debug(f"Filter mode: {self.mode}")
        pf.debug(f"Active components: {self.components}")

    def error(self, message: str):
        self.errors.append(message)

    def finalize(self, doc=None):
        if not self.errors:
            return

        RED = "\033[91m"
        RESET = "\033[0m"
        print(f"\n{RED}Errors encountered during filter execution:{RESET}\n", file=sys.stderr)
        for err in self.errors:
            print(f"{RED}  • {err}{RESET}", file=sys.stderr)

        # Also write to a log file
        with open("filter_errors.log", "w", encoding="utf-8") as f:
            for err in self.errors:
                f.write(f"- {err}\n")

        sys.exit(1)

    def ensure_symbol(self, symbol: str):
        if symbol not in SubmitSymbolRegistry.all_symbols():
            self.error(f"Unrecognized or disallowed symbol prefix: {symbol!r}")
        if symbol not in self.components:
            self.error(f"Symbol '{symbol}' not in enabled components: {self.components}")

    def load_document(self, path: Path) -> pf.Doc:
      if not path.exists():
          self.error(f"Linked file does not exist: {path}")
          return pf.Doc()  # empty fallback to avoid crash
  
      text = path.read_text(encoding="utf-8")
      return pf.convert_text(text, input_format="markdown")


    def parse_paragraph_symbol(self, para: pf.Para) -> str:
        text = pf.stringify(para).strip()
        if not text:
            self.error("Blank paragraph encountered.")
            return ""
        symbol, _ = SubmitSymbolRegistry.parse_symbol_line(text)
        if not symbol:
            self.error(f"Paragraph does not begin with a recognized symbol: {text!r}")
            return ""
        self.ensure_symbol(symbol)
        return symbol


class CombinedFilter(BaseFilter):
    def build_div(self, handler: SymbolSpec, kind: str, content: List[pf.Element]) -> Optional[pf.Div]:
        style = handler.get_style(self.mode, kind)
        if not style:
            return None
        if not all(isinstance(elem, pf.Block) for elem in content):
            raise TypeError(f"Non-block element passed to build_div[{kind}]: {content}")
        return pf.Div(*content, attributes={"custom-style": style})

    def action(self, elem, doc):
        if isinstance(elem, pf.Para):
            first = elem.content[0] if elem.content else None
            if isinstance(first, pf.Image):
                return None

            symbol = self.parse_paragraph_symbol(elem)
            if not symbol or symbol not in self.components:
                return pf.Null()

            handler = SubmitSymbolRegistry.get(symbol)

            linked_blocks = []
            for inline in elem.content:
                if isinstance(inline, pf.Link):
                    url = inline.url
                    if url.endswith(".md") and not url.startswith("http"):
                        linked_blocks.extend(self.load_document(Path(url)))

            if linked_blocks:
                result = list(filter(None, linked_blocks))
                if not all(isinstance(el, pf.Block) for el in result):
                    self.error(f"Linked content contains non-block elements: {result}")
                    return pf.Null()
                return result
            elif any(isinstance(i, pf.Link) and i.url.endswith(".md") for i in elem.content):
                self.error(f"Link in paragraph with symbol {symbol} did not resolve to content")

            middle = [pf.Para(*elem.content)]

            if self.mode == "review":
                return self.build_div(handler, "wrap", middle)

            before = self.build_div(handler, "before", middle)
            after = self.build_div(handler, "after", middle)

            result = list(filter(None, [before] + middle + [after]))
            if not all(isinstance(el, pf.Element) for el in result):
                raise TypeError(f"action() returned non-Element objects: {result}")
            return result


        return None


def main(doc=None):
    filt = CombinedFilter()
    pf.run_filter(filt.action, prepare=filt.prepare, finalize=filt.finalize, doc=doc)


if __name__ == "__main__":
    main()

"""Learns per-key extraction rules from (source document, confirmed values).

A rule = locator + extractor + transform:
  locator   : how to find the target cell from an anchor label
              ("self": the label's own cell, "grid": table cell by row label and
               column header, "right": next cell to the right, "below": next
               cell below), plus which occurrence of the label
  extractor : whole cell, or the text after a prefix up to a tail word
  transform : output format learned from the confirmed value (e.g. dates)

Rules are induced by locating each confirmed value in its source document.
A rule's reliability is how often it reproduces the confirmed value on the
documents it fires on, so every user correction refines the rule set.
"""

import re
from collections import Counter, defaultdict
from dataclasses import dataclass
from functools import lru_cache

from rawdoc import Cell, RawDocument, clean, norm

DATE = re.compile(r"^(\d{1,2})\s*[/.-]\s*(\d{1,2})\s*[/.-]\s*(\d{4})$")
MAX_PREFIX_WORDS = 3


@dataclass(frozen=True)
class Rule:
    locator: str  # self | grid | right | below
    anchor: str  # normalized label text
    nth: int  # occurrence of the anchor in the document
    prefix: str  # normalized text before the value inside the target cell ("" = start)
    tail: str  # first word after the value (normalized), "digit" = next word with a
    #            digit, "char:<c>" to stop at a character inside a token
    #            (e.g. "/" in 282/2026/CNBT), "" = end of cell
    seg: int = 0  # "/"- or "-"-separated segments to skip inside the first token


@lru_cache(maxsize=None)
def _norm_index(text: str) -> tuple[str, list[int]]:
    """norm(text) plus, for each normalized char, its index in `text`."""
    out, idx = [], []
    for i, ch in enumerate(text):
        n = norm(ch)
        out.append(n)
        idx.extend([i] * len(n))
    return "".join(out), idx


def _word_end(text: str, label: str) -> int | None:
    """End (in `text`) of the first occurrence of the normalized `label` that
    is made of whole words, so that the label "Mái" does not match in the name
    "Hoàng Mai"; a digit may follow, as in "Số12". None when there is none."""
    text_norm, idx = _norm_index(text)
    pos = text_norm.find(label)
    while pos >= 0:
        start, end = idx[pos], idx[pos + len(label) - 1] + 1
        before_ok = start == 0 or not text[start - 1].isalpha()
        if before_ok and (end == len(text) or not text[end].isalpha()):
            return end
        pos = text_norm.find(label, pos + 1)
    return None


def _span(cell_text: str, value: str) -> tuple[int, int] | None:
    """Character span of `value` inside `cell_text`, matched on normalized text."""
    target = norm(value)
    if not target:
        return None
    text_norm, idx = _norm_index(cell_text)
    pos = text_norm.find(target)
    if pos < 0:
        return None
    return idx[pos], idx[pos + len(target) - 1] + 1


SEGMENT = re.compile(r"[/-]")


def _prefix_words(text: str) -> str:
    """Up to MAX_PREFIX_WORDS label words right before the value. Words with
    digits are other values (they change between documents), so the prefix
    stops there."""
    words = []
    for w in reversed([w for w in re.split(r"\s+", text) if norm(w)]):
        if re.search(r"\d", w) or len(words) == MAX_PREFIX_WORDS:
            break
        words.insert(0, w)
    return norm(" ".join(words))


def _tail(after: str) -> str:
    if not after:
        return ""
    if not after[0].isspace() and not after[0].isalnum():
        return f"char:{after[0]}"
    if after[0].isalpha():  # glued unit, e.g. "677,7" in "677,7m2"
        return f"char:{re.match(r'[^\W\d_]+', after).group()}"
    word = next((w for w in re.split(r"\s+", after) if norm(w)), "")
    # A following number (phone, area...) changes per document: stop at
    # "the next word containing a digit" instead of that literal word.
    return "digit" if re.search(r"\d", word) else norm(word)


def _split_before(before: str) -> tuple[str, int] | None:
    """Splits the text before a value into (label part, segments to skip).

    "Số: 282/" -> ("Số: ", 1). Returns None when the text right before the
    value cannot be described by a label (it ends in another value)."""
    seg = 0
    if before and not before[-1].isspace():
        token = before.split()[-1]
        if SEGMENT.search(token[-1]):
            seg = len(SEGMENT.findall(token))
            before = before[: len(before) - len(token)]
        elif norm(token[-1]):
            return None  # value starts in the middle of a word
    label = _prefix_words(before)
    if not label and norm(before):
        return None  # only variable content (numbers) before the value
    return label, seg


# Documents hash by identity, so these caches are per document object.
def _grid_key(doc: RawDocument, cell: Cell) -> str:
    """"<row label>@<column header>", e.g. "thoidiemgiaodich@taisansosanh1"."""
    cols = doc.property_columns.get(cell.row)
    if cols:  # comparison table: generic header_of() is unreliable there
        header = cols[cell.col].text if cell.col in cols else ""
        parent = doc.table_parents.get(cell.row, "")
        label = norm(parent) + "/" + norm(doc.row_label(cell)) if parent else norm(doc.row_label(cell))
        label, header = label.strip("/"), norm(header)
    else:
        label, header = norm(doc.row_label(cell)), norm(doc.header_of(cell))
    return f"{label}@{header}" if label and header else ""


@lru_cache(maxsize=None)
def _anchor_cells(doc: RawDocument, anchor: str, locator: str) -> tuple[Cell, ...]:
    if locator == "self":
        return tuple(c for c in doc.cells if _word_end(c.text, anchor) is not None)
    if locator == "grid":
        return tuple(c for c in doc.cells if _grid_key(doc, c) == anchor)
    return tuple(c for c in doc.cells if c.key == anchor)


def _extract(cell: Cell, prefix: str, tail: str, seg: int = 0) -> str | None:
    text = cell.text
    if prefix:
        end_of_prefix = _word_end(text, prefix)
        if end_of_prefix is None:
            return None
        text = text[end_of_prefix:]
    text = text.lstrip(" :.-–—\t\n")
    # A value does not run over a line break inside the cell.
    text = text.split("\n", 1)[0]
    if seg:
        token = text.split()[0] if text.split() else ""
        separators = list(SEGMENT.finditer(token))
        if len(separators) < seg:
            return None
        text = text[separators[seg - 1].end() :]
    if tail.startswith("char:"):
        stop = text.find(tail[5:], 1)
        if stop > 0:
            text = text[:stop]
    elif tail:
        # cut before the first word whose normalized form is the tail
        for m in re.finditer(r"\S+", text):
            hit = re.search(r"\d", m.group()) if tail == "digit" else norm(m.group()) == tail
            if hit and m.start() > 0:
                text = text[: m.start()]
                break
    value = clean(text).rstrip(" ,;:.-–")
    # Drop an unmatched bracket left by the cut: "(10.97, 107.92" -> "10.97, 107.92",
    # but keep "Đất ở (ONT)".
    if value.startswith("(") and ")" not in value:
        value = value[1:].strip()
    if value.endswith(")") and "(" not in value:
        value = value[:-1].strip()
    return value or None


@lru_cache(maxsize=None)
def apply_rule(doc: RawDocument, rule: Rule) -> str | None:
    anchors = _anchor_cells(doc, rule.anchor, rule.locator)
    if rule.nth >= len(anchors):
        return None
    anchor = anchors[rule.nth]
    target = {
        "self": lambda c: c,
        "grid": lambda c: c,
        "right": doc.right_of,
        "below": doc.below,
    }[rule.locator](anchor)
    if target is None:
        return None
    return _extract(target, rule.prefix, rule.tail, rule.seg)


@lru_cache(maxsize=None)
def candidate_rules(doc: RawDocument, value: str) -> frozenset[Rule]:
    """Every rule that would extract `value` from `doc`."""
    rules: set[Rule] = set()
    target = norm(value)
    if len(target) < 1:
        return rules
    for cell in doc.cells:
        if target not in cell.key:
            continue
        span = _span(cell.text, value)
        if span is None:
            continue
        before, after = cell.text[: span[0]], cell.text[span[1] :]
        split = _split_before(before)
        if split is None:
            continue
        prefix, seg = split
        tail = _tail(after)

        # Label inside the same cell, e.g. "Số: 494/2026/BCĐG".
        if prefix:
            occurrences = _anchor_cells(doc, prefix, "self")
            if cell in occurrences:
                rules.add(Rule("self", prefix, occurrences.index(cell), prefix, tail, seg))

        # Table cell addressed by row label x column header, e.g.
        # "Thời điểm giao dịch" x "Tài sản so sánh 2".
        grid = _grid_key(doc, cell)
        if grid:
            occurrences = _anchor_cells(doc, grid, "grid")
            rules.add(Rule("grid", grid, occurrences.index(cell), prefix, tail, seg))

        # Label in the cell to the left / above.
        for locator, neighbour in (("right", doc.left_of(cell)), ("below", doc.above(cell))):
            if neighbour is None or not neighbour.key:
                continue
            occurrences = _anchor_cells(doc, neighbour.key, locator)
            if neighbour in occurrences:
                rules.add(
                    Rule(locator, neighbour.key, occurrences.index(neighbour), prefix, tail, seg)
                )
    return frozenset(rules)


def learn_transform(raw: str, confirmed: str) -> str:
    raw, confirmed = clean(raw), clean(confirmed)
    if raw == confirmed:
        return "identity"
    m_raw, m_conf = DATE.match(raw), DATE.match(confirmed)
    if m_raw and m_conf:
        sep = re.search(r"[/.-]", confirmed).group()
        pad = len(m_conf.group(1)) == 2
        return f"date{sep}{'0' if pad else ''}"
    return _number_format(raw, confirmed) or _separator_map(raw, confirmed) or "identity"


NUMERIC = re.compile(r"^[\d.,\s]+$")
PLAIN_NUMBER = re.compile(r"^(\d+)(?:\.(\d+))?$")  # how Excel numbers are extracted


def _format_number(raw: str, thousands: str, decimal: str) -> str | None:
    m = PLAIN_NUMBER.match(clean(raw))
    if not m:
        return None
    whole, frac = m.groups()
    grouped = f"{int(whole):,}".replace(",", thousands)
    if frac and frac.strip("0"):
        return f"{grouped}{decimal}{frac.rstrip('0')}"
    return grouped


def _number_format(raw: str, confirmed: str) -> str | None:
    """Plain Excel number to the user's format, e.g. 1800000 -> 1.800.000,
    945.2 -> 945,2. Encoded as "num:<thousands><decimal>" ("_" = none)."""
    if not PLAIN_NUMBER.match(raw):
        return None
    for thousands in (".", ",", " ", ""):
        for decimal in (",", "."):
            if thousands != decimal and _format_number(raw, thousands, decimal) == confirmed:
                return f"num:{thousands or '_'}{decimal}"
    return None


def _separator_map(raw: str, confirmed: str) -> str | None:
    """Number written with other separators, e.g. 945.2 -> 945,2 or
    1.234.000 -> 1,234,000 or 1.234.000 -> 1234000. Encoded as "map:<from><to>..."
    ("_" = delete)."""
    if not (NUMERIC.match(raw) and NUMERIC.match(confirmed)):
        return None
    if re.sub(r"\D", "", raw) != re.sub(r"\D", "", confirmed):
        return None
    raw_seps = re.findall(r"[.,]", raw)
    conf_seps = re.findall(r"[.,]", confirmed)
    mapping: dict[str, str] = {}
    if not conf_seps:
        mapping = {s: "_" for s in raw_seps}
    elif len(raw_seps) == len(conf_seps):
        for a, b in zip(raw_seps, conf_seps):
            if mapping.setdefault(a, b) != b:
                return None
    else:
        return None
    return "map:" + "".join(a + b for a, b in sorted(mapping.items()))


def apply_transform(value: str, transform: str) -> str:
    if transform.startswith("num:"):
        thousands = "" if transform[4] == "_" else transform[4]
        return _format_number(value, thousands, transform[5]) or value
    if transform.startswith("map:") and NUMERIC.match(value):
        pairs = transform[4:]
        table = {pairs[i]: pairs[i + 1] for i in range(0, len(pairs), 2)}
        return "".join(
            "" if table.get(c) == "_" else table.get(c, c) for c in clean(value)
        )
    if transform.startswith("date"):
        m = DATE.match(clean(value))
        if m:
            sep, pad = transform[4], transform.endswith("0")
            d, mo, y = m.groups()
            if pad:
                d, mo = d.zfill(2), mo.zfill(2)
            return f"{d}{sep}{mo}{sep}{y}"
    return value


def same_value(a: str | None, b: str | None) -> bool:
    """Strict comparison: case/whitespace-insensitive, punctuation-sensitive."""
    if a is None or b is None:
        return False
    return re.sub(r"\s+", "", clean(a).lower()) == re.sub(r"\s+", "", clean(b).lower())


def near_value(a: str | None, b: str | None, min_ratio: float = 85) -> bool:
    """Needs only a small text edit: identical digits (numbers must be exact)
    and >= min_ratio% similar text, e.g. "(nay là ...)" vs "(Địa chỉ mới: ...)"."""
    from rapidfuzz import fuzz

    if not a or not b:
        return False
    if same_value(a, b):
        return True
    if re.sub(r"\D", "", a) != re.sub(r"\D", "", b):
        return False
    return fuzz.ratio(clean(a).lower(), clean(b).lower()) >= min_ratio


def wilson_lower_bound(correct: int, total: int, z: float = 1.64) -> float:
    """Pessimistic precision estimate: 3/3 ranks below 28/29, unlike a plain
    or Laplace-smoothed ratio."""
    if total == 0:
        return 0.0
    p = correct / total
    denom = 1 + z * z / total
    centre = p + z * z / (2 * total)
    margin = z * ((p * (1 - p) + z * z / (4 * total)) / total) ** 0.5
    return (centre - margin) / denom


@dataclass
class Prediction:
    value: str
    confidence: float
    rule: Rule
    support: int


class Mapper:
    """Rule set learned from training cases; `fit` is cheap, so the app can
    re-learn after every export."""

    def __init__(self, min_support: int = 2, min_fired: int = 3, min_confidence: float = 0.5):
        self.min_support = min_support  # documents the rule was induced from
        self.min_fired = min_fired  # documents the rule was checked on
        # Below this, leave the field empty: an empty field is visibly "to do",
        # a wrong value may slip through.
        self.min_confidence = min_confidence
        self.rules: dict[str, dict[Rule, dict]] = {}

    def fit(self, cases: list[tuple[RawDocument, dict[str, str]]]) -> "Mapper":
        producers: dict[str, dict[Rule, set[int]]] = defaultdict(lambda: defaultdict(set))
        for i, (doc, values) in enumerate(cases):
            for key, value in values.items():
                if value and norm(value):
                    for rule in candidate_rules(doc, value):
                        producers[key][rule].add(i)

        self.rules = {}
        for key, by_rule in producers.items():
            kept = {}
            for rule, docs in by_rule.items():
                if len(docs) < self.min_support:
                    continue
                outputs = [
                    (raw, values[key])
                    for doc, values in cases
                    if values.get(key) and (raw := apply_rule(doc, rule)) is not None
                ]
                fired = len(outputs)
                if fired < self.min_fired:
                    continue
                # One transform per rule (the one reproducing the most confirmed
                # values), then score every document with it.
                options = {learn_transform(raw, conf) for raw, conf in outputs} | {"identity"}
                scored = {
                    t: sum(same_value(apply_transform(raw, t), conf) for raw, conf in outputs)
                    for t in options
                }
                transform = max(scored, key=lambda t: (scored[t], t == "identity"))
                correct = scored[transform]
                kept[rule] = {
                    "support": len(docs),
                    "fired": fired,
                    "correct": correct,
                    "transform": transform,
                    "reliability": wilson_lower_bound(correct, fired),
                }
            if kept:
                self.rules[key] = kept
        return self

    def predict(self, doc: RawDocument) -> dict[str, Prediction]:
        out: dict[str, Prediction] = {}
        for key, rules in self.rules.items():
            ranked = sorted(
                rules.items(),
                key=lambda kv: (kv[1]["reliability"], kv[1]["support"]),
                reverse=True,
            )
            for rule, stats in ranked:
                if stats["reliability"] < self.min_confidence:
                    break
                raw = apply_rule(doc, rule)
                if raw is None:
                    continue
                out[key] = Prediction(
                    apply_transform(raw, stats["transform"]),
                    stats["reliability"],
                    rule,
                    stats["support"],
                )
                break
        return out

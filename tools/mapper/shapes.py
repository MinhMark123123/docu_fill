"""Rejects values whose shape never occurs in a field's confirmed values, e.g. a
section heading in a phone number field or a long amount in a short field."""

import re

MASK = "⁇"  # OCR number the two recognizers disagree on: still a number
MIN_EXAMPLES = 5  # fewer say too little about what a field looks like
ALWAYS = 0.95  # share of confirmed values that makes a trait required
LETTER = re.compile(r"[^\W\d_]")


def plausible(value: str, confirmed: list[str]) -> bool:
    if len(confirmed) < MIN_EXAMPLES:
        return True
    value = value.replace(MASK, "0")
    n = len(confirmed)
    if sum(bool(re.search(r"\d", c)) for c in confirmed) / n >= ALWAYS and not re.search(r"\d", value):
        return False
    if sum(not LETTER.search(c) for c in confirmed) / n >= ALWAYS and LETTER.search(value):
        return False
    if sum("%" in c for c in confirmed) / n >= ALWAYS and "%" not in value:
        return False
    lengths = sorted(len(c) for c in confirmed)
    return len(value) <= lengths[int(ALWAYS * (n - 1))] * 2 + 5

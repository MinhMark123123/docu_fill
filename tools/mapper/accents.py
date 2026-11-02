"""Accent repair of OCR values from what users confirmed for the same field.

OCR sometimes misreads Vietnamese accents. Correcting single words or word
sequences across a document was measured to do harm ("đại" -> "dài", or customer
names such as "Nguyễn Thị Anh" -> "Ánh"), so only a whole value is repaired, only
from confirmed values of its own field, and only accents or case may change.
"""

import re

from rawdoc import clean, norm

MASK = "⁇"  # OCR number the two recognizers disagree on


def _numbers(text: str) -> list[str]:
    # norm() drops punctuation, so "15,5m" and "155m" would look the same.
    return re.findall(r"\d+", text)


def fix_accents(value: str, confirmed: list[str]) -> str:
    """The one confirmed spelling of `value`, or `value` unchanged when it is
    already a confirmed spelling, has none, or has several (ambiguous)."""
    if MASK in value or not re.search(r"[^\W\d_]", value):
        return value
    key, numbers = norm(value), _numbers(value)
    same = {clean(c).lower(): clean(c) for c in confirmed if norm(c) == key and _numbers(c) == numbers}
    if clean(value).lower() in same or len(same) != 1:
        return value
    return next(iter(same.values()))

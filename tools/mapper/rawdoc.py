"""Normalized source document: rows of cells, shared by Excel, Word and OCR.

Excel extraction and ocr_bench/layout.py both emit one row per line with
cells separated by " | "; Excel adds "--- Sheet: name ---" headers.
"""

import re
import unicodedata
from dataclasses import dataclass

SHEET = re.compile(r"^--- Sheet: (.*) ---$")


def norm(s: str) -> str:
    """Lowercase, no diacritics, alphanumerics only: for matching labels/values."""
    s = unicodedata.normalize("NFD", (s or "").lower()).replace("đ", "d")
    s = "".join(c for c in s if unicodedata.category(c) != "Mn")
    return re.sub(r"[^0-9a-z]", "", s)


def clean(s: str) -> str:
    return re.sub(r"\s+", " ", unicodedata.normalize("NFC", s or "")).strip()


@dataclass(frozen=True)
class Cell:
    sheet: str
    row: int
    col: int
    text: str

    @property
    def key(self) -> str:
        return norm(self.text)


class RawDocument:
    def __init__(self, text: str):
        self.rows: list[list[Cell]] = []
        sheet = ""
        for line in text.replace("\r\n", "\n").split("\n"):
            m = SHEET.match(line.strip())
            if m:
                sheet = m.group(1)
                continue
            parts = [clean(c) for c in line.split(" | ")]
            if not any(parts):
                continue
            r = len(self.rows)
            self.rows.append([Cell(sheet, r, c, t) for c, t in enumerate(parts)])
        self.cells = [c for row in self.rows for c in row if c.text]

    def right_of(self, cell: Cell) -> Cell | None:
        """Next non-empty cell to the right in the same row."""
        return next((c for c in self.rows[cell.row][cell.col + 1 :] if c.text), None)

    def left_of(self, cell: Cell) -> Cell | None:
        return next((c for c in reversed(self.rows[cell.row][: cell.col]) if c.text), None)

    def below(self, cell: Cell) -> Cell | None:
        """Next non-empty cell in the same column further down (same sheet)."""
        for row in self.rows[cell.row + 1 :]:
            if row and row[0].sheet != cell.sheet:
                return None
            if cell.col < len(row) and row[cell.col].text:
                return row[cell.col]
        return None

    def above(self, cell: Cell) -> Cell | None:
        for row in reversed(self.rows[: cell.row]):
            if row and row[0].sheet != cell.sheet:
                return None
            if cell.col < len(row) and row[cell.col].text:
                return row[cell.col]
        return None

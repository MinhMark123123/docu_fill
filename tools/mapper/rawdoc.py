"""Normalized source document: rows of cells, shared by Excel, Word and OCR.

Excel extraction and ocr_bench/layout.py both emit one row per line with
cells separated by " | "; Excel adds "--- Sheet: name ---" headers.

Excel cells may contain line breaks, which the extractor writes as real
newlines, splitting one sheet row over several lines. Every row of a sheet
has the same number of cells, so physical lines are re-joined until a row
has all its separators; line breaks are kept inside the cell text.
"""

import re
import unicodedata
from dataclasses import dataclass
from functools import cached_property

SHEET = re.compile(r"^--- Sheet: (.*) ---$")
SEP = " | "
HEADER_MIN_CELLS = 3
HEADER_MAX_LEN = 40
HEADER_MAX_DISTANCE = 80  # rows a column header applies to
# "Tài sản thẩm định" -> "0", "Tài sản so sánh 2" -> "2"
PROPERTY_HEADER = re.compile(r"^taisan(?:sosanh([1-9])|(thamdinh))$")
SECTION_TITLE_LEN = 15


def norm(s: str) -> str:
    """Lowercase, no diacritics, alphanumerics only: for matching labels/values."""
    s = unicodedata.normalize("NFD", (s or "").lower()).replace("đ", "d")
    s = "".join(c for c in s if unicodedata.category(c) != "Mn")
    return re.sub(r"[^0-9a-z]", "", s)


def clean(s: str) -> str:
    return re.sub(r"\s+", " ", unicodedata.normalize("NFC", s or "")).strip()


def clean_cell(s: str) -> str:
    """Like clean(), but keeps line breaks inside a cell."""
    return "\n".join(c for c in (clean(line) for line in (s or "").split("\n")) if c)


@dataclass(frozen=True)
class Cell:
    sheet: str
    row: int
    col: int
    text: str

    @property
    def key(self) -> str:
        return norm(self.text)


def _logical_rows(text: str) -> list[tuple[str, str]]:
    """(sheet, row line) pairs with Excel rows split by in-cell newlines re-joined."""
    sheets: list[tuple[str, list[str]]] = [("", [])]
    for line in text.replace("\r\n", "\n").split("\n"):
        m = SHEET.match(line.strip())
        if m:
            sheets.append((m.group(1), []))
        else:
            sheets[-1][1].append(line)

    rows = []
    for sheet, lines in sheets:
        if not sheet:  # Word / OCR text: one line is one row
            rows.extend((sheet, line) for line in lines)
            continue
        expected = max((l.count(SEP) for l in lines), default=0)
        buffer = None
        for line in lines:
            buffer = line if buffer is None else f"{buffer}\n{line}"
            if buffer.count(SEP) >= expected:
                rows.append((sheet, buffer))
                buffer = None
        if buffer is not None:
            rows.append((sheet, buffer))
    return rows


class RawDocument:
    def __init__(self, text: str):
        self.rows: list[list[Cell]] = []
        for sheet, line in _logical_rows(text):
            parts = [clean_cell(c) for c in line.split(SEP)]
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

    @cached_property
    def _header_rows(self) -> list[int]:
        """Rows that look like table headers: several short single-line cells,
        e.g. "TT | Nội dung | Tài sản thẩm định | Tài sản so sánh 1 | ..."."""
        out = []
        for i, row in enumerate(self.rows):
            filled = [c for c in row if c.text]
            if len(filled) >= HEADER_MIN_CELLS and all(
                len(c.text) <= HEADER_MAX_LEN and "\n" not in c.text for c in filled
            ):
                out.append(i)
        return out

    def header_of(self, cell: Cell) -> str:
        """Column header of the nearest header row above (same sheet), or ""."""
        for h in reversed(self._header_rows):
            if h >= cell.row:
                continue
            if cell.row - h > HEADER_MAX_DISTANCE:
                return ""
            row = self.rows[h]
            if row[0].sheet != cell.sheet or cell.col >= len(row):
                return ""
            return row[cell.col].text
        return ""

    @cached_property
    def property_columns(self) -> dict[int, dict[int, Cell]]:
        """row -> {col: header cell} for rows of a comparison table
        ("Nội dung | Tài sản thẩm định | Tài sản so sánh 1 | ..."). The generic
        header_of() is unreliable there: data rows such as "12 | 10 | 15" look
        like headers too. A table ends at a section title (one long cell left
        of the property columns) or at the end of the sheet."""
        out: dict[int, dict[int, Cell]] = {}
        current, sheet = None, None
        for i, row in enumerate(self.rows):
            cols = {c.col: c for c in row if PROPERTY_HEADER.match(c.key)}
            if len(cols) >= 2:
                current, sheet = cols, row[0].sheet
                out[i] = current
                continue
            if current is None:
                continue
            filled = [c for c in row if c.text]
            if row[0].sheet != sheet or (
                len(filled) == 1
                and filled[0].col < min(current)
                and len(filled[0].text) > SECTION_TITLE_LEN
            ):
                current = None
                continue
            out[i] = current
        return out

    def property_of(self, cell: Cell) -> str | None:
        """"0" (appraised property) or "1".."9" (comparable) when the cell sits
        in that column of a comparison table, else None."""
        header = self.property_columns.get(cell.row, {}).get(cell.col)
        if header is None:
            return None
        m = PROPERTY_HEADER.match(header.key)
        return m.group(1) or "0"

    def row_label(self, cell: Cell) -> str:
        """Left-most cell of the row that reads as a label (has letters, not a
        numbering like "1" or "b"), when it is left of `cell`."""
        for c in self.rows[cell.row][: cell.col]:
            if len(c.key) >= 3 and re.search(r"[a-z]", c.key):
                return c.text
        return ""

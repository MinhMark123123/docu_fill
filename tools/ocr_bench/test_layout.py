"""Run with: python -I -X utf8 test_layout.py (from tools/ocr_bench)."""

import sys
import unittest
from pathlib import Path

import cv2
import numpy as np

sys.path.insert(0, str(Path(__file__).parent))
from layout import page_text  # noqa: E402

COLUMNS = [100, 200, 500, 800, 1100, 1400]
ROWS = [100, 200, 300, 400]


def table_page() -> np.ndarray:
    """Three rows and five columns; the first column of rows 2-3 is one merged cell."""
    img = np.full((1000, 1600, 3), 255, np.uint8)
    for y in ROWS:
        start = COLUMNS[0] if y in (ROWS[0], ROWS[1], ROWS[3]) else COLUMNS[1]
        cv2.line(img, (start, y), (COLUMNS[-1], y), (0, 0, 0), 2)
    for x in COLUMNS:
        cv2.line(img, (x, ROWS[0]), (x, ROWS[-1]), (0, 0, 0), 2)
    return img


def line(text: str, column: int, row: int) -> dict:
    x, y = COLUMNS[column] + 20, ROWS[row] + 30
    return {"text": text, "box": [[x, y], [x + 60, y], [x + 60, y + 30], [x, y + 30]]}


class PageText(unittest.TestCase):
    def test_empty_cells_keep_later_cells_in_their_column(self):
        lines = [
            line("TT", 0, 0), line("Noi dung", 1, 0), line("TS1", 2, 0), line("TS2", 3, 0), line("TS3", 4, 0),
            line("Gia", 1, 1), line("100", 3, 1), line("200", 4, 1),
        ]
        self.assertEqual(page_text(lines, table_page()).splitlines(), ["TT | Noi dung | TS1 | TS2 | TS3", " | Gia |  | 100 | 200"])

    def test_row_without_its_merged_first_cell(self):
        lines = [line("Ty le", 1, 2), line("0%", 2, 2), line("1%", 3, 2), line("2%", 4, 2)]
        self.assertEqual(page_text(lines, table_page()), " | Ty le | 0% | 1% | 2%")

    def test_text_outside_tables_is_unchanged(self):
        free = {"text": "Tieu de", "box": [[100, 600], [300, 600], [300, 640], [100, 640]]}
        self.assertEqual(page_text([free], table_page()), "Tieu de")


if __name__ == "__main__":
    unittest.main()

"""Layout-aware reading order for OCR lines.

Text detectors return lines roughly top-to-bottom, which interleaves the
columns of tables (e.g. the comparable-property table with TS1/TS2/TS3) and
splits one cell's value over several lines. Bank reports draw table borders,
so cells are recovered from the ruling lines in the page image; every OCR line
is assigned to the cell containing it, and each cell's lines are joined.
Text outside tables is grouped into rows by vertical overlap.
"""

from dataclasses import dataclass
from statistics import median

import cv2
import numpy as np


COLUMN_TOLERANCE = 12  # pixels at 200 dpi between left edges of one column


@dataclass
class Rect:
    x0: float
    y0: float
    x1: float
    y1: float

    @property
    def cx(self) -> float:
        return (self.x0 + self.x1) / 2

    @property
    def cy(self) -> float:
        return (self.y0 + self.y1) / 2

    @property
    def h(self) -> float:
        return self.y1 - self.y0

    def contains(self, x: float, y: float) -> bool:
        return self.x0 <= x <= self.x1 and self.y0 <= y <= self.y1


def line_rect(line: dict) -> Rect:
    xs = [p[0] for p in line["box"]]
    ys = [p[1] for p in line["box"]]
    return Rect(min(xs), min(ys), max(xs), max(ys))


def detect_cells(img: np.ndarray) -> list[list[Rect]]:
    """Returns table cells (one list per table) found from ruling lines."""
    gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY) if img.ndim == 3 else img
    binary = cv2.adaptiveThreshold(
        gray, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY_INV, 25, 15
    )
    h, w = binary.shape
    horizontal = cv2.morphologyEx(
        binary, cv2.MORPH_OPEN, cv2.getStructuringElement(cv2.MORPH_RECT, (max(20, w // 25), 1))
    )
    vertical = cv2.morphologyEx(
        binary, cv2.MORPH_OPEN, cv2.getStructuringElement(cv2.MORPH_RECT, (1, max(20, h // 40)))
    )
    grid = cv2.dilate(horizontal | vertical, np.ones((3, 3), np.uint8), iterations=2)

    tables = []
    contours, _ = cv2.findContours(grid, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    for contour in contours:
        tx, ty, tw, th = cv2.boundingRect(contour)
        if tw < 0.3 * w or th < 0.03 * h:
            continue  # stray line, underline, logo
        roi = 255 - grid[ty : ty + th, tx : tx + tw]
        count, _, stats, _ = cv2.connectedComponentsWithStats(roi, connectivity=4)
        cells = []
        for x, y, cw, ch, _area in stats[1:count]:
            touches_border = x == 0 or y == 0 or x + cw >= tw or y + ch >= th
            if touches_border or cw < 15 or ch < 10:
                continue
            cells.append(Rect(tx + x, ty + y, tx + x + cw, ty + y + ch))
        if len(cells) >= 2:
            tables.append(cells)
    return tables


def _rows(items: list, rect_of) -> list[list]:
    """Groups items into rows by vertical overlap, each row sorted left-to-right."""
    rows: list[list] = []
    for item in sorted(items, key=lambda i: rect_of(i).cy):
        r = rect_of(item)
        if rows:
            row = rows[-1]
            top = min(rect_of(i).y0 for i in row)
            bottom = max(rect_of(i).y1 for i in row)
            overlap = min(bottom, r.y1) - max(top, r.y0)
            if overlap >= 0.5 * min(r.h, min(rect_of(i).h for i in row)):
                row.append(item)
                continue
        rows.append([item])
    for row in rows:
        row.sort(key=lambda i: rect_of(i).x0)
    return rows


def _column_starts(cells: list[Rect]) -> list[float]:
    """Left edge of every table column, from the left edges of all its cells."""
    groups: list[list[float]] = []
    for x in sorted(c.x0 for c in cells):
        if groups and x - groups[-1][-1] <= COLUMN_TOLERANCE:
            groups[-1].append(x)
        else:
            groups.append([x])
    return [median(g) for g in groups]


def page_text(lines: list[dict], img: np.ndarray) -> str:
    """Page text in reading order. Table rows are rendered as
    "cell | cell | cell" with each cell's wrapped lines joined. Empty cells are
    kept, so that a cell's position always tells its column: in "Giá | | 100"
    the 100 belongs to the third column, not the second."""
    lines = [l for l in lines if l["text"].strip()]
    tables = detect_cells(img)

    cell_lines: dict[tuple[int, int], list[dict]] = {}
    free: list[dict] = []
    for line in lines:
        r = line_rect(line)
        for t, cells in enumerate(tables):
            hit = next((i for i, c in enumerate(cells) if c.contains(r.cx, r.cy)), None)
            if hit is not None:
                cell_lines.setdefault((t, hit), []).append(line)
                break
        else:
            free.append(line)

    # Each table and each free row becomes a "segment" positioned by its top.
    segments: list[tuple[float, str]] = []
    for t, cells in enumerate(tables):
        used = [i for i in range(len(cells)) if (t, i) in cell_lines]
        if not used:
            continue
        texts = {}
        for i in used:
            in_cell = _rows(cell_lines[(t, i)], line_rect)
            texts[i] = " ".join(l["text"] for row in in_cell for l in row)
        starts = _column_starts(cells)
        rendered = []
        for row in _rows(used, lambda i: cells[i]):
            slots = [""] * len(starts)
            for i in row:
                column = min(range(len(starts)), key=lambda c: abs(starts[c] - cells[i].x0))
                slots[column] = f"{slots[column]} {texts[i]}".strip()
            while not slots[-1]:
                slots.pop()
            rendered.append(" | ".join(slots))
        body = "\n".join(rendered)
        segments.append((min(cells[i].y0 for i in used), body))
    for row in _rows(free, line_rect):
        segments.append((line_rect(row[0]).y0, " ".join(l["text"] for l in row)))

    segments.sort(key=lambda s: s[0])
    return "\n".join(text for _, text in segments)

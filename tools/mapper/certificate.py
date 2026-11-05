"""Land use certificates (GCN) inside a scanned dossier.

A dossier PDF holds both the report and the scanned certificate it is based on.
The report is what the mapper fills fields from; the certificate is the legal
source, so what it says is used to check the report, never to overrule it: either
side can be misread, and only the user can tell which. It is also read when the
report part gave nothing.

Handwritten parts (the book number, the signing date) are read badly, but OCR
masks those numbers, and masked numbers are ignored here.
"""

import re
import unicodedata
from dataclasses import dataclass

from domain import plain_number, vn_number
from rawdoc import norm

MASK = "⁇"
ZONE_LINES = 30  # a certificate's fields, on the page of its heading
NUMBER_FIELD = r"(?![\d.,]*" + MASK + r")"

PARCEL = re.compile(r"thua\s*dat\s*so\s*:?\s*(\d+)")
SHEET = re.compile(r"to\s*ban\s*do\s*so\s*:?\s*(\d+)")
AREA = re.compile(r"dien\s*tich\s*:\s*" + NUMBER_FIELD + r"(\d[\d.,]*)\s*m")
ISSUE_NUMBER = re.compile(r"so\s*phat\s*hanh\s*gcn\s*:?\s*" + NUMBER_FIELD + r"([a-z]{0,2}\s*\d{6,})")
SERIAL_LINE = re.compile(r"^\s*([a-z]{2}\s*\d{6,9})\s*$")

PAPER_START = re.compile(r"^[-–•\s]*(?:gcn\b|giay\s*chung\s*nhan\b|trich\s*luc\b|manh\s*trich\b)")
PAPER_NUMBER = re.compile(r"\bS[ỐO]\b", re.I)
# Reports write some labels in capitals; the field does not.
LOUD_LABELS = (
    (r"\bhồ sơ gốc số\b", "hồ sơ gốc số"),
    (r"\bsố vào sổ cấp gcn\b", "số vào sổ cấp GCN"),
)
OWNER = re.compile(r"^[-–•\s]*chu\s*so\s*huu\s*tai\s*san\s*:", re.I)

# Keys checked against the certificate, by what they hold.
PARCEL_KEY, SHEET_KEY, AREA_KEY = "%%SoThuaDat%%", "%%SoToBanDo%%", "%%DienTichDat%%"
PAPER_KEY = "%%GiayChungNhanQuyenSuDungDat%%"


@dataclass
class Certificate:
    parcel: str = ""
    sheet: str = ""
    area: str = ""  # "364,0" as printed
    number: str = ""  # serial or issue number, "AA 12345678"


def _plain(line: str) -> str:
    """Lowercase without accents, spaces kept: OCR writes "Thứa" or "Thừa" for "Thửa"."""
    decomposed = unicodedata.normalize("NFD", line.lower()).replace("đ", "d")
    return "".join(c for c in decomposed if unicodedata.category(c) != "Mn")


def _is_heading(line: str) -> bool:
    # Exactly the heading: "GIẤY CHỨNG NHẬN KẾT HÔN" is a marriage certificate.
    return norm(line) == "giaychungnhan" or norm(line).startswith("trangbosunggiaychungnhan")


def _first_zone(lines: list[str]) -> int:
    return next((i for i, line in enumerate(lines) if _is_heading(line)), len(lines))


def read_certificates(text: str) -> list[Certificate]:
    """One entry per parcel. The main page and the supplement page of one
    certificate are merged, as the supplement repeats its parcel and number."""
    lines = text.split("\n")
    found: list[Certificate] = []
    for start in (i for i, line in enumerate(lines) if _is_heading(line)):
        cert = Certificate()
        for line in lines[start + 1 : start + 1 + ZONE_LINES]:
            if _is_heading(line):
                break
            plain = _plain(line)
            for regex, attr in ((PARCEL, "parcel"), (SHEET, "sheet"), (AREA, "area"), (ISSUE_NUMBER, "number")):
                m = regex.search(plain)
                if m and not getattr(cert, attr):
                    setattr(cert, attr, m.group(1))
            m = SERIAL_LINE.match(plain)
            if m and not cert.number:
                cert.number = m.group(1).upper()
        if not (cert.parcel or cert.number):
            continue  # an old certificate's first page: its parcel is on a later page
        same = next((c for c in found if cert.parcel and c.parcel == cert.parcel), None)
        if same:
            same.sheet = same.sheet or cert.sheet
            same.area = same.area or cert.area
            same.number = same.number or cert.number
        else:
            found.append(cert)
    return [c for c in found if c.parcel]


def _numbers(value: str) -> list[str]:
    return [n.lstrip("0") or "0" for n in re.findall(r"\d+", value)]


def _area_number(text: str) -> float | None:
    plain = plain_number(text)
    return float(plain) if plain else None


def compare(values: dict[str, str], certs: list[Certificate]) -> tuple[dict[str, str], dict[str, str]]:
    """(values to fill because the report part gave none, what the certificate
    says where the report's value differs)."""
    fill: dict[str, str] = {}
    differs: dict[str, str] = {}
    if not certs:
        return fill, differs

    for key, attr in ((PARCEL_KEY, "parcel"), (SHEET_KEY, "sheet")):
        said = list(dict.fromkeys(getattr(c, attr) for c in certs if getattr(c, attr)))
        if not said:
            continue
        value = values.get(key)
        if not value:
            fill[key] = " + ".join(said)
        elif MASK not in value and not set(_numbers(value)) <= set(_numbers(" ".join(said))):
            differs[key] = " + ".join(said)

    areas = [a for a in (_area_number(c.area) for c in certs if c.area) if a is not None]
    if areas and len(areas) == len(certs):
        total = sum(areas)
        value = values.get(AREA_KEY)
        if not value:
            fill[AREA_KEY] = vn_number(f"{total:g}")
        elif MASK not in value:
            read = _area_number(value)
            if read is not None and abs(read - total) > 0.001:
                differs[AREA_KEY] = vn_number(f"{total:g}")

    numbers = [c.number for c in certs if c.number]
    paper = values.get(PAPER_KEY)
    if numbers and paper and MASK not in paper:
        digits = re.sub(r"\D", "", paper)
        missing = [n for n in numbers if re.sub(r"\D", "", n) not in digits]
        # Several certificates may share the field with other papers: one known
        # number is enough; none at all means another certificate was described.
        if len(missing) == len(numbers):
            differs[PAPER_KEY] = " + ".join(numbers)
    return fill, differs


def _report_papers(lines: list[str]) -> list[str]:
    """Paper lines of the report part ("- GCN ... số ...", "- Trích lục ..."), each
    joined with the lines it wraps onto."""
    papers: list[str] = []
    current: list[str] | None = None
    for line in lines:
        stripped = line.strip()
        if PAPER_START.match(_plain(stripped)):
            if current:
                papers.append(" ".join(current))
            current = [stripped]
        elif current is not None:
            # Wrapped text does not open a new item or a label.
            if not stripped or re.match(r"^[-+–•*]|^\d+\.|^[a-zA-Z]\.\s|^[^:\d]{0,40}:", stripped):
                papers.append(" ".join(current))
                current = None
                if papers and not PAPER_START.match(_plain(stripped)):
                    break
            else:
                current.append(stripped)
    if current:
        papers.append(" ".join(current))
    return papers


def _expand(paper: str, owner: str | None) -> str:
    """The report abbreviates: "GCN QSHNO & QSDĐO số 47..." -> the certificate's
    full name, which is how the field is written."""
    text = re.sub(r"^[-–•\s]+", "", paper).rstrip(" ,.;")
    named = re.search(r"[.,]?\s*CSH\s*:\s*(.+)$", text)  # "... CSH: Ông A và Bà B"
    if named:
        text, owner = text[: named.start()].rstrip(" ,."), named.group(1)
    for wrote, written in LOUD_LABELS:
        text = re.sub(wrote, written, text, flags=re.I)
    if not re.match(r"gcn\b", _plain(text)):
        return text
    plain = _plain(text)
    if re.search(r"qshn", plain):
        name = "Giấy chứng nhận Quyền sở hữu nhà ở và quyền sử dụng đất ở"
    elif re.search(r"qshts|tsglvd|tsgl", plain):
        name = "Giấy chứng nhận Quyền sử dụng đất, quyền sở hữu tài sản gắn liền với đất"
    else:
        name = "Giấy chứng nhận Quyền sử dụng đất"
    m = PAPER_NUMBER.search(text)
    if not m:
        return text
    rest = text[m.end():].lstrip(" :")
    result = f"{name} số: {rest}"
    return f"{result}. Chủ sở hữu là {owner}" if owner else result


def _is_certificate(paper: str) -> bool:
    return bool(re.match(r"[-–•\s]*(?:gcn|giay\s*chung\s*nhan)", _plain(paper)))


def papers_from_report(text: str) -> dict[str, str]:
    """The legal papers listed in the report part, before the scanned certificates."""
    lines = text.split("\n")
    report = lines[: _first_zone(lines)]
    owner = next(
        (line.split(":", 1)[1].strip().rstrip(" .") for line in report if OWNER.match(_plain(line)) and ":" in line),
        None,
    )
    # Listed under "Chứng từ pháp lý", and the certificate also on the request page.
    section = next((i for i, line in enumerate(report) if "chungtuphaply" in norm(line)), None)
    papers = _report_papers(report if section is None else report[section + 1 :])
    requested = [] if section is None else _report_papers(report[:section])
    out: dict[str, str] = {}
    if not papers:
        papers = requested
    if not papers:
        return out
    certificates = [p for p in papers if _is_certificate(p)]
    if certificates:
        # A number OCR could not settle on one page may be clear on the other.
        clean_copy = next((p for p in requested if MASK not in p and _is_certificate(p)), None)
        chosen = clean_copy if MASK in certificates[0] and clean_copy else certificates[0]
        out[PAPER_KEY] = _expand(chosen, owner)
    others = [p for p in papers if not certificates or p is not certificates[0]]
    # Three fields on the form: extra papers share the last so none is lost.
    if len(others) > 3:
        others = others[:2] + ["; ".join(_expand(p, None) for p in others[2:])]
    for n, paper in enumerate(others, 1):
        body = _expand(paper, None)
        out[f"%%CanCuPhapLyKhac{n}%%"] = body if body.startswith("Căn cứ") else f"Căn cứ {body}"
    return out

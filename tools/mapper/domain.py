"""Fields read directly from the structure of the bank's appraisal form.

Learned rules and the LLM know nothing about what a field means, which is how
the bank's address ended up as the customer's and a comparable's area as its
parcel number. Where the form states the answer, or the user's corrections show
a fixed convention, it is read here instead.

extract() returns:
  values: key -> value, preferred over rules and the LLM
  empty:  keys the source shows have no value; nothing may fill them, because a
          blank field is visibly "to do" while a guess may slip through
  check:  keys whose value follows a convention, not the source text alone, so
          the user should look at them
"""

import re
from dataclasses import dataclass, field
from datetime import date

from rawdoc import Cell, RawDocument, clean, norm

NUMBER = re.compile(r"-?\d+(?:\.\d+)?$")
PROPERTIES = ("1", "2", "3")
# Keys with one value per branch, which the source files do not contain.
BRANCH_KEYS = ("%%DiaChiChiNhanhPGD%%",)
DIRECTION = (
    r"Đông\s*Bắc|Đông\s*Nam|Tây\s*Bắc|Tây\s*Nam|Đông|Tây|Nam|Bắc"
)
HUONG = re.compile(
    rf"^[-\s]*Hướng\s*:?\s*(?P<dirs>(?:{DIRECTION})(?:\s*(?:và|,|-)\s*(?:{DIRECTION}))*)"
    r"\s*[:,\-–]?\s*(?P<road>.*)$",
    re.I,
)
PARCEL = re.compile(r"thửa(?:\s*đất)?(?:\s*số)?\s*:?\s*(\d[\d.,]*)", re.I)
SHEET_NO = re.compile(r"tờ(?:\s*bản\s*đồ)?(?:\s*số)?\s*:?\s*(\d[\d.,]*)", re.I)
ROAD_WIDTH = re.compile(r"rộng\s*(?:khoảng\s*)?(\d+(?:[.,]\d+)?)\s*m", re.I)
BARE_WIDTH = re.compile(r"^\s*(\d+(?:[.,]\d+)?)\s*m\s*$", re.I)  # a cell holding only "13m"
SPAN = r"\d+(?:[.,]\d+)?\s*m?(?:\s*[-–]\s*\d+(?:[.,]\d+)?\s*m?)?"
SIZE = re.compile(rf"ngang\s*({SPAN})\s*[x×]\s*dài\s*({SPAN})", re.I)
# Land items of the valuation table that the form calls "trong lộ giới".
RIGHT_OF_WAY = re.compile(r"logioi|quyhoach|giaothong")
SITED = r"t[oọ][aạ]\s*lạc|giáp\b"  # where a description moves from what to where
FRONTAGES = re.compile(r"(?<![\d.,])\b(0?[1-4]|một|hai|ba)\s*mặt\s*tiền\b", re.I)
WORD_COUNT = {"một": "1", "hai": "2", "ba": "3"}
ROAD_START = re.compile(r"(?:đường|hẻm|ngõ)\b", re.I)
# "Nhà cấp 4 (DTXD: khoảng 80m2, CLCL: 85%)" in a comparable's description.
HOUSE = re.compile(r"((?:căn\s*)?nhà\s*cấp\s*\d)\s*\(([^)]*)\)", re.I)
HOUSE_AREA = re.compile(r"DT(?:XD|SD)\s*:?\s*(?:~|khoảng)?\s*(\d+(?:[.,]\d+)?)\s*m", re.I)
HOUSE_QUALITY = re.compile(r"CLCL\s*:?\s*~?\s*(\d+(?:[.,]\d+)?)\s*%", re.I)
STOREYS = re.compile(r"\b(?:tầng|lầu|trệt)\b", re.I)
CONTACT = re.compile(r"Liên\s*hệ\s*:\s*(.+)$", re.I | re.S)
PHONE = re.compile(r"(?<![\d.])0\d[\d. ]{7,13}\d(?![\d.])")
BUILDING = re.compile(r"\b(?:nhà|CTXD|DTXD|xưởng|cấp\s*4)\b", re.I)
# Comparison-table rows that carry an adjustment rate, by template key part.
RATE_ROWS = {
    "DienTich": "dientichdat",
    "HinhDang": "hinhdang",
    "DoRongMatTien": "dorongmattien",
    "DoRongDuong": "dorongmatcatngo",
}
STRUCTURE = (
    ("sotang", "%%SoTang%%"),
    ("mai", "%%Mai%%"),
    ("tuong", "%%Tuong%%"),
    ("nen", "%%Nen%%"),
    ("san", "%%San%%"),
    ("khungcot", "%%KhungCot%%"),
    ("mong", "%%Mong%%"),
)


@dataclass
class Extraction:
    values: dict[str, str] = field(default_factory=dict)
    empty: set[str] = field(default_factory=set)
    check: set[str] = field(default_factory=set)

    def put(self, key: str, value: str | None, check: bool = False) -> None:
        if value:
            self.values[f"%%{key}%%"] = value
            if check:
                self.check.add(f"%%{key}%%")

    def blank(self, key: str) -> None:
        self.empty.add(f"%%{key}%%")


# --- value formats ------------------------------------------------------------

def plain_number(text: str) -> str:
    """"1.234,5" / "1,234.5" / "1234.5" -> "1234.5"; "" when not a number or when
    it could be read two ways ("1.234" is 1234 or 1.234): numbers must be exact."""
    t = re.sub(r"\s", "", text or "")
    if "," in t and "." in t:
        t = t.replace(".", "").replace(",", ".") if t.rfind(",") > t.rfind(".") else t.replace(",", "")
    elif "," in t:
        if re.search(r"[,]\d{3}$", t) and t.count(",") == 1:
            return ""
        t = t.replace(",", ".") if t.count(",") == 1 else t.replace(",", "")
    elif t.count(".") > 1:
        t = t.replace(".", "")
    elif re.search(r"^-?\d{1,3}\.\d{3}$", t):
        return ""
    if not NUMBER.match(t):
        return ""
    # Excel float noise: 524999999.99999994 is 525000000.
    if len(t.partition(".")[2]) >= 8:
        t = f"{float(t):.6f}".rstrip("0").rstrip(".")
    return t


def vn_number(text: str) -> str:
    """Excel number as the user writes it: 1234500000 -> 1.234.500.000, 195.5 -> 195,5."""
    plain = plain_number(text)
    if not plain:
        return ""
    whole, _, frac = plain.partition(".")
    sign = "-" if whole.startswith("-") else ""
    grouped = f"{int(whole.lstrip('-') or 0):,}".replace(",", ".")
    frac = frac.rstrip("0")
    return f"{sign}{grouped},{frac}" if frac else f"{sign}{grouped}"


def decimal_comma(text: str) -> str:
    """"169.19m - 182.25m" -> "169,19m - 182,25m"."""
    return re.sub(r"(?<=\d)\.(?=\d{1,2}(?!\d))", ",", text)


def trim_zeros(text: str) -> str:
    """"7,10m" -> "7,1m", "6,0m" -> "6m": decimals as the user writes them."""
    text = re.sub(r"(\d),0+(?![\d])", r"\1", text)
    return re.sub(r"(\d,\d*?[1-9])0+(?![\d])", r"\1", text)


def measure(text: str) -> str:
    """A length or range from a description, as the fields hold it:
    "3.8m" -> "3,8", "20,5m - 20,7m" -> "20,5-20,7", "74.90" -> "74,9"."""
    text = re.sub(r"\s*m\b", "", text.replace("–", "-"))
    text = re.sub(r"\s*-\s*", "-", text.strip())
    return trim_zeros(re.sub(r"(?<=\d)\.(?=\d{1,2}(?!\d))", ",", text))


AWAY_FROM_APPRAISED = re.compile(r"\s*\(\s*cách\s*TS\s*T[ĐD][^)]*\)", re.I)


def tidy(key: str, value: str) -> str:
    """Remarks the user always deletes, whichever mapper produced the value."""
    if re.fullmatch(r"%%KhoangCachTuTaiSan\d?DenDuongPhoChinh%%", key):
        return AWAY_FROM_APPRAISED.sub("", value).strip()
    return value


def percent(text: str) -> str | None:
    """Rate cell as a percentage: -0.05 -> -5%, 0 -> 0%. The value goes into the
    document as text, where "-0.05" would be printed as it is."""
    text = clean(text)
    if not NUMBER.match(text):  # rates are plain decimals: "0.015" is not 15
        return None
    return f"{round(float(text) * 100, 4):g}%"


def _sentence(text: str) -> str:
    text = clean(text).strip(" .;,-–")
    return text[:1].upper() + text[1:] if text else text


def _strip_about(text: str) -> str:
    """"rộng khoảng 3m" -> "rộng 3m", as the user writes road widths. Distances
    keep theirs: "cách chợ khoảng 250m"."""
    return re.sub(r"\b(rộng)\s+khoảng\s+(?=\d)", r"\1 ", text, flags=re.I)


def split_new_address(text: str) -> tuple[str, str | None]:
    """"Thôn 2, ... (Xã A, Tỉnh B)." -> (old address, new address).
    The bracket may be written bare, as "nay là ..." or as "Địa chỉ mới: ..."."""
    text = clean(text).rstrip(" .")
    m = re.search(r"[.,\s]*\(\s*(?:nay là|địa chỉ mới\s*:?)?\s*([^()]*)\)?$", text, re.I)
    if not m or not re.search(r"\b(xã|phường|đặc khu)\b", m.group(1), re.I):
        return text, None
    return text[: m.start()].rstrip(" .,"), clean(m.group(1)).rstrip(" .,")


# --- locating cells -----------------------------------------------------------

def _labeled(doc: RawDocument, label: str, start: int = 0, stop: int | None = None) -> tuple[str, int] | None:
    """Value of the first cell whose text starts with `label` (normalized): the
    text after its colon, else the next non-empty cell to the right."""
    for row in doc.rows[start:stop]:
        for cell in row:
            if not cell.key.startswith(label):
                continue
            _, colon, after = cell.text.partition(":")
            after = clean(after) if colon else ""
            if not norm(after):
                right = doc.right_of(cell)
                after = clean(right.text) if right else ""
            return after, cell.row
    return None


def _row_index(doc: RawDocument, label: str, start: int = 0) -> int | None:
    for i, row in enumerate(doc.rows[start:], start):
        if any(c.key.startswith(label) for c in row):
            return i
    return None


def _comparison_rows(doc: RawDocument) -> list[int]:
    return sorted(doc.property_columns)


def _column(doc: RawDocument, i: int, prop: str) -> Cell | None:
    for c in doc.rows[i]:
        if c.col in doc.property_columns.get(i, {}) and doc.property_of(c) == prop:
            return c
    return None


def _table_row(doc: RawDocument, label: str) -> int | None:
    """Comparison-table row whose label cell starts with `label`."""
    for i in _comparison_rows(doc):
        cols = doc.property_columns[i]
        if any(c.key.startswith(label) for c in doc.rows[i][: min(cols)]):
            return i
    return None


# --- sections of the form -----------------------------------------------------

def _dates(out: Extraction, today: date) -> None:
    # The report date and consultation month are when the report is made, not
    # dates in the source; the date the file was received is in no source file.
    out.put("ngaythangnam", f"ngày {today.day:02d} tháng {today.month:02d} năm {today.year}", check=True)
    out.put("ThangNamTuVanGia", f"{today.month:02d}/{today.year}")
    out.blank("NgayThangNamNhanHoSo")
    out.blank("sothongbao")  # the case number the user gives the export


def _customer(doc: RawDocument, out: Extraction) -> None:
    found = _labeled(doc, "khachhangvay")
    if found and norm(found[0]):
        out.put("TenKhachHang", clean(found[0]), check=True)
    # The request form lists the customer first, then the lending branch, each
    # with an address: only the one right under "Khách hàng" is the customer's.
    start = _row_index(doc, "1khachhang")
    if start is not None:
        address = _labeled(doc, "diachi", start, start + 5)
        if address and norm(address[0]):
            out.put("DiaChiKhachHang", address[0].rstrip(" ."), check=True)


def _property_address(doc: RawDocument, out: Extraction) -> None:
    found = _labeled(doc, "diachitaisan")
    if not found or not norm(found[0]):
        return
    old, new = split_new_address(found[0])
    if new is None:
        out.put("DiaChiTaiSan", old)
        return
    out.put("DiaChiTaiSan", f"{old} (Địa chỉ mới: {new})")
    parts = [p.strip() for p in new.split(",")]
    if len(parts) >= 2:
        out.put("PhuongXa", parts[-2], check=True)
        out.put("TinhThanhpho", parts[-1], check=True)


def _legal(doc: RawDocument, out: Extraction) -> None:
    start, stop = _row_index(doc, "2chungtuphaply"), _row_index(doc, "3dacdiem")
    if start is None or stop is None:
        return
    papers = []
    for row in doc.rows[start + 1 : stop]:
        text = " ".join(c.text for c in row if c.text)
        if norm(text):
            papers.append(clean(text).lstrip("-–• ").rstrip(" ."))
    if not papers:
        return
    # Page counts are added by the user from the paper file: always a check.
    out.put("GiayChungNhanQuyenSuDungDat", papers[0], check=True)
    others = [f"Căn cứ {p[0].lower() + p[1:] if p.startswith('Trích') else p}" for p in papers[1:]]
    # Three fields on the form: extra papers share the last so none is lost.
    if len(others) > 3:
        others = others[:2] + ["; ".join(others[2:])]
    for n, text in enumerate(others, 1):
        out.put(f"CanCuPhapLyKhac{n}", text, check=True)


def _land(doc: RawDocument, out: Extraction) -> None:
    start = _row_index(doc, "avedat")
    stop = _row_index(doc, "bvetaisan")
    if start is None:
        return
    rows = doc.rows[start:stop]
    front = back = depth = None
    for row in rows:
        for c in row:
            m = re.search(r"mặt tiền\)\s*:\s*(.+)$", c.text, re.I)
            if m and front is None:
                front = clean(m.group(1))
            m = re.match(r"\s*Mặt hậu\s*:\s*(.+)$", c.text, re.I)
            if m and back is None:
                back = clean(m.group(1))
            m = re.match(r"\s*Chiều dài\s*:\s*(.+)$", c.text, re.I)
            if m and depth is None:
                depth = clean(m.group(1))
    if front and back:
        out.put("MatTienMatHau", trim_zeros(decimal_comma(f"{front}/ {back}")))
    if depth:
        out.put("ChieuSauTrungBinh", trim_zeros(decimal_comma(depth)))

    # Written "Thửa đất số: 116"; the request form buries it inside a sentence.
    for label, key in (("thuadatso", "SoThuaDat"), ("tobandoso", "SoToBanDo")):
        found = _labeled(doc, label, start, stop)
        if found and re.fullmatch(r"[\d\s+,;và]+", found[0]):
            out.put(key, found[0])
    shape = _labeled(doc, "hinhdangthuadat", start, stop)
    if shape and norm(shape[0]):
        value = _sentence(shape[0])
        out.put("HinhDangThuaDat", "Tương đối cân đối" if value == "Tương đối" else value)
    use = _labeled(doc, "mucdichsudungdat", start, stop)
    if use and norm(use[0]):
        out.put("MucDichSuDungDat", _sentence(use[0]))
    origin = _labeled(doc, "nguongocsudungdat", start, stop)
    if origin:
        parts = [origin[0]] if norm(origin[0]) else []
        if not parts:
            # Listed on the rows below when there are several parcels.
            for row in doc.rows[origin[1] + 1 : stop]:
                cells = [c for c in row if c.text]
                if len(cells) != 1 or cells[0].col == 0:
                    break
                parts.append(cells[0].text.lstrip("-– "))
        unique = list(dict.fromkeys(_sentence(re.sub(r"\(thửa đất[^)]*\)", "", p, flags=re.I)) for p in parts))
        out.put("NguonGocSuDung", "; ".join(u for u in unique if u))

    # Facing directions and the road on each side.
    sides: list[tuple[str, str]] = []
    for row in rows:
        for c in row:
            m = HUONG.match(c.text)
            if m:
                # Only a road counts: a side can border a stream or a neighbour,
                # and the rest of the line can be a remark "(theo GCN)".
                road = re.sub(r"^(?:mặt tiền\s*)?(?:tiếp\s*)?(?:giáp\s*)?", "", clean(m.group("road")), flags=re.I)
                road = _sentence(_strip_about(road)) if ROAD_START.match(road) else ""
                for d in re.findall(DIRECTION, m.group("dirs"), re.I):
                    sides.append((clean(d), road))
    if sides:
        out.put("Huong1", sides[0][0])
        out.put("TiepGiapDuong1", sides[0][1])
        sides[1:] = [s for s in sides[1:] if s[1]]
        if len(sides) > 1:
            out.put("Huong2", f"Hướng {sides[1][0]}")
            out.put("TiepGiapDuong2", sides[1][1])
        else:
            out.blank("Huong2")
            out.blank("TiepGiapDuong2")


def _building(doc: RawDocument, out: Extraction) -> None:
    """"+Số tầng: 1 + Mái tôn", "+Tường: gạch  +Nền: Gạch ceramic"."""
    start = _row_index(doc, "bvetaisan")
    if start is None:
        return
    stop = _row_index(doc, "iiiketqua", start)
    for row in doc.rows[start:stop]:
        for c in row:
            if "+" not in c.text:
                continue
            for piece in c.text.split("+"):
                head, colon, tail = piece.partition(":")
                for label, key in STRUCTURE:
                    if norm(head).startswith(label):
                        # No colon: the label's own words come first ("Mái tôn").
                        skip = 2 if label == "sotang" else 1
                        value = tail if colon else " ".join(head.split()[skip:])
                        if norm(value):
                            out.put(key.strip("%"), _sentence(value))
                        break


def _building_figures(doc: RawDocument, out: Extraction) -> None:
    """Year and footprint from the first building described under "b. Về tài sản
    gắn liền với đất", and the valuation table "Hạng mục CTXD | Diện tích |
    Đơn giá | Chất lượng còn lại | Giá trị" when it values a single building."""
    start = _row_index(doc, "bvetaisan")
    if start is not None:
        stop = _row_index(doc, "iiiketqua", start)
        text = "\n".join(c.text for row in doc.rows[start:stop] for c in row if c.text)
        year = re.search(r"Năm xây dựng\D{0,20}?(\d{4})", text, re.I)
        if year:
            out.put("NamXayDung", year.group(1))
        area = re.search(r"Diện tích xây dựng\s*:?\s*(\d+(?:[.,]\d+)?)\s*m", text, re.I)
        if area:
            out.put("DienTichXayDungCTXD", measure(area.group(1)))

    head = _row_index(doc, "sttxhangmucctxd".replace("x", ""))
    if head is None:
        head = next((i for i, row in enumerate(doc.rows) if any(c.key == "hangmucctxd" for c in row)), None)
    if head is None:
        return
    cols = {}
    for c in doc.rows[head]:
        for name, label in (("area", "dientich"), ("price", "dongia"), ("quality", "chatluongconlai"), ("value", "giatri")):
            if c.key.startswith(label) and name not in cols:
                cols[name] = c.col
    if len(cols) < 4:
        return
    items = []
    for row in doc.rows[head + 1 : head + 8]:
        first = next((c for c in row if c.text), None)
        if first is None or not re.fullmatch(r"\d+", first.text.strip()):
            if first is not None and items:
                break
            continue
        items.append(row)
    if len(items) != 1:
        return  # several buildings: how they add up is the user's call

    def cell(name: str) -> str:
        col = cols[name]
        return items[0][col].text if col < len(items[0]) else ""

    if plain_number(cell("area")) in ("", "0"):
        return
    area = measure(plain_number(cell("area")))
    # The table values the floor area the user also writes as used and recognised.
    out.put("DienTichSuDungThucTeCTXD", area, check=True)
    out.put("DienTichSuDungCongNhanCTXD", area, check=True)
    out.put("DonGiaCTXD", vn_number(cell("price")))
    out.put("ChatLuongConLai", percent(cell("quality")))
    rounded = _labeled(doc, "giatritaisantrendatlamtron")
    value = rounded[0] if rounded and plain_number(rounded[0]) else cell("value")
    if plain_number(value):
        out.put("GiaTriCTXD", vn_number(f"{float(plain_number(value)):.0f}"))


def _valuation(doc: RawDocument, out: Extraction) -> None:
    """"Khoản mục | Theo đơn giá nhà nước | Theo đơn giá thẩm định" and the rows
    under it. The form's "ngoài lộ giới" is its first land item; "trong lộ giới"
    is land in a right of way or planned for a road. Other land items (several
    parcels or land types) are how the user adds them up, so nothing is read."""
    head = _row_index(doc, "khoanmuc")
    if head is None:
        return
    cols = {c.key: c.col for c in doc.rows[head] if c.text}
    state, appraised = cols.get("theodongianhanuoc"), cols.get("theodongiathamdinh")
    if state is None or appraised is None:
        return
    items = []
    for i in range(head + 1, min(head + 16, len(doc.rows))):
        label = next((c.key for c in doc.rows[i] if c.text), "")
        if re.match(r"\d", label) and "giatriquyensudungdat" in label:
            items.append(i)
    if len(items) < 2 or not all(
        RIGHT_OF_WAY.search(" ".join(c.key for c in doc.rows[i])) for i in items[1:]
    ):
        return

    def cell(i: int, col: int) -> str:
        return doc.rows[i][col].text if col < len(doc.rows[i]) else ""

    first, others = items[0], items[1:]
    out.put("GiaTriDatONgoaiLoGioi", vn_number(cell(first, appraised)))
    out.put("DienTichDatNgoaiLoGioi", vn_number(cell(first + 1, appraised)))
    out.put("DonGiaDatNhaNuoc", vn_number(cell(first + 2, state)))
    used = [i for i in others if plain_number(cell(i, appraised)) not in ("", "0")]
    if not used:
        out.blank("DienTichDatTrongLoGioi")
        out.blank("GiaTriDatOTrongLoGioi")
    elif len(used) == 1:
        (second,) = used
        out.put("GiaTriDatOTrongLoGioi", vn_number(cell(second, appraised)))
        out.put("DienTichDatTrongLoGioi", vn_number(cell(second + 1, appraised)))


def _description_block(desc: str) -> dict[str, str]:
    """Parts of a comparable's "Mô tả chi tiết tài sản" cell."""
    text = desc.replace("\n", " ")
    parts = {}
    m = re.search(r"Địa chỉ\s*:\s*(.+?)(?=\s*(?:Diện tích|To[aạ] ?độ|Liên hệ)\s*:|$)", text, re.I)
    if m:
        parts["address"] = clean(m.group(1))
    m = re.match(rf"\s*(?:DT\s*:\s*[\d.,]+\s*m2\s*)?(.+?)\s*,?\s*(?={SITED})", text, re.I)
    # Must name a land type: some start with the building ("Nhà cấp 4 (DTXD...").
    if m and "+" not in m.group(1) and len(m.group(1)) < 60 and re.search(r"\bđất\b", m.group(1), re.I):
        parts["land"] = _sentence(m.group(1))
    return parts


def contact(text: str) -> tuple[str, str, bool] | None:
    """(name, phones, needs a check) from "Liên hệ: Anh Tuấn - 0797 986 682" or
    "Liên hệ: 0919.21.7474 - Anh Nhân". Phones are kept as written; several are
    joined with " - ". None without a phone number."""
    m = CONTACT.search(text.replace("\n", " "))
    if not m:
        return None
    rest = re.split(r"\s*(?:To[aạ]\s*độ|Diện\s*tích|Địa\s*chỉ)\s*:", m.group(1), flags=re.I)[0]
    phones = [p.strip() for p in PHONE.findall(rest) if len(re.sub(r"\D", "", p)) in (10, 11)]
    if not phones:
        return None
    name = rest
    for phone in phones:
        name = name.replace(phone, " ")
    several = bool(re.search(r"\bhoặc\b|,", name, re.I))
    name = re.sub(r"\b\d+\b", " ", name)  # a year of birth: "Lan 1990 - 09..."
    name = clean(re.sub(r"\s*[-–/]\s*", " ", name)).strip(" .,;:")
    return name, " - ".join(phones), several or not name


def _house(desc: str, value: str, out: Extraction, n: str) -> None:
    """A comparable with a house on it: type, floor area and remaining quality
    from its description, value from "Giá trị ts trên đất". The storeys are rarely
    written; one is proposed and flagged."""
    m = HOUSE.search(desc)
    if not m:
        return
    out.put(f"LoaiCongTrinhXayDungTaiSan{n}", _sentence(m.group(1)))
    area = HOUSE_AREA.search(m.group(2))
    if area:
        out.put(f"DienTichCongTrinhXayDungTaiSan{n}", area.group(1).replace(".", ","))
    quality = HOUSE_QUALITY.search(m.group(2))
    if quality:
        out.put(f"ChatLuongConLaiCongTrinhXayDungTaiSan{n}", f"{quality.group(1).replace('.', ',')}%")
    if plain_number(value) not in ("", "0"):
        out.put(f"GiaTriCongTrinhXayDungTaiSan{n}", vn_number(value))
    if not STOREYS.search(desc):
        out.put(f"SoTangTaiSan{n}", "1", check=True)


def _comparables(doc: RawDocument, out: Extraction) -> None:
    desc_row = _table_row(doc, "motachitiet")
    build_row = _table_row(doc, "giatritstrendat")
    price_row = _table_row(doc, "giathamkhao")
    time_row = _table_row(doc, "thoidiemgiaodich")
    road_row = _table_row(doc, "dorongmatcatngo")
    width_row = _table_row(doc, "dorongmattien")
    for n in PROPERTIES:
        if desc_row is not None and (cell := _column(doc, desc_row, n)):
            parts = _description_block(cell.text)
            if "address" in parts:
                old, new = split_new_address(parts["address"])
                out.put(f"DiaChiTaiSan{n}", f"{old} (nay là {new})" if new else old)
            land = parts.get("land")
            if land is None and HOUSE.search(cell.text):
                # A house's description names the building, not the land: offers
                # in the same street usually share the appraised land's use.
                land = out.values.get("%%MucDichSuDungDat%%")
            out.put(f"LoaiDatVaDienTichTaiSan{n}", land, check=True)
            size = SIZE.search(cell.text.replace("\n", " "))
            if size:
                width, length = measure(size.group(1)), measure(size.group(2))
                # The width row of the table can disagree (e.g. 10,21 for "ngang 10m").
                listed = _column(doc, width_row, n) if width_row is not None else None
                differs = listed is not None and plain_number(listed.text) not in ("", plain_number(width.split("-")[0]))
                out.put(f"ChieuNgangTaiSan{n}", width, check=differs)
                out.put(f"ChieuDaiTaiSan{n}", length)
            # Offers rarely state these; other numbers in the text are not them.
            for regex, key in ((PARCEL, "ThuaDatTaiSan"), (SHEET_NO, "ToBanDoTaiSan")):
                m = regex.search(cell.text)
                if m:
                    out.put(f"{key}{n}", m.group(1).rstrip(".,"))
                else:
                    out.blank(f"{key}{n}")
            seller = contact(cell.text)
            if seller:
                name, phones, unsure = seller
                out.put(f"NguoiBan{n}", name, check=unsure)
                out.put(f"SoDienThoaiNguoiBan{n}", phones, check=unsure)
        if price_row is not None and (cell := _column(doc, price_row, n)):
            if plain_number(cell.text):
                # The offered price, not the estimated deal price on the next row.
                out.put(f"GiaBanTaiSan{n}", plain_number(cell.text))
        if time_row is not None and (cell := _column(doc, time_row, n)):
            m = re.search(r"\d{1,2}/\d{4}", cell.text)
            if m:
                out.put(f"ThoiDiemGiaoDichTaiSan{n}", m.group())
        if road_row is not None and (cell := _column(doc, road_row, n)):
            m = ROAD_WIDTH.search(cell.text) or BARE_WIDTH.match(cell.text)
            if m:
                out.put(f"DoRongDuongTaiSan{n}", f"{m.group(1).replace('.', ',')}m")
        # Vacant land: "Giá trị ts trên đất" empty or zero, so nothing to value.
        if build_row is not None:
            cell = _column(doc, build_row, n)
            desc = _column(doc, desc_row, n) if desc_row is not None else None
            built = desc is not None and BUILDING.search(desc.text)
            if built:
                _house(desc.text, cell.text if cell else "", out, n)
            elif cell is None or plain_number(cell.text) in ("", "0"):
                out.put(f"LoaiCongTrinhXayDungTaiSan{n}", "Đất trống")
                for key in (
                    "SoTangTaiSan", "DienTichCongTrinhXayDungTaiSan", "DonGiaXayDungCongTrinhTaiSan",
                    "ChatLuongConLaiCongTrinhXayDungTaiSan", "GiaTriCongTrinhXayDungTaiSan",
                ):
                    out.put(f"{key}{n}", "0")


def _rate_row(doc: RawDocument, row: int | None, prop: str) -> str | None:
    """Rate of a property on the "Tỷ lệ điều chỉnh" row right under `row`."""
    if row is None or row + 1 not in doc.property_columns:
        return None
    cell = _column(doc, row + 1, prop)
    return percent(cell.text) if cell else None


def _rates(doc: RawDocument, out: Extraction) -> None:
    for part, label in RATE_ROWS.items():
        row = _table_row(doc, label)
        for n in PROPERTIES:
            out.put(f"PhanTramDieuChinh{part}TaiSan{n}", _rate_row(doc, row, n))
    distance = _table_row(doc, "khoangcachraduong")
    for n in PROPERTIES:
        out.put(f"PhanTramDieuChinhKhoangCachTuTaiSan{n}DenDuongPhoChinh", _rate_row(doc, distance, n))

    # The template has one "other factor": the social environment row, unless
    # that row adjusts nothing and "Yếu tố khác" holds the real one.
    social, other = _table_row(doc, "moitruong"), _table_row(doc, "yeutokhac")
    def row_used(row: int | None) -> bool:
        return row is not None and any(
            percent(c.text) not in (None, "0%")
            for n in PROPERTIES
            if row + 1 in doc.property_columns and (c := _column(doc, row + 1, n))
        )
    has_other = other is not None and any(
        (c := _column(doc, other, p)) and c.text for p in ("0", *PROPERTIES)
    )
    source = social if row_used(social) or not has_other else other
    if source is None:
        return
    for prop, key in (("0", "YeuToKhacTaiSanThamDinh"), ("1", "YeuToKhacTaiSan1"), ("2", "YeuToKhacTaiSan2"), ("3", "YeuToKhacTaiSan3")):
        cell = _column(doc, source, prop)
        if cell and norm(cell.text):
            out.put(key, clean(cell.text))
    for n in PROPERTIES:
        out.put(f"PhanTramDieuChinhYeuToKhacTaiSan{n}", _rate_row(doc, source, n))


def _strengths(doc: RawDocument, out: Extraction) -> None:
    for row in doc.rows:
        for c in row:
            if not c.key.startswith("bdstd"):
                continue
            m = re.search(SITED, c.text, re.I)
            if not m:
                continue
            text = _strip_about(clean(c.text[m.start():])).rstrip(" .")
            sparse = re.search(r"[,.]?\s*khu vực dân cư thưa thớt", text, re.I)
            if sparse:
                text = text[: sparse.start()]
            out.put("LoiThe1", text, check=True)
            out.put(
                "NhuocDiem1",
                "toạ lạc tại khu vực dân cư thưa thớt" if sparse else "không có nhược điểm nào đáng kể",
                check=True,
            )
            return


def _frontages(doc: RawDocument, out: Extraction, ocr: bool) -> None:
    """Number of frontages: as the comparison table states it ("2 mặt tiền" in a
    property's description), else 1, flagged for the user to check. The appraised
    property also has its own line in the form, and is written "01"."""
    row = None if ocr else _table_row(doc, "motachitiet")

    def in_table(prop: str) -> str | None:
        cell = _column(doc, row, prop) if row is not None else None
        m = FRONTAGES.search(cell.text) if cell else None
        return str(int(WORD_COUNT.get(m.group(1).lower(), m.group(1)))) if m else None

    for n in PROPERTIES:
        count = in_table(n)
        out.put(f"SoMatTienTaiSan{n}", count or "1", check=count is None)
        # With the default count there is nothing to adjust for. A stated count has
        # no rate row of its own: closest is "Khả năng kinh doanh". Both stay flagged.
        rate = "0%" if count is None else _rate_row(doc, _table_row(doc, "khanangkinhdoanh"), n)
        out.put(f"PhanTramDieuChinhSoMatTienTaiSan{n}", rate, check=True)

    stated = in_table("0")
    line = _labeled(doc, "soluongmattien")
    m = FRONTAGES.search(f"{line[0]} mặt tiền") if line else None
    own = str(int(WORD_COUNT.get(m.group(1).lower(), m.group(1)))) if m else None
    count = stated or own
    out.put(
        "SoMatTienTaiSanThamDinh",
        f"{int(count or 1):02d}",
        check=count is None or (stated is not None and own is not None and stated != own),
    )


def extract(doc: RawDocument, today: date, ocr: bool = False) -> Extraction:
    """Empty for documents that are not this form: every part needs its labels.

    From OCR only the labeled lines are read. Table columns can shift on a scan,
    which would put a number under the wrong property, and comparables' parcel
    numbers can be on the scanned certificate pages, so they are not blanked."""
    out = Extraction()
    if _row_index(doc, "bdstd") is None and _row_index(doc, "khachhangvay") is None:
        return out
    _dates(out, today)
    _customer(doc, out)
    _property_address(doc, out)
    _land(doc, out)
    _building(doc, out)
    _building_figures(doc, out)
    _frontages(doc, out, ocr)
    if not ocr:
        _legal(doc, out)
        _valuation(doc, out)
        _comparables(doc, out)
        _rates(doc, out)
    _strengths(doc, out)
    # A key the form stated wins over one it left blank elsewhere in the form.
    out.empty -= set(out.values)
    return out


def branch_values(cases: list[tuple[str, dict[str, str]]], branch: str | None) -> dict[str, str]:
    """Values fixed per branch: the latest one confirmed for the same branch.
    `cases` are newest first."""
    out: dict[str, str] = {}
    if not branch:
        return out
    for _, values in cases:
        if norm(values.get("%%TenChiNhanh%%", "")) != norm(branch):
            continue
        for key in BRANCH_KEYS:
            if key not in out and values.get(key):
                out[key] = values[key]
    return out

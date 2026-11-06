"""Run with: python -I -X utf8 test_domain.py"""

import re
import sys
from datetime import date
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from domain import branch_values, extract, percent, split_new_address, vn_number  # noqa: E402
from learner import _word_end  # noqa: E402
from llm_mapper import grounded  # noqa: E402
from rawdoc import RawDocument  # noqa: E402
from reviewed import was_reviewed  # noqa: E402

FORM = """--- Sheet: De nghi ---
1. Khách hàng:  | Ông Lê Văn A |  |
- Địa chỉ:  | 1 Đường A, TP B. |  |
2. Đơn vị cho vay: Ngân hàng |  |  |
- Địa chỉ:  | 203 Tôn Đức Thắng, phường Phú Thuỷ. |  |
--- Sheet: BC ---
- Khách hàng vay:   |  | Ông Lê Văn A & Bà Nguyễn Thị B |  |  |  |
- Địa chỉ tài sản:Thôn 2, Huyện H, Tỉnh Bình Thuận (Xã Hòa Bình, Tỉnh Lâm Đồng). |  |  |  |  |  |
- BĐSTĐ là đất khác tọa lạc tại đường đất rộng khoảng 3m, cách chợ khoảng 200m, khu vực dân cư thưa thớt. |  |  |  |  |  |
2. Chứng từ pháp lý |  |  |  |  |  |
- Giấy chứng nhận số CV 1. Chủ sở hữu là Bà C. |  |  |  |  |  |
- Trích lục bản đồ cấp ngày 13/01/2025. |  |  |  |  |  |
3. Đặc điểm về bất động sản |  |  |  |  |  |
a. Về đất: |  |  |  |  |  |
-Thửa đất số: 216 |  |  |  |  |  |
-DTSD thực tế: 1234.5m2  |  |  | Chiều rộng (mặt tiền): 12.64m |  |  |
 |  |  | Chiều dài: 69.19m - 82.25m  |  | Mặt hậu: 15.9m |
- Hình dáng thửa đất: Không cân đối. |  |  |  |  |  |
- Hướng: Đông Bắc : đường đất rộng khoảng 3m |  |  |  |  |  |
- Hướng: Tây Nam đường bê tông rộng khoảng 2m |  |  |  |  |  |
b. Về tài sản gắn liền với đất:  |  |  |  |  |  |
+Sô tầng: 1    + Mái tôn |  |  |  |  |  |
+Tường : gạch   +Nền: Gạch ceramic |  |  |  |  |  |
III. KẾT QUẢ THẨM ĐỊNH: |  |  |  |  |  |
 | Khoản mục |  | Theo đơn giá nhà nước | Theo đơn giá thẩm định |  |
 | 1. Giá trị quyền sử dụng đất nông nghiệp khác |  | 222916800 | 1111215200 |  |
 | Tổng diện tích (m2) |  | 1234.5 | 1234.5 |  |
 | Đơn giá (đồng/m2) |  | 104000 | 356000 |  |
 | 2. Giá trị quyền sử dụng đất trồng cây lâu năm thuộc lộ giới |  | 0 | 0 |  |
 | Tổng diện tích (m2) |  | 0 | 0 |  |
TT | Nội dung | Tài sản thẩm định | Tài sản so sánh 1 | Tài sản so sánh 2 | Tài sản so sánh 3 |
 | Mô tả chi tiết tài sản | x | DT: 2100m2 Đất trồng cây, tọa lạc tại đường rộng khoảng 3m. Địa chỉ: Thôn 2, tỉnh B.(Xã H, Tỉnh L). Toạ độ: (1, 2) Liên hệ: Chị Tư 1990 - 0912345678 | Đất ở, giáp đường, 2 mặt tiền. Thửa đất số 52, tờ bản đồ số 140. Liên hệ: 0901.234.567 - Anh Ba | DT: 109m2, Nhà cấp 4 (DTXD: khoảng 80m2, CLCL: 85%), giáp đường. Liên hệ: Anh Năm - 0911.111.111 - 0922.222.222 |
A | Giá tham khảo (đồng) |  | 1000000000 | 450000000 | 2500000000 |
2 | Giá trị ts trên đất (đồng) |  |  |  | 500000000 |
1 | Diện tích đất (m2) | 1234.5 | 2100 | 1000 | 5800 |
 | Tỷ lệ điều chỉnh |  | -0.05 | 0 | -0.02 |
5 | Độ rộng mặt cắt ngõ | a | rộng khoảng 3m | rộng 1.5m | b |
"""


def _sheet_rows(text: str) -> str:
    """Pads rows to the same cell count per sheet, as the Excel extractor writes them."""
    sheets, out = [[]], []
    for line in text.splitlines():
        line = re.sub(r"(\s*\|\s*)+$", "", line)
        if line.startswith("---"):
            sheets.append([line])
        else:
            sheets[-1].append(line)
    for sheet in sheets:
        rows = [l for l in sheet if not l.startswith("---")]
        width = max((l.count(" | ") for l in rows), default=0)
        out += [l if l.startswith("---") else l + " | " * (width - l.count(" | ")) for l in sheet]
    return "\n".join(out)


def _values(**kwargs):
    return extract(RawDocument(_sheet_rows(FORM)), date(2026, 11, 4), **kwargs)


def test_customer_address_is_not_the_lending_branch():
    assert _values().values["%%DiaChiKhachHang%%"] == "1 Đường A, TP B"


def test_new_address_gives_ward_and_province():
    v = _values().values
    assert v["%%DiaChiTaiSan%%"] == "Thôn 2, Huyện H, Tỉnh Bình Thuận (Địa chỉ mới: Xã Hòa Bình, Tỉnh Lâm Đồng)"
    assert v["%%PhuongXa%%"] == "Xã Hòa Bình"
    assert v["%%TinhThanhpho%%"] == "Tỉnh Lâm Đồng"


def test_report_dates_are_the_day_of_the_report():
    out = _values()
    assert out.values["%%ngaythangnam%%"] == "ngày 04 tháng 11 năm 2026"
    assert out.values["%%ThangNamTuVanGia%%"] == "11/2026"
    assert "%%ThangNamTuVanGia%%" not in out.check
    assert "%%NgayThangNamNhanHoSo%%" in out.empty


def test_offered_price_needs_no_check():
    assert "%%GiaBanTaiSan1%%" not in _values().check


def test_frontages_from_the_table_else_one_and_flagged():
    out = _values()
    assert out.values["%%SoMatTienTaiSan2%%"] == "2"
    assert "%%SoMatTienTaiSan2%%" not in out.check
    assert out.values["%%SoMatTienTaiSan1%%"] == "1"
    assert "%%SoMatTienTaiSan1%%" in out.check
    assert out.values["%%PhanTramDieuChinhSoMatTienTaiSan1%%"] == "0%"
    assert "%%PhanTramDieuChinhSoMatTienTaiSan1%%" in out.check
    assert out.values["%%SoMatTienTaiSanThamDinh%%"] == "01"
    assert "%%SoMatTienTaiSanThamDinh%%" in out.check


def test_appraised_frontages_use_its_own_line_when_the_table_is_silent():
    form = FORM.replace("a. Về đất: |", "a. Về đất: |\n- Số lượng mặt tiền: 02 mặt tiền. |", 1)
    out = extract(RawDocument(_sheet_rows(form)), date(2026, 11, 4))
    assert out.values["%%SoMatTienTaiSanThamDinh%%"] == "02"
    assert "%%SoMatTienTaiSanThamDinh%%" not in out.check


def test_frontages_on_a_scan_do_not_read_table_columns():
    out = _values(ocr=True)
    assert out.values["%%SoMatTienTaiSan2%%"] == "1"
    assert "%%SoMatTienTaiSan2%%" in out.check


def test_directions_are_whole():
    v = _values().values
    assert (v["%%Huong1%%"], v["%%Huong2%%"]) == ("Đông Bắc", "Hướng Tây Nam")
    assert v["%%TiepGiapDuong1%%"] == "Đường đất rộng 3m"


def test_single_direction_blanks_the_second():
    form = re.sub(r"- Hướng: Tây Nam.*\n", "", FORM)
    out = extract(RawDocument(_sheet_rows(form)), date(2026, 11, 4))
    assert "%%Huong2%%" in out.empty and "%%TiepGiapDuong2%%" in out.empty


def test_building_cells_split_on_plus():
    v = _values().values
    assert v["%%SoTang%%"] == "1"
    assert v["%%Mai%%"] == "Tôn"
    assert v["%%Nen%%"] == "Gạch ceramic"


def test_land_and_valuation():
    out = _values()
    v = out.values
    assert v["%%SoThuaDat%%"] == "216"
    assert v["%%MatTienMatHau%%"] == "12,64m/ 15,9m"
    assert v["%%ChieuSauTrungBinh%%"] == "69,19m - 82,25m"
    assert v["%%HinhDangThuaDat%%"] == "Không cân đối"
    assert v["%%DonGiaDatNhaNuoc%%"] == "104.000"
    assert v["%%GiaTriDatONgoaiLoGioi%%"] == "1.111.215.200"
    assert v["%%DienTichDatNgoaiLoGioi%%"] == "1.234,5"
    assert "%%DienTichDatTrongLoGioi%%" in out.empty


def test_legal_papers_are_all_kept():
    v = _values().values
    assert v["%%GiayChungNhanQuyenSuDungDat%%"] == "Giấy chứng nhận số CV 1. Chủ sở hữu là Bà C"
    assert v["%%CanCuPhapLyKhac1%%"] == "Căn cứ trích lục bản đồ cấp ngày 13/01/2025"


def test_comparable_numbers_need_their_label():
    out = _values()
    assert "%%ThuaDatTaiSan1%%" in out.empty and "%%ToBanDoTaiSan1%%" in out.empty
    assert out.values["%%ThuaDatTaiSan2%%"] == "52"
    assert out.values["%%ToBanDoTaiSan2%%"] == "140"


def test_comparable_table():
    v = _values().values
    assert v["%%GiaBanTaiSan3%%"] == "2500000000"
    assert v["%%DiaChiTaiSan1%%"] == "Thôn 2, tỉnh B (nay là Xã H, Tỉnh L)"
    assert v["%%LoaiDatVaDienTichTaiSan1%%"] == "Đất trồng cây"
    assert "%%LoaiDatVaDienTichTaiSan3%%" not in v  # names a building, not land
    assert v["%%PhanTramDieuChinhDienTichTaiSan1%%"] == "-5%"
    assert v["%%DoRongDuongTaiSan2%%"] == "1,5m"
    assert v["%%LoaiCongTrinhXayDungTaiSan1%%"] == "Đất trống"
    assert v["%%DienTichCongTrinhXayDungTaiSan1%%"] == "0"
    assert v["%%LoaiCongTrinhXayDungTaiSan3%%"] == "Nhà cấp 4"  # not vacant: a house


def test_comparable_with_a_house():
    out = _values()
    v = out.values
    assert v["%%LoaiCongTrinhXayDungTaiSan3%%"] == "Nhà cấp 4"
    assert v["%%DienTichCongTrinhXayDungTaiSan3%%"] == "80"
    assert v["%%ChatLuongConLaiCongTrinhXayDungTaiSan3%%"] == "85%"
    assert v["%%GiaTriCongTrinhXayDungTaiSan3%%"] == "500.000.000"
    assert v["%%SoTangTaiSan3%%"] == "1" and "%%SoTangTaiSan3%%" in out.check


def test_sellers():
    out = _values()
    v = out.values
    assert (v["%%NguoiBan1%%"], v["%%SoDienThoaiNguoiBan1%%"]) == ("Chị Tư", "0912345678")
    assert (v["%%NguoiBan2%%"], v["%%SoDienThoaiNguoiBan2%%"]) == ("Anh Ba", "0901.234.567")
    assert v["%%SoDienThoaiNguoiBan3%%"] == "0911.111.111 - 0922.222.222"
    assert "%%NguoiBan1%%" not in out.check


def test_ocr_skips_table_columns_and_blanks_nothing_on_comparables():
    out = _values(ocr=True)
    assert "%%GiaBanTaiSan1%%" not in out.values
    assert "%%ThuaDatTaiSan1%%" not in out.empty
    assert out.values["%%DiaChiKhachHang%%"]


def test_other_documents_give_nothing():
    out = extract(RawDocument("Hợp đồng mua bán | số 12"), date(2026, 11, 4))
    assert not out.values and not out.empty


def test_formats():
    assert vn_number("1234500000") == "1.234.500.000"
    assert vn_number("195.5") == "195,5"
    assert percent("-0.05") == "-5%"
    assert percent("0") == "0%"
    assert percent("0.015") == "1.5%"
    assert vn_number("524999999.99999994") == "525.000.000"
    assert vn_number("1.234") == ""  # 1234 or 1.234: not guessed
    assert vn_number("1234.125") == "1.234,125"
    assert percent("") is None
    assert split_new_address("Thôn 2, Tỉnh A (nay là Phường B, Tỉnh C).") == ("Thôn 2, Tỉnh A", "Phường B, Tỉnh C")
    assert split_new_address("Số 1 (đường cụt)") == ("Số 1 (đường cụt)", None)


def test_branch_value_comes_from_the_same_branch():
    cases = [
        ("", {"%%TenChiNhanh%%": "Đồng Nai", "%%DiaChiChiNhanhPGD%%": "207 Đồng Khởi"}),
        ("", {"%%TenChiNhanh%%": "Bình Thuận", "%%DiaChiChiNhanhPGD%%": "203 Tôn Đức Thắng"}),
    ]
    assert branch_values(cases, "Bình Thuận") == {"%%DiaChiChiNhanhPGD%%": "203 Tôn Đức Thắng"}
    assert branch_values(cases, None) == {}


def test_labels_match_whole_words():
    assert _word_end("Mái: tôn", "mai") == 3
    assert _word_end("Thị Hoàng Mainha", "mai") is None
    assert _word_end("Số12/2026", "so") == 2


def test_grounding_tells_accents_and_words_apart():
    shown = ["Đất trồng cây hàng năm khác", "Đồng Nai", "Toạ độ X"]
    assert grounded("Đất trồng cây", shown)
    assert not grounded("Đất trống", shown)
    assert not grounded("Đông", shown)
    assert grounded("tọa độ", shown)  # tone mark in either place
    assert grounded("Đất trống", shown, accents=False)
    assert not grounded("Đất 5", shown)


def test_unreviewed_export_is_recognized():
    predicted = {f"k{i}": str(i) for i in range(100)}
    assert not was_reviewed(predicted, dict(predicted))
    edited = {**predicted, **{f"k{i}": "x" for i in range(11)}}
    assert was_reviewed(predicted, edited)
    assert was_reviewed({"a": "1"}, {"a": "1"})  # too few proposals to tell
    assert was_reviewed({}, {"a": "1"})


def test_the_users_choice_wins():
    predicted = {f"k{i}": str(i) for i in range(100)}
    assert was_reviewed(predicted, dict(predicted), "good")
    edited = {**predicted, **{f"k{i}": "x" for i in range(50)}}
    assert not was_reviewed(predicted, edited, "failed")
    assert was_reviewed(predicted, edited, "needsReview")


if __name__ == "__main__":
    failed = 0
    for name, test in list(globals().items()):
        if name.startswith("test_"):
            try:
                test()
                print("ok  ", name)
            except AssertionError as e:
                failed += 1
                print("FAIL", name, e)
    sys.exit(1 if failed else 0)

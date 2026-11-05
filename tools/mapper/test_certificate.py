"""Run with: python -I -X utf8 test_certificate.py"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from certificate import Certificate, compare, papers_from_report, read_certificates  # noqa: E402

MODERN = """GIẤY CHỨNG NHẬN
QUYỀN SỬ DỤNG ĐẤT, QUYỀN SỞ HỮU TÀI SẢN GẮN LIỀN VỚI ĐẤT
Ông Nguyễn Văn An, CCCD: 012345678901
a. Thửa đất số: 108 stờ bản đồ số: 16 b. Diện tích: 264,0 m?
C. Loại đất: Đất ở tại nông thôn 80,0m?
AA 12345678
Thông tin chi tiết được thế hiện tại mã QR."""

OLD_SUPPLEMENT = """TRANG BỔ SỤNG GIẤY CHỨNG NHẬN
Thứa đất số: 103 Tờ bản đồ số: 17
Số phát hành GCN:111222333444555 SỐ VÀO SỔ CẤP GCN: HO⁇."""

REPORT = """GIẤY ĐỀ NGHỊ
GCN QSHNƠ & QSDĐƠ SỐ 1234567890, HỒ SƠ GỐC SỐ: 1111, do UBND tỉnh
Đồng Nai cấp ngày 01/02/2003. CSH: Ông Trần Văn Bình và Bà Lê Thị Cúc
4. Mục đích tư vấn giá: Làm cơ sở cấp tín dụng
BÁO CÁO
- Chủ sở hữu tài sản: Ông Trần Văn Bình và Lài Thị Cúc
2. Chứng từ pháp lý
- GCN QSHNO ⁇ QSDDO số 1234567890, hồ sơ gốc số: 1111, do UBND tỉnh Đồng Nai cấp ngày 01/02/2003,
- Trích lục thửa đất bản đồ địa chính số: 1000/2025 ngày 02/03/2025
3. Đặc điểm về bất động sản
- Thửa đất số: 999, tờ bản đồ: 17"""


def test_modern_certificate():
    (cert,) = read_certificates(MODERN)
    assert (cert.parcel, cert.sheet, cert.area, cert.number) == ("108", "16", "264,0", "AA 12345678")


def test_supplement_page_of_an_old_certificate():
    (cert,) = read_certificates(OLD_SUPPLEMENT)
    assert (cert.parcel, cert.sheet, cert.number) == ("103", "17", "111222333444555")


def test_main_and_supplement_pages_are_one_certificate():
    pages = MODERN + "\n" + OLD_SUPPLEMENT.replace("103", "108").replace("17", "16")
    assert len(read_certificates(pages)) == 1


def test_other_documents_are_not_certificates():
    marriage = "GIẤY CHỨNG NHẬN KẾT HÔN\nThửa đất số: 1 Tờ bản đồ số: 2"
    assert read_certificates(marriage) == []
    # The report's own parcel line is what gets checked, so it must not be read.
    assert read_certificates(REPORT) == []


def test_masked_numbers_are_not_read():
    (cert,) = read_certificates("GIẤY CHỨNG NHẬN\nThửa đất số: 5 Tờ bản đồ số: 6 Diện tích: ⁇ m2")
    assert cert.area == ""
    (cert,) = read_certificates("GIẤY CHỨNG NHẬN\nThửa đất số: 5 Diện tích: 12,⁇ m2")
    assert cert.area == ""


def test_matching_values_raise_nothing():
    certs = [Certificate("108", "16", "264,0", "AA 12345678")]
    values = {"%%SoThuaDat%%": "108", "%%SoToBanDo%%": "16", "%%DienTichDat%%": "264",
              "%%GiayChungNhanQuyenSuDungDat%%": "Giấy chứng nhận số: AA 12345678, ..."}
    assert compare(values, certs) == ({}, {})


def test_differences_are_reported_not_replaced():
    certs = [Certificate("108", "16", "264,0", "AA 12345678")]
    values = {"%%SoThuaDat%%": "180", "%%SoToBanDo%%": "16", "%%DienTichDat%%": "246",
              "%%GiayChungNhanQuyenSuDungDat%%": "Giấy chứng nhận số: AA 12345687"}
    fill, differs = compare(values, certs)
    assert fill == {}
    assert differs == {"%%SoThuaDat%%": "108", "%%DienTichDat%%": "264",
                       "%%GiayChungNhanQuyenSuDungDat%%": "AA 12345678"}


def test_empty_fields_are_filled():
    fill, differs = compare({}, [Certificate("108", "16", "142,5", "")])
    assert fill == {"%%SoThuaDat%%": "108", "%%SoToBanDo%%": "16", "%%DienTichDat%%": "142,5"}
    assert differs == {}


def test_a_masked_value_is_not_called_different():
    certs = [Certificate("108", "16", "264,0", "")]
    assert compare({"%%SoThuaDat%%": "⁇", "%%DienTichDat%%": "3⁇"}, certs)[1] == {}


def test_two_certificates():
    certs = [Certificate("11", "9", "400", ""), Certificate("22", "9", "5600,7", "")]
    values = {"%%SoThuaDat%%": "11 + 22", "%%SoToBanDo%%": "9", "%%DienTichDat%%": "6.000,7"}
    assert compare(values, certs) == ({}, {})
    assert compare({}, certs)[0]["%%SoThuaDat%%"] == "11 + 22"


def test_papers_take_the_clear_copy_and_the_named_owner():
    papers = papers_from_report(REPORT)
    assert papers["%%GiayChungNhanQuyenSuDungDat%%"] == (
        "Giấy chứng nhận Quyền sở hữu nhà ở và quyền sử dụng đất ở số: 1234567890, hồ sơ gốc số: 1111, "
        "do UBND tỉnh Đồng Nai cấp ngày 01/02/2003. Chủ sở hữu là Ông Trần Văn Bình và Bà Lê Thị Cúc"
    )
    assert papers["%%CanCuPhapLyKhac1%%"] == "Căn cứ Trích lục thửa đất bản đồ địa chính số: 1000/2025 ngày 02/03/2025"


def test_papers_stop_at_the_scanned_certificate():
    text = "2. Chứng từ pháp lý\n- GCN QSDĐ số AA 1\n" + MODERN.replace("Thửa đất số", "- GCN QSDĐ số BB 2\nThửa đất số")
    papers = papers_from_report(text)
    assert "AA 1" in papers["%%GiayChungNhanQuyenSuDungDat%%"]
    assert "%%CanCuPhapLyKhac1%%" not in papers


def test_no_papers_in_other_documents():
    assert papers_from_report("Hợp đồng mua bán\nSố 12") == {}


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

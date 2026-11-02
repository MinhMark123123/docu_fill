"""Run with: python -I -X utf8 -m unittest test_accents (from tools/mapper)."""

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from accents import fix_accents  # noqa: E402


class FixAccents(unittest.TestCase):
    def test_repairs_accents_from_the_confirmed_value(self):
        self.assertEqual(fix_accents("Xã Hàm Thanh", ["Xã Hàm Thạnh"]), "Xã Hàm Thạnh")

    def test_keeps_a_value_that_is_already_confirmed(self):
        self.assertEqual(fix_accents("Nguyễn Thị Anh", ["Nguyễn Thị Anh", "Nguyễn Thị Ánh"]), "Nguyễn Thị Anh")

    def test_ambiguous_spellings_change_nothing(self):
        self.assertEqual(fix_accents("Nguyen Thi Anh", ["Nguyễn Thị Anh", "Nguyễn Thị Ánh"]), "Nguyen Thi Anh")

    def test_different_letters_change_nothing(self):
        self.assertEqual(fix_accents("Xã Hàm Cần", ["Xã Hàm Thạnh"]), "Xã Hàm Cần")

    def test_number_grouping_must_match(self):
        self.assertEqual(fix_accents("155m đát", ["15,5m đất"]), "155m đát")

    def test_same_numbers_repair_the_letters_only(self):
        self.assertEqual(fix_accents("15,5m đát", ["15,5m đất"]), "15,5m đất")

    def test_masked_numbers_stay_masked(self):
        self.assertEqual(fix_accents("⁇ Hàm Thanh", ["Hàm Thạnh"]), "⁇ Hàm Thanh")

    def test_plain_numbers_are_never_touched(self):
        self.assertEqual(fix_accents("1250000000", ["1.250.000.000"]), "1250000000")


if __name__ == "__main__":
    unittest.main()

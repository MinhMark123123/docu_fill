"""Run with: python -I -X utf8 test_shapes.py (from tools/mapper)."""

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from shapes import plausible  # noqa: E402

PHONES = ["0975169095", "0969457920", "0377913424", "0987620441", "0832.79.05.79"]
PERCENTS = ["0%", "-5%", "2%", "3%", "5%"]


class Plausible(unittest.TestCase):
    def test_too_few_examples_accept_anything(self):
        self.assertTrue(plausible("IV. KIẾN NGHỊ", PHONES[:4]))

    def test_heading_in_a_number_field(self):
        self.assertFalse(plausible("IV. KIẾN NGHỊ", PHONES))

    def test_letters_in_a_digits_only_field(self):
        self.assertFalse(plausible("0975 anh Hiếu", PHONES))

    def test_amount_in_a_percent_field(self):
        self.assertFalse(plausible("3,093,200,000", PERCENTS))

    def test_a_wrong_but_well_shaped_value_passes(self):
        self.assertTrue(plausible("-5%", PERCENTS))

    def test_masked_number_stays(self):
        self.assertTrue(plausible("⁇", PHONES))

    def test_much_longer_than_ever_confirmed(self):
        self.assertFalse(plausible("x" * 40, ["Nam", "Bắc", "Đông", "Tây", "Nam"]))


if __name__ == "__main__":
    unittest.main()

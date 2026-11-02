"""Run with: python -I -X utf8 test_llm_parse.py (from tools/mapper)."""

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from llm_mapper import parse_answer  # noqa: E402


class ParseAnswer(unittest.TestCase):
    def test_lines(self):
        self.assertEqual(
            parse_answer("k1: 0975169095\nk2: Thôn 3, Xã Hàm Cần"),
            {"k1": "0975169095", "k2": "Thôn 3, Xã Hàm Cần"},
        )

    def test_empty_answers_do_not_swallow_the_next_line(self):
        self.assertEqual(
            parse_answer("k1: \nk2: 10/2026\nk3:\n\nk4: 650m\nk5:"),
            {"k1": "", "k2": "10/2026", "k3": "", "k4": "650m", "k5": ""},
        )

    def test_ignores_other_text(self):
        self.assertEqual(parse_answer("Đây là kết quả:\n\n- k1: 650m\nHết."), {"k1": "650m"})

    def test_json_style_still_reads(self):
        self.assertEqual(parse_answer('{\n"k1": "650m",\n"k2": "6m"\n}'), {"k1": "650m", "k2": "6m"})

    def test_cut_off_line_keeps_the_others(self):
        self.assertEqual(parse_answer("k1: 650m\nk2: Thôn"), {"k1": "650m", "k2": "Thôn"})

    def test_first_answer_wins(self):
        self.assertEqual(parse_answer("k1: 650m\nk1: 700m"), {"k1": "650m"})

    def test_colon_inside_value(self):
        self.assertEqual(parse_answer("k1: Đất ở: Lâu dài"), {"k1": "Đất ở: Lâu dài"})


if __name__ == "__main__":
    unittest.main()

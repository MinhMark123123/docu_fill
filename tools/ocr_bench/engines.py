"""OCR engines used by the benchmark. All models load from ./models only."""

import io
import subprocess
from dataclasses import dataclass
from pathlib import Path

import netguard  # noqa: F401  (must come before OCR libraries)

import cv2
import numpy as np
import pymupdf
from PIL import Image

MODELS = Path(__file__).parent / "models"
TESSERACT_EXE = Path(r"C:\Program Files\Tesseract-OCR\tesseract.exe")


@dataclass
class Line:
    text: str
    box: list  # 4 points [[x, y], ...] in page pixels
    score: float


def render_pages(pdf_path: str, dpi: int):
    """Yields (page_index, RGB ndarray) for every page."""
    doc = pymupdf.open(pdf_path)
    for i, page in enumerate(doc):
        pix = page.get_pixmap(dpi=dpi, colorspace=pymupdf.csRGB)
        img = np.frombuffer(pix.samples, np.uint8).reshape(pix.h, pix.w, 3)
        yield i, img.copy()


def _rapid(det: str, rec: str | None, version, det_type, rec_type, lang=None):
    from rapidocr import RapidOCR

    params = {
        "Global.log_level": "warning",
        "Global.max_side_len": 4000,
        "Cls.model_path": str(MODELS / "ch_ppocr_mobile_v2.0_cls_mobile.onnx"),
        "Det.model_path": str(MODELS / det),
        "Det.ocr_version": version,
        "Det.model_type": det_type,
    }
    if rec is None:
        params["Global.use_rec"] = False
    else:
        params.update(
            {
                "Rec.model_path": str(MODELS / rec),
                "Rec.ocr_version": version,
                "Rec.model_type": rec_type,
            }
        )
        if lang is not None:
            params["Rec.lang_type"] = lang
    return RapidOCR(params=params)


class RapidEngine:
    """PaddleOCR models through RapidOCR/ONNX Runtime (detection + recognition)."""

    def __init__(self, preset: str):
        from rapidocr.utils.typings import LangRec, ModelType, OCRVersion

        v5, v6 = OCRVersion.PPOCRV5, OCRVersion.PPOCRV6
        presets = {
            "v6_small": ("PP-OCRv6_det_small.onnx", "PP-OCRv6_rec_small.onnx", v6, ModelType.SMALL, ModelType.SMALL, None),
            "v6_medium": ("PP-OCRv6_det_medium.onnx", "PP-OCRv6_rec_medium.onnx", v6, ModelType.MEDIUM, ModelType.MEDIUM, None),
            "v5_latin": ("ch_PP-OCRv5_det_server.onnx", "latin_PP-OCRv5_rec_mobile.onnx", v5, ModelType.SERVER, ModelType.MOBILE, LangRec.LATIN),
        }
        self._ocr = _rapid(*presets[preset])

    def __call__(self, img: np.ndarray) -> list[Line]:
        out = self._ocr(img)
        if out.boxes is None:
            return []
        return [
            Line(t, b.tolist(), float(s))
            for t, b, s in zip(out.txts, out.boxes, out.scores)
        ]


def _crop_quad(img: np.ndarray, box: np.ndarray, pad: int = 3) -> np.ndarray:
    box = box.astype(np.float32)
    w = int(max(np.linalg.norm(box[0] - box[1]), np.linalg.norm(box[2] - box[3])))
    h = int(max(np.linalg.norm(box[0] - box[3]), np.linalg.norm(box[1] - box[2])))
    dst = np.array([[pad, pad], [w + pad, pad], [w + pad, h + pad], [pad, h + pad]], np.float32)
    m = cv2.getPerspectiveTransform(box, dst)
    return cv2.warpPerspective(
        img, m, (w + 2 * pad, h + 2 * pad), borderMode=cv2.BORDER_REPLICATE
    )


class DetVietOcrEngine:
    """PP-OCRv6 text detection + VietOCR recognition per detected line."""

    def __init__(self, model: str = "vgg_seq2seq", det: str = "small"):
        import torch
        from rapidocr.utils.typings import ModelType, OCRVersion
        from vietocr.tool.config import Cfg
        from vietocr.tool.predictor import Predictor

        torch.set_num_threads(max(1, torch.get_num_threads()))
        det_file, det_type = {
            "small": ("PP-OCRv6_det_small.onnx", ModelType.SMALL),
            "medium": ("PP-OCRv6_det_medium.onnx", ModelType.MEDIUM),
        }[det]
        self._det = _rapid(det_file, None, OCRVersion.PPOCRV6, det_type, None)

        cfg = Cfg.load_config_from_file(str(MODELS / "vietocr" / "base.yml"))
        cfg.update(
            Cfg.load_config_from_file(
                str(MODELS / "vietocr" / f"{model.replace('_', '-')}.yml")
            )
        )
        cfg["weights"] = str(MODELS / "vietocr" / f"{model}.pth")
        cfg["cnn"]["pretrained"] = False  # avoid torchvision ImageNet download
        cfg["device"] = "cpu"
        cfg["predictor"]["beamsearch"] = False
        self._rec = Predictor(cfg)

    def __call__(self, img: np.ndarray) -> list[Line]:
        out = self._det(img)
        if out.boxes is None:
            return []
        boxes = list(out.boxes)
        crops = [Image.fromarray(_crop_quad(img, b)) for b in boxes]
        texts, probs = self._rec.predict_batch(crops, return_prob=True)
        return [
            Line(t, b.tolist(), float(p)) for t, b, p in zip(texts, boxes, probs)
        ]


class TesseractEngine:
    """Tesseract 5 with Vietnamese traineddata from ./models (best or fast)."""

    def __init__(self, variant: str = "best", psm: int = 3):
        self._tessdata = MODELS / f"tessdata_{variant}"
        self._psm = psm

    def __call__(self, img: np.ndarray) -> list[Line]:
        buf = io.BytesIO()
        Image.fromarray(img).save(buf, format="PNG")
        result = subprocess.run(
            [
                str(TESSERACT_EXE), "stdin", "stdout",
                "--tessdata-dir", str(self._tessdata),
                "-l", "vie", "--psm", str(self._psm),
                # The "tsv" config file lives in the system tessdata, not ours.
                "-c", "tessedit_create_tsv=1",
            ],
            input=buf.getvalue(),
            capture_output=True,
            check=True,
        )
        return _tsv_lines(result.stdout.decode("utf-8"))


def _tsv_lines(tsv: str) -> list[Line]:
    """Groups Tesseract word rows into lines."""
    lines: dict[tuple, dict] = {}
    for row in tsv.splitlines()[1:]:
        cols = row.split("\t")
        if len(cols) < 12 or cols[0] != "5" or not cols[11].strip():
            continue
        key = tuple(cols[1:5])  # page, block, paragraph, line
        x, y, w, h = map(int, cols[6:10])
        entry = lines.setdefault(key, {"words": [], "conf": [], "x0": x, "y0": y, "x1": x + w, "y1": y + h})
        entry["words"].append(cols[11])
        entry["conf"].append(float(cols[10]))
        entry["x0"], entry["y0"] = min(entry["x0"], x), min(entry["y0"], y)
        entry["x1"], entry["y1"] = max(entry["x1"], x + w), max(entry["y1"], y + h)
    return [
        Line(
            " ".join(e["words"]),
            [[e["x0"], e["y0"]], [e["x1"], e["y0"]], [e["x1"], e["y1"]], [e["x0"], e["y1"]]],
            sum(e["conf"]) / len(e["conf"]) / 100,
        )
        for e in lines.values()
    ]


ENGINES = {
    "rapid_v6_small": lambda: RapidEngine("v6_small"),
    "rapid_v5_latin": lambda: RapidEngine("v5_latin"),
    "tess_best": lambda: TesseractEngine("best"),
    "tess_fast": lambda: TesseractEngine("fast"),
    "det_vietocr_s2s": lambda: DetVietOcrEngine("vgg_seq2seq"),
    "det_vietocr_tf": lambda: DetVietOcrEngine("vgg_transformer"),
}

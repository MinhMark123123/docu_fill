"""Dev-machine only: download OCR models once into ./models.

This is the only script in the project that uses the network. Everything that
runs at OCR time loads models from ./models via explicit paths and imports
netguard, so bank machines never download anything.
"""

import hashlib
import sys
import urllib.request
from pathlib import Path

import json

RAPID = "https://www.modelscope.cn/models/RapidAI/RapidOCR/resolve/v3.10.0/onnx"
VIETOCR = "https://vocr.vn/data/vietocr"
TESSDATA = "https://github.com/tesseract-ocr"
HF = "https://huggingface.co"

# relative target -> (url, sha256). RapidOCR hashes come from
# rapidocr/default_models.yaml v3.10.0; None means "pin on first download"
# (the hash is then recorded in models/pinned.json and enforced afterwards).
MODELS = {
    "PP-OCRv6_det_medium.onnx": (
        f"{RAPID}/PP-OCRv6/det/PP-OCRv6_det_medium.onnx",
        "92078b7355007ccfffcd4c8cd441a3afd4538904d06881b29a155e1e679907c2",
    ),
    "PP-OCRv6_rec_medium.onnx": (
        f"{RAPID}/PP-OCRv6/rec/PP-OCRv6_rec_medium.onnx",
        "eef444829dbbe18d7fea59a3f6eb75647518d2b3a9568d27c92e42940204894b",
    ),
    "ch_PP-OCRv5_det_server.onnx": (
        f"{RAPID}/PP-OCRv5/det/ch_PP-OCRv5_det_server.onnx",
        "0f8846b1d4bba223a2a2f9d9b44022fbc22cc019051a602b41a7fda9667e4cad",
    ),
    "latin_PP-OCRv5_rec_mobile.onnx": (
        f"{RAPID}/PP-OCRv5/rec/latin_PP-OCRv5_rec_mobile.onnx",
        "b20bd37c168a570f583afbc8cd7925603890efbcdc000a59e22c269d160b5f5a",
    ),
    "vietocr/base.yml": (f"{VIETOCR}/config/base.yml", None),
    "vietocr/vgg-transformer.yml": (f"{VIETOCR}/config/vgg-transformer.yml", None),
    "vietocr/vgg-seq2seq.yml": (f"{VIETOCR}/config/vgg-seq2seq.yml", None),
    "vietocr/vgg_transformer.pth": (f"{VIETOCR}/vgg_transformer.pth", None),
    "vietocr/vgg_seq2seq.pth": (f"{VIETOCR}/vgg_seq2seq.pth", None),
    "tessdata_best/vie.traineddata": (
        f"{TESSDATA}/tessdata_best/raw/main/vie.traineddata",
        None,
    ),
    "tessdata_fast/vie.traineddata": (
        f"{TESSDATA}/tessdata_fast/raw/main/vie.traineddata",
        None,
    ),
    # Local LLM for field mapping (GGUF holds weights only, no executable code).
    "llm/Qwen_Qwen3-4B-Instruct-2507-Q4_K_M.gguf": (
        f"{HF}/bartowski/Qwen_Qwen3-4B-Instruct-2507-GGUF/resolve/main/"
        "Qwen_Qwen3-4B-Instruct-2507-Q4_K_M.gguf",
        "2fde00ce69dd4899c70d020845e2638353015bba0fdf161b3eb965f2bca4464e",
    ),
}


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> int:
    models_dir = Path(__file__).parent / "models"
    models_dir.mkdir(exist_ok=True)
    pinned_file = models_dir / "pinned.json"
    pinned = json.loads(pinned_file.read_text()) if pinned_file.exists() else {}
    failed = False
    for name, (url, expected) in MODELS.items():
        expected = expected or pinned.get(name)
        target = models_dir / name
        target.parent.mkdir(parents=True, exist_ok=True)
        if target.exists() and (expected is None or sha256(target) == expected):
            pinned.setdefault(name, sha256(target))
            print(f"ok      {name}")
            continue
        print(f"fetch   {name}")
        tmp = target.with_name(target.name + ".part")
        urllib.request.urlretrieve(url, tmp)
        actual = sha256(tmp)
        if expected is not None and actual != expected:
            tmp.unlink()
            print(f"BAD SHA {name}", file=sys.stderr)
            failed = True
            continue
        tmp.replace(target)
        pinned[name] = actual
    pinned_file.write_text(json.dumps(pinned, indent=2))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())

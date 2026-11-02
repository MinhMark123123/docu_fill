"""VietOCR vgg_seq2seq on ONNX Runtime: same results as vietocr.Predictor.predict_batch
(greedy decoding), without torch and without loading pickled .pth weights."""

import math
import os
from collections import defaultdict
from pathlib import Path

import numpy as np
import onnxruntime as ort
from PIL import Image

IMAGE_HEIGHT = 32
IMAGE_MIN_WIDTH = 32
IMAGE_MAX_WIDTH = 512
ROUND_WIDTH_TO = 10
MAX_LENGTH = 128
SOS, EOS = 1, 2
FIRST_CHAR = 4  # ids below are special tokens


def ocr_threads() -> int:
    """Threads per ONNX session: the physical cores, at most 4. More threads than
    cores was measured 7x slower (164 s against 22 s on a 2-core 4-thread CPU)."""
    override = os.environ.get("DOCUFILL_THREADS")
    return int(override) if override else min(4, max(1, (os.cpu_count() or 2) // 2))


def _prepare(image: Image.Image) -> np.ndarray:
    w, h = image.size
    width = math.ceil(int(IMAGE_HEIGHT * float(w) / float(h)) / ROUND_WIDTH_TO) * ROUND_WIDTH_TO
    width = min(max(width, IMAGE_MIN_WIDTH), IMAGE_MAX_WIDTH)
    resized = image.convert("RGB").resize((width, IMAGE_HEIGHT), Image.LANCZOS)
    return (np.asarray(resized).transpose(2, 0, 1) / 255).astype(np.float32)


def _softmax(logits: np.ndarray) -> np.ndarray:
    exp = np.exp(logits - logits.max(axis=-1, keepdims=True))
    return exp / exp.sum(axis=-1, keepdims=True)


class VietOcrOnnx:
    def __init__(self, folder: Path):
        options = ort.SessionOptions()
        options.intra_op_num_threads = ocr_threads()
        # The decoder runs one tiny step per character; spinning threads waste the cores.
        options.add_session_config_entry("session.intra_op.allow_spinning", "0")
        self._cnn, self._encoder, self._decoder = (
            ort.InferenceSession(str(folder / f"{n}.onnx"), options, providers=["CPUExecutionProvider"])
            for n in ("cnn", "encoder", "decoder")
        )
        self._chars = (folder / "vocab.txt").read_text(encoding="utf-8")

    def _decode(self, ids: list[int]) -> str:
        last = ids.index(EOS) if EOS in ids else None
        specials = {0: "<pad>", SOS: "<sos>", EOS: "<eos>", 3: "*"}
        return "".join(specials.get(i) or self._chars[i - FIRST_CHAR] for i in ids[1:last])

    def _translate(self, images: np.ndarray) -> tuple[list[str], list[float]]:
        features = self._cnn.run(None, {"image": images})[0]
        hidden, memory = self._encoder.run(None, {"features": features})
        tokens = np.full(len(images), SOS, dtype=np.int64)
        sentence, probs = [tokens], [np.ones(len(images), dtype=np.float64)]
        finished = np.zeros(len(images), dtype=bool)
        length = 0
        while length <= MAX_LENGTH and not finished.all():
            logits, hidden = self._decoder.run(None, {"token": tokens, "hidden": hidden, "memory": memory})
            scores = _softmax(logits)
            tokens = scores.argmax(axis=-1).astype(np.int64)
            sentence.append(tokens)
            probs.append(scores[np.arange(len(tokens)), tokens].astype(np.float64))
            finished |= tokens == EOS
            length += 1
        ids = np.stack(sentence, axis=1)
        values = np.stack(probs, axis=1) * (ids > FIRST_CHAR - 1)
        with np.errstate(invalid="ignore", divide="ignore"):
            confidence = values.sum(axis=-1) / (values > 0).sum(axis=-1)
        return [self._decode(row) for row in ids.tolist()], confidence.tolist()

    def predict_batch(self, images: list[Image.Image], return_prob: bool = False):
        """Crops of one width form one batch, as in vietocr's Predictor."""
        buckets = defaultdict(list)
        for index, image in enumerate(images):
            prepared = _prepare(image)
            buckets[prepared.shape[-1]].append((index, prepared))
        texts, probs = [""] * len(images), [0.0] * len(images)
        for bucket in buckets.values():
            batch_texts, batch_probs = self._translate(np.stack([p for _, p in bucket]))
            for (index, _), text, prob in zip(bucket, batch_texts, batch_probs):
                texts[index], probs[index] = text, prob
        return (texts, probs) if return_prob else texts

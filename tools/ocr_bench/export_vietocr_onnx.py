"""Dev-machine only: exports VietOCR vgg_seq2seq to ONNX in models/vietocr_onnx.

Three graphs, because recognition loops over the decoder one character at a time:
cnn (image -> features), encoder (features -> memory), decoder (one step).
Checks every graph against torch before finishing.

Usage: python -I -X utf8 export_vietocr_onnx.py
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import engines  # noqa: E402  (imports netguard first: exporting needs no network)
import numpy as np  # noqa: E402
import onnxruntime as ort  # noqa: E402
import torch  # noqa: E402
from torch import nn  # noqa: E402

OUT = engines.MODELS / "vietocr_onnx"
OPSET = 17
MAX_DIFFERENCE = 1e-3  # float32 graphs, torch vs ONNX Runtime


class Cnn(nn.Module):
    """vietocr's Vgg.forward without negative axes, which ONNX Transpose rejects."""

    def __init__(self, vgg):
        super().__init__()
        self.vgg = vgg

    def forward(self, x):
        conv = self.vgg.last_conv_1x1(self.vgg.features(x))
        return conv.transpose(2, 3).flatten(2).permute(2, 0, 1)


class Encoder(nn.Module):
    def __init__(self, seq2seq):
        super().__init__()
        self.encoder = seq2seq.encoder

    def forward(self, src):
        outputs, hidden = self.encoder(src)
        return hidden, outputs


class Decoder(nn.Module):
    def __init__(self, seq2seq):
        super().__init__()
        self.decoder = seq2seq.decoder

    def forward(self, tgt, hidden, encoder_outputs):
        prediction, hidden, _ = self.decoder(tgt, hidden, encoder_outputs)
        return prediction, hidden


def export(model: nn.Module, args: tuple, path: Path, inputs: list[str], outputs: list[str], axes: dict) -> None:
    # The exporter restores the wrapper's training flag on all submodules, so it
    # must be eval: a new wrapper starts in training mode.
    torch.onnx.export(
        model.eval(), args, str(path), input_names=inputs, output_names=outputs,
        dynamic_axes=axes, opset_version=OPSET, dynamo=False,
    )


def main() -> None:
    OUT.mkdir(exist_ok=True)
    predictor = engines._vietocr("vgg_seq2seq")
    model = predictor.model.eval()
    seq2seq = model.transformer

    image = torch.rand(2, 3, 32, 160)
    with torch.no_grad():
        src = model.cnn(image)
        hidden, memory = Encoder(seq2seq)(src)
    tokens = torch.LongTensor([1, 1])

    export(Cnn(model.cnn.model), (image,), OUT / "cnn.onnx", ["image"], ["features"],
           {"image": {0: "batch", 3: "width"}, "features": {0: "time", 1: "batch"}})
    export(Encoder(seq2seq), (src,), OUT / "encoder.onnx", ["features"], ["hidden", "memory"],
           {"features": {0: "time", 1: "batch"}, "hidden": {0: "batch"}, "memory": {0: "time", 1: "batch"}})
    export(Decoder(seq2seq), (tokens, hidden, memory), OUT / "decoder.onnx", ["token", "hidden", "memory"], ["logits", "next_hidden"],
           {"token": {0: "batch"}, "hidden": {0: "batch"}, "memory": {0: "time", 1: "batch"}, "logits": {0: "batch"}, "next_hidden": {0: "batch"}})
    (OUT / "vocab.txt").write_text(predictor.vocab.chars, encoding="utf-8", newline="")

    sessions = {n: ort.InferenceSession(str(OUT / f"{n}.onnx"), providers=["CPUExecutionProvider"]) for n in ("cnn", "encoder", "decoder")}
    worst = 0.0
    for batch, width in ((1, 32), (3, 90), (2, 310), (4, 512)):
        image = torch.rand(batch, 3, 32, width)
        tokens = torch.randint(4, 200, (batch,))
        with torch.no_grad():
            src = model.cnn(image)
            hidden, memory = Encoder(seq2seq)(src)
            logits, next_hidden = Decoder(seq2seq)(tokens, hidden, memory)
        onnx_src = sessions["cnn"].run(None, {"image": image.numpy()})[0]
        onnx_hidden, onnx_memory = sessions["encoder"].run(None, {"features": src.numpy()})
        onnx_logits, onnx_next = sessions["decoder"].run(None, {"token": tokens.numpy(), "hidden": hidden.numpy(), "memory": memory.numpy()})
        for ours, theirs in ((onnx_src, src), (onnx_hidden, hidden), (onnx_memory, memory), (onnx_logits, logits), (onnx_next, next_hidden)):
            worst = max(worst, float(np.abs(ours - theirs.numpy()).max()))
    print(f"largest difference from torch: {worst:.2e}")
    if worst > MAX_DIFFERENCE:
        raise SystemExit("ONNX graphs differ from torch")
    for path in sorted(OUT.iterdir()):
        print(f"{path.name}: {path.stat().st_size / 2**20:.1f} MB")


if __name__ == "__main__":
    main()

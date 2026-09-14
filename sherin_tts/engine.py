from dataclasses import dataclass
from typing import Protocol
import wave
import struct
import math

from .config import VoiceTuneConfig
from .text import normalize_text

@dataclass(frozen=True)
class SynthesisRequest:
    text: str
    voice: str = "default"
    tune: VoiceTuneConfig = VoiceTuneConfig()
    sample_rate: int = 22050

class AcousticModel(Protocol):
    def synthesize(self, text: str, tune: VoiceTuneConfig, sample_rate: int) -> list[float]: ...

class DeterministicFallback:
    """Dependency-free fallback used until a local neural model is installed."""
    def synthesize(self, text: str, tune: VoiceTuneConfig, sample_rate: int) -> list[float]:
        duration = max(0.18, min(12.0, 0.045 * len(text) / tune.speed))
        n = int(duration * sample_rate)
        base = 180.0 * (1.0 + 0.25 * tune.pitch)
        amp = min(0.8, 0.12 * tune.energy)
        return [amp * math.sin(2 * math.pi * base * i / sample_rate) for i in range(n)]

class SherinTTSEngine:
    def __init__(self, model: AcousticModel | None = None):
        self.model = model or DeterministicFallback()

    def synthesize(self, request: SynthesisRequest) -> list[float]:
        text = normalize_text(request.text).text
        tune = request.tune.normalized()
        return self.model.synthesize(text, tune, request.sample_rate)

    @staticmethod
    def write_wav(samples: list[float], path: str, sample_rate: int = 22050) -> None:
        pcm = b"".join(struct.pack("<h", int(max(-1, min(1, x)) * 32767)) for x in samples)
        with wave.open(path, "wb") as f:
            f.setnchannels(1); f.setsampwidth(2); f.setframerate(sample_rate); f.writeframes(pcm)

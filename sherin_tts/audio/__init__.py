"""Audio processing interfaces. RNNoise/VAD native adapters belong here."""
from dataclasses import dataclass

@dataclass(frozen=True)
class AudioConfig:
    sample_rate: int = 22050
    channels: int = 1
    sample_width: int = 2


def clamp_pcm(value: float) -> float:
    return max(-1.0, min(1.0, float(value)))

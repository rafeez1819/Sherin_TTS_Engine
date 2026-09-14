from dataclasses import dataclass


def _clamp(value: float, low: float, high: float) -> float:
    return max(low, min(high, float(value)))


@dataclass(frozen=True)
class VoiceTuneConfig:
    pitch: float = 0.0
    speed: float = 1.0
    energy: float = 1.0
    emotion: str = "neutral"
    style: str = "default"

    def normalized(self) -> "VoiceTuneConfig":
        return VoiceTuneConfig(
            pitch=_clamp(self.pitch, -1.0, 1.0),
            speed=_clamp(self.speed, 0.5, 2.0),
            energy=_clamp(self.energy, 0.0, 2.0),
            emotion=self.emotion.strip().lower() or "neutral",
            style=self.style.strip().lower() or "default",
        )

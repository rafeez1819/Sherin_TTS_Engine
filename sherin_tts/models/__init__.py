"""Model adapter interfaces for local inference backends."""
from typing import Protocol
from ..config import VoiceTuneConfig

class TFLiteModel(Protocol):
    def synthesize(self, text: str, tune: VoiceTuneConfig, sample_rate: int) -> list[float]: ...

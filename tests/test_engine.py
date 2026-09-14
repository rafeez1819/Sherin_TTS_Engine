import pytest
from sherin_tts.config import VoiceTuneConfig
from sherin_tts.text import normalize_text
from sherin_tts.engine import SherinTTSEngine, SynthesisRequest

def test_normalization():
    n = normalize_text("  Hello   Sherin! ")
    assert n.text == "Hello Sherin!"
    assert n.tokens[-1] == "!"

def test_tune_is_clamped():
    x = VoiceTuneConfig(pitch=8, speed=9, energy=-2).normalized()
    assert x.pitch == 1 and x.speed == 2 and x.energy == 0

def test_fallback_synthesis():
    r = SynthesisRequest("Hello")
    samples = SherinTTSEngine().synthesize(r)
    assert samples
    assert max(samples) <= 1 and min(samples) >= -1

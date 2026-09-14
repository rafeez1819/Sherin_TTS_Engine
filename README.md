# Sherin TTS Engine

**Zero-payload, privacy-first speech synthesis architecture for Sherin Cognitor.**

Sherin TTS Engine is designed as an offline-first speech pipeline with deterministic VoiceTune controls, a model-runtime abstraction, audio post-processing, and Android-ready deployment boundaries.

## Architecture

```text
Text → Normalizer → Voice/Style → VoiceTune → Acoustic Model → Vocoder → PCM → AudioTrack
```

Input-side voice processing can use RNNoise + VAD when microphone analysis is enabled. The synthesis path is model-runtime agnostic so FastSpeech 2 + HiFi-GAN/VITS can be deployed through TFLite without coupling the core to a cloud provider.

## Repository status

This repository establishes the executable core, interfaces, tests, web demo, Android integration boundary, security policy, and CI. Model weights are intentionally not committed. Place approved local model artifacts under `models/` or configure a local model directory.

## Security

- No API keys or credentials in source.
- Offline operation is the default.
- No telemetry is implemented by the core.
- Model files are treated as untrusted inputs and should be integrity-verified before loading.
- See `SECURITY.md`.

## Quick start

```bash
python -m venv .venv
# Windows: .venv\\Scripts\\activate
# Linux/macOS: source .venv/bin/activate
pip install -e .[dev]
pytest -q
python -m sherin_tts --text "Hello from Sherin" --output output.wav
```

## VoiceTune

`VoiceTuneConfig` provides deterministic controls for pitch, speed, energy, emotion, and style. The controls are normalized and clamped before being passed to the model runtime.

## Product boundary

The engine is a local speech component. It does not include proprietary voice cloning data, third-party credentials, or cloud APIs. Those can be integrated later through explicit adapters.

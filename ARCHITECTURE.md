# Sherin TTS Engine — Architecture

```text
Sherin Cognitor
  -> TTS Orchestrator
  -> Text Normalizer / Tokenizer / G2P boundary
  -> Voice Identity + Style
  -> VoiceTune
       pitch / speed / energy / emotion / style
  -> Acoustic Model
       FastSpeech 2 adapter
  -> Mel Spectrogram
  -> Vocoder
       HiFi-GAN / VITS adapter
  -> PCM
  -> AudioTrack / WebAudio
```

Optional input-side analysis:

```text
Microphone -> PCM -> RNNoise -> VAD -> voice features -> VoiceTune
```

## Runtime contract

The core deliberately exposes a small `AcousticModel` protocol. This keeps the engine independent of a particular inference backend. A production adapter can target TensorFlow Lite, ONNX Runtime, or another local runtime without changing orchestration or VoiceTune.

## Model lifecycle

Training and conversion happen outside the runtime package. Approved artifacts are versioned and integrity-checked before deployment. Large binary weights are not stored in Git source history.

## Android target

The intended Android implementation uses Kotlin/Java around a local TFLite runtime with NNAPI acceleration where available and CPU fallback otherwise. Audio output should be streamed in bounded buffers to avoid unnecessary memory growth.

## Performance goals

The original design target is low-latency, offline synthesis on constrained devices. Benchmarks must be measured on real target hardware before claiming latency, RAM, or storage figures.

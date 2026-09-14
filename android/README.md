# Sherin TTS Android

This directory defines the Android integration boundary. The production Android module will host the local TFLite runtime, VoiceTune controller, streaming PCM output, and optional RNNoise/VAD native components.

The repository intentionally does not vendor Gradle caches or binary model weights.

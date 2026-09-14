import argparse
from .engine import SherinTTSEngine, SynthesisRequest


def main() -> None:
    p = argparse.ArgumentParser(description="Sherin offline TTS engine")
    p.add_argument("--text", required=True)
    p.add_argument("--output", default="output.wav")
    args = p.parse_args()
    engine = SherinTTSEngine()
    req = SynthesisRequest(args.text)
    engine.write_wav(engine.synthesize(req), args.output, req.sample_rate)
    print(f"Wrote {args.output}")

if __name__ == "__main__":
    main()

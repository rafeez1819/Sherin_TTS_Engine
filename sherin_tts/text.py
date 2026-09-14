from dataclasses import dataclass
import re

@dataclass(frozen=True)
class NormalizedText:
    text: str
    tokens: tuple[str, ...]


def normalize_text(text: str) -> NormalizedText:
    if not isinstance(text, str):
        raise TypeError("text must be a string")
    clean = re.sub(r"\s+", " ", text.strip())
    if not clean:
        raise ValueError("text must not be empty")
    tokens = tuple(re.findall(r"[\w']+|[^\w\s]", clean, flags=re.UNICODE))
    return NormalizedText(clean, tokens)

from __future__ import annotations

import shutil
from pathlib import Path

from PIL import Image, ImageEnhance, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
DISPLAY_ASSET = ROOT / "assets" / "images" / "body_back.png"
GENERATED_SOURCE = ROOT / "assets" / "source_assets" / "body_back_imagegen_posterior.png"
ORIGINAL_BACKUP = ROOT / "assets" / "source_assets" / "body_back_labeled_stretched.png"

TARGET_WIDTH = 500


def main() -> None:
    if not GENERATED_SOURCE.exists():
        raise FileNotFoundError(GENERATED_SOURCE)

    ORIGINAL_BACKUP.parent.mkdir(parents=True, exist_ok=True)
    if DISPLAY_ASSET.exists() and not ORIGINAL_BACKUP.exists():
        shutil.copy2(DISPLAY_ASSET, ORIGINAL_BACKUP)

    image = Image.open(GENERATED_SOURCE).convert("RGB")
    target_height = round(TARGET_WIDTH * image.height / image.width)
    image = image.resize((TARGET_WIDTH, target_height), Image.Resampling.LANCZOS)

    image = ImageEnhance.Contrast(image).enhance(1.03)
    image = ImageEnhance.Color(image).enhance(1.02)
    image = image.filter(ImageFilter.UnsharpMask(radius=0.9, percent=55, threshold=2))
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    for y in range(rgba.height):
        for x in range(rgba.width):
            r, g, b, _ = pixels[x, y]
            whiteness = min(r, g, b)
            alpha = 0 if whiteness > 247 else 255
            if 235 < whiteness <= 247:
                alpha = int((247 - whiteness) / 12 * 255)
            pixels[x, y] = (r, g, b, alpha)
    rgba.save(DISPLAY_ASSET, optimize=True)


if __name__ == "__main__":
    main()

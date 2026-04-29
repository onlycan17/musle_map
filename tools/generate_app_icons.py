from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets" / "source_assets" / "app_icon_imagegen.png"
APP_ICON = ROOT / "assets" / "images" / "app_icon.png"

ANDROID_ICONS = {
    "mipmap-mdpi/ic_launcher.png": 48,
    "mipmap-hdpi/ic_launcher.png": 72,
    "mipmap-xhdpi/ic_launcher.png": 96,
    "mipmap-xxhdpi/ic_launcher.png": 144,
    "mipmap-xxxhdpi/ic_launcher.png": 192,
}

IOS_ICONS = {
    "Icon-App-20x20@1x.png": 20,
    "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58,
    "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40,
    "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120,
    "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180,
    "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}

WEB_ICONS = {
    "favicon.png": 32,
    "icons/Icon-192.png": 192,
    "icons/Icon-512.png": 512,
    "icons/Icon-maskable-192.png": 192,
    "icons/Icon-maskable-512.png": 512,
}


def _square_source() -> Image.Image:
    image = Image.open(SOURCE).convert("RGBA")
    side = min(image.size)
    left = (image.width - side) // 2
    top = (image.height - side) // 2
    return image.crop((left, top, left + side, top + side))


def _save_resized(image: Image.Image, path: Path, size: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    resized = image.resize((size, size), Image.Resampling.LANCZOS)
    # Launcher icons should be fully opaque on every target used here.
    background = Image.new("RGBA", resized.size, "#fff0ec")
    background.alpha_composite(resized)
    background.convert("RGB").save(path, optimize=True)


def main() -> None:
    source = _square_source()
    _save_resized(source, APP_ICON, 1024)

    for relative, size in ANDROID_ICONS.items():
        _save_resized(source, ROOT / "android/app/src/main/res" / relative, size)

    ios_dir = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for filename, size in IOS_ICONS.items():
        _save_resized(source, ios_dir / filename, size)

    for relative, size in WEB_ICONS.items():
        _save_resized(source, ROOT / "web" / relative, size)


if __name__ == "__main__":
    main()

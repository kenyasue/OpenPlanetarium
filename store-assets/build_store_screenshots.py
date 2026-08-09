from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
import math


ROOT = Path(__file__).resolve().parent
CAPTIONS = {
    1: "A Lightweight\nPlanetarium",
    2: "Explore Rich\nSky Catalogs",
    3: "View the Sky with\nDSS Surveys",
    4: "Configure Your\nEquipment",
    5: "Visualize Your\nField of View",
    6: "Discover Minor\nCelestial Objects",
    7: "Explore Fully\nOffline",
    8: "Simple, Intuitive\nControls",
    9: "Ready for\nthe Field",
}

# Current representative portrait upload sizes.
TARGETS = {
    "iOS/phone": (1320, 2868),
    "iOS/tablet": (2064, 2752),
    "android/phone": (1080, 1920),
}

AI_BACKGROUNDS = [
    ROOT / "generated-backgrounds/portrait-milkyway.png",
    ROOT / "generated-backgrounds/portrait-planet.png",
    ROOT / "generated-backgrounds/portrait-nebula.png",
]

FONT_CANDIDATES = [
    Path("C:/Windows/Fonts/segoeuib.ttf"),
    Path("C:/Windows/Fonts/arialbd.ttf"),
]
FONT_PATH = next(p for p in FONT_CANDIDATES if p.exists())


def cover(im, size):
    scale = max(size[0] / im.width, size[1] / im.height)
    resized = im.resize((math.ceil(im.width * scale), math.ceil(im.height * scale)), Image.Resampling.LANCZOS)
    left = (resized.width - size[0]) // 2
    top = (resized.height - size[1]) // 2
    return resized.crop((left, top, left + size[0], top + size[1]))


def fit(im, box):
    scale = min(box[0] / im.width, box[1] / im.height)
    return im.resize((round(im.width * scale), round(im.height * scale)), Image.Resampling.LANCZOS)


def rounded_paste(base, im, xy, radius, border_width, border_color):
    mask = Image.new("L", im.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, im.width - 1, im.height - 1), radius=radius, fill=255)
    shadow = Image.new("RGBA", base.size, (0, 0, 0, 0))
    shadow_mask = Image.new("L", base.size, 0)
    sx, sy = xy
    ImageDraw.Draw(shadow_mask).rounded_rectangle(
        (sx, sy + border_width, sx + im.width, sy + im.height + border_width), radius=radius, fill=190
    )
    shadow_mask = shadow_mask.filter(ImageFilter.GaussianBlur(max(12, border_width * 4)))
    shadow.putalpha(shadow_mask)
    base.alpha_composite(shadow)
    base.paste(im.convert("RGBA"), xy, mask)
    draw = ImageDraw.Draw(base)
    draw.rounded_rectangle(
        (sx, sy, sx + im.width - 1, sy + im.height - 1),
        radius=radius,
        outline=border_color,
        width=border_width,
    )


def make_asset(src, caption, size, tablet=False, source_index=None):
    w, h = size
    # Remove Android status bar and gesture/navigation area.
    # Screenshot 4 includes the Android Gboard; exclude it for iOS-safe artwork.
    clean_bottom = 1006 if source_index == 4 else 1567
    clean = src.crop((0, 72, src.width, clean_bottom)).convert("RGB")

    bg_path = AI_BACKGROUNDS[(source_index - 1) % len(AI_BACKGROUNDS)]
    with Image.open(bg_path) as generated_bg:
        bg = cover(generated_bg.convert("RGB"), size).convert("RGBA")
    # Keep AI detail visible around the edges while maintaining legibility.
    overlay = Image.new("RGBA", size, (2, 7, 18, 82))
    canvas = Image.alpha_composite(bg, overlay)
    draw = ImageDraw.Draw(canvas)

    # Subtle cyan glow behind the headline and screenshot.
    glow = Image.new("RGBA", size, (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse((-w * .25, -h * .25, w * 1.25, h * .60), fill=(36, 190, 229, 36))
    glow = glow.filter(ImageFilter.GaussianBlur(w // 7))
    canvas = Image.alpha_composite(canvas, glow)
    draw = ImageDraw.Draw(canvas)

    margin = int(w * (0.095 if tablet else 0.075))
    top = int(h * (0.075 if tablet else 0.065))
    accent_w = int(w * .09)
    accent_h = max(7, int(h * .0035))
    draw.rounded_rectangle((margin, top, margin + accent_w, top + accent_h), radius=accent_h // 2, fill=(117, 218, 242, 255))

    font_size = int(w * (0.064 if tablet else 0.075))
    font = ImageFont.truetype(str(FONT_PATH), font_size)
    line_gap = int(font_size * .16)
    text_y = top + int(h * .021)
    draw.multiline_text((margin, text_y), caption, font=font, fill=(247, 250, 255, 255), spacing=line_gap)

    if tablet:
        screen_top = int(h * .31)
        max_box = (int(w * .60), int(h * .63))
    else:
        screen_top = int(h * .245)
        max_box = (int(w * .86), int(h * .715))
    screen = fit(clean, max_box)
    x = (w - screen.width) // 2
    y = screen_top + max(0, (max_box[1] - screen.height) // 2)
    radius = max(24, int(w * .026))
    border = max(2, int(w * .0025))
    rounded_paste(canvas, screen, (x, y), radius, border, (139, 211, 230, 130))

    # Small decorative orbital arc, kept away from text and UI.
    draw = ImageDraw.Draw(canvas)
    arc_box = (int(w * .70), int(h * .035), int(w * 1.10), int(h * .23))
    draw.arc(arc_box, 120, 255, fill=(117, 218, 242, 80), width=max(2, w // 500))
    draw.ellipse((int(w * .905), int(h * .091), int(w * .916), int(h * .096)), fill=(255, 216, 125, 220))
    return canvas.convert("RGB")


def make_feature_graphic():
    size = (1024, 500)
    with Image.open(ROOT / "generated-backgrounds/feature-panorama.png") as source:
        canvas = cover(source.convert("RGB"), size).convert("RGBA")

    # Left-to-right dark veil keeps the title readable at thumbnail size.
    veil = Image.new("RGBA", size, (0, 0, 0, 0))
    vd = ImageDraw.Draw(veil)
    for x in range(size[0]):
        t = x / size[0]
        alpha = round(175 * max(0, 1 - t / .72))
        vd.line((x, 0, x, size[1]), fill=(1, 6, 16, alpha))
    canvas = Image.alpha_composite(canvas, veil)
    draw = ImageDraw.Draw(canvas)

    title_font = ImageFont.truetype(str(FONT_PATH), 69)
    tagline_font = ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 30)
    x, y = 72, 154
    draw.rounded_rectangle((x, 112, x + 88, 119), radius=4, fill=(117, 218, 242, 255))
    draw.text((x, y), "OpenPlanetarium", font=title_font, fill=(249, 252, 255, 255))
    draw.text((x + 2, y + 92), "Explore the universe. Even offline.", font=tagline_font, fill=(193, 225, 237, 255))
    return canvas.convert("RGB")


def main():
    for rel, size in TARGETS.items():
        out_dir = ROOT / rel
        out_dir.mkdir(parents=True, exist_ok=True)
        tablet = rel.endswith("tablet")
        for index, caption in CAPTIONS.items():
            with Image.open(ROOT / f"{index}.png") as src:
                out = make_asset(src, caption, size, tablet=tablet, source_index=index)
                out.save(out_dir / f"{index:02d}.png", "PNG", optimize=True)
    feature_dir = ROOT / "android"
    feature_dir.mkdir(parents=True, exist_ok=True)
    make_feature_graphic().save(feature_dir / "feature-graphic.png", "PNG", optimize=True)


if __name__ == "__main__":
    main()

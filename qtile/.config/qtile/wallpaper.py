#!/usr/bin/env python3
"""Render the Observatory "aurora scrim" as a static wallpaper.

Layers follow the Observatory design tokens (SilverBullet: Projects/SilverBullet
Observatory Refresh -> "Scrim (the signature)"): warm-orange radial focal at
top-center, a faint violet blob bottom-right, a blue blob bottom-left, a faint
conic "spiral" ring, sparse particle dots, and a vignette, all over the
#07090d canvas.

Usage:  wallpaper.py [OUT_DIR] [WIDTHxHEIGHT ...]
Default: ~/Pictures/Wallpapers  1366x768 3840x2160
"""

import math
import random
import sys
from pathlib import Path
from typing import NamedTuple

import cairo

# --- Observatory tokens -----------------------------------------------------
CANVAS = "#07090d"
ORANGE = "#ffaa00"  # primary accent / focal glow
SORANGE = "#ff9e64"  # warm secondary
PURPLE = "#bb9af7"  # violet blob
BLUE = "#7aa2f7"  # blue blob
HAIR2 = "#3b4261"  # hairline (ring)
TXT = "#c0caf5"  # particle dots

RING_STEPS = 720
# The ring is visible only between these fractions of the sweep.
RING_VISIBLE = (0.22, 0.78)
REF_HEIGHT = 768  # the laptop panel; everything scales from it

RGB = tuple[float, float, float]


class Blob(NamedTuple):
    """A soft radial glow; ``sx``/``sy`` stretch it into an ellipse."""

    cx: float
    cy: float
    r: float
    color: str
    alpha: float
    sx: float = 1.0
    sy: float = 1.0


def rgb(hexstr: str) -> RGB:
    """Convert ``#rrggbb`` to a cairo-style 0..1 RGB tuple."""
    h = hexstr.lstrip("#")
    r, g, b = (int(h[i : i + 2], 16) / 255 for i in (0, 2, 4))
    return r, g, b


def draw_blob(ctx: cairo.Context, b: Blob) -> None:
    """Paint one soft radial blob."""
    ctx.save()
    ctx.translate(b.cx, b.cy)
    ctx.scale(b.sx, b.sy)
    g = cairo.RadialGradient(0, 0, 0, 0, 0, b.r)
    c = rgb(b.color)
    g.add_color_stop_rgba(0.0, *c, b.alpha)
    g.add_color_stop_rgba(0.45, *c, b.alpha * 0.45)
    g.add_color_stop_rgba(1.0, *c, 0.0)
    ctx.set_source(g)
    ctx.arc(0, 0, b.r, 0, 2 * math.pi)
    ctx.fill()
    ctx.restore()


def ring_opacity(t: float) -> float:
    """Masked sweep: transparent for ~45% of the circle, rising to a soft peak.

    That makes the ring read as a fading arc rather than a drawn circle.
    """
    lo, hi = RING_VISIBLE
    if not lo < t < hi:
        return 0.0
    return max(0.0, math.sin(math.pi * (t * 1.8 - 0.4))) ** 3


def spiral_ring(
    ctx: cairo.Context, cx: float, cy: float, r: float, width: float
) -> None:
    """Approximate the mockup's masked conic ring (cairo has no conic gradient)."""
    c = rgb(HAIR2)
    o = rgb(ORANGE)
    ctx.set_line_width(width)
    start = -math.pi * 0.95  # upper-left, so the bright part sweeps over top-right
    for i in range(RING_STEPS):
        a0 = 2 * math.pi * i / RING_STEPS
        a1 = 2 * math.pi * (i + 1.5) / RING_STEPS
        k = ring_opacity(i / RING_STEPS)
        mix = k * 0.45
        r_, g_, b_ = (c[j] * (1 - mix) + o[j] * mix for j in range(3))
        ctx.set_source_rgba(r_, g_, b_, 0.11 * k)
        ctx.arc(cx, cy, r, a0 + start, a1 + start)
        ctx.stroke()


def dots(ctx: cairo.Context, w: int, h: int, s: float, seed: int = 7) -> None:
    """Sparse, dim particle dots, density scaled to the screen area."""
    rnd = random.Random(seed)  # noqa: S311 - visual noise, not crypto
    c = rgb(TXT)
    count = int(70 * (w * h) / (1366 * 768) + 60)
    for _ in range(count):
        x, y = rnd.random() * w, rnd.random() * h
        r = (0.6 + rnd.random() * 0.9) * s
        ctx.set_source_rgba(*c, 0.03 + rnd.random() * 0.10)
        ctx.arc(x, y, r, 0, 2 * math.pi)
        ctx.fill()


def vignette(ctx: cairo.Context, w: int, h: int) -> None:
    """Darken toward the edges."""
    g = cairo.RadialGradient(
        w / 2,
        h * 0.42,
        min(w, h) * 0.25,
        w / 2,
        h * 0.42,
        math.hypot(w, h) * 0.62,
    )
    g.add_color_stop_rgba(0, 0, 0, 0, 0.0)
    g.add_color_stop_rgba(1, 0, 0, 0, 0.55)
    ctx.set_source(g)
    ctx.paint()


def dither(surface: cairo.ImageSurface, amount: int = 2, seed: int = 11) -> None:
    """Add +/- ``amount`` of noise per channel to break up gradient banding."""
    surface.flush()
    buf = surface.get_data()
    pixels = len(buf) // 4
    # One independent random byte per pixel (no repeating table -> no streaks).
    noise = random.Random(seed).randbytes(pixels)  # noqa: S311 - visual noise
    span = 2 * amount + 1
    lut = [
        [min(255, max(0, v + (r % span) - amount)) for v in range(256)]
        for r in range(span)
    ]
    for p in range(pixels):  # BGRA, leave alpha alone
        row = lut[noise[p] % span]
        i = p * 4
        buf[i] = row[buf[i]]
        buf[i + 1] = row[buf[i + 1]]
        buf[i + 2] = row[buf[i + 2]]
    surface.mark_dirty()


def render(w: int, h: int, path: Path) -> Path:
    """Render one wallpaper of ``w`` x ``h`` to ``path``."""
    s = min(w, h) / REF_HEIGHT
    surf = cairo.ImageSurface(cairo.FORMAT_RGB24, w, h)
    ctx = cairo.Context(surf)
    ctx.set_source_rgb(*rgb(CANVAS))
    ctx.paint()

    ctx.set_operator(cairo.OPERATOR_ADD)
    for b in (
        # warm focal at top-center (the signature), stretched wide; the softer
        # orange leads so the glow reads amber rather than olive
        Blob(w * 0.5, -h * 0.04, h * 0.66, SORANGE, 0.15, sx=1.55),
        Blob(w * 0.5, -h * 0.02, h * 0.42, ORANGE, 0.10, sx=1.4),
        # cool counterweights
        Blob(w * 0.86, h * 0.90, h * 0.62, PURPLE, 0.11, sx=1.25),
        Blob(w * 0.12, h * 0.94, h * 0.58, BLUE, 0.10, sx=1.3),
    ):
        draw_blob(ctx, b)
    ctx.set_operator(cairo.OPERATOR_OVER)

    spiral_ring(ctx, w * 0.5, h * 0.30, h * 0.36, max(1.0, 1.2 * s))
    dots(ctx, w, h, s)
    vignette(ctx, w, h)
    dither(surf)
    surf.write_to_png(str(path))
    return path


def main() -> None:
    """Render each requested size into the output directory."""
    out = Path(sys.argv[1] if len(sys.argv) > 1 else "~/Pictures/Wallpapers")
    out = out.expanduser()
    sizes = sys.argv[2:] or ["1366x768", "3840x2160"]
    out.mkdir(parents=True, exist_ok=True)
    for size in sizes:
        w, h = (int(v) for v in size.lower().split("x"))
        p = render(w, h, out / f"observatory-aurora-{w}x{h}.png")
        sys.stdout.write(f"{p}\n")


if __name__ == "__main__":
    main()

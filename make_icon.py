#!/usr/bin/env python3
"""Generate Sigil app icon as PNG at multiple sizes, then build .icns"""
from PIL import Image, ImageDraw
import struct, os, subprocess

def draw_icon(size):
    img = Image.new('RGBA', (size, size), (16, 16, 24, 255))
    draw = ImageDraw.Draw(img)

    s = size
    cx, cy = s // 2, s // 2

    cyan = (141, 216, 255, 255)
    pink = (255, 77, 138, 255)

    # Outer diamond
    margin = int(s * 0.14)
    diamond = [
        (cx, margin),
        (s - margin, cy),
        (cx, s - margin),
        (margin, cy)
    ]
    lw = max(2, int(s * 0.016))
    draw.polygon(diamond, outline=cyan, width=lw)

    # Eye shape (two arcs forming a vesica/almond)
    eye_w = int(s * 0.46)
    eye_h = int(s * 0.17)
    elw = max(2, int(s * 0.012))

    # Top arc
    bbox_top = (cx - eye_w, cy - eye_h * 3, cx + eye_w, cy + eye_h)
    draw.arc(bbox_top, start=30, end=150, fill=pink, width=elw)

    # Bottom arc
    bbox_bot = (cx - eye_w, cy - eye_h, cx + eye_w, cy + eye_h * 3)
    draw.arc(bbox_bot, start=210, end=330, fill=pink, width=elw)

    # Central vertical line with serifs
    bar_top = int(s * 0.29)
    bar_bot = int(s * 0.71)
    serif_half = int(s * 0.055)
    blw = max(2, int(s * 0.016))

    # Vertical bar
    draw.line([(cx, bar_top), (cx, bar_bot)], fill=cyan, width=blw)
    # Top serif
    draw.line([(cx - serif_half, bar_top), (cx + serif_half, bar_top)], fill=cyan, width=blw)
    # Bottom serif
    draw.line([(cx - serif_half, bar_bot), (cx + serif_half, bar_bot)], fill=cyan, width=blw)

    # Center dot
    dot_r = max(3, int(s * 0.032))
    draw.ellipse(
        (cx - dot_r, cy - dot_r, cx + dot_r, cy + dot_r),
        fill=pink
    )

    return img

def make_iconset():
    iconset_dir = 'Sigil.iconset'
    os.makedirs(iconset_dir, exist_ok=True)

    sizes = [16, 32, 64, 128, 256, 512]
    for sz in sizes:
        img = draw_icon(sz)
        img.save(f'{iconset_dir}/icon_{sz}x{sz}.png')
        # @2x versions
        if sz <= 256:
            img2x = draw_icon(sz * 2)
            img2x.save(f'{iconset_dir}/icon_{sz}x{sz}@2x.png')

    # Also save a standalone 512 for GitHub
    img = draw_icon(512)
    img.save('icon.png')

    # Convert iconset to icns
    subprocess.run(['iconutil', '-c', 'icns', iconset_dir], check=True)
    print(f'Created Sigil.icns and icon.png')

if __name__ == '__main__':
    make_iconset()

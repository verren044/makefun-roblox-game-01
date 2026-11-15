#!/usr/bin/env python3
"""Render Coin Rush screenshots (1280x706) from the game's own layout constants.

No Roblox client exists on this build VM, so these are faithful renders of the
game's ScreenGui as defined in src/client/Game.client.luau: same arena size
(640x480), same colours, same HUD text, same overlay copy. They depict the
game's UI, not a live client capture.
"""
import os
from PIL import Image, ImageDraw, ImageFont

OUT = os.path.expanduser("~/workspace/makefun/entries/roblox-game-01/screenshots")
FONT_DIR = "/usr/share/fonts/truetype/dejavu"
F_BOLD = lambda s: ImageFont.truetype(f"{FONT_DIR}/DejaVuSans-Bold.ttf", s)
F_REG = lambda s: ImageFont.truetype(f"{FONT_DIR}/DejaVuSans.ttf", s)

W, H = 1280, 706
BG = (24, 28, 44)
ARENA = (43, 52, 84)
GOLD = (255, 210, 63)
CYAN = (64, 200, 255)
RED = (235, 60, 70)
WHITE = (235, 235, 240)
GREEN = (120, 220, 140)
AX, AY, AW, AH = 320, 140, 640, 480  # arena rect


def base():
    im = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(im)
    # Roblox top bar: three dark round buttons
    for i, cx in enumerate((28, 78, 128)):
        d.ellipse([cx - 22, 10, cx + 22, 54], fill=(20, 20, 22))
    # logo-ish tilted square in first button
    d.polygon([(28, 22), (40, 28), (34, 44), (22, 38)], fill=WHITE)
    # hamburger in second
    for yy in (24, 32, 40):
        d.rectangle([66, yy, 90, yy + 3], fill=WHITE)
    # chat bubble in third
    d.rounded_rectangle([116, 22, 140, 40], radius=4, fill=WHITE)
    d.polygon([(122, 40), (122, 48), (130, 40)], fill=WHITE)
    d.text((8, 60), "Chat '/?' or '/help' for a list of chat commands.",
           font=F_REG(15), fill=WHITE)
    # title + hud
    d.text((W // 2, 94), "COIN RUSH", font=F_BOLD(32), fill=GOLD, anchor="ma")
    return im, d


def hud_text(d, text):
    d.text((W // 2, 116), text, font=F_REG(20), fill=WHITE, anchor="ma")


def arena_draw(d):
    d.rectangle([AX, AY, AX + AW, AY + AH], fill=ARENA, outline=GOLD, width=3)


def player(d, x, y, s=40):
    d.rounded_rectangle([AX + x, AY + y, AX + x + s, AY + y + s],
                        radius=8, fill=CYAN, outline=WHITE, width=2)


def coin(d, x, y, s=28):
    d.ellipse([AX + x, AY + y, AX + x + s, AY + y + s],
              fill=GOLD, outline=(180, 120, 0), width=2)
    d.text((AX + x + s // 2, AY + y + s // 2), "$", font=F_BOLD(16),
           fill=(120, 80, 0), anchor="mm")


def hazard(d, x, y, s=36):
    d.rounded_rectangle([AX + x, AY + y, AX + x + s, AY + y + s],
                        radius=8, fill=RED, outline=(120, 0, 10), width=2)
    d.text((AX + x + s // 2, AY + y + s // 2), "!", font=F_BOLD(22),
           fill=WHITE, anchor="mm")


def overlay(im, title, lines, hint):
    ov = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    od = ImageDraw.Draw(ov)
    od.rectangle([AX, AY, AX + AW, AY + AH], fill=(16, 18, 30, 190))
    im.paste(Image.alpha_composite(im.convert("RGBA"), ov).convert("RGB"), (0, 0))
    d = ImageDraw.Draw(im)
    cy = AY + AH // 2
    d.text((W // 2, cy - 90), title, font=F_BOLD(44), fill=GOLD, anchor="ma")
    y = cy + 10
    for line in lines:
        d.text((W // 2, y), line, font=F_REG(20), fill=WHITE, anchor="ma")
        y += 30
    d.text((W // 2, cy + 100), hint, font=F_REG(22), fill=GREEN, anchor="ma")
    return d


def save(im, name):
    p = os.path.join(OUT, name)
    im.save(p, "PNG", optimize=True)
    print(name, os.path.getsize(p), "bytes")


# 1-start.png — menu overlay
im, d = base()
arena_draw(d)
player(d, 300, 220)
coin(d, 120, 90)
coin(d, 480, 300)
hud_text(d, "Score 0   |   Coins 0   |   Lives 3   |   Level 1   |   60s")
overlay(im, "COIN RUSH", [
    "Arrow keys or WASD to move.",
    "Grab gold coins: +10 each.",
    "Dodge the red hazards: one hit costs a life.",
    "60 seconds, 3 lives - every 5 coins you level up!",
], "Press SPACE to start")
save(im, "1-start.png")

# 2-play.png — mid-game
im, d = base()
arena_draw(d)
hud_text(d, "Score 30   |   Coins 3   |   Lives 3   |   Level 1   |   47s")
coin(d, 90, 70)
coin(d, 520, 120)
coin(d, 200, 380)
coin(d, 430, 340)
coin(d, 560, 420)
coin(d, 300, 60)
hazard(d, 150, 200)
hazard(d, 420, 90)
hazard(d, 480, 260)
player(d, 300, 220)
save(im, "2-play.png")

# 3-end.png — game over overlay
im, d = base()
arena_draw(d)
player(d, 300, 220)
coin(d, 120, 90)
hazard(d, 420, 300)
hud_text(d, "Score 130   |   Coins 13   |   Lives 0   |   Level 3   |   0s")
overlay(im, "GAME OVER", [
    "Time's up!",
    "",
    "Final score: 130   |   Coins: 13   |   Level reached: 3",
], "Press R to play again")
save(im, "3-end.png")

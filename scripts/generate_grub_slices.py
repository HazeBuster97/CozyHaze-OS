import os
from PIL import Image, ImageDraw

theme_dir = r"C:\Users\kevin\.gemini\antigravity-ide\scratch\CozyHaze-OS\boot\grub\themes\cozyhaze"
os.makedirs(theme_dir, exist_ok=True)

# Erstelle 9-Slice Pixmaps für den Auswahleffekt (Anthrazit mit Neon-Cyan Rand)
# Rand: 4 Pixel, Glow: #00F2FE, Füllung: #1E293B (halbtransparent)
size = 16
bg_color = (30, 41, 59, 210)
border_color = (0, 242, 254, 255)

# Center
img_c = Image.new("RGBA", (size, size), bg_color)
img_c.save(os.path.join(theme_dir, "select_c.png"))

# West (Left)
img_w = Image.new("RGBA", (size, size), bg_color)
draw = ImageDraw.Draw(img_w)
draw.rectangle([0, 0, 3, size], fill=border_color)
img_w.save(os.path.join(theme_dir, "select_w.png"))

# East (Right)
img_e = Image.new("RGBA", (size, size), bg_color)
draw = ImageDraw.Draw(img_e)
draw.rectangle([size-4, 0, size, size], fill=border_color)
img_e.save(os.path.join(theme_dir, "select_e.png"))

# North (Top)
img_n = Image.new("RGBA", (size, size), bg_color)
draw = ImageDraw.Draw(img_n)
draw.rectangle([0, 0, size, 2], fill=border_color)
img_n.save(os.path.join(theme_dir, "select_n.png"))

# South (Bottom)
img_s = Image.new("RGBA", (size, size), bg_color)
draw = ImageDraw.Draw(img_s)
draw.rectangle([0, size-3, size, size], fill=border_color)
img_s.save(os.path.join(theme_dir, "select_s.png"))

# Ecken
img_nw = Image.new("RGBA", (size, size), bg_color)
draw = ImageDraw.Draw(img_nw)
draw.rectangle([0, 0, 3, size], fill=border_color)
draw.rectangle([0, 0, size, 2], fill=border_color)
img_nw.save(os.path.join(theme_dir, "select_nw.png"))

img_ne = Image.new("RGBA", (size, size), bg_color)
draw = ImageDraw.Draw(img_ne)
draw.rectangle([size-4, 0, size, size], fill=border_color)
draw.rectangle([0, 0, size, 2], fill=border_color)
img_ne.save(os.path.join(theme_dir, "select_ne.png"))

img_sw = Image.new("RGBA", (size, size), bg_color)
draw = ImageDraw.Draw(img_sw)
draw.rectangle([0, 0, 3, size], fill=border_color)
draw.rectangle([0, size-3, size, size], fill=border_color)
img_sw.save(os.path.join(theme_dir, "select_sw.png"))

img_se = Image.new("RGBA", (size, size), bg_color)
draw = ImageDraw.Draw(img_se)
draw.rectangle([size-4, 0, size, size], fill=border_color)
draw.rectangle([0, size-3, size, size], fill=border_color)
img_se.save(os.path.join(theme_dir, "select_se.png"))

print("GRUB selection pixmaps generated.")

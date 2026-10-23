import os
from PIL import Image

src_wall = r"C:\Users\kevin\.gemini\antigravity-ide\brain\60641ea9-5575-488c-8fcc-2fe0aae72521\cozyhaze_wallpaper_1792721861376.jpg"
src_logo = r"C:\Users\kevin\.gemini\antigravity-ide\brain\60641ea9-5575-488c-8fcc-2fe0aae72521\cozyhaze_logo_1792721873804.jpg"
base = r"C:\Users\kevin\.gemini\antigravity-ide\scratch\CozyHaze-OS"

dirs = [
    os.path.join(base, "themes", "wallpaper"),
    os.path.join(base, "themes", "icons"),
    os.path.join(base, "boot", "grub", "themes", "cozyhaze"),
    os.path.join(base, "boot", "plymouth", "themes", "cozyhaze-glow"),
    os.path.join(base, "installer", "branding", "cozyhaze")
]
for d in dirs:
    os.makedirs(d, exist_ok=True)

# 1. Wallpaper
img_w = Image.open(src_wall)
img_w.save(os.path.join(base, "themes", "wallpaper", "cozyhaze-wallpaper.jpg"), quality=95)
img_w.save(os.path.join(base, "themes", "wallpaper", "cozyhaze-wallpaper.png"))

# GRUB background (1440x900 native MBP 15")
grub_bg = img_w.resize((1440, 900), Image.Resampling.LANCZOS)
grub_bg.save(os.path.join(base, "boot", "grub", "themes", "cozyhaze", "background.png"))

# 2. Logo
img_l = Image.open(src_logo)
img_l.save(os.path.join(base, "themes", "icons", "cozyhaze-logo.png"))

# GRUB Logo (256x256)
grub_logo = img_l.resize((256, 256), Image.Resampling.LANCZOS)
grub_logo.save(os.path.join(base, "boot", "grub", "themes", "cozyhaze", "logo.png"))

# Plymouth Splash logo
plymouth_logo = img_l.resize((192, 192), Image.Resampling.LANCZOS)
plymouth_logo.save(os.path.join(base, "boot", "plymouth", "themes", "cozyhaze-glow", "logo.png"))

# Calamares Branding
cal_logo = img_l.resize((128, 128), Image.Resampling.LANCZOS)
cal_logo.save(os.path.join(base, "installer", "branding", "cozyhaze", "cozyhaze-logo.png"))

cal_welcome = img_w.resize((800, 500), Image.Resampling.LANCZOS)
cal_welcome.save(os.path.join(base, "installer", "branding", "cozyhaze", "welcome.png"))
cal_welcome.save(os.path.join(base, "installer", "branding", "cozyhaze", "slide1.png"))

print("All branding image assets created and processed successfully!")

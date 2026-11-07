from PIL import Image, ImageDraw
import sprite, random
ROOT = '/home/claude/NyanCat6767/android/app/src/main/res'
PAL = dict(k='#000000', c='#FFCC99', f='#FF99FF', s='#FF3399', z='#FF99FF', y='#FF99FF', g='#999999', p='#FF9999', e='#000000', w='#FFFFFF')
TRAIL = ['#FF0000','#FF9900','#FFFF00','#33FF00','#0099FF','#6633FF']
def cat_layer(size, content=0.62):
    """transparent layer with the cat + trail centred (adaptive icon foreground)"""
    rows = sprite.build_frame(0); tw = 12
    gw = sprite.W + tw; px = int(size * content / gw)
    im = Image.new('RGBA', (size, size), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    ox = (size - gw * px) // 2; oy = (size - 25 * px) // 2 - sprite.OY * px + px * 2
    for col in range(tw):
        off = 1 if (col // 4) % 2 else 0
        for i, c in enumerate(TRAIL):
            y0 = oy + (sprite.OY + 2 + i * 3 + off) * px
            d.rectangle([ox + col * px, y0, ox + (col + 1) * px - 1, y0 + 3 * px - 1], fill=c)
    for y, r in enumerate(rows):
        for x, ch in enumerate(r):
            if ch != '.':
                d.rectangle([ox + (x + tw) * px, oy + y * px, ox + (x + tw + 1) * px - 1, oy + (y + 1) * px - 1], fill=PAL[ch])
    return im
def background(size):
    im = Image.new('RGB', (size, size)); d = ImageDraw.Draw(im)
    for y in range(size):
        t = y / (size - 1)
        c = (int(18 + 120 * t), int(20 + 10 * t), int(90 + 20 * t))
        d.line([(0, y), (size, y)], fill=c)
    rnd = random.Random(5)
    for _ in range(40):
        x, y = rnd.randrange(size), rnd.randrange(size); s = max(1, size // 90)
        d.rectangle([x, y, x + s, y + s], fill=(255, 255, 255))
    return im
dens = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}
big_fg = cat_layer(1296, .60); big_bg = background(1296)
legacy_big = big_bg.convert('RGBA'); legacy_big.alpha_composite(cat_layer(1296, .80))
for name, m in dens.items():
    fg = big_fg.resize((int(108 * m), int(108 * m)), Image.LANCZOS); fg.save('%s/mipmap-%s/ic_launcher_foreground.png' % (ROOT, name))
    lg = legacy_big.resize((int(48 * m), int(48 * m)), Image.LANCZOS).convert('RGB'); lg.save('%s/mipmap-%s/ic_launcher.png' % (ROOT, name))
big_bg.resize((512, 512), Image.LANCZOS).save('/home/claude/work/icon_preview.png')
print('icons ok')

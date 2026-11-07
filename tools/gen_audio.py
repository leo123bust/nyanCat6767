import numpy as np, wave, math, subprocess, os
SR = 22050
OUT = '/home/claude/NyanCat6767/assets/audio'
def tone(freq, dur, kind='square', duty=.5, vol=1.0, a=.005, r=.05, slide=0.0):
    n = int(SR * dur); t = np.arange(n) / SR
    f = freq + slide * t
    ph = np.cumsum(f) / SR
    if kind == 'square': w = np.where((ph % 1.0) < duty, 1.0, -1.0)
    elif kind == 'tri': w = 2 * np.abs(2 * (ph % 1.0) - 1) - 1
    elif kind == 'sine': w = np.sin(2 * np.pi * ph)
    elif kind == 'saw': w = 2 * (ph % 1.0) - 1
    else: w = np.random.uniform(-1, 1, n)
    env = np.ones(n); na = max(1, int(a * SR)); nr = max(1, int(r * SR))
    env[:na] = np.linspace(0, 1, na); env[-nr:] = np.minimum(env[-nr:], np.linspace(1, 0, nr))
    return w * env * vol
def noise(dur, vol=1.0, decay=20.0):
    n = int(SR * dur); t = np.arange(n) / SR
    return np.random.uniform(-1, 1, n) * np.exp(-decay * t) * vol
def mix(parts, total):
    out = np.zeros(int(SR * total))
    for (t0, s) in parts:
        i = int(t0 * SR); j = min(len(out), i + len(s))
        if i < len(out): out[i:j] += s[:j - i]
    return out
def save(name, x, peak=.8):
    x = x / max(1e-6, np.max(np.abs(x))) * peak
    path = os.path.join(OUT, name)
    with wave.open(path, 'wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes((x * 32767).astype('<i2').tobytes())
    return path
def hz(n): return 440.0 * 2 ** ((n - 69) / 12)
np.random.seed(7)
# ---------------- SFX
save('coin.wav', mix([(0, tone(hz(88), .07, 'square', .25, .6)), (.07, tone(hz(95), .18, 'square', .25, .6, r=.12))], .28))
save('hit.wav', mix([(0, noise(.28, .9, 9) + tone(220, .28, 'saw', vol=.5, slide=-600, r=.2))], .3))
save('click.wav', mix([(0, tone(hz(84), .04, 'square', .5, .5, r=.03))], .06))
save('buy.wav', mix([(0, tone(hz(79), .07, 'square', .25, .5)), (.07, tone(hz(84), .07, 'square', .25, .5)), (.14, tone(hz(91), .07, 'square', .25, .5)), (.21, tone(hz(96), .3, 'square', .25, .5, r=.2))], .55))
save('win.wav', mix([(i * .11, tone(hz(n), .22, 'square', .25, .55, r=.12)) for i, n in enumerate([72, 76, 79, 84, 79, 84, 88])] + [(.77, tone(hz(91), .6, 'square', .25, .55, r=.4))], 1.45))
save('lose.wav', mix([(i * .18, tone(hz(n), .3, 'tri', vol=.8, r=.2)) for i, n in enumerate([67, 64, 60, 55])], 1.1))
save('heart.wav', mix([(0, tone(hz(76), .08, 'sine', vol=.8)), (.08, tone(hz(83), .08, 'sine', vol=.8)), (.16, tone(hz(88), .25, 'sine', vol=.8, r=.2))], .45))
save('error.wav', mix([(0, tone(150, .12, 'square', .5, .5)), (.13, tone(120, .2, 'square', .5, .5, r=.15))], .35))
# ---------------- music
def song(bpm, bars, lead_pat, bass_pat, chords, drums=True, lead_kind='square', lead_vol=.32, name='x.wav'):
    spb = 60.0 / bpm; total = bars * 4 * spb; parts = []
    for b in range(bars):
        root = chords[b % len(chords)]
        for i in range(8):
            t0 = (b * 8 + i) * spb / 2
            bn = bass_pat[i % len(bass_pat)]
            if bn is not None: parts.append((t0, tone(hz(root + bn - 24), spb / 2 * .9, 'tri', vol=.55, r=.04)))
            ln = lead_pat[(b % 2) * 8 + i]
            if ln is not None: parts.append((t0, tone(hz(root + ln + 12), spb / 2 * .85, lead_kind, .25, lead_vol, r=.05)))
            if drums:
                if i % 2 == 0: parts.append((t0, noise(.04, .18, 80)))
                if i in (0, 4): parts.append((t0, tone(110, .12, 'sine', vol=.6, slide=-300, r=.1)))
                if i in (2, 6): parts.append((t0, noise(.12, .3, 30)))
    return mix(parts, total)
chords = [0, -3, -7, -5, 0, -3, -7, -5]  # C Am F G
lead_game = [12, None, 7, 4, 7, None, 12, 16, 14, None, 9, 5, 9, 12, 9, 5,
             16, 12, 7, 12, 16, None, 19, 16, 14, 11, 7, 11, 14, None, 11, 7]
bass_game = [0, None, 0, 7, 0, None, 0, 7]
save('music_game.wav', song(140, 8, lead_game, bass_game, chords, True, 'square', .30), .85)
lead_menu = [7, None, None, 12, None, 7, None, 4, 5, None, None, 9, None, 5, None, 2,
             4, None, None, 7, None, 4, None, 0, 2, None, None, 5, None, 7, None, 11]
bass_menu = [0, None, None, None, 7, None, None, None]
save('music_menu.wav', song(96, 8, lead_menu, bass_menu, chords, False, 'tri', .55), .8)
for n in ('music_game', 'music_menu'):
    src = os.path.join(OUT, n + '.wav'); dst = os.path.join(OUT, n + '.ogg')
    subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-i', src, '-c:a', 'libvorbis', '-q:a', '3', dst], check=True)
    os.remove(src)
for f in sorted(os.listdir(OUT)): print(f, os.path.getsize(os.path.join(OUT, f)))

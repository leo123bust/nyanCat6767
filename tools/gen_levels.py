"""Level generator + feasibility verifier for NyanCat6767.
Every level is checked with a reachability DP (time x height) using the SAME collision
geometry as the Dart game, with a safety margin and a limited vertical agility."""
import json, math, random, sys, hashlib

N_LEVELS = 120
CATX = 110.0          # fixed cat screen x (virtual units)
HW, HH = 36.0, 20.0   # cat hitbox half size
YMIN, YMAX, CELL = 120.0, 860.0, 4.0
NC = int((YMAX - YMIN) / CELL) + 1
FULL = (1 << NC) - 1
START_Y = 490.0
FPS = 60.0

def r1(v): return round(v, 1)

def cell_range(lo, hi):
    """cells whose centre lies strictly inside (lo, hi)"""
    a = math.floor((lo - YMIN) / CELL) + 1
    b = math.ceil((hi - YMIN) / CELL) - 1
    a = max(a, 0); b = min(b, NC - 1)
    if b < a: return 0
    return ((1 << (b - a + 1)) - 1) << a

def dilate(r, k):
    out = r
    for i in range(1, k + 1):
        out |= (r << i) | (r >> i)
    return out & FULL

def frac(x): return x - math.floor(x)

def forb_mask(o, s, hw, hh):
    """forbidden cell mask for obstacle o when the scroll is s"""
    t = o[0]; cxw = s + CATX
    if t == 0:
        _, x, y, r, _v = o
        dxc = max(abs(x - cxw) - hw, 0.0)
        if dxc >= r: return 0
        d = hh + math.sqrt(r * r - dxc * dxc)
        return cell_range(y - d, y + d)
    if t == 1:
        _, x, y, r, amp, per, ph, _v = o
        dxc = max(abs(x - cxw) - hw, 0.0)
        if dxc >= r: return 0
        cy = y + amp * math.sin(2 * math.pi * s / per + ph)
        d = hh + math.sqrt(r * r - dxc * dxc)
        return cell_range(cy - d, cy + d)
    if t in (2, 3):
        if t == 2: _, x, gy, gh, w, _v = o; amp = 0; per = 1; ph = 0
        else: _, x, gy, gh, w, amp, per, ph, _v = o
        if not (cxw + hw > x and cxw - hw < x + w): return 0
        g = gy + amp * math.sin(2 * math.pi * s / per + ph)
        top = g - gh / 2; bot = g + gh / 2
        return cell_range(-1e9, top + hh) | cell_range(bot - hh, 1e9)
    if t == 4:
        _, x, y, ln, th, per, ph, duty = o
        if not (cxw + hw > x and cxw - hw < x + ln): return 0
        if frac(s / per + ph) >= duty: return 0
        return cell_range(y - th / 2 - hh, y + th / 2 + hh)
    if t == 5:
        _, x, y, L, br, per, ph = o
        ang = 2 * math.pi * s / per + ph
        ca, sa = math.cos(ang), math.sin(ang)
        n = int(math.ceil(L / 10.0)); m = 0
        for j in range(-n, n + 1):
            px = x + ca * L * j / n; py = y + sa * L * j / n
            rad = br if abs(j) == n else 7.0
            dxc = max(abs(px - cxw) - hw, 0.0)
            if dxc >= rad: continue
            d = hh + math.sqrt(rad * rad - dxc * dxc)
            m |= cell_range(py - d, py + d)
        return m
    return 0

def obstacle_extent(o):
    t = o[0]
    if t in (0, 1): return o[1] - o[3], o[1] + o[3]
    if t in (2, 3): return o[1], o[1] + o[4]
    if t == 4: return o[1], o[1] + o[3]
    if t == 5: return o[1] - o[3] - o[4], o[1] + o[3] + o[4]
    if t == 6: return o[1], o[2]
    return o[1], o[1]

def wind_at(winds, cxw):
    for w in winds:
        if w[1] <= cxw <= w[2]: return abs(w[3])
    return 0.0

def advance(reach, s0, s1, obs, winds, v, kcells, margin, rec=None):
    ds = v / FPS
    hw, hh = HW + margin, HH + margin
    s = s0
    ext = [obstacle_extent(o) for o in obs]
    while s < s1:
        s += ds
        cxw = s + CATX
        k = kcells
        w = wind_at(winds, cxw)
        if w: k = max(0, int((kcells * 240.0 - w) // 240))
        reach = dilate(reach, k)
        fm = 0
        for o, (a, b) in zip(obs, ext):
            if cxw + hw + 2 < a or cxw - hw - 2 > b: continue
            fm |= forb_mask(o, s, hw, hh)
        reach &= ~fm & FULL
        if rec is not None: rec.append((reach, k))
        if reach == 0: return 0, s
    return reach, s

# ---------------------------------------------------------------- patterns
def P_rocks(rng, x0, d, sp, vr):
    n = rng.randint(3, 3 + int(4 * d))
    obs = []
    for i in range(n):
        r = rng.uniform(20, 22 + 24 * d)
        obs.append([0, r1(x0 + i * sp * rng.uniform(.8, 1.15)), r1(rng.uniform(190, 800)), r1(r), vr()])
    return obs, n * sp + 140

def P_gates(rng, x0, d, sp, vr):
    n = rng.randint(2, 3 + int(2 * d)); obs = []; g = rng.uniform(300, 680)
    gap = 330 - 185 * d
    for i in range(n):
        g = min(740, max(240, g + rng.uniform(-1, 1) * (110 + 150 * d)))
        obs.append([2, r1(x0 + i * (sp + 110)), r1(g), r1(gap * rng.uniform(.95, 1.15)), r1(rng.uniform(52, 66)), vr()])
    return obs, n * (sp + 110) + 140

def P_slalom(rng, x0, d, sp, vr):
    n = rng.randint(4, 4 + int(2 * d)); amp = 150 + 100 * d; obs = []
    c = rng.uniform(380, 600); up = rng.random() < .5
    for i in range(n):
        y = c + (-amp if up else amp) * rng.uniform(.8, 1.1)
        obs.append([0, r1(x0 + i * sp * .85), r1(min(820, max(200, y))), r1(rng.uniform(34, 40 + 12 * d)), vr()])
        up = not up
    return obs, n * sp * .85 + 160

def P_floaters(rng, x0, d, sp, vr):
    k = rng.randint(2, 3 + int(2 * d)); obs = []
    per = rng.uniform(520, 900)
    for i in range(k):
        obs.append([1, r1(x0 + i * rng.uniform(70, 130)), r1(rng.uniform(300, 680)), r1(rng.uniform(22, 30 + 12 * d)),
                    r1(rng.uniform(70, 150 + 90 * d)), r1(per * rng.uniform(.8, 1.25)), r1(rng.uniform(0, 6.28)), vr()])
    return obs, k * 130 + 220

def P_swing(rng, x0, d, sp, vr):
    n = rng.randint(1, 2 + int(d * 2)); obs = []
    for i in range(n):
        obs.append([3, r1(x0 + i * (sp + 120)), r1(rng.uniform(380, 600)), r1(300 - 150 * d), r1(rng.uniform(52, 64)),
                    r1(rng.uniform(70, 120 + 60 * d)), r1(rng.uniform(700, 1100)), r1(rng.uniform(0, 6.28)), vr()])
    return obs, n * (sp + 120) + 160

def P_lasers(rng, x0, d, sp, vr):
    n = rng.randint(1, 2 + int(d * 2)); obs = []
    for i in range(n):
        obs.append([4, r1(x0 + i * 140), r1(rng.uniform(220, 780)), r1(rng.uniform(300, 420)), 14.0,
                    r1(rng.uniform(520, 800)), r1(rng.random()), r1(rng.uniform(.35, .5))])
    return obs, n * 140 + 520

def P_spinners(rng, x0, d, sp, vr):
    n = rng.randint(1, 1 + int(d * 2)); obs = []
    for i in range(n):
        obs.append([5, r1(x0 + i * (sp + 80)), r1(rng.uniform(330, 650)), r1(rng.uniform(60, 90 + 20 * d)), r1(rng.uniform(14, 18)),
                    r1(rng.uniform(520, 800) * rng.choice([1, -1])), r1(rng.uniform(0, 6.28))])
    return obs, n * (sp + 80) + 260

def P_wind(rng, x0, d, sp, vr):
    L = rng.uniform(520, 800); vy = rng.choice([-1, 1]) * rng.uniform(90, 140 + 50 * d)
    obs = [[6, r1(x0), r1(x0 + L), r1(vy)]]
    for i in range(rng.randint(1, 2 + int(d * 2))):
        obs.append([0, r1(x0 + 140 + i * 230), r1(rng.uniform(220, 780)), r1(rng.uniform(22, 30 + 14 * d)), vr()])
    return obs, L + 160

def P_vee(rng, x0, d, sp, vr):
    c = rng.uniform(360, 620); op = 190 - 40 * d; obs = []; flip = rng.random() < .5
    for i in range(5):
        off = op / 2 + i * 55
        obs.append([0, r1(x0 + i * 62), r1(c - off), r1(rng.uniform(28, 34)), vr()])
        obs.append([0, r1(x0 + i * 62), r1(c + off), r1(rng.uniform(28, 34)), vr()])
    if flip:
        for o in obs: o[1] = r1(x0 + 4 * 62 - (o[1] - x0))
    return obs, 5 * 62 + 170

def P_rest(rng, x0, d, sp, vr): return [], rng.uniform(260, 420)

PAT = {'rocks': (P_rocks, 0), 'gates': (P_gates, 0), 'slalom': (P_slalom, 0), 'vee': (P_vee, 0), 'rest': (P_rest, 0),
       'floaters': (P_floaters, 1), 'wind': (P_wind, 1), 'lasers': (P_lasers, 2), 'swing': (P_swing, 2), 'spinners': (P_spinners, 2)}

WORLD_W = [
    dict(rocks=.45, gates=.2, slalom=.15, rest=.2),
    dict(rocks=.2, gates=.3, slalom=.15, floaters=.2, wind=.05, rest=.1),
    dict(vee=.3, floaters=.3, rocks=.15, gates=.1, rest=.15),
    dict(lasers=.4, gates=.2, rocks=.15, slalom=.1, rest=.15),
    dict(rocks=.2, spinners=.3, gates=.2, slalom=.15, rest=.15),
    dict(floaters=.3, rocks=.2, wind=.15, gates=.15, slalom=.1, rest=.1),
    dict(gates=.25, spinners=.3, swing=.25, rocks=.1, rest=.1),
    dict(lasers=.3, swing=.25, gates=.2, spinners=.15, rest=.1),
    dict(floaters=.25, wind=.2, rocks=.15, slalom=.15, gates=.15, vee=.1),
    dict(floaters=.3, swing=.25, wind=.2, rocks=.15, rest=.1),
    dict(spinners=.3, wind=.2, floaters=.2, lasers=.2, swing=.1),
    dict(rocks=.1, gates=.1, slalom=.1, floaters=.15, wind=.1, lasers=.15, swing=.15, spinners=.15),
]

def pick(rng, weights, tier_max):
    items = [(k, w) for k, w in weights.items() if PAT[k][1] <= tier_max]
    tot = sum(w for _, w in items); r = rng.random() * tot
    for k, w in items:
        r -= w
        if r <= 0: return k
    return items[-1][0]

def gen_level(lvl):
    rng = random.Random(lvl * 7919 + 31)
    d = (lvl - 1) / (N_LEVELS - 1)
    world = (lvl - 1) // 10; inw = (lvl - 1) % 10
    v = 175 + 150 * d ** 0.85 + 4 * inw
    dur = 26 + 32 * d + (8 if inw == 9 else 0)
    length = round(v * dur, 0)
    tier = 0 if d < .09 else (1 if d < .2 else 2)
    kcells = 1 if d < .12 else (2 if d < .6 else 3)
    margin = 12 if d < .35 else (9 if d < .7 else 6)
    sp = 560 - 260 * d + rng.uniform(-30, 30)
    vr = lambda: rng.randint(0, 3)
    obs_all, winds = [], []
    rec = []
    reach = 1 << int(round((START_Y - YMIN) / CELL)); s = 0.0
    x = 560.0; end = length - 480
    # advance through empty start zone
    reach, s = advance(reach, s, x - CATX - HW - 20, [], [], v, kcells, margin, rec)
    seg_s = s
    guard = 0
    while x < end and guard < 400:
        guard += 1
        name = pick(rng, WORLD_W[world], tier)
        # first level of each world gets an easier first obstacle set (introduction)
        ok = False
        for attempt in range(14):
            dd = d * (0.7 if attempt > 6 else 1.0)
            obs, width = PAT[name][0](rng, x, dd, sp, vr)
            ob = [o for o in obs if o[0] != 6]; wd = [o for o in obs if o[0] == 6]
            test_rec = []
            r2, s2 = advance(reach, seg_s, x + width - CATX + HW + 10, ob, wd, v, kcells, margin, test_rec)
            if r2:
                rec.extend(test_rec); reach, seg_s = r2, s2; obs_all += ob; winds += wd; x += width + rng.uniform(.9, 1.2) * sp * .6
                ok = True; break
        if not ok:
            width = 300
            r2, s2 = advance(reach, seg_s, x + width - CATX, [], [], v, kcells, margin, rec)
            reach, seg_s = r2, s2; x += width
            if not reach: raise RuntimeError('dead level %d' % lvl)
    reach, seg_s = advance(reach, seg_s, length - CATX, [], [], v, kcells, margin, rec)
    assert reach, 'level %d infeasible' % lvl
    # backtrack a feasible path for coin placement
    n = len(rec); cell = None
    centre = (START_Y - YMIN) / CELL
    best = min((c for c in range(NC) if (reach >> c) & 1), key=lambda c: abs(c - centre)); path = [0] * n; cell = best
    for t in range(n - 1, -1, -1):
        path[t] = cell
        prev = rec[t - 1][0] if t > 0 else (1 << int(round((START_Y - YMIN) / CELL)))
        k = rec[t][1]
        cands = [c for c in range(max(0, cell - k), min(NC - 1, cell + k) + 1) if (prev >> c) & 1]
        cell = cell if (cell in cands) else min(cands, key=lambda c: abs(c - cell))
    ds = v / FPS
    ys = [YMIN + c * CELL for c in path]
    # smooth
    sm = []
    for i in range(n):
        a = max(0, i - 12); b = min(n, i + 13); sm.append(sum(ys[a:b]) / (b - a))
    coins, hearts = [], []
    step = max(1, int(round(34 / ds)))
    t = int((560 - CATX) / ds); gi = 0
    while t < n - int(500 / ds):
        cnt = rng.randint(5, 8)
        for j in range(cnt):
            tj = t + j * step
            if tj >= n: break
            yy = sm[tj] if abs(sm[tj] - ys[tj]) < 30 else ys[tj]
            coins.append([r1((tj + 1) * ds + CATX), r1(yy)])
        t += int(rng.uniform(380, 640) / ds) + cnt * step; gi += 1
    if lvl >= 4:
        th = int(n * rng.uniform(.5, .65)); hearts.append([r1((th + 1) * ds + CATX), r1(ys[th])])
    # required agility metric: min cells/step for the whole level
    need = None
    for kk in range(1, 6):
        rr = 1 << int(round((START_Y - YMIN) / CELL)); ss = 0.0
        rr, ss = advance(rr, ss, length - CATX, obs_all, winds, v, kk, margin)
        if rr: need = kk; break
    assert need is not None and need <= kcells, ('level %d need %s cap %d' % (lvl, need, kcells))
    slack = 0
    for mm in (0, 12, 20, 28, 36, 44):
        rr = 1 << int(round((START_Y - YMIN) / CELL))
        rr, _ = advance(rr, 0.0, length - CATX, obs_all, winds, v, kcells, mm)
        if rr: slack = mm
    obs_out = sorted(obs_all + winds, key=lambda o: obstacle_extent(o)[0])
    return dict(id=lvl, world=world, speed=r1(v), length=length, need=need, margin=margin, slack=slack,
                bg=lvl * 101 % 997, obs=obs_out, coins=coins, hearts=hearts)

if __name__ == '__main__':
    levels = []
    for l in range(1, N_LEVELS + 1):
        lv = gen_level(l); levels.append(lv)
        kinds = {}
        for o in lv['obs']: kinds[o[0]] = kinds.get(o[0], 0) + 1
        print('L%3d w%2d v=%5.1f len=%6.0f obs=%3d coins=%3d need=%s slack=%2d margin=%2d' % (l, lv['world'], lv['speed'], lv['length'], len(lv['obs']), len(lv['coins']), lv['need'], lv['slack'], lv['margin']))
        sys.stdout.flush()
    with open('levels.json', 'w') as f:
        json.dump({'version': 1, 'catX': CATX, 'levels': levels}, f, separators=(',', ':'))
    hs = set(hashlib.md5(json.dumps(l['obs']).encode()).hexdigest() for l in levels)
    print('levels', len(levels), 'unique layouts', len(hs))

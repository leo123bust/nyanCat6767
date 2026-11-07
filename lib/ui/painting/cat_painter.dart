import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/clock.dart';
import '../../core/theme.dart';
import '../../data/skins.dart';
import '../../data/sprite_data.dart';

/// Resolved colours of a skin at a given moment (hue-cycling skins change over time).
class CatStyle {
  const CatStyle({
    required this.outline,
    required this.crust,
    required this.frost,
    required this.sprinkle,
    required this.accZ,
    required this.accY,
    required this.fur,
    required this.cheek,
    required this.eye,
    required this.eyeHi,
    required this.accA,
    required this.accB,
    required this.accC,
    required this.aura,
    required this.trail,
    required this.fx,
  });

  final Color outline;
  final Color crust;
  final Color frost;
  final Color sprinkle;
  final Color accZ;
  final Color accY;
  final Color fur;
  final Color cheek;
  final Color eye;
  final Color eyeHi;
  final Color accA;
  final Color accB;
  final Color accC;
  final Color aura;
  final List<Color> trail;
  final List<Color> fx;
}

final Map<String, CatStyle> _styleCache = <String, CatStyle>{};

Color _shift(int argb, double deg) {
  final HSVColor h = HSVColor.fromColor(Color(argb));
  return h.withHue((h.hue + deg) % 360.0).toColor();
}

CatStyle _makeStyle(SkinDef s, double deg, bool shift) {
  Color sh(int v) => shift ? _shift(v, deg) : Color(v);
  return CatStyle(
    outline: Color(s.outline),
    crust: sh(s.crust),
    frost: sh(s.frost),
    sprinkle: sh(s.sprinkle),
    accZ: sh(s.accentZ),
    accY: sh(s.accentY),
    fur: Color(s.fur),
    cheek: Color(s.cheek),
    eye: Color(s.eye),
    eyeHi: Color(s.eyeHi),
    accA: sh(s.accA),
    accB: sh(s.accB),
    accC: sh(s.accC),
    aura: sh(s.aura),
    trail: <Color>[for (final int c in s.trail) sh(c)],
    fx: <Color>[for (final int c in s.fxColors) sh(c)],
  );
}

CatStyle styleFor(SkinDef s, double t) {
  if (!s.hue) {
    return _styleCache.putIfAbsent(s.id, () => _makeStyle(s, 0, false));
  }
  return _makeStyle(s, (t * s.hueSpeed) % 360.0, true);
}

class _Run {
  const _Run(this.x, this.y, this.len, this.ch);

  final int x;
  final int y;
  final int len;
  final String ch;
}

List<_Run> _buildRuns(List<String> rows) {
  final List<_Run> out = <_Run>[];
  for (int y = 0; y < rows.length; y++) {
    final String r = rows[y];
    int x = 0;
    while (x < r.length) {
      final String ch = r[x];
      if (ch == '.') {
        x++;
        continue;
      }
      int e = x + 1;
      while (e < r.length && r[e] == ch) {
        e++;
      }
      out.add(_Run(x, y, e - x, ch));
      x = e;
    }
  }
  return out;
}

final List<_Run> _runsA = _buildRuns(kFrameA);
final List<_Run> _runsB = _buildRuns(kFrameB);

Color _roleColor(String ch, CatStyle s) {
  switch (ch) {
    case 'k':
      return s.outline;
    case 'c':
      return s.crust;
    case 'f':
      return s.frost;
    case 's':
      return s.sprinkle;
    case 'z':
      return s.accZ;
    case 'y':
      return s.accY;
    case 'g':
      return s.fur;
    case 'p':
      return s.cheek;
    case 'e':
      return s.eye;
    case 'w':
      return s.eyeHi;
    default:
      return s.frost;
  }
}

/// Grid cell (col,row) that is the visual centre of the cat's body + head.
const double kCatCenterCol = 23.5;
const double kCatCenterRow = 15.0;

/// Number of 4px trail columns used by previews.
const int kPreviewTrailCols = 6;

/// Draws the pixel cat. [origin] is the top-left of the sprite grid, [ps] the size of one pixel.
void drawCat(Canvas canvas, Offset origin, double ps, SkinDef skin, CatStyle st, double t) {
  final int frame = (t * 8).floor() % 2;
  final double bob = frame == 1 ? -ps * 0.7 : 0.0;
  final List<_Run> runs = frame == 0 ? _runsA : _runsB;
  final Paint p = Paint()..isAntiAlias = false;
  for (final _Run r in runs) {
    p.color = _roleColor(r.ch, st);
    canvas.drawRect(Rect.fromLTWH(origin.dx + r.x * ps, origin.dy + r.y * ps + bob, r.len * ps, ps), p);
  }
  if (skin.acc != Accessory.none) {
    final List<int>? px = kAccessoryPixels[skin.acc.name];
    if (px != null) {
      final double dy = (skin.acc == Accessory.flame && frame == 1) ? -ps : 0.0;
      for (int i = 0; i + 2 < px.length; i += 3) {
        switch (px[i + 2]) {
          case 0:
            p.color = st.accA;
            break;
          case 1:
            p.color = st.accB;
            break;
          case 2:
            p.color = st.accC;
            break;
          default:
            p.color = st.outline;
            break;
        }
        canvas.drawRect(Rect.fromLTWH(origin.dx + px[i] * ps, origin.dy + px[i + 1] * ps + bob + dy, ps, ps), p);
      }
    }
  }
}

/// Static (non-scrolling) rainbow trail used by menus and previews.
void drawTrailStatic(Canvas canvas, Offset origin, double ps, CatStyle st, double t, int cols) {
  final double right = origin.dx + (kSpriteOx + 9) * ps;
  final double top = origin.dy + (kSpriteOy + 2) * ps;
  final double colW = 4 * ps;
  final int tick = (t * 8).floor();
  final Paint p = Paint()..isAntiAlias = false;
  for (int c = 0; c < cols; c++) {
    final double x = right - (c + 1) * colW;
    final double off = ((c + tick) % 2 == 0) ? 0.0 : ps;
    for (int i = 0; i < 6; i++) {
      p.color = st.trail[i];
      canvas.drawRect(Rect.fromLTWH(x, top + i * 3 * ps + off, colW, 3 * ps), p);
    }
  }
}

void drawAura(Canvas canvas, Offset center, double radius, Color color, double strength) {
  final int a = clampInt((150 * strength).round(), 0, 255);
  final Paint p = Paint()
    ..shader = ui.Gradient.radial(center, radius, <Color>[color.withAlpha(a), color.withAlpha(0)], <double>[0.0, 1.0]);
  canvas.drawCircle(center, radius, p);
}

/// Total width of the preview in grid cells.
double previewCells(bool trail) => trail ? (kPreviewTrailCols * 4 - 11 + kSpriteW).toDouble() : kSpriteW.toDouble();

void paintCatPreview(Canvas canvas, Size size, SkinDef skin, double t, {required bool trail, required bool glow, required bool dim}) {
  final double ps = size.width / previewCells(trail);
  final double ox = trail ? (kPreviewTrailCols * 4 - 11) * ps : 0.0;
  final Offset origin = Offset(ox, 0);
  final CatStyle st = styleFor(skin, t);
  final Rect layer = Rect.fromLTWH(-2, -2, size.width + 4, size.height + 4);
  if (dim) {
    canvas.saveLayer(layer, Paint()..colorFilter = const ColorFilter.mode(Color(0xD0101030), BlendMode.srcATop));
  }
  if (glow && skin.rarity != Rarity.common) {
    drawAura(canvas, origin + Offset(kCatCenterCol * ps, kCatCenterRow * ps), ps * 24, st.aura, 0.35 + skin.rarity.glow * 0.5);
  }
  if (skin.ghost) {
    canvas.saveLayer(layer, Paint()..color = const Color(0xB8FFFFFF));
  }
  if (trail) drawTrailStatic(canvas, origin, ps, st, t, kPreviewTrailCols);
  drawCat(canvas, origin, ps, skin, st, t);
  if (skin.ghost) canvas.restore();
  if (dim) canvas.restore();
}

class _CatPainter extends CustomPainter {
  _CatPainter(this.skin, this.trail, this.animated, this.glow, this.dim) : super(repaint: animated ? AppClock.t : null);

  final SkinDef skin;
  final bool trail;
  final bool animated;
  final bool glow;
  final bool dim;

  @override
  void paint(Canvas canvas, Size size) {
    paintCatPreview(canvas, size, skin, animated ? AppClock.t.value : 0.3, trail: trail, glow: glow, dim: dim);
  }

  @override
  bool shouldRepaint(_CatPainter old) =>
      old.skin != skin || old.trail != trail || old.animated != animated || old.glow != glow || old.dim != dim;
}

/// Animated preview of a skin (menus, shop, collection).
class CatSprite extends StatelessWidget {
  const CatSprite({
    super.key,
    required this.skin,
    this.width = 140,
    this.trail = true,
    this.animated = true,
    this.glow = true,
    this.dim = false,
  });

  final SkinDef skin;
  final double width;
  final bool trail;
  final bool animated;
  final bool glow;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final double ps = width / previewCells(trail);
    return SizedBox(
      width: width,
      height: ps * kSpriteH,
      child: CustomPaint(painter: _CatPainter(skin, trail, animated, glow, dim)),
    );
  }
}

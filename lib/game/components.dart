import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/levels.dart';
import '../data/skins.dart';
import '../data/sprite_data.dart';
import '../data/worlds.dart';
import '../ui/painting/cat_painter.dart';
import 'nyan_game.dart';
import 'obstacle_art.dart';

double _frac(double x) => x - x.floorToDouble();

/// Root component: scales the 900-unit-high world to the screen.
class WorldLayer extends PositionComponent {
  WorldLayer() : super(position: Vector2.zero(), size: Vector2.zero());
}

// ------------------------------------------------------------------ background

class _BStar {
  const _BStar(this.x, this.y, this.size, this.phase, this.layer);

  final double x;
  final double y;
  final double size;
  final double phase;
  final int layer;
}

class SpaceBackdrop extends Component {
  SpaceBackdrop(this.game) : super(priority: -100) {
    final math.Random r = math.Random(game.level.seed + 5);
    for (int i = 0; i < 54; i++) {
      _stars.add(_BStar(r.nextDouble(), r.nextDouble(), 1.4 + r.nextDouble() * 1.8, r.nextDouble() * 6.28, i % 3));
    }
    final Color base = Color(game.worldDef.bottom);
    _planetColors = <Color>[
      Color.lerp(base, Color(game.worldDef.accent), 0.35) ?? base,
      Color.lerp(base, Color(game.worldDef.neb1), 0.5) ?? base,
    ];
    _planetY = <double>[180 + (game.level.seed % 7) * 70.0, 560 + (game.level.seed % 5) * 55.0];
  }

  final NyanGame game;
  final List<_BStar> _stars = <_BStar>[];
  late final List<Color> _planetColors;
  late final List<double> _planetY;
  Paint? _bg;
  double _bgW = -1;
  Paint? _neb1;
  Paint? _neb2;

  @override
  void render(Canvas canvas) {
    final double w = game.viewW;
    const double h = NyanGame.worldH;
    final WorldDef wd = game.world;
    if (_bg == null || _bgW != w) {
      _bgW = w;
      final Color top = Color.lerp(Color(wd.top), Color(wd.accent), (game.level.seed % 5) * 0.035) ?? Color(wd.top);
      _bg = Paint()..shader = ui.Gradient.linear(const Offset(0, -40), const Offset(0, h + 40), <Color>[top, Color(wd.bottom)]);
      _neb1 = Paint()..shader = ui.Gradient.radial(Offset.zero, 380, <Color>[Color(wd.neb1).withAlpha(95), Color(wd.neb1).withAlpha(0)]);
      _neb2 = Paint()..shader = ui.Gradient.radial(Offset.zero, 420, <Color>[Color(wd.neb2).withAlpha(85), Color(wd.neb2).withAlpha(0)]);
    }
    canvas.drawRect(Rect.fromLTWH(-60, -60, w + 120, h + 120), _bg!);
    final double t = game.gameTime;
    final double s = game.scroll;
    canvas.save();
    canvas.translate(w * (0.3 + 0.1 * math.sin(t * 0.07)) - (s * 0.02) % 60, h * 0.3);
    canvas.drawCircle(Offset.zero, 380, _neb1!);
    canvas.restore();
    canvas.save();
    canvas.translate(w * (0.85 + 0.08 * math.cos(t * 0.06)), h * 0.78);
    canvas.drawCircle(Offset.zero, 420, _neb2!);
    canvas.restore();
    // far planets (slow parallax)
    for (int i = 0; i < 2; i++) {
      final double r = i == 0 ? 130 : 80;
      final double par = i == 0 ? 0.06 : 0.11;
      final double span = w + r * 4;
      final double x = ((w * (i == 0 ? 0.75 : 0.25) - s * par) % span) - r * 2;
      final Offset c = Offset(x, _planetY[i]);
      canvas.drawCircle(c, r, Paint()..color = _planetColors[i].withAlpha(150));
      canvas.drawCircle(c.translate(-r * 0.25, -r * 0.25), r * 0.7, Paint()..color = const Color(0x18FFFFFF));
      if (i == 0) {
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(-0.35);
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 2.9, height: r * 0.55), Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0x33FFFFFF));
        canvas.restore();
      }
    }
    final Paint sp = Paint()..isAntiAlias = false;
    for (final _BStar st in _stars) {
      final double par = 0.05 + st.layer * 0.12;
      final double x = (st.x * w - s * par) % w;
      final double a = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(t * 2.0 + st.phase));
      sp.color = Color.fromARGB((a * 255).round(), 255, 255, 255);
      canvas.drawRect(Rect.fromLTWH(x, st.y * h, st.size, st.size), sp);
    }
  }
}

class FinishComp extends Component {
  FinishComp(this.game) : super(priority: 2);

  final NyanGame game;

  @override
  void render(Canvas canvas) {
    final double x = game.level.length - game.scroll;
    if (x < -120 || x > game.viewW + 120) return;
    final Color a = Color(game.worldDef.accent);
    canvas.drawRect(
      Rect.fromLTWH(x - 70, 0, 140, NyanGame.worldH),
      Paint()..shader = ui.Gradient.linear(Offset(x - 70, 0), Offset(x + 70, 0), <Color>[a.withAlpha(0), a.withAlpha(90), a.withAlpha(0)], <double>[0.0, 0.5, 1.0]),
    );
    final Paint white = Paint()..color = const Color(0xFFFFFFFF);
    final Paint black = Paint()..color = const Color(0xFF14102E);
    for (int i = 0; i < 45; i++) {
      for (int j = 0; j < 2; j++) {
        canvas.drawRect(Rect.fromLTWH(x - 20 + j * 20, i * 20.0, 20, 20), (i + j) % 2 == 0 ? white : black);
      }
    }
  }
}

// ------------------------------------------------------------------ obstacles

abstract class ObstacleComp extends Component {
  ObstacleComp(this.game, this.spec) : super(priority: 0);

  final NyanGame game;
  final ObSpec spec;

  double get worldX => spec.p[0];

  /// World x of the right-most point (used to despawn).
  double get rightEdge;

  bool hits(double catWorldX, double catY) => false;

  static ObstacleComp create(NyanGame g, ObSpec s) {
    switch (s.type) {
      case 0:
      case 1:
        return RockComp(g, s);
      case 2:
      case 3:
        return GateComp(g, s);
      case 4:
        return LaserComp(g, s);
      case 5:
        return SpinnerComp(g, s);
      default:
        return WindComp(g, s);
    }
  }
}

class RockComp extends ObstacleComp {
  RockComp(super.game, super.spec);

  double get r => spec.p[2];
  bool get moving => spec.type == 1;
  int get variant => spec.p[moving ? 6 : 3].toInt();

  double centreY() {
    if (!moving) return spec.p[1];
    return spec.p[1] + spec.p[3] * math.sin(2 * math.pi * game.scroll / spec.p[4] + spec.p[5]);
  }

  @override
  double get rightEdge => spec.p[0] + r;

  @override
  bool hits(double catWorldX, double catY) => catHitsCircle(spec.p[0], centreY(), r, catWorldX, catY);

  @override
  void render(Canvas canvas) {
    final double x = spec.p[0] - game.scroll;
    if (x < -r - 40 || x > game.viewW + r + 40) return;
    final int theme = game.worldDef.index;
    canvas.save();
    canvas.translate(x, centreY());
    if (theme == 0 || theme == 1 || theme == 2 || theme == 4 || theme == 6 || theme == 8) {
      canvas.rotate(game.gameTime * 0.5 * (variant.isEven ? 1 : -1) + spec.p[0]);
    }
    paintRock(canvas, theme, r, variant, game.gameTime);
    canvas.restore();
  }
}

class GateComp extends ObstacleComp {
  GateComp(super.game, super.spec);

  bool get swing => spec.type == 3;
  double get gapH => spec.p[2];
  double get w => spec.p[3];

  double gapY() {
    if (!swing) return spec.p[1];
    return spec.p[1] + spec.p[4] * math.sin(2 * math.pi * game.scroll / spec.p[5] + spec.p[6]);
  }

  @override
  double get rightEdge => spec.p[0] + w;

  @override
  bool hits(double catWorldX, double catY) {
    final double x = spec.p[0];
    if (!(catWorldX + NyanGame.hitHW > x && catWorldX - NyanGame.hitHW < x + w)) return false;
    final double g = gapY();
    return catY - NyanGame.hitHH < g - gapH / 2 || catY + NyanGame.hitHH > g + gapH / 2;
  }

  @override
  void render(Canvas canvas) {
    final double x = spec.p[0] - game.scroll;
    if (x < -w - 40 || x > game.viewW + 40) return;
    final double g = gapY();
    final int theme = game.worldDef.index;
    paintPillar(canvas, theme, game.worldDef, Rect.fromLTRB(x, -80, x + w, g - gapH / 2), true, game.gameTime);
    paintPillar(canvas, theme, game.worldDef, Rect.fromLTRB(x, g + gapH / 2, x + w, NyanGame.worldH + 80), false, game.gameTime);
  }
}

class LaserComp extends ObstacleComp {
  LaserComp(super.game, super.spec);

  double get len => spec.p[2];
  double get thick => spec.p[3];

  /// 0 off, 1 warning, 2 on.
  int state() {
    final double u = _frac(game.scroll / spec.p[4] + spec.p[5]);
    if (u < spec.p[6]) return 2;
    if (u > 0.88) return 1;
    return 0;
  }

  @override
  double get rightEdge => spec.p[0] + len;

  @override
  bool hits(double catWorldX, double catY) {
    final double x = spec.p[0];
    if (!(catWorldX + NyanGame.hitHW > x && catWorldX - NyanGame.hitHW < x + len)) return false;
    if (state() != 2) return false;
    return (catY - spec.p[1]).abs() < thick / 2 + NyanGame.hitHH;
  }

  @override
  void render(Canvas canvas) {
    final double x = spec.p[0] - game.scroll;
    if (x < -len - 40 || x > game.viewW + 40) return;
    paintLaser(canvas, game.worldDef, Rect.fromLTWH(x, spec.p[1] - thick / 2, len, thick), state(), game.gameTime);
  }
}

class SpinnerComp extends ObstacleComp {
  SpinnerComp(super.game, super.spec);

  double get armLen => spec.p[2];
  double get ballR => spec.p[3];

  double angle() => 2 * math.pi * game.scroll / spec.p[4] + spec.p[5];

  @override
  double get rightEdge => spec.p[0] + armLen + ballR;

  @override
  bool hits(double catWorldX, double catY) {
    if ((catWorldX - spec.p[0]).abs() > armLen + ballR + NyanGame.hitHW + 4) return false;
    final double a = angle();
    final double ca = math.cos(a);
    final double sa = math.sin(a);
    final int n = (armLen / 10.0).ceil();
    for (int j = -n; j <= n; j++) {
      final double px = spec.p[0] + ca * armLen * j / n;
      final double py = spec.p[1] + sa * armLen * j / n;
      final double rad = j.abs() == n ? ballR : 7.0;
      if (catHitsCircle(px, py, rad, catWorldX, catY)) return true;
    }
    return false;
  }

  @override
  void render(Canvas canvas) {
    final double x = spec.p[0] - game.scroll;
    if (x < -armLen - 60 || x > game.viewW + armLen + 60) return;
    canvas.save();
    canvas.translate(x, spec.p[1]);
    paintSpinner(canvas, game.worldDef, armLen, ballR, angle());
    canvas.restore();
  }
}

/// Ion storm: pushes the cat up or down while it is inside.
class WindComp extends ObstacleComp {
  WindComp(super.game, super.spec);

  double get x0 => spec.p[0];
  double get x1 => spec.p[1];
  double get vy => spec.p[2];

  @override
  double get rightEdge => x1;

  @override
  void render(Canvas canvas) {
    final double a = math.max(x0 - game.scroll, -20.0);
    final double b = math.min(x1 - game.scroll, game.viewW + 20);
    if (b <= a) return;
    final Color c = Color(game.worldDef.accent2);
    canvas.drawRect(Rect.fromLTRB(a, 0, b, NyanGame.worldH), Paint()..color = c.withAlpha(16));
    final Paint line = Paint()
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = c.withAlpha(120);
    final double dir = vy >= 0 ? 1.0 : -1.0;
    for (int i = 0; i < 16; i++) {
      final double px = a + 20 + ((i * 57.0) % math.max(10.0, b - a - 40));
      final double py = ((i * 97.0 + game.gameTime * vy * 1.8) % NyanGame.worldH);
      canvas.drawLine(Offset(px, py), Offset(px, py - dir * 46), line);
    }
  }
}

// ------------------------------------------------------------------ pickups

class PickupComp extends Component {
  PickupComp(this.game, this.worldX, this.y, this.isHeart) : super(priority: 1);

  final NyanGame game;
  final double worldX;
  final double y;
  final bool isHeart;

  double get radius => isHeart ? 20 : 17;

  @override
  void render(Canvas canvas) {
    final double x = worldX - game.scroll;
    if (x < -40 || x > game.viewW + 40) return;
    final double bob = math.sin(game.gameTime * 5 + worldX * 0.05) * 3;
    canvas.save();
    canvas.translate(x, y + bob);
    if (isHeart) {
      const double r = 15;
      final Path hp = Path()
        ..moveTo(0, r * 0.95)
        ..cubicTo(-r * 1.6, -r * 0.2, -r * 0.6, -r * 1.3, 0, -r * 0.4)
        ..cubicTo(r * 0.6, -r * 1.3, r * 1.6, -r * 0.2, 0, r * 0.95);
      canvas.drawPath(hp, Paint()
        ..color = const Color(0x66FF5A7A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      canvas.drawPath(hp, Paint()..color = const Color(0xFFFF5A7A));
      canvas.drawCircle(const Offset(-6, -5), 3.5, Paint()..color = const Color(0xAAFFFFFF));
    } else {
      final double sw = 0.35 + 0.65 * math.cos(game.gameTime * 4 + worldX * 0.03).abs();
      const double r = 13;
      canvas.drawCircle(Offset.zero, r + 5, Paint()..color = const Color(0x33FFC83D));
      final Rect oval = Rect.fromCenter(center: Offset.zero, width: r * 2 * sw, height: r * 2);
      canvas.drawOval(oval, Paint()..color = const Color(0xFFFFC83D));
      canvas.drawOval(oval.deflate(3), Paint()..color = const Color(0xFFFFE27A));
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 0.7 * sw, height: r * 1.1), Paint()..color = const Color(0xFFFFA000));
    }
    canvas.restore();
  }
}

// ------------------------------------------------------------------ cat + trail

class CatComp extends Component {
  CatComp(this.game) : super(priority: 6) {
    style = styleFor(game.skin, 0);
  }

  final NyanGame game;
  double y = 490;
  double vy = 0;
  double dx = 0;
  bool visible = true;
  late CatStyle style;

  /// Smoothly follows the finger-controlled target height.
  void ease(double dt) {
    if (dt <= 0) return;
    double step = (game.targetY - y) * (1 - math.exp(-16 * dt));
    final double maxStep = 1500 * dt;
    if (step > maxStep) step = maxStep;
    if (step < -maxStep) step = -maxStep;
    y += step;
    vy = step / dt;
  }

  @override
  void update(double dt) {
    style = styleFor(game.skin, game.gameTime);
    if (game.phase == GameStatus.finishing) {
      dx += (260 + dx * 2.2) * dt;
      vy = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    if (!visible) return;
    if (game.invuln > 0 && (game.gameTime * 14).floor() % 2 == 0) return;
    const double ps = NyanGame.ps;
    final SkinDef skin = game.skin;
    canvas.save();
    canvas.translate(NyanGame.catX + dx, y);
    canvas.rotate(clampD(vy / 1800, -0.25, 0.25));
    if (skin.rarity != Rarity.common) {
      drawAura(canvas, Offset.zero, ps * 22, style.aura, 0.3 + skin.rarity.glow * 0.5);
    }
    final Offset origin = Offset(-kCatCenterCol * ps, -kCatCenterRow * ps);
    if (skin.ghost) {
      canvas.saveLayer(Rect.fromLTWH(origin.dx - 10, origin.dy - 10, kSpriteW * ps + 20, kSpriteH * ps + 20), Paint()..color = const Color(0xB8FFFFFF));
    }
    drawCat(canvas, origin, ps, skin, style, game.gameTime);
    if (skin.ghost) canvas.restore();
    canvas.restore();
  }
}

/// Animated rainbow trail that follows the cat's recent path.
class TrailComp extends Component {
  TrailComp(this.game) : super(priority: 5);

  final NyanGame game;
  final List<double> _sx = <double>[];
  final List<double> _sy = <double>[];
  final List<int> _sq = <int>[];
  double _last = 0;
  int _seq = 0;

  @override
  void update(double dt) {
    if (game.phase == GameStatus.dying || !game.cat.visible) return;
    while (game.scroll - _last >= 5) {
      _last += 5;
      _sx.add(_last);
      _sy.add(game.cat.y);
      _sq.add(_seq++);
    }
    while (_sx.length > 2 && _sx.first < game.scroll - 200) {
      _sx.removeAt(0);
      _sy.removeAt(0);
      _sq.removeAt(0);
    }
  }

  @override
  void render(Canvas canvas) {
    if (!game.cat.visible) return;
    const double ps = NyanGame.ps;
    final CatStyle st = game.cat.style;
    final double anchorX = NyanGame.catX + game.cat.dx - (kCatCenterCol - (kSpriteOx + 9)) * ps;
    final double topOff = -(kCatCenterRow - (kSpriteOy + 2)) * ps;
    final double band = 3 * ps;
    final int tick = (game.gameTime * 8).floor();
    final Paint p = Paint()..isAntiAlias = false;
    final bool ghost = game.skin.ghost;
    void column(double x, double w, double yc, int seq) {
      final double off = (((seq ~/ 4) + tick) % 2 == 0) ? 0.0 : ps;
      for (int b = 0; b < 6; b++) {
        p.color = ghost ? st.trail[b].withAlpha(170) : st.trail[b];
        canvas.drawRect(Rect.fromLTWH(x, yc + topOff + b * band + off, w + 0.6, band), p);
      }
    }

    double rightX = anchorX;
    for (int i = _sx.length - 1; i >= 0; i--) {
      final double x = (NyanGame.catX - (kCatCenterCol - (kSpriteOx + 9)) * ps) + _sx[i] - game.scroll;
      if (rightX - x > 0.5) column(x, rightX - x, _sy[i], _sq[i]);
      rightX = x;
      if (x < -20) break;
    }
  }
}

// ------------------------------------------------------------------ particles

class _Spark {
  _Spark(this.x, this.y, this.vx, this.vy, this.life, this.size, this.color, this.shape, this.rot, this.grav) : max = life;

  double x;
  double y;
  double vx;
  double vy;
  double life;
  final double max;
  final double size;
  final Color color;
  final int shape;
  double rot;
  final double grav;
}

/// All particle effects: skin effects, coin/heart bursts, hit sparks, confetti.
class FxLayer extends Component {
  FxLayer(this.game) : super(priority: 8);

  final NyanGame game;
  final List<_Spark> _p = <_Spark>[];
  final math.Random _r = math.Random(5);
  double _emit = 0;
  final Paint _paint = Paint();

  double _rnd(double a, double b) => a + _r.nextDouble() * (b - a);

  void _add(_Spark s) {
    if (_p.length < 420) _p.add(s);
  }

  void burst(double x, double y, int n, List<int> colors, double speed) {
    for (int i = 0; i < n; i++) {
      final double a = _r.nextDouble() * math.pi * 2;
      final double sp = _rnd(speed * 0.3, speed);
      _add(_Spark(x, y, math.cos(a) * sp, math.sin(a) * sp, _rnd(0.35, 0.8), _rnd(3, 7), Color(colors[_r.nextInt(colors.length)]), _r.nextInt(3), _rnd(0, 6), 0));
    }
  }

  void confetti() {
    const List<int> cols = <int>[0xFFFF4DFF, 0xFF4DFFFF, 0xFFFFE04D, 0xFF5CF2A5, 0xFFFF5A7A, 0xFFFFFFFF];
    for (int i = 0; i < 90; i++) {
      _add(_Spark(_rnd(40, game.viewW - 40), _rnd(-40, 300), _rnd(-60, 60), _rnd(60, 260), _rnd(1.0, 1.8), _rnd(5, 9), Color(cols[_r.nextInt(cols.length)]), 0, _rnd(0, 6), 60));
    }
  }

  void _skinFx() {
    final SkinDef sk = game.skin;
    if (sk.fx == Fx.none) return;
    final List<Color> cols = game.cat.style.fx;
    final Color c = cols[_r.nextInt(cols.length)];
    final double cx = NyanGame.catX + game.cat.dx;
    final double cy = game.cat.y;
    final double back = -game.level.speed * 0.35;
    switch (sk.fx) {
      case Fx.sparkle:
        _add(_Spark(cx + _rnd(-60, 40), cy + _rnd(-34, 34), back + _rnd(-30, 10), _rnd(-30, 30), 0.7, _rnd(3, 6), c, 2, 0, 0));
        break;
      case Fx.snow:
        _add(_Spark(cx + _rnd(-70, 40), cy + _rnd(-50, -20), back + _rnd(-30, 0), _rnd(30, 70), 1.0, _rnd(2, 4), c, 1, 0, 0));
        break;
      case Fx.petal:
        _add(_Spark(cx + _rnd(-60, 30), cy + _rnd(-30, 30), back + _rnd(-60, -20), _rnd(-40, 40), 1.1, _rnd(5, 8), c, 5, _rnd(0, 6), 0));
        break;
      case Fx.bubble:
        _add(_Spark(cx + _rnd(-60, 30), cy + _rnd(-10, 40), back + _rnd(-20, 0), _rnd(-90, -50), 1.0, _rnd(4, 8), c, 3, 0, 0));
        break;
      case Fx.flame:
        _add(_Spark(cx + _rnd(-60, 0), cy + _rnd(-20, 30), back + _rnd(-40, -10), _rnd(-130, -60), 0.5, _rnd(4, 8), c, 0, 0, 0));
        break;
      case Fx.glitch:
        _add(_Spark(cx + _rnd(-70, 50), cy + _rnd(-40, 40), 0, 0, 0.25, _rnd(5, 11), c, 0, 0, 0));
        break;
      case Fx.electric:
        _add(_Spark(cx + _rnd(-60, 50), cy + _rnd(-40, 40), _rnd(-260, 260), _rnd(-260, 260), 0.16, 3, c, 4, 0, 0));
        break;
      case Fx.stars:
        _add(_Spark(cx + _rnd(-70, 40), cy + _rnd(-45, 45), back + _rnd(-40, -10), _rnd(-20, 20), 1.0, _rnd(4, 7), c, 2, 0, 0));
        break;
      case Fx.smoke:
        _add(_Spark(cx + _rnd(-60, 0), cy + _rnd(-20, 30), back + _rnd(-30, -10), _rnd(-30, -10), 0.9, _rnd(7, 13), c.withAlpha(110), 1, 0, 0));
        break;
      case Fx.rainbow:
        _add(_Spark(cx + _rnd(-60, 30), cy + _rnd(-30, 30), back + _rnd(-60, -20), _rnd(-40, 40), 0.7, _rnd(3, 5), c, 0, 0, 0));
        break;
      case Fx.orbit:
        final double a = game.gameTime * 5 + _rnd(0, 0.4);
        for (int k = 0; k < 2; k++) {
          final double aa = a + k * math.pi;
          _add(_Spark(cx + math.cos(aa) * 62, cy + math.sin(aa) * 38, back * 0.3, 0, 0.45, 5, c, 2, 0, 0));
        }
        break;
      default:
        break;
    }
  }

  @override
  void update(double dt) {
    if (game.phase == GameStatus.playing && game.cat.visible) {
      _emit += dt;
      while (_emit > 0.045) {
        _emit -= 0.045;
        _skinFx();
      }
    }
    for (int i = _p.length - 1; i >= 0; i--) {
      final _Spark s = _p[i];
      s.life -= dt;
      if (s.life <= 0) {
        _p.removeAt(i);
        continue;
      }
      s.vy += s.grav * dt;
      s.x += s.vx * dt;
      s.y += s.vy * dt;
      s.rot += dt * 4;
    }
  }

  @override
  void render(Canvas canvas) {
    for (final _Spark s in _p) {
      final double k = s.life / s.max;
      _paint
        ..style = PaintingStyle.fill
        ..strokeWidth = 2
        ..color = s.color.withAlpha(clampInt((255 * (k > 1 ? 1 : k)).round(), 0, 255));
      switch (s.shape) {
        case 0:
          canvas.drawRect(Rect.fromCenter(center: Offset(s.x, s.y), width: s.size, height: s.size), _paint);
          break;
        case 1:
          canvas.drawCircle(Offset(s.x, s.y), s.size * 0.5, _paint);
          break;
        case 2:
          canvas.drawRect(Rect.fromCenter(center: Offset(s.x, s.y), width: s.size, height: s.size * 0.3), _paint);
          canvas.drawRect(Rect.fromCenter(center: Offset(s.x, s.y), width: s.size * 0.3, height: s.size), _paint);
          break;
        case 3:
          _paint.style = PaintingStyle.stroke;
          canvas.drawCircle(Offset(s.x, s.y), s.size * 0.5, _paint);
          break;
        case 4:
          _paint.style = PaintingStyle.stroke;
          canvas.drawLine(Offset(s.x, s.y), Offset(s.x - s.vx * 0.06, s.y - s.vy * 0.06), _paint);
          break;
        default:
          canvas.save();
          canvas.translate(s.x, s.y);
          canvas.rotate(s.rot);
          canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: s.size, height: s.size * 0.55), _paint);
          canvas.restore();
          break;
      }
    }
  }
}

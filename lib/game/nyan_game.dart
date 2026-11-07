import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../core/theme.dart';
import '../data/levels.dart';
import '../data/skins.dart';
import '../data/worlds.dart';
import 'components.dart';

enum GameStatus { playing, finishing, dying, over }

class WinResult {
  const WinResult(this.score, this.coins, this.totalCoins, this.stars, this.livesLeft);

  final int score;
  final int coins;
  final int totalCoins;
  final int stars;
  final int livesLeft;
}

/// Circle (cx, cy, r) versus the cat's hit box (same maths as the level verifier).
bool catHitsCircle(double cx, double cy, double r, double catWorldX, double catY) {
  final double dx = (cx - catWorldX).abs();
  final double dy = (cy - catY).abs();
  final double dxc = dx > NyanGame.hitHW ? dx - NyanGame.hitHW : 0.0;
  final double dyc = dy > NyanGame.hitHH ? dy - NyanGame.hitHH : 0.0;
  return dxc * dxc + dyc * dyc < r * r;
}

/// The Flame game: a side-scrolling flying-cat arcade level. World units: height 900, the cat sits at x = 110.
class NyanGame extends FlameGame {
  NyanGame({
    required this.level,
    required this.skin,
    required this.onSfx,
    required this.onWin,
    required this.onLose,
  });

  static const double worldH = 900.0;
  static const double catX = 110.0;
  static const double hitHW = 36.0;
  static const double hitHH = 20.0;
  static const double yMin = 120.0;
  static const double yMax = 860.0;

  /// Size of one sprite pixel in world units.
  static const double ps = 3.4;

  final LevelDef level;
  final SkinDef skin;
  final void Function(String name) onSfx;
  final void Function(WinResult result) onWin;
  final VoidCallback onLose;

  late final WorldDef worldDef = kWorlds[level.world];

  final ValueNotifier<int> scoreN = ValueNotifier<int>(0);
  final ValueNotifier<int> coinsN = ValueNotifier<int>(0);
  final ValueNotifier<int> livesN = ValueNotifier<int>(3);
  final ValueNotifier<double> progressN = ValueNotifier<double>(0);

  GameStatus phase = GameStatus.playing;
  double scroll = 0;
  double gameTime = 0;
  double scaleF = 1;
  double viewW = 450;
  double targetY = 490;
  double invuln = 0;
  int lives = 3;
  int coinsGot = 0;
  int score = 0;

  final WorldLayer layer = WorldLayer();
  late final CatComp cat;
  late final TrailComp trail;
  late final FxLayer fx;
  final List<ObstacleComp> obstacles = <ObstacleComp>[];
  final List<PickupComp> pickups = <PickupComp>[];

  bool _hasSize = false;
  bool _shaking = false;
  double _endTimer = 0;
  double _shakeT = 0;
  int _nextSpec = 0;
  int _nextCoin = 0;
  int _nextHeart = 0;
  final math.Random _rnd = math.Random(11);

  @override
  Future<void> onLoad() async {
    add(layer);
    layer.add(SpaceBackdrop(this));
    layer.add(FinishComp(this));
    trail = TrailComp(this);
    cat = CatComp(this);
    fx = FxLayer(this);
    layer.add(trail);
    layer.add(cat);
    layer.add(fx);
    cat.y = targetY;
    layer.scale = Vector2.all(scaleF);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (size.y <= 0) return;
    scaleF = size.y / worldH;
    viewW = size.x / scaleF;
    _hasSize = true;
    layer.scale = Vector2.all(scaleF);
  }

  /// Called from touch input with the finger movement in logical pixels.
  void dragBy(double dyPixels) {
    if (!_hasSize || phase != GameStatus.playing) return;
    targetY = clampD(targetY + dyPixels / scaleF * 1.35, yMin, yMax);
  }

  @override
  void update(double dt) {
    final double d = dt > 1 / 30 ? 1 / 30 : dt;
    if (_hasSize && isLoaded) {
      gameTime += d;
      if (phase == GameStatus.playing) {
        _updatePlaying(d);
      } else if (phase == GameStatus.finishing) {
        scroll += level.speed * d;
        _spawn();
        _endTimer -= d;
        if (_endTimer <= 0) {
          phase = GameStatus.over;
          _finishLevel();
        }
      } else if (phase == GameStatus.dying) {
        _endTimer -= d;
        if (_endTimer <= 0) {
          phase = GameStatus.over;
          onLose();
        }
      }
      _updateShake(d);
    }
    super.update(d);
  }

  void _updatePlaying(double d) {
    scroll += level.speed * d;
    final double cw = scroll + catX;
    double wind = 0;
    for (final ObstacleComp o in obstacles) {
      if (o is WindComp && cw >= o.x0 && cw <= o.x1) {
        wind = o.vy;
      }
    }
    if (wind != 0) targetY = clampD(targetY + wind * d, yMin, yMax);
    cat.ease(d);
    if (invuln > 0) invuln -= d;
    _spawn();
    _collide(cw);
    score = coinsGot * 10 + (scroll / 10).floor();
    scoreN.value = score;
    progressN.value = clampD(cw / level.length, 0.0, 1.0);
    if (phase == GameStatus.playing && cw >= level.length) {
      phase = GameStatus.finishing;
      _endTimer = 1.3;
      onSfx('win');
      fx.confetti();
    }
  }

  void _spawn() {
    final double limit = scroll + viewW + 200;
    final List<ObSpec> specs = level.obstacles;
    while (_nextSpec < specs.length && specs[_nextSpec].left < limit) {
      final ObstacleComp c = ObstacleComp.create(this, specs[_nextSpec]);
      obstacles.add(c);
      layer.add(c);
      _nextSpec++;
    }
    final List<double> coins = level.coins;
    while (_nextCoin * 2 + 1 < coins.length && coins[_nextCoin * 2] < limit) {
      final PickupComp p = PickupComp(this, coins[_nextCoin * 2], coins[_nextCoin * 2 + 1], false);
      pickups.add(p);
      layer.add(p);
      _nextCoin++;
    }
    final List<double> hearts = level.hearts;
    while (_nextHeart * 2 + 1 < hearts.length && hearts[_nextHeart * 2] < limit) {
      final PickupComp p = PickupComp(this, hearts[_nextHeart * 2], hearts[_nextHeart * 2 + 1], true);
      pickups.add(p);
      layer.add(p);
      _nextHeart++;
    }
    for (int i = obstacles.length - 1; i >= 0; i--) {
      if (obstacles[i].rightEdge < scroll - 160) {
        obstacles[i].removeFromParent();
        obstacles.removeAt(i);
      }
    }
    for (int i = pickups.length - 1; i >= 0; i--) {
      if (pickups[i].worldX < scroll - 120) {
        pickups[i].removeFromParent();
        pickups.removeAt(i);
      }
    }
  }

  void _collide(double cw) {
    final double cy = cat.y;
    if (invuln <= 0) {
      for (final ObstacleComp o in obstacles) {
        if (o.hits(cw, cy)) {
          _hit();
          break;
        }
      }
    }
    for (int i = pickups.length - 1; i >= 0; i--) {
      final PickupComp p = pickups[i];
      if (catHitsCircle(p.worldX, p.y, p.radius, cw, cy)) {
        _collect(p);
        pickups.removeAt(i);
      }
    }
  }

  void _hit() {
    if (invuln > 0 || phase != GameStatus.playing) return;
    lives -= 1;
    livesN.value = lives;
    onSfx('hit');
    _shakeT = 0.35;
    fx.burst(catX, cat.y, 22, const <int>[0xFFFF5A7A, 0xFFFFFFFF, 0xFFFFC83D], 260);
    if (lives <= 0) {
      phase = GameStatus.dying;
      _endTimer = 1.0;
      cat.visible = false;
      fx.burst(catX, cat.y, 46, const <int>[0xFFFF5A7A, 0xFFFFFFFF, 0xFFFFC83D, 0xFFB388FF], 380);
    } else {
      invuln = 1.6;
    }
  }

  void _collect(PickupComp p) {
    final double sx = p.worldX - scroll;
    if (p.isHeart) {
      if (lives < 3) lives += 1;
      livesN.value = lives;
      onSfx('heart');
      fx.burst(sx, p.y, 14, const <int>[0xFFFF5A7A, 0xFFFFB3C6, 0xFFFFFFFF], 200);
    } else {
      coinsGot += 1;
      coinsN.value = coinsGot;
      onSfx('coin');
      fx.burst(sx, p.y, 8, const <int>[0xFFFFC83D, 0xFFFFF3A0, 0xFFFFFFFF], 150);
    }
    p.removeFromParent();
  }

  void _finishLevel() {
    final int total = level.totalCoins;
    final double ratio = total == 0 ? 1.0 : coinsGot / total;
    final int stars = ratio >= 0.85 ? 3 : (ratio >= 0.5 ? 2 : 1);
    final int finalScore = coinsGot * 10 + (level.length / 10).floor() + lives * 50;
    scoreN.value = finalScore;
    onWin(WinResult(finalScore, coinsGot, total, stars, lives));
  }

  void _updateShake(double d) {
    if (_shakeT > 0) {
      _shakeT -= d;
      final double a = _shakeT * 30;
      layer.position = Vector2((_rnd.nextDouble() - 0.5) * a, (_rnd.nextDouble() - 0.5) * a);
      _shaking = true;
    } else if (_shaking) {
      layer.position = Vector2.zero();
      _shaking = false;
    }
  }
}

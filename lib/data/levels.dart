import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// One obstacle. Parameter layout of [p] depends on [type]:
/// 0 rock:        x, y, r, variant
/// 1 floater:     x, y, r, amp, period, phase, variant   (moves up/down with the scroll distance)
/// 2 gate:        x, gapY, gapH, width, variant
/// 3 swing gate:  x, gapY, gapH, width, amp, period, phase, variant
/// 4 laser:       x, y, length, thickness, period, phase, duty
/// 5 spinner:     x, y, armLen, ballR, period, phase
/// 6 wind zone:   x0, x1, vy
class ObSpec {
  const ObSpec(this.type, this.p);

  final int type;
  final List<double> p;

  /// Left-most world x of this obstacle (the list is sorted by this value).
  double get left {
    switch (type) {
      case 0:
      case 1:
        return p[0] - p[2];
      case 5:
        return p[0] - p[2] - p[3];
      default:
        return p[0];
    }
  }
}

class LevelDef {
  const LevelDef({
    required this.id,
    required this.world,
    required this.speed,
    required this.length,
    required this.seed,
    required this.obstacles,
    required this.coins,
    required this.hearts,
  });

  final int id;
  final int world;
  final double speed;
  final double length;
  final int seed;
  final List<ObSpec> obstacles;

  /// Flat list x0, y0, x1, y1, ...
  final List<double> coins;
  final List<double> hearts;

  int get totalCoins => coins.length ~/ 2;
}

class LevelCatalog {
  LevelCatalog._();

  static List<LevelDef> levels = <LevelDef>[];
  static int get count => levels.length;

  static LevelDef byId(int id) {
    int i = id - 1;
    if (i < 0) i = 0;
    if (i >= levels.length) i = levels.length - 1;
    return levels[i];
  }

  static List<double> _nums(List<dynamic> a, int from) {
    final List<double> out = <double>[];
    for (int i = from; i < a.length; i++) {
      out.add((a[i] as num).toDouble());
    }
    return out;
  }

  static Future<void> load() async {
    final String text = await rootBundle.loadString('assets/levels/levels.json');
    final Map<String, dynamic> data = jsonDecode(text) as Map<String, dynamic>;
    final List<dynamic> raw = data['levels'] as List<dynamic>;
    final List<LevelDef> out = <LevelDef>[];
    for (final dynamic l in raw) {
      final Map<String, dynamic> m = l as Map<String, dynamic>;
      final List<ObSpec> obs = <ObSpec>[];
      for (final dynamic o in m['obs'] as List<dynamic>) {
        final List<dynamic> a = o as List<dynamic>;
        obs.add(ObSpec((a[0] as num).toInt(), _nums(a, 1)));
      }
      final List<double> coins = <double>[];
      for (final dynamic c in m['coins'] as List<dynamic>) {
        coins.addAll(_nums(c as List<dynamic>, 0));
      }
      final List<double> hearts = <double>[];
      for (final dynamic c in m['hearts'] as List<dynamic>) {
        hearts.addAll(_nums(c as List<dynamic>, 0));
      }
      obs.sort((ObSpec a, ObSpec b) => a.left.compareTo(b.left));
      out.add(LevelDef(
        id: (m['id'] as num).toInt(),
        world: (m['world'] as num).toInt(),
        speed: (m['speed'] as num).toDouble(),
        length: (m['length'] as num).toDouble(),
        seed: (m['bg'] as num).toInt(),
        obstacles: obs,
        coins: coins,
        hearts: hearts,
      ));
    }
    out.sort((LevelDef a, LevelDef b) => a.id.compareTo(b.id));
    levels = out;
  }
}

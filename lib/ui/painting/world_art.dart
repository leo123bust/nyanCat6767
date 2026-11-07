import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/clock.dart';
import '../../data/worlds.dart';
import '../../game/obstacle_art.dart';

class _WorldArtPainter extends CustomPainter {
  _WorldArtPainter(this.world) : super(repaint: AppClock.t);

  final WorldDef world;

  @override
  void paint(Canvas canvas, Size size) {
    final double t = AppClock.t.value;
    final Rect rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, <Color>[Color(world.top), Color(world.bottom)]));
    final Offset n1 = Offset(size.width * 0.25, size.height * 0.3);
    final Offset n2 = Offset(size.width * 0.8, size.height * 0.75);
    canvas.drawCircle(n1, size.width * 0.45, Paint()..shader = ui.Gradient.radial(n1, size.width * 0.45, <Color>[Color(world.neb1).withAlpha(110), Color(world.neb1).withAlpha(0)]));
    canvas.drawCircle(n2, size.width * 0.5, Paint()..shader = ui.Gradient.radial(n2, size.width * 0.5, <Color>[Color(world.neb2).withAlpha(100), Color(world.neb2).withAlpha(0)]));
    final math.Random rnd = math.Random(world.index * 17 + 3);
    final Paint sp = Paint()..isAntiAlias = false;
    for (int i = 0; i < 22; i++) {
      final double a = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(t * (0.8 + rnd.nextDouble() * 1.5) + i));
      sp.color = Color.fromARGB((a * 255).round(), 255, 255, 255);
      canvas.drawRect(Rect.fromLTWH(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height, 2, 2), sp);
    }
    final double s = size.width;
    void item(double fx, double fy, double fr, int variant, double ph) {
      canvas.save();
      canvas.translate(s * fx, size.height * fy + math.sin(t * 1.3 + ph) * 3);
      canvas.rotate(math.sin(t * 0.7 + ph) * 0.25);
      paintRock(canvas, world.index, s * fr, variant, t);
      canvas.restore();
    }

    item(0.5, 0.5, 0.27, 0, 0.0);
    item(0.17, 0.2, 0.11, 1, 1.0);
    item(0.84, 0.24, 0.09, 2, 2.0);
    item(0.82, 0.82, 0.12, 3, 3.0);
    item(0.18, 0.83, 0.08, 1, 4.0);
  }

  @override
  bool shouldRepaint(_WorldArtPainter old) => old.world != world;
}

/// Themed illustration of a world (home carousel, level list).
class WorldArt extends StatelessWidget {
  const WorldArt({super.key, required this.world, this.radius = 20});

  final WorldDef world;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CustomPaint(painter: _WorldArtPainter(world), size: Size.infinite),
    );
  }
}

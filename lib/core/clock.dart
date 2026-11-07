import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// One global animation clock (seconds). Painters listen to it and repaint without rebuilding widgets.
class AppClock {
  AppClock._();

  static final ValueNotifier<double> t = ValueNotifier<double>(0);
  static Ticker? _ticker;

  static void start() {
    if (_ticker != null) return;
    final Ticker ticker = Ticker((Duration d) {
      t.value = d.inMicroseconds / 1000000.0;
    });
    _ticker = ticker;
    ticker.start();
  }
}

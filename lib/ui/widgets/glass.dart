import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/clock.dart';
import '../../core/theme.dart';
import '../../data/skins.dart';
import '../../services/audio_service.dart';

/// Fade page transition used everywhere.
Route<T> fadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondary) => page,
    transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondary, Widget child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 320),
  );
}

void showToast(BuildContext context, String message) {
  final ScaffoldMessengerState? m = ScaffoldMessenger.maybeOf(context);
  if (m == null) return;
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    content: Text(message, style: ts(15)),
    behavior: SnackBarBehavior.floating,
    backgroundColor: const Color(0xFF241B63),
    duration: const Duration(milliseconds: 1700),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ));
}

/// Frosted-glass card (translucent gradient + light border), like the reference design.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 24,
    this.blur = false,
    this.borderColor,
    this.glow,
    this.onTap,
    this.fill,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool blur;
  final Color? borderColor;
  final Color? glow;
  final VoidCallback? onTap;
  final List<Color>? fill;

  @override
  Widget build(BuildContext context) {
    final BorderRadius br = BorderRadius.circular(radius);
    Widget box = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: br,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: fill ?? const <Color>[NC.glassTop, NC.glassBottom],
        ),
        border: Border.all(color: borderColor ?? NC.glassBorder, width: 1.2),
        boxShadow: glow == null ? null : <BoxShadow>[BoxShadow(color: glow!.withAlpha(90), blurRadius: 18, spreadRadius: 1)],
      ),
      child: child,
    );
    if (blur) {
      box = ClipRRect(
        borderRadius: br,
        child: BackdropFilter(filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12), child: box),
      );
    }
    if (onTap != null) {
      box = GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: box);
    }
    return box;
  }
}

class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, required this.style, required this.colors, this.align = TextAlign.center});

  final String text;
  final TextStyle style;
  final List<Color> colors;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) => LinearGradient(colors: colors).createShader(bounds),
      child: Text(text, textAlign: align, style: style.copyWith(color: Colors.white)),
    );
  }
}

enum GlowStyle { galaxy, outline, solid, danger }

class GlowButton extends StatefulWidget {
  const GlowButton({
    super.key,
    required this.label,
    required this.onTap,
    this.width,
    this.height = 56,
    this.style = GlowStyle.galaxy,
    this.icon,
    this.fontSize = 20,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final double? width;
  final double height;
  final GlowStyle style;
  final IconData? icon;
  final double fontSize;
  final bool enabled;

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final GlowStyle st = widget.style;
    final Widget label = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (widget.icon != null) ...<Widget>[Icon(widget.icon, color: Colors.white, size: widget.fontSize + 4), const SizedBox(width: 8)],
        Flexible(
          child: Text(widget.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(widget.fontSize, weight: FontWeight.w800, spacing: 1.2)),
        ),
      ],
    );
    Widget body;
    if (st == GlowStyle.galaxy) {
      body = Container(
        width: widget.width,
        height: widget.height,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.height),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[NC.glassTop, NC.glassBottom]),
          border: Border.all(color: NC.glassBorder, width: 1.4),
          boxShadow: <BoxShadow>[BoxShadow(color: NC.violet.withAlpha(120), blurRadius: 26, spreadRadius: 1)],
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.height),
            gradient: const LinearGradient(colors: NC.galaxyButton),
          ),
          child: label,
        ),
      );
    } else if (st == GlowStyle.outline) {
      body = Container(
        width: widget.width,
        height: widget.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.height),
          color: const Color(0x14FFFFFF),
          border: Border.all(color: NC.violet, width: 2),
          boxShadow: <BoxShadow>[BoxShadow(color: NC.violet.withAlpha(110), blurRadius: 14)],
        ),
        child: label,
      );
    } else {
      final bool danger = st == GlowStyle.danger;
      body = Container(
        width: widget.width,
        height: widget.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.height),
          gradient: LinearGradient(colors: danger ? const <Color>[Color(0xFFFF5A7A), Color(0xFFC2185B)] : const <Color>[Color(0xFF6A5CF0), Color(0xFF8E6CF0)]),
          boxShadow: <BoxShadow>[BoxShadow(color: (danger ? NC.danger : NC.violet).withAlpha(110), blurRadius: 16)],
        ),
        child: label,
      );
    }
    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.55,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (TapDownDetails d) => setState(() => _down = true),
        onTapUp: (TapUpDetails d) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: () {
          AudioService.instance.sfx('click');
          widget.onTap();
        },
        child: AnimatedScale(scale: _down ? 0.95 : 1.0, duration: const Duration(milliseconds: 90), child: body),
      ),
    );
  }
}

class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[Color(0xFFFFF3A0), Color(0xFFFFB300)]),
        border: Border.all(color: const Color(0xFFFF8F00), width: size * 0.09),
        boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x66FFC83D), blurRadius: 8)],
      ),
      child: Text('N', style: ts(size * 0.55, weight: FontWeight.w900, color: const Color(0xFFB36B00))),
    );
  }
}

class CoinPill extends StatelessWidget {
  const CoinPill({super.key, required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 20,
      padding: const EdgeInsets.fromLTRB(8, 5, 14, 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[const CoinIcon(size: 24), const SizedBox(width: 8), Text('$amount', style: ts(18, weight: FontWeight.w800))],
      ),
    );
  }
}

class NyanToggle extends StatelessWidget {
  const NyanToggle({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        AudioService.instance.sfx('click');
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 56,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: value ? const LinearGradient(colors: <Color>[NC.neonBlue, NC.violet]) : null,
          color: value ? null : const Color(0x33FFFFFF),
          border: Border.all(color: NC.glassBorder),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 160),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(width: 24, height: 24, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
        ),
      ),
    );
  }
}

/// Rarity-coloured frame. Chromatic and Ultra frames animate (colour sweep).
class RarityFrame extends StatelessWidget {
  const RarityFrame({super.key, required this.rarity, required this.child, this.radius = 20, this.width = 2.4, this.selected = false});

  final Rarity rarity;
  final Widget child;
  final double radius;
  final double width;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final BorderRadius outer = BorderRadius.circular(radius);
    final BorderRadius inner = BorderRadius.circular(radius - width < 2 ? 2 : radius - width);
    final double g = rarity.glow;
    if (!rarity.animated) {
      return Container(
        padding: EdgeInsets.all(selected ? width + 1.2 : width),
        decoration: BoxDecoration(
          borderRadius: outer,
          color: selected ? Colors.white : rarity.color.withAlpha(rarity == Rarity.common ? 150 : 255),
          boxShadow: g <= 0 && !selected
              ? null
              : <BoxShadow>[BoxShadow(color: rarity.color.withAlpha(clampInt((60 + 150 * g).round(), 0, 255)), blurRadius: 8 + 14 * g, spreadRadius: selected ? 2 : 0)],
        ),
        child: ClipRRect(borderRadius: inner, child: child),
      );
    }
    return ValueListenableBuilder<double>(
      valueListenable: AppClock.t,
      builder: (BuildContext context, double t, Widget? _) {
        return Container(
          padding: EdgeInsets.all(selected ? width + 1.2 : width),
          decoration: BoxDecoration(
            borderRadius: outer,
            gradient: SweepGradient(colors: rarity.sweep, transform: GradientRotation(t * 2.2)),
            boxShadow: <BoxShadow>[BoxShadow(color: rarity.sweep[(t * 1.5).floor() % (rarity.sweep.length - 1)].withAlpha(170), blurRadius: 12 + 12 * g)],
          ),
          child: ClipRRect(borderRadius: inner, child: child),
        );
      },
    );
  }
}

/// Small coloured rarity label.
class RarityBadge extends StatelessWidget {
  const RarityBadge({super.key, required this.rarity, required this.label});

  final Rarity rarity;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: rarity.color.withAlpha(46),
        border: Border.all(color: rarity.color.withAlpha(190)),
      ),
      child: Text(label, style: ts(11, weight: FontWeight.w800, color: rarity.color, spacing: 0.6)),
    );
  }
}

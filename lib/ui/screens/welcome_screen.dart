import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../services/app_state.dart';
import '../../services/audio_service.dart';
import '../painting/cat_painter.dart';
import '../painting/space_painter.dart';
import '../widgets/glass.dart';
import 'main_shell.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    AudioService.instance.playMusic('menu');
  }

  void _start() {
    Navigator.of(context).pushReplacement(fadeRoute<void>(const MainShell()));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (BuildContext context, Widget? _) {
        return Scaffold(
          body: SpaceBackground(
            colors: NC.welcomeBg,
            stops: NC.welcomeStops,
            icons: true,
            seed: 11,
            starCount: 60,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: <Widget>[
                    const Spacer(flex: 3),
                    CatSprite(skin: AppState.instance.equippedSkin, width: 270),
                    const SizedBox(height: 34),
                    GradientText(tr('welcome1'), style: ts(33, weight: FontWeight.w800, spacing: 1.2), colors: const <Color>[Color(0xFFC9B8FF), Color(0xFF9A7CF5)]),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: GradientText('NyanCat6767', style: ts(46, weight: FontWeight.w800, spacing: 0.5), colors: const <Color>[Color(0xFFB59BFF), Color(0xFF7C5CFF)]),
                    ),
                    const SizedBox(height: 18),
                    Text(tr('welcomeSub'), textAlign: TextAlign.center, style: ts(17, weight: FontWeight.w500, color: Colors.white, height: 1.35)),
                    const Spacer(flex: 2),
                    GlowButton(label: tr('start'), onTap: _start, width: double.infinity, height: 70, fontSize: 26),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

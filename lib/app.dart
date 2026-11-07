import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'services/audio_service.dart';
import 'ui/screens/welcome_screen.dart';

class NyanApp extends StatefulWidget {
  const NyanApp({super.key});

  @override
  State<NyanApp> createState() => _NyanAppState();
}

class _NyanAppState extends State<NyanApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AudioService.instance.resumeMusic();
    } else if (state == AppLifecycleState.paused) {
      AudioService.instance.pauseMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NyanCat6767',
      theme: buildTheme(),
      home: const WelcomeScreen(),
    );
  }
}

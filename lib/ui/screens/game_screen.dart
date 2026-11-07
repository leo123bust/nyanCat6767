import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/levels.dart';
import '../../game/nyan_game.dart';
import '../../services/app_state.dart';
import '../../services/audio_service.dart';
import '../widgets/glass.dart';

enum _Phase { playing, paused, won, lost }

const List<Color> _panel = <Color>[Color(0xF21B1560), Color(0xF20E0B3D)];

/// Hosts the Flame game, the HUD and the pause / win / game-over overlays.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.levelId});

  final int levelId;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late int _levelId;
  late NyanGame _game;
  int _run = 0;
  _Phase _phase = _Phase.playing;
  WinResult? _win;
  int _granted = 0;
  bool _hint = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _levelId = widget.levelId;
    _newGame();
    AudioService.instance.playMusic('game');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _phase == _Phase.playing) {
      _pause();
    }
  }

  void _newGame() {
    _run++;
    _phase = _Phase.playing;
    _win = null;
    _granted = 0;
    _hint = true;
    final int run = _run;
    _game = NyanGame(
      level: LevelCatalog.byId(_levelId),
      skin: AppState.instance.equippedSkin,
      onSfx: AudioService.instance.sfx,
      onWin: _onWin,
      onLose: _onLose,
    );
    Future<void>.delayed(const Duration(milliseconds: 2800), () {
      if (mounted && run == _run) {
        setState(() => _hint = false);
      }
    });
  }

  void _onWin(WinResult r) {
    if (!mounted || _phase != _Phase.playing) return;
    // Reward is granted exactly once per level (AppState keeps the set of rewarded levels).
    final int granted = AppState.instance.completeLevel(_levelId, r.score, r.stars);
    _game.pauseEngine();
    setState(() {
      _win = r;
      _granted = granted;
      _phase = _Phase.won;
    });
  }

  void _onLose() {
    if (!mounted || _phase != _Phase.playing) return;
    AudioService.instance.sfx('lose');
    _game.pauseEngine();
    setState(() => _phase = _Phase.lost);
  }

  void _pause() {
    if (_phase != _Phase.playing) return;
    _game.pauseEngine();
    setState(() => _phase = _Phase.paused);
  }

  void _resume() {
    if (_phase != _Phase.paused) return;
    _game.resumeEngine();
    setState(() => _phase = _Phase.playing);
  }

  void _restart() {
    setState(_newGame);
  }

  void _exit() {
    AudioService.instance.playMusic('menu');
    Navigator.of(context).pop();
  }

  void _home() {
    AudioService.instance.playMusic('menu');
    Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst);
  }

  void _next() {
    Navigator.of(context).pushReplacement(fadeRoute<void>(GameScreen(levelId: _levelId + 1)));
  }

  Widget _scrim(Widget child) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xB0050520),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(child: child),
      ),
    );
  }

  Widget _hud() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _pause,
                  child: const GlassCard(radius: 22, padding: EdgeInsets.all(8), child: Icon(Icons.pause_rounded, size: 26, color: Colors.white)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ValueListenableBuilder<double>(
                    valueListenable: _game.progressN,
                    builder: (BuildContext context, double v, Widget? _) {
                      return Container(
                        height: 14,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: const Color(0x44000000), border: Border.all(color: NC.glassBorder)),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: clampD(v, 0.02, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: const LinearGradient(colors: <Color>[Color(0xFF3F6BFF), Color(0xFFFF6EC7)]),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ValueListenableBuilder<int>(
                  valueListenable: _game.livesN,
                  builder: (BuildContext context, int v, Widget? _) {
                    return Row(
                      children: <Widget>[
                        for (int i = 0; i < 3; i++) Icon(i < v ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: NC.danger, size: 24),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                ValueListenableBuilder<int>(
                  valueListenable: _game.coinsN,
                  builder: (BuildContext context, int v, Widget? _) {
                    return GlassCard(
                      radius: 18,
                      padding: const EdgeInsets.fromLTRB(6, 4, 12, 4),
                      child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[const CoinIcon(size: 20), const SizedBox(width: 6), Text('$v/${_game.level.totalCoins}', style: ts(15, weight: FontWeight.w800))]),
                    );
                  },
                ),
                const Spacer(),
                Text('${_levelWord()} $_levelId', style: ts(15, weight: FontWeight.w700, color: NC.textDim)),
                const Spacer(),
                ValueListenableBuilder<int>(
                  valueListenable: _game.scoreN,
                  builder: (BuildContext context, int v, Widget? _) => Text('${tr('score')}: $v', style: ts(15, weight: FontWeight.w800)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _levelWord() => tr('levelWord');

  Widget _pauseOverlay() {
    return _scrim(
      ListenableBuilder(
        listenable: AppState.instance,
        builder: (BuildContext context, Widget? _) {
          final AppState s = AppState.instance;
          return GlassCard(
            radius: 28,
            padding: const EdgeInsets.all(22),
            fill: _panel,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(tr('paused'), style: ts(28, weight: FontWeight.w800, spacing: 2)),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    const Icon(Icons.music_note_rounded, color: NC.lavender),
                    const SizedBox(width: 10),
                    Expanded(child: Text(tr('music'), style: ts(16))),
                    NyanToggle(value: s.musicOn, onChanged: s.setMusicOn),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    const Icon(Icons.volume_up_rounded, color: NC.lavender),
                    const SizedBox(width: 10),
                    Expanded(child: Text(tr('sound'), style: ts(16))),
                    NyanToggle(value: s.sfxOn, onChanged: s.setSfxOn),
                  ],
                ),
                const SizedBox(height: 18),
                GlowButton(label: tr('resume'), onTap: _resume, width: double.infinity, height: 56, fontSize: 19, icon: Icons.play_arrow_rounded),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(child: GlowButton(label: tr('restart'), onTap: _restart, style: GlowStyle.outline, height: 46, fontSize: 14, icon: Icons.replay_rounded)),
                    const SizedBox(width: 10),
                    Expanded(child: GlowButton(label: tr('home'), onTap: _home, style: GlowStyle.outline, height: 46, fontSize: 14, icon: Icons.home_rounded)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _winOverlay() {
    final WinResult r = _win ?? const WinResult(0, 0, 0, 1, 0);
    final bool hasNext = _levelId < LevelCatalog.count;
    return _scrim(
      GlassCard(
        radius: 28,
        padding: const EdgeInsets.all(22),
        fill: _panel,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GradientText(tr('levelComplete'), style: ts(24, weight: FontWeight.w800, spacing: 1), colors: const <Color>[Color(0xFFFFE27A), Color(0xFFFF9AD5)]),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[for (int i = 0; i < 3; i++) Icon(i < r.stars ? Icons.star_rounded : Icons.star_border_rounded, color: NC.gold, size: 48)],
            ),
            const SizedBox(height: 10),
            Text('${tr('score')}: ${r.score}', style: ts(19, weight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text('${tr('collected')}: ${r.coins}/${r.totalCoins}', style: ts(15, weight: FontWeight.w500, color: NC.textDim)),
            const SizedBox(height: 14),
            if (_granted > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('${tr('reward')}:', style: ts(17, weight: FontWeight.w600, color: NC.textDim)),
                  const SizedBox(width: 10),
                  const CoinIcon(size: 30),
                  const SizedBox(width: 8),
                  Text('+$_granted', style: ts(28, weight: FontWeight.w800, color: NC.gold)),
                ],
              )
            else
              Text(tr('rewardClaimed'), textAlign: TextAlign.center, style: ts(14, weight: FontWeight.w500, color: NC.textDim)),
            const SizedBox(height: 18),
            if (hasNext) ...<Widget>[
              GlowButton(label: tr('next'), onTap: _next, width: double.infinity, height: 58, fontSize: 19, icon: Icons.skip_next_rounded),
              const SizedBox(height: 10),
            ],
            Row(
              children: <Widget>[
                Expanded(child: GlowButton(label: tr('restart'), onTap: _restart, style: GlowStyle.outline, height: 46, fontSize: 14, icon: Icons.replay_rounded)),
                const SizedBox(width: 10),
                Expanded(child: GlowButton(label: tr('navLevels'), onTap: _exit, style: GlowStyle.outline, height: 46, fontSize: 14, icon: Icons.apps_rounded)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _loseOverlay() {
    return _scrim(
      GlassCard(
        radius: 28,
        padding: const EdgeInsets.all(22),
        fill: _panel,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.sentiment_dissatisfied_rounded, color: NC.danger, size: 48),
            const SizedBox(height: 8),
            Text(tr('gameOver'), style: ts(26, weight: FontWeight.w800, spacing: 1.5)),
            const SizedBox(height: 8),
            Text('${tr('score')}: ${_game.score}', style: ts(18, weight: FontWeight.w700)),
            const SizedBox(height: 18),
            GlowButton(label: tr('tryAgain'), onTap: _restart, width: double.infinity, height: 58, fontSize: 19, icon: Icons.replay_rounded),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(child: GlowButton(label: tr('navLevels'), onTap: _exit, style: GlowStyle.outline, height: 46, fontSize: 14, icon: Icons.apps_rounded)),
                const SizedBox(width: 10),
                Expanded(child: GlowButton(label: tr('home'), onTap: _home, style: GlowStyle.outline, height: 46, fontSize: 14, icon: Icons.home_rounded)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        if (_phase == _Phase.playing) {
          _pause();
        } else if (_phase == _Phase.paused) {
          _resume();
        } else {
          _exit();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerMove: (PointerMoveEvent e) => _game.dragBy(e.delta.dy),
                child: GameWidget<NyanGame>(key: ValueKey<int>(_run), game: _game),
              ),
            ),
            if (_phase == _Phase.playing || _phase == _Phase.paused) _hud(),
            if (_hint && _phase == _Phase.playing)
              Positioned(
                left: 24,
                right: 24,
                bottom: 90,
                child: IgnorePointer(
                  child: GlassCard(
                    radius: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(Icons.swap_vert_rounded, color: Colors.white),
                        const SizedBox(width: 10),
                        Flexible(child: Text(tr('dragHint'), textAlign: TextAlign.center, style: ts(15, weight: FontWeight.w600))),
                      ],
                    ),
                  ),
                ),
              ),
            if (_phase == _Phase.paused) _pauseOverlay(),
            if (_phase == _Phase.won) _winOverlay(),
            if (_phase == _Phase.lost) _loseOverlay(),
          ],
        ),
      ),
    );
  }
}

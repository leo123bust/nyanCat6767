import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/levels.dart';
import '../../data/worlds.dart';
import '../../services/app_state.dart';
import '../../services/audio_service.dart';
import '../painting/space_painter.dart';
import '../painting/world_art.dart';
import '../widgets/glass.dart';
import 'game_screen.dart';

/// Level selection: every world has a glass card with its 10 levels (completed / available / locked).
class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key, this.initialWorld = 0});

  final int initialWorld;

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  final List<GlobalKey> _keys = List<GlobalKey>.generate(kWorlds.length, (int i) => GlobalKey());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted) return;
      int w = widget.initialWorld;
      if (w < 0) w = 0;
      if (w >= _keys.length) w = _keys.length - 1;
      final BuildContext? c = _keys[w].currentContext;
      if (c != null) {
        Scrollable.ensureVisible(c, alignment: 0.02);
      }
    });
  }

  void _start(int level) {
    if (AppState.instance.isUnlocked(level)) {
      Navigator.of(context).push(fadeRoute<void>(GameScreen(levelId: level)));
    } else {
      AudioService.instance.sfx('error');
      showToast(context, tr('finishPrev'));
    }
  }

  Widget _legend(IconData icon, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[Icon(icon, size: 15, color: color), const SizedBox(width: 4), Text(label, style: ts(12, weight: FontWeight.w500, color: NC.textDim))],
    );
  }

  Widget _section(WorldDef w) {
    final AppState s = AppState.instance;
    int done = 0;
    for (int l = w.firstLevel; l <= w.lastLevel; l++) {
      if (s.isCompleted(l)) done++;
    }
    return Padding(
      key: _keys[w.index],
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        radius: 24,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('${tr('levelWord')} ${w.firstLevel}–${w.lastLevel}:', style: ts(18, weight: FontWeight.w800)),
                      Text(w.name, style: ts(18, weight: FontWeight.w800, height: 1.15)),
                      const SizedBox(height: 4),
                      Text(done == 10 ? tr('completed') : '${tr('completed')}: $done/10', style: ts(14, weight: FontWeight.w500, color: done == 10 ? NC.good : NC.textDim)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(width: 62, height: 62, child: WorldArt(world: w, radius: 31)),
                if (done == 10) ...<Widget>[const SizedBox(width: 10), const Icon(Icons.check_rounded, color: Colors.white, size: 28)],
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints cons) {
                final double cw = (cons.maxWidth - 4 * 8) / 5;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[for (int l = w.firstLevel; l <= w.lastLevel; l++) _LevelChip(level: l, size: cw, onTap: _start)],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (BuildContext context, Widget? _) {
        final AppState s = AppState.instance;
        return Scaffold(
          body: SpaceBackground(
            colors: NC.darkBg,
            stops: NC.darkStops,
            seed: 31,
            nebula: const <NebulaBlob>[NebulaBlob(0.1, 0.4, 0.7, 0xFF2A4C8F), NebulaBlob(0.95, 0.25, 0.6, 0xFFB0297F), NebulaBlob(0.5, 0.9, 0.6, 0xFF512DA8)],
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const GlassCard(radius: 22, padding: EdgeInsets.all(10), child: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white)),
                        ),
                        Expanded(child: Center(child: Text(tr('levelsTitle'), style: ts(26, weight: FontWeight.w800, spacing: 1.5)))),
                        const SizedBox(width: 44),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('${tr('unlocked')}: ${s.unlockedCount}/${LevelCatalog.count}', style: ts(15, weight: FontWeight.w600, spacing: 0.8)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _legend(Icons.check_circle_rounded, NC.good, tr('completed')),
                      const SizedBox(width: 14),
                      _legend(Icons.play_arrow_rounded, NC.gold, tr('available')),
                      const SizedBox(width: 14),
                      _legend(Icons.lock_rounded, const Color(0x99FFFFFF), tr('lockedLevel')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Column(children: <Widget>[for (final WorldDef w in kWorlds) _section(w)]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.level, required this.size, required this.onTap});

  final int level;
  final double size;
  final void Function(int level) onTap;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppState.instance;
    final bool done = s.isCompleted(level);
    final bool open = s.isUnlocked(level);
    final bool current = open && !done;
    final int st = s.stars[level] ?? 0;
    final Color border = done ? NC.good : (current ? NC.gold : const Color(0x33FFFFFF));
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(level),
      child: Container(
        width: size,
        height: size + 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: open ? const <Color>[Color(0x40FFFFFF), Color(0x14FFFFFF)] : const <Color>[Color(0x14FFFFFF), Color(0x08FFFFFF)],
          ),
          border: Border.all(color: border, width: current ? 2 : 1.2),
          boxShadow: current ? <BoxShadow>[BoxShadow(color: NC.gold.withAlpha(90), blurRadius: 12)] : null,
        ),
        child: Stack(
          children: <Widget>[
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (open) Text('$level', style: ts(18, weight: FontWeight.w800)) else const Icon(Icons.lock_rounded, color: Color(0x88FFFFFF), size: 22),
                  const SizedBox(height: 2),
                  if (done)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[for (int i = 0; i < 3; i++) Icon(Icons.star_rounded, size: 11, color: i < st ? NC.gold : const Color(0x44FFFFFF))],
                    )
                  else if (current)
                    const Icon(Icons.play_arrow_rounded, color: NC.gold, size: 16)
                  else
                    const SizedBox(height: 16),
                ],
              ),
            ),
            if (done) const Positioned(top: 3, right: 3, child: Icon(Icons.check_circle_rounded, size: 14, color: NC.good)),
          ],
        ),
      ),
    );
  }
}

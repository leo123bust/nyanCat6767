import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/levels.dart';
import '../../data/skins.dart';
import '../../data/worlds.dart';
import '../../services/app_state.dart';
import '../painting/cat_painter.dart';
import '../painting/space_painter.dart';
import '../painting/world_art.dart';
import '../widgets/glass.dart';
import 'game_screen.dart';
import 'levels_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final PageController _pc;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _page = worldOfLevel(AppState.instance.currentLevel).index;
    _pc = PageController(viewportFraction: 0.6, initialPage: _page);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _play(int level) {
    Navigator.of(context).push(fadeRoute<void>(GameScreen(levelId: level)));
  }

  Widget _progressBar(double fraction) {
    return Container(
      height: 12,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: const Color(0x33FFFFFF), border: Border.all(color: NC.glassBorder)),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: clampD(fraction, 0.03, 1.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(colors: <Color>[Color(0xFF3F6BFF), Color(0xFF9A6CFF)]),
              boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x887C5CFF), blurRadius: 8)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _worldCard(int index) {
    final WorldDef w = kWorlds[index];
    return AnimatedBuilder(
      animation: _pc,
      builder: (BuildContext context, Widget? _) {
        double page = _page.toDouble();
        if (_pc.hasClients && _pc.position.haveDimensions) {
          page = _pc.page ?? page;
        }
        final double d = clampD((page - index).abs(), 0.0, 1.0);
        final double scale = 1.0 - d * 0.14;
        return Center(
          child: Transform.scale(
            scale: scale,
            child: GlassCard(
              radius: 26,
              blur: false,
              padding: const EdgeInsets.all(10),
              borderColor: d < 0.5 ? const Color(0x77FFFFFF) : NC.glassBorder,
              glow: d < 0.3 ? NC.violet : null,
              onTap: () => Navigator.of(context).push(fadeRoute<void>(LevelsScreen(initialWorld: index))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AspectRatio(aspectRatio: 1.0, child: WorldArt(world: w, radius: 18)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 60,
                    child: Center(
                      child: Text(w.name, textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis, style: ts(17, weight: FontWeight.w800, height: 1.15)),
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

  @override
  Widget build(BuildContext context) {
    final double bottomPad = MediaQuery.paddingOf(context).bottom + 96;
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (BuildContext context, Widget? _) {
        final AppState s = AppState.instance;
        final int cur = s.currentLevel;
        final int total = LevelCatalog.count;
        final SkinDef skin = s.equippedSkin;
        return SpaceBackground(
          colors: NC.homeBg,
          stops: NC.homeStops,
          seed: 5,
          nebula: const <NebulaBlob>[NebulaBlob(0.2, 0.3, 0.6, 0xFF3F51B5), NebulaBlob(0.9, 0.55, 0.6, 0xFFB0297F), NebulaBlob(0.3, 0.85, 0.5, 0xFF512DA8)],
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, bottomPad),
              child: Column(
                children: <Widget>[
                  GlassCard(
                    blur: true,
                    radius: 24,
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: <Color>[Color(0xFF5B6CFF), Color(0xFF9A6CFF)])),
                              child: const Icon(Icons.star_rounded, color: Color(0xFFFFE27A), size: 22),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: _progressBar(total == 0 ? 0 : s.completed.length / total)),
                            const SizedBox(width: 10),
                            const Icon(Icons.favorite_rounded, color: Color(0xFFFF5A7A), size: 26),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${tr('level')} $cur', style: ts(21, weight: FontWeight.w800, spacing: 1.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      CoinPill(amount: s.coins),
                      Flexible(
                        child: GlassCard(
                          radius: 20,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          borderColor: skin.rarity.color.withAlpha(200),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text('${tr('skin')}: ', style: ts(13, weight: FontWeight.w500, color: NC.textDim)),
                              Flexible(child: Text(L10n.lang == 'en' ? skin.nameEn : skin.nameBg, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(13, weight: FontWeight.w800))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: PageView.builder(
                      controller: _pc,
                      itemCount: kWorlds.length,
                      onPageChanged: (int i) => setState(() => _page = i),
                      itemBuilder: (BuildContext context, int i) => _worldCard(i),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      for (int i = 0; i < kWorlds.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _page ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: i == _page ? Colors.white : const Color(0x55FFFFFF)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 78,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        GlowButton(label: tr('playNow'), onTap: () => _play(cur), width: 270, height: 66, fontSize: 23),
                        Positioned(right: 0, bottom: -6, child: IgnorePointer(child: CatSprite(skin: skin, width: 92, glow: false))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).push(fadeRoute<void>(LevelsScreen(initialWorld: _page))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      child: Text('${tr('allLevels')}  •  ${s.unlockedCount}/$total', style: ts(14, weight: FontWeight.w600, color: NC.lavender)),
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

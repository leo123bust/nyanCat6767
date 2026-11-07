import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/skins.dart';
import '../../services/app_state.dart';
import '../../services/audio_service.dart';
import '../painting/cat_painter.dart';
import '../painting/space_painter.dart';
import '../widgets/glass.dart';
import 'shop_tab.dart';

/// "My skins": all skins with owned / locked / equipped status (reference design: 2-column grid).
class CollectionTab extends StatelessWidget {
  const CollectionTab({super.key, required this.onGoShop});

  final VoidCallback onGoShop;

  Widget _card(BuildContext context, SkinDef sk) {
    final AppState s = AppState.instance;
    final bool owned = s.owns(sk.id);
    final bool eq = s.equipped == sk.id;
    Widget button;
    if (eq) {
      button = GlowButton(label: tr('equipped'), onTap: () {}, style: GlowStyle.solid, height: 38, fontSize: 14, width: double.infinity);
    } else if (owned) {
      button = GlowButton(label: tr('select'), onTap: () => s.equip(sk.id), style: GlowStyle.outline, height: 38, fontSize: 14, width: double.infinity);
    } else {
      button = GlowButton(
        label: '${tr('buy')} ${sk.price}',
        onTap: () {
          ShopFocus.request.value = sk.id;
          onGoShop();
        },
        style: GlowStyle.outline,
        height: 38,
        fontSize: 14,
        width: double.infinity,
      );
    }
    return RarityFrame(
      rarity: sk.rarity,
      radius: 24,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[Color(0xFF1D1C60), Color(0xFF0D0C36)])),
        child: Column(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: owned
                    ? null
                    : () {
                        AudioService.instance.sfx('click');
                        ShopFocus.request.value = sk.id;
                        onGoShop();
                      },
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    FittedBox(child: CatSprite(skin: sk, width: 150, dim: !owned, animated: owned)),
                    if (!owned) const Icon(Icons.lock_rounded, color: Colors.white, size: 40),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(skinName(sk), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: ts(14, weight: FontWeight.w700)),
            const SizedBox(height: 4),
            RarityBadge(rarity: sk.rarity, label: tr(sk.rarity.key).toUpperCase()),
            const SizedBox(height: 8),
            button,
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
        return SpaceBackground(
          colors: NC.darkBg,
          stops: NC.darkStops,
          seed: 51,
          nebula: const <NebulaBlob>[NebulaBlob(0.1, 0.3, 0.6, 0xFF2A4C8F), NebulaBlob(0.9, 0.6, 0.6, 0xFFB0297F)],
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                    child: Column(
                      children: <Widget>[
                        Text(tr('mySkins'), style: ts(26, weight: FontWeight.w800, spacing: 1.5)),
                        const SizedBox(height: 6),
                        Text('${tr('owned')}: ${s.owned.length}/${SkinCatalog.all.length}', style: ts(15, weight: FontWeight.w600, color: NC.textDim)),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 14, 16, MediaQuery.paddingOf(context).bottom + 110),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((BuildContext c, int i) => _card(c, SkinCatalog.all[i]), childCount: SkinCatalog.all.length),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.78),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

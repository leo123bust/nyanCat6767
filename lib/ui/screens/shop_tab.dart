import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/skins.dart';
import '../../services/app_state.dart';
import '../../services/audio_service.dart';
import '../painting/cat_painter.dart';
import '../painting/space_painter.dart';
import '../widgets/glass.dart';

/// Lets other tabs ask the shop to focus a skin.
class ShopFocus {
  ShopFocus._();

  static final ValueNotifier<String?> request = ValueNotifier<String?>(null);
}

String skinName(SkinDef s) => L10n.lang == 'en' ? s.nameEn : s.nameBg;

const List<Color> kPanel = <Color>[Color(0xFF1B1A5A), Color(0xFF0C0B33)];

class ShopTab extends StatefulWidget {
  const ShopTab({super.key});

  @override
  State<ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends State<ShopTab> {
  Rarity? _filter;
  String _sel = AppState.instance.equipped;

  @override
  void initState() {
    super.initState();
    ShopFocus.request.addListener(_onFocus);
  }

  @override
  void dispose() {
    ShopFocus.request.removeListener(_onFocus);
    super.dispose();
  }

  void _onFocus() {
    final String? id = ShopFocus.request.value;
    if (id != null) {
      setState(() {
        _sel = id;
        _filter = null;
      });
      ShopFocus.request.value = null;
    }
  }

  void _buy(SkinDef s) {
    final BuyResult r = AppState.instance.buySkin(s);
    if (r == BuyResult.ok) {
      AudioService.instance.sfx('buy');
      showToast(context, tr('bought'));
    } else if (r == BuyResult.notEnough) {
      AudioService.instance.sfx('error');
      showToast(context, tr('notEnough'));
    }
  }

  Widget _chip(String label, Color color, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        AudioService.instance.sfx('click');
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected ? color.withAlpha(70) : const Color(0x14FFFFFF),
          border: Border.all(color: selected ? color : const Color(0x44FFFFFF), width: selected ? 2 : 1.2),
          boxShadow: selected ? <BoxShadow>[BoxShadow(color: color.withAlpha(110), blurRadius: 10)] : null,
        ),
        child: Text(label, style: ts(13, weight: FontWeight.w800, color: selected ? Colors.white : NC.textDim)),
      ),
    );
  }

  Widget _preview(SkinDef sk) {
    final AppState s = AppState.instance;
    final bool owned = s.owns(sk.id);
    final bool eq = s.equipped == sk.id;
    Widget button;
    if (eq) {
      button = GlowButton(label: tr('equipped'), onTap: () {}, style: GlowStyle.solid, height: 50, fontSize: 17, width: double.infinity, icon: Icons.check_rounded);
    } else if (owned) {
      button = GlowButton(
        label: tr('select'),
        onTap: () {
          s.equip(sk.id);
        },
        style: GlowStyle.outline,
        height: 50,
        fontSize: 17,
        width: double.infinity,
      );
    } else {
      button = GlowButton(
        label: '${tr('buy')}  ${sk.price}',
        onTap: () => _buy(sk),
        height: 56,
        fontSize: 18,
        width: double.infinity,
        style: s.coins >= sk.price ? GlowStyle.galaxy : GlowStyle.outline,
      );
    }
    return RarityFrame(
      rarity: sk.rarity,
      radius: 26,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: kPanel)),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text(skinName(sk), style: ts(20, weight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis)),
                RarityBadge(rarity: sk.rarity, label: tr(sk.rarity.key).toUpperCase()),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(height: 142, child: Center(child: CatSprite(skin: sk, width: 250))),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const CoinIcon(size: 24),
                const SizedBox(width: 8),
                Text(sk.isStarter ? tr('starter') : '${sk.price}', style: ts(22, weight: FontWeight.w800)),
                if (owned) ...<Widget>[const SizedBox(width: 10), const Icon(Icons.check_circle_rounded, color: NC.good, size: 22)],
              ],
            ),
            const SizedBox(height: 12),
            button,
          ],
        ),
      ),
    );
  }

  Widget _tile(SkinDef sk) {
    final AppState s = AppState.instance;
    final bool owned = s.owns(sk.id);
    final bool eq = s.equipped == sk.id;
    final bool sel = sk.id == _sel;
    return GestureDetector(
      onTap: () {
        AudioService.instance.sfx('click');
        setState(() => _sel = sk.id);
      },
      child: RarityFrame(
        rarity: sk.rarity,
        radius: 18,
        selected: sel,
        child: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: kPanel)),
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    FittedBox(child: CatSprite(skin: sk, width: 100, trail: false, animated: false, glow: false, dim: !owned)),
                    if (!owned) const Icon(Icons.lock_rounded, color: Color(0xCCFFFFFF), size: 24),
                  ],
                ),
              ),
              Text(skinName(sk), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: ts(11.5, height: 1.1)),
              const SizedBox(height: 4),
              if (owned)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(eq ? Icons.check_circle_rounded : Icons.lock_open_rounded, size: 14, color: eq ? NC.good : NC.lavender),
                    const SizedBox(width: 3),
                    Flexible(child: Text(eq ? tr('equipped') : tr('owned'), maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(10.5, weight: FontWeight.w600, color: NC.textDim))),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[const CoinIcon(size: 15), const SizedBox(width: 4), Text('${sk.price}', style: ts(12.5, weight: FontWeight.w800))],
                ),
            ],
          ),
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
        final List<SkinDef> list = _filter == null ? SkinCatalog.all : SkinCatalog.ofRarity(_filter!);
        final SkinDef selected = SkinCatalog.byId(_sel);
        return SpaceBackground(
          colors: NC.darkBg,
          stops: NC.darkStops,
          seed: 41,
          nebula: const <NebulaBlob>[NebulaBlob(0.9, 0.2, 0.6, 0xFF7C4DFF), NebulaBlob(0.1, 0.6, 0.6, 0xFF2A4C8F), NebulaBlob(0.8, 0.95, 0.5, 0xFFB0297F)],
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text(tr('shopTitle'), style: ts(26, weight: FontWeight.w800, spacing: 1.5))),
                        CoinPill(amount: s.coins),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
                    child: Row(
                      children: <Widget>[
                        _chip(tr('filterAll'), Colors.white, _filter == null, () => setState(() => _filter = null)),
                        for (final Rarity r in Rarity.values) _chip(tr(r.key), r.color, _filter == r, () => setState(() => _filter = r)),
                      ],
                    ),
                  ),
                ),
                SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20), sliver: SliverToBoxAdapter(child: _preview(selected))),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 10),
                    child: Text('${tr('owned')}: ${s.owned.length}/${SkinCatalog.all.length}  •  ${tr('tapToSelect')}', style: ts(13, weight: FontWeight.w500, color: NC.textDim)),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((BuildContext c, int i) => _tile(list[i]), childCount: list.length),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.74),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 110)),
              ],
            ),
          ),
        );
      },
    );
  }
}

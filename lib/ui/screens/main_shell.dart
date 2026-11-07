import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../services/app_state.dart';
import '../../services/audio_service.dart';
import '../widgets/glass.dart';
import 'collection_tab.dart';
import 'home_tab.dart';
import 'settings_tab.dart';
import 'shop_tab.dart';

class _NavItem {
  const _NavItem(this.icon, this.key);

  final IconData icon;
  final String key;
}

const List<_NavItem> _items = <_NavItem>[
  _NavItem(Icons.sports_esports_rounded, 'navLevels'),
  _NavItem(Icons.storefront_rounded, 'navShop'),
  _NavItem(Icons.style_rounded, 'navCollection'),
  _NavItem(Icons.settings_rounded, 'navSettings'),
];

/// Main menu: Home (play), Shop, Collection, Settings with a frosted bottom navigation bar.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    AudioService.instance.playMusic('menu');
  }

  void _go(int i) {
    if (i == _tab) return;
    AudioService.instance.sfx('click');
    setState(() => _tab = i);
  }

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.paddingOf(context).bottom;
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (BuildContext context, Widget? _) {
        return Scaffold(
          body: Stack(
            children: <Widget>[
              Positioned.fill(
                child: IndexedStack(
                  index: _tab,
                  children: <Widget>[
                    const HomeTab(),
                    const ShopTab(),
                    CollectionTab(onGoShop: () => _go(1)),
                    const SettingsTab(),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 10 + bottom,
                child: GlassCard(
                  blur: true,
                  radius: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  fill: const <Color>[Color(0x33FFFFFF), Color(0x1AFFFFFF)],
                  child: Row(
                    children: <Widget>[
                      for (int i = 0; i < _items.length; i++)
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _go(i),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 3,
                                  width: i == _tab ? 34 : 0,
                                  margin: const EdgeInsets.only(bottom: 5),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: Colors.white),
                                ),
                                Icon(_items[i].icon, size: 26, color: i == _tab ? Colors.white : NC.textDim),
                                const SizedBox(height: 2),
                                Text(tr(_items[i].key), style: ts(12, weight: i == _tab ? FontWeight.w800 : FontWeight.w500, color: i == _tab ? Colors.white : NC.textDim)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

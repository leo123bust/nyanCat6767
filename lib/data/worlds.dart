import '../core/l10n.dart';

/// One of the 12 worlds (10 levels each). Colours are 0xAARRGGBB ints.
class WorldDef {
  const WorldDef(this.index, this.nameBg, this.nameEn, this.top, this.bottom, this.accent, this.accent2, this.neb1, this.neb2);

  final int index;
  final String nameBg;
  final String nameEn;
  final int top;
  final int bottom;
  final int accent;
  final int accent2;
  final int neb1;
  final int neb2;

  String get name => L10n.lang == 'en' ? nameEn : nameBg;
  int get firstLevel => index * 10 + 1;
  int get lastLevel => index * 10 + 10;
}

const List<WorldDef> kWorlds = <WorldDef>[
  WorldDef(0, 'Космически старт', 'Space Start', 0xFF0B1245, 0xFF3B1F7A, 0xFF7C5CFF, 0xFFB8A2FF, 0xFF3F51B5, 0xFF9C27B0),
  WorldDef(1, 'Планета на бонбоните', 'Candy Planet', 0xFF2A0B55, 0xFFB3347A, 0xFFFF6EB4, 0xFFFFFFFF, 0xFFFF4081, 0xFF7C4DFF),
  WorldDef(2, 'Светът на космическите понички', 'Space Donut World', 0xFF1A0B4D, 0xFF6B2FA0, 0xFFFF8CC6, 0xFFFFD6A5, 0xFF9C27B0, 0xFFFF4081),
  WorldDef(3, 'Лазерна галактика', 'Laser Galaxy', 0xFF050B30, 0xFF2A1060, 0xFFFF2E93, 0xFF00E5FF, 0xFFFF2E93, 0xFF2979FF),
  WorldDef(4, 'Ледена мъглявина', 'Ice Nebula', 0xFF06274D, 0xFF1C7C9E, 0xFF81D4FA, 0xFFFFFFFF, 0xFF29B6F6, 0xFF7C4DFF),
  WorldDef(5, 'Лава луна', 'Lava Moon', 0xFF2B0A0A, 0xFF9C2A10, 0xFFFF9A3C, 0xFFFFD54F, 0xFFFF5722, 0xFF8E0000),
  WorldDef(6, 'Кристална пещера', 'Crystal Cavern', 0xFF0D1B3A, 0xFF4B2C8C, 0xFF8FFFE0, 0xFFD1A3FF, 0xFF7E57C2, 0xFF1DE9B6),
  WorldDef(7, 'Кибер град', 'Cyber City', 0xFF02051A, 0xFF123B6E, 0xFF00FFC6, 0xFFFF00E6, 0xFF00B0FF, 0xFFD500F9),
  WorldDef(8, 'Сакура орбита', 'Sakura Orbit', 0xFF2B0F3F, 0xFFC85A9A, 0xFFFFC1E3, 0xFFFFFFFF, 0xFFF06292, 0xFFAB47BC),
  WorldDef(9, 'Призрачна станция', 'Ghost Station', 0xFF0C0F1F, 0xFF2D3A5C, 0xFFBFD7FF, 0xFFFFFFFF, 0xFF546E7A, 0xFF3949AB),
  WorldDef(10, 'Хоризонт на събитията', 'Event Horizon', 0xFF000008, 0xFF2A0A4A, 0xFFFFB347, 0xFFFF5E00, 0xFF4A148C, 0xFFFF6D00),
  WorldDef(11, 'Ултра космос', 'Ultra Cosmos', 0xFF120036, 0xFF00316B, 0xFFFF4DFF, 0xFF4DFFFF, 0xFFFF00C8, 0xFF00E5FF),
];

WorldDef worldOfLevel(int level) {
  int i = (level - 1) ~/ 10;
  if (i < 0) i = 0;
  if (i >= kWorlds.length) i = kWorlds.length - 1;
  return kWorlds[i];
}

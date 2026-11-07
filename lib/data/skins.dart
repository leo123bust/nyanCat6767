// Cat skins catalogue (32 skins, 7 rarities). Entries are generated from tools/gen_dart_data.py.
import 'package:flutter/material.dart';

enum Rarity { common, rare, epic, mythic, legendary, chromatic, ultra }

enum Accessory { none, partyHat, crown, halo, visor, horns, flame, flower, headphones, wings, antenna, bow, crystal }

enum Fx { none, sparkle, snow, petal, bubble, flame, glitch, electric, stars, smoke, rainbow, orbit }

const List<int> _rarityColors = <int>[0xFFB0BEC5, 0xFF4FC3F7, 0xFFB388FF, 0xFFFF4D8D, 0xFFFFC107, 0xFF00E5FF, 0xFFFF00C8];
const List<double> _rarityGlow = <double>[0.0, 0.25, 0.4, 0.55, 0.7, 0.85, 1.0];

extension RarityInfo on Rarity {
  /// Localisation key of the rarity name.
  String get key => 'r_$name';
  Color get color => Color(_rarityColors[index]);
  double get glow => _rarityGlow[index];

  /// Chromatic and Ultra frames are animated (colour sweep).
  bool get animated => this == Rarity.chromatic || this == Rarity.ultra;

  List<Color> get sweep {
    if (this == Rarity.chromatic) {
      return const <Color>[Color(0xFF00E5FF), Color(0xFFB388FF), Color(0xFFFF4D8D), Color(0xFFFFD54F), Color(0xFF00E5FF)];
    }
    return const <Color>[Color(0xFFFF0000), Color(0xFFFFFF00), Color(0xFF00FF00), Color(0xFF00FFFF), Color(0xFF0000FF), Color(0xFFFF00FF), Color(0xFFFF0000)];
  }
}

class SkinDef {
  const SkinDef({
    required this.id,
    required this.nameEn,
    required this.nameBg,
    required this.rarity,
    required this.price,
    required this.outline,
    required this.crust,
    required this.frost,
    required this.sprinkle,
    required this.accentZ,
    required this.accentY,
    required this.fur,
    required this.cheek,
    required this.eye,
    required this.eyeHi,
    required this.trail,
    required this.acc,
    required this.accA,
    required this.accB,
    required this.accC,
    required this.fx,
    required this.fxColors,
    required this.aura,
    required this.hue,
    required this.hueSpeed,
    required this.ghost,
  });

  final String id;
  final String nameEn;
  final String nameBg;
  final Rarity rarity;
  final int price;
  final int outline;
  final int crust;
  final int frost;
  final int sprinkle;
  final int accentZ;
  final int accentY;
  final int fur;
  final int cheek;
  final int eye;
  final int eyeHi;
  final List<int> trail;
  final Accessory acc;
  final int accA;
  final int accB;
  final int accC;
  final Fx fx;
  final List<int> fxColors;
  final int aura;

  /// Colours slowly cycle through the rainbow (Chromatic / Ultra).
  final bool hue;
  final double hueSpeed;

  /// Semi-transparent, floaty look.
  final bool ghost;

  bool get isStarter => id == SkinCatalog.starterId;
}

class SkinCatalog {
  SkinCatalog._();

  static const String starterId = 'classic';

  static const List<SkinDef> all = <SkinDef>[
  SkinDef(id: 'classic', nameEn: 'Classic Nyan Cat', nameBg: 'Класически Нян', rarity: Rarity.common, price: 100,
      outline: 0xFF000000, crust: 0xFFFFCC99, frost: 0xFFFF99FF, sprinkle: 0xFFFF3399, accentZ: 0xFFFF99FF, accentY: 0xFFFF99FF, fur: 0xFF999999, cheek: 0xFFFF9999, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFFF0000, 0xFFFF9900, 0xFFFFFF00, 0xFF33FF00, 0xFF0099FF, 0xFF6633FF], acc: Accessory.none, accA: 0xFFFFD700, accB: 0xFFFF1744, accC: 0xFFFFFFFF,
      fx: Fx.none, fxColors: <int>[0xFFFFFFFF, 0xFFFFEB3B], aura: 0xFFFF99FF, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'pixel', nameEn: 'Pixel Cat', nameBg: 'Пиксел Нян', rarity: Rarity.common, price: 150,
      outline: 0xFF1B1B1B, crust: 0xFFC8A165, frost: 0xFF8BC34A, sprinkle: 0xFF33691E, accentZ: 0xFFAED581, accentY: 0xFF8BC34A, fur: 0xFFBDBDBD, cheek: 0xFFE57373, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFE53935, 0xFFFB8C00, 0xFFFDD835, 0xFF43A047, 0xFF1E88E5, 0xFF8E24AA], acc: Accessory.none, accA: 0xFFFFD700, accB: 0xFFFF1744, accC: 0xFFFFFFFF,
      fx: Fx.none, fxColors: <int>[0xFFFFFFFF, 0xFFFFEB3B], aura: 0xFF8BC34A, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'party', nameEn: 'Party Nyan', nameBg: 'Парти Нян', rarity: Rarity.common, price: 200,
      outline: 0xFF000000, crust: 0xFFFFCC99, frost: 0xFFFF80AB, sprinkle: 0xFF00E5FF, accentZ: 0xFFFFEB3B, accentY: 0xFFFF80AB, fur: 0xFF999999, cheek: 0xFFFF9999, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFFF4081, 0xFFFFB300, 0xFFFFEE58, 0xFF66BB6A, 0xFF29B6F6, 0xFFAB47BC], acc: Accessory.partyHat, accA: 0xFF7C4DFF, accB: 0xFFFFEB3B, accC: 0xFFFF4081,
      fx: Fx.none, fxColors: <int>[0xFFFFFFFF, 0xFFFFEB3B], aura: 0xFFFF80AB, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'mint', nameEn: 'Mint Cat', nameBg: 'Мента Нян', rarity: Rarity.common, price: 250,
      outline: 0xFF000000, crust: 0xFFE0F2F1, frost: 0xFFA7FFEB, sprinkle: 0xFF00BFA5, accentZ: 0xFFFFFFFF, accentY: 0xFFA7FFEB, fur: 0xFFB0BEC5, cheek: 0xFFFF8A80, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFB2FF59, 0xFF69F0AE, 0xFF64FFDA, 0xFF18FFFF, 0xFF40C4FF, 0xFF448AFF], acc: Accessory.none, accA: 0xFFFFD700, accB: 0xFFFF1744, accC: 0xFFFFFFFF,
      fx: Fx.none, fxColors: <int>[0xFFFFFFFF, 0xFFFFEB3B], aura: 0xFF64FFDA, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'toast', nameEn: 'Toast Cat', nameBg: 'Препечен Нян', rarity: Rarity.common, price: 300,
      outline: 0xFF2B1B10, crust: 0xFFA1662F, frost: 0xFFFFE0B2, sprinkle: 0xFF8D5524, accentZ: 0xFFFFF3E0, accentY: 0xFFFFE0B2, fur: 0xFFA1887F, cheek: 0xFFFFAB91, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFFFE082, 0xFFFFCA28, 0xFFFFA726, 0xFFFF7043, 0xFF8D6E63, 0xFF5D4037], acc: Accessory.none, accA: 0xFFFFD700, accB: 0xFFFF1744, accC: 0xFFFFFFFF,
      fx: Fx.none, fxColors: <int>[0xFFFFFFFF, 0xFFFFEB3B], aura: 0xFFFFCA28, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'ice', nameEn: 'Ice Cat', nameBg: 'Леден Нян', rarity: Rarity.rare, price: 350,
      outline: 0xFF0D47A1, crust: 0xFFE1F5FE, frost: 0xFFB3E5FC, sprinkle: 0xFF0288D1, accentZ: 0xFFFFFFFF, accentY: 0xFFE1F5FE, fur: 0xFFCFD8DC, cheek: 0xFF90CAF9, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFE1F5FE, 0xFFB3E5FC, 0xFF81D4FA, 0xFF4FC3F7, 0xFF29B6F6, 0xFF0288D1], acc: Accessory.none, accA: 0xFFFFD700, accB: 0xFFFF1744, accC: 0xFFFFFFFF,
      fx: Fx.snow, fxColors: <int>[0xFFFFFFFF, 0xFFB3E5FC], aura: 0xFF81D4FA, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'neon', nameEn: 'Neon Cat', nameBg: 'Неонов Нян', rarity: Rarity.rare, price: 450,
      outline: 0xFF00E5FF, crust: 0xFF1A1A2E, frost: 0xFF12122A, sprinkle: 0xFFFF00E6, accentZ: 0xFF00E5FF, accentY: 0xFF12122A, fur: 0xFF2D2D44, cheek: 0xFFFF00E6, eye: 0xFF00E5FF, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFFF00E6, 0xFFFF2E63, 0xFFFFEA00, 0xFF00FF9C, 0xFF00E5FF, 0xFF7C4DFF], acc: Accessory.headphones, accA: 0xFFFF00E6, accB: 0xFF00E5FF, accC: 0xFFFFFFFF,
      fx: Fx.sparkle, fxColors: <int>[0xFF00E5FF, 0xFFFF00E6], aura: 0xFFFF00E6, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'sakura', nameEn: 'Sakura Cat', nameBg: 'Сакура Нян', rarity: Rarity.rare, price: 500,
      outline: 0xFF5D2A42, crust: 0xFFFCE4EC, frost: 0xFFF8BBD0, sprinkle: 0xFFE91E63, accentZ: 0xFFFFFFFF, accentY: 0xFFF8BBD0, fur: 0xFFD7CCC8, cheek: 0xFFF48FB1, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFFFCDD2, 0xFFF8BBD0, 0xFFF48FB1, 0xFFF06292, 0xFFEC407A, 0xFFD81B60], acc: Accessory.flower, accA: 0xFFF48FB1, accB: 0xFFF06292, accC: 0xFFFFEB3B,
      fx: Fx.petal, fxColors: <int>[0xFFF8BBD0, 0xFFF48FB1], aura: 0xFFF48FB1, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'ocean', nameEn: 'Ocean Cat', nameBg: 'Океански Нян', rarity: Rarity.rare, price: 600,
      outline: 0xFF01343C, crust: 0xFFB2EBF2, frost: 0xFF4DD0E1, sprinkle: 0xFF006064, accentZ: 0xFFE0F7FA, accentY: 0xFF4DD0E1, fur: 0xFF90A4AE, cheek: 0xFF80DEEA, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFB2EBF2, 0xFF80DEEA, 0xFF4DD0E1, 0xFF26C6DA, 0xFF00ACC1, 0xFF0277BD], acc: Accessory.none, accA: 0xFFFFD700, accB: 0xFFFF1744, accC: 0xFFFFFFFF,
      fx: Fx.bubble, fxColors: <int>[0xFFE0F7FA, 0xFF80DEEA], aura: 0xFF26C6DA, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'candy', nameEn: 'Candy Cat', nameBg: 'Бонбонен Нян', rarity: Rarity.rare, price: 700,
      outline: 0xFF4A1A5E, crust: 0xFFFFF59D, frost: 0xFFFF80AB, sprinkle: 0xFF7C4DFF, accentZ: 0xFFFFFFFF, accentY: 0xFFFFC1E3, fur: 0xFFCE93D8, cheek: 0xFFFF5252, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFFF5252, 0xFFFFFFFF, 0xFFFF4081, 0xFFFFFFFF, 0xFF7C4DFF, 0xFFFFFFFF], acc: Accessory.bow, accA: 0xFFFF4081, accB: 0xFFFFFFFF, accC: 0xFFFFEB3B,
      fx: Fx.sparkle, fxColors: <int>[0xFFFF80AB, 0xFFFFFFFF], aura: 0xFFFF80AB, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'fire', nameEn: 'Fire Cat', nameBg: 'Огнен Нян', rarity: Rarity.epic, price: 800,
      outline: 0xFF3E0A00, crust: 0xFFBF360C, frost: 0xFFFF7043, sprinkle: 0xFFFFEB3B, accentZ: 0xFFFFAB40, accentY: 0xFFFFCC80, fur: 0xFF6D4C41, cheek: 0xFFFF8A65, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFFFEB3B, 0xFFFFC107, 0xFFFF9800, 0xFFFF5722, 0xFFE53935, 0xFFB71C1C], acc: Accessory.flame, accA: 0xFFFF5722, accB: 0xFFFFC107, accC: 0xFFFFEB3B,
      fx: Fx.flame, fxColors: <int>[0xFFFF5722, 0xFFFFC107], aura: 0xFFFF5722, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'cyber', nameEn: 'Cyber Cat', nameBg: 'Кибер Нян', rarity: Rarity.epic, price: 900,
      outline: 0xFF0B1118, crust: 0xFF546E7A, frost: 0xFF263238, sprinkle: 0xFF00E676, accentZ: 0xFF00B0FF, accentY: 0xFF76FF03, fur: 0xFF90A4AE, cheek: 0xFF00E676, eye: 0xFF00E5FF, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFF00E676, 0xFF00E5FF, 0xFF2979FF, 0xFF651FFF, 0xFFD500F9, 0xFFFF1744], acc: Accessory.visor, accA: 0xFF00E5FF, accB: 0xFF1A237E, accC: 0xFFFFFFFF,
      fx: Fx.glitch, fxColors: <int>[0xFF00E5FF, 0xFF00E676, 0xFFFF1744], aura: 0xFF00E5FF, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'electric', nameEn: 'Electric Cat', nameBg: 'Електрик Нян', rarity: Rarity.epic, price: 1000,
      outline: 0xFF3E2723, crust: 0xFFF9A825, frost: 0xFFFFEE58, sprinkle: 0xFFF57F17, accentZ: 0xFFFFFFFF, accentY: 0xFFFFFDE7, fur: 0xFFFFD54F, cheek: 0xFFFF5252, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFFFFFFF, 0xFFFFF59D, 0xFFFFEE58, 0xFFFFD600, 0xFFFFAB00, 0xFFFF6F00], acc: Accessory.antenna, accA: 0xFFFFEB3B, accB: 0xFFFF6F00, accC: 0xFFFFFFFF,
      fx: Fx.electric, fxColors: <int>[0xFFFFFFFF, 0xFFFFEB3B, 0xFF80D8FF], aura: 0xFFFFEB3B, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'galaxy', nameEn: 'Galaxy Cat', nameBg: 'Галактичен Нян', rarity: Rarity.epic, price: 1100,
      outline: 0xFF0D0033, crust: 0xFF7E57C2, frost: 0xFF311B92, sprinkle: 0xFFFFFFFF, accentZ: 0xFF80D8FF, accentY: 0xFFEA80FC, fur: 0xFF455A64, cheek: 0xFFB388FF, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFF50057, 0xFFD500F9, 0xFF651FFF, 0xFF3D5AFE, 0xFF00B0FF, 0xFF00E5FF], acc: Accessory.none, accA: 0xFFFFD700, accB: 0xFFFF1744, accC: 0xFFFFFFFF,
      fx: Fx.stars, fxColors: <int>[0xFFFFFFFF, 0xFF80D8FF, 0xFFEA80FC], aura: 0xFF7C4DFF, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'shadow', nameEn: 'Shadow Cat', nameBg: 'Сенчест Нян', rarity: Rarity.epic, price: 1200,
      outline: 0xFF7C4DFF, crust: 0xFF424242, frost: 0xFF212121, sprinkle: 0xFF9C27B0, accentZ: 0xFF6A1B9A, accentY: 0xFF311B92, fur: 0xFF1A1A1A, cheek: 0xFF4A148C, eye: 0xFFE040FB, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFF000000, 0xFF1A1A1A, 0xFF311B92, 0xFF4A148C, 0xFF6A1B9A, 0xFFAA00FF], acc: Accessory.horns, accA: 0xFF7B1FA2, accB: 0xFFCE93D8, accC: 0xFFFFFFFF,
      fx: Fx.smoke, fxColors: <int>[0xFF6A1B9A, 0xFF311B92], aura: 0xFF6A1B9A, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'lava', nameEn: 'Lava Cat', nameBg: 'Лава Нян', rarity: Rarity.mythic, price: 1300,
      outline: 0xFF1A0000, crust: 0xFFBF360C, frost: 0xFF2B2B2B, sprinkle: 0xFFFF3D00, accentZ: 0xFFFFAB00, accentY: 0xFFFF6D00, fur: 0xFF3E2723, cheek: 0xFFFF6E40, eye: 0xFFFFEA00, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFFFFF00, 0xFFFFC400, 0xFFFF9100, 0xFFFF3D00, 0xFFDD2C00, 0xFF7F0000], acc: Accessory.horns, accA: 0xFFFF3D00, accB: 0xFFFFAB00, accC: 0xFFFFFF00,
      fx: Fx.flame, fxColors: <int>[0xFFFF3D00, 0xFFFFAB00, 0xFFFFFF00], aura: 0xFFFF3D00, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'crystal', nameEn: 'Crystal Cat', nameBg: 'Кристален Нян', rarity: Rarity.mythic, price: 1500,
      outline: 0xFF4527A0, crust: 0xFF7E57C2, frost: 0xFFCE93D8, sprinkle: 0xFFFFFFFF, accentZ: 0xFFE1BEE7, accentY: 0xFFFFFFFF, fur: 0xFFB0BEC5, cheek: 0xFFF8BBD0, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFF3E5F5, 0xFFE1BEE7, 0xFFCE93D8, 0xFFBA68C8, 0xFF9575CD, 0xFF7986CB], acc: Accessory.none, accA: 0xFFFFD700, accB: 0xFFFF1744, accC: 0xFFFFFFFF,
      fx: Fx.sparkle, fxColors: <int>[0xFFFFFFFF, 0xFFE1BEE7, 0xFFB388FF], aura: 0xFFB388FF, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'ghost', nameEn: 'Ghost Cat', nameBg: 'Призрачен Нян', rarity: Rarity.mythic, price: 1700,
      outline: 0xFF78909C, crust: 0xFFBBDEFB, frost: 0xFFE3F2FD, sprinkle: 0xFF90CAF9, accentZ: 0xFFFFFFFF, accentY: 0xFFE3F2FD, fur: 0xFFECEFF1, cheek: 0xFFB3E5FC, eye: 0xFF1A237E, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFFFFFFF, 0xFFE3F2FD, 0xFFBBDEFB, 0xFF90CAF9, 0xFF64B5F6, 0xFF42A5F5], acc: Accessory.halo, accA: 0xFFE1F5FE, accB: 0xFFB3E5FC, accC: 0xFFFFFFFF,
      fx: Fx.smoke, fxColors: <int>[0xFFE3F2FD, 0xFFFFFFFF], aura: 0xFF90CAF9, hue: false, hueSpeed: 0, ghost: true),
  SkinDef(id: 'cosmic', nameEn: 'Cosmic Cat', nameBg: 'Космически Нян', rarity: Rarity.mythic, price: 1850,
      outline: 0xFF0A0F40, crust: 0xFF3949AB, frost: 0xFF1A237E, sprinkle: 0xFFFFD740, accentZ: 0xFFFFFFFF, accentY: 0xFFFF80AB, fur: 0xFF5C6BC0, cheek: 0xFFFF80AB, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFFF80AB, 0xFFFFD740, 0xFF69F0AE, 0xFF40C4FF, 0xFFB388FF, 0xFFFF8A80], acc: Accessory.none, accA: 0xFFFFD700, accB: 0xFFFF1744, accC: 0xFFFFFFFF,
      fx: Fx.orbit, fxColors: <int>[0xFFFFD740, 0xFFFFFFFF, 0xFFFF80AB], aura: 0xFF536DFE, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'royal', nameEn: 'Royal Cat', nameBg: 'Кралски Нян', rarity: Rarity.mythic, price: 2000,
      outline: 0xFF311B92, crust: 0xFFFFD700, frost: 0xFF7B1FA2, sprinkle: 0xFFFFD700, accentZ: 0xFFE040FB, accentY: 0xFFCE93D8, fur: 0xFFE0E0E0, cheek: 0xFFF48FB1, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFFFF176, 0xFFFFD54F, 0xFFFFB300, 0xFFAB47BC, 0xFF8E24AA, 0xFF6A1B9A], acc: Accessory.crown, accA: 0xFFFFD700, accB: 0xFFFF1744, accC: 0xFFFFFFFF,
      fx: Fx.sparkle, fxColors: <int>[0xFFFFD700, 0xFFFFFFFF], aura: 0xFFFFD700, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'golden', nameEn: 'Golden Cat', nameBg: 'Златен Нян', rarity: Rarity.legendary, price: 2200,
      outline: 0xFF4E342E, crust: 0xFFFFB300, frost: 0xFFFFD54F, sprinkle: 0xFFFF6F00, accentZ: 0xFFFFF59D, accentY: 0xFFFFFFFF, fur: 0xFFFFC107, cheek: 0xFFFF8F00, eye: 0xFF3E2723, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFFFFDE7, 0xFFFFF59D, 0xFFFFEE58, 0xFFFFD54F, 0xFFFFC107, 0xFFFF8F00], acc: Accessory.halo, accA: 0xFFFFD54F, accB: 0xFFFFB300, accC: 0xFFFFFFFF,
      fx: Fx.sparkle, fxColors: <int>[0xFFFFD54F, 0xFFFFFFFF], aura: 0xFFFFC107, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'galaxygold', nameEn: 'Galaxy Gold Nyan', nameBg: 'Галактичен Златен Нян', rarity: Rarity.legendary, price: 2500,
      outline: 0xFF3E2723, crust: 0xFFFFE082, frost: 0xFFFFB300, sprinkle: 0xFFFF6F00, accentZ: 0xFFFFFFFF, accentY: 0xFFFFF8E1, fur: 0xFFFFCA28, cheek: 0xFFFF8F00, eye: 0xFF3E2723, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFFFF8E1, 0xFFFFECB3, 0xFFFFE082, 0xFFFFD54F, 0xFFFFB300, 0xFFFF8F00], acc: Accessory.wings, accA: 0xFFFFE082, accB: 0xFFFFC107, accC: 0xFFFFFFFF,
      fx: Fx.stars, fxColors: <int>[0xFFFFFFFF, 0xFFFFE082], aura: 0xFFFFC107, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'diamond', nameEn: 'Diamond Cat', nameBg: 'Диамантен Нян', rarity: Rarity.legendary, price: 2700,
      outline: 0xFF006064, crust: 0xFF80DEEA, frost: 0xFFE0F7FA, sprinkle: 0xFF00B8D4, accentZ: 0xFFB2EBF2, accentY: 0xFFFFFFFF, fur: 0xFFECEFF1, cheek: 0xFFB3E5FC, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFFFFFFF, 0xFFE0F7FA, 0xFFB2EBF2, 0xFF80DEEA, 0xFF4DD0E1, 0xFF00BCD4], acc: Accessory.crystal, accA: 0xFFB2EBF2, accB: 0xFF80DEEA, accC: 0xFFFFFFFF,
      fx: Fx.sparkle, fxColors: <int>[0xFFFFFFFF, 0xFFB2EBF2], aura: 0xFF80DEEA, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'phoenix', nameEn: 'Phoenix Cat', nameBg: 'Феникс Нян', rarity: Rarity.legendary, price: 3000,
      outline: 0xFF4A0E0E, crust: 0xFFFFD600, frost: 0xFFFF6D00, sprinkle: 0xFFD50000, accentZ: 0xFFFF9100, accentY: 0xFFFFEA00, fur: 0xFFFF8A65, cheek: 0xFFFFD600, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFFFFF8D, 0xFFFFEA00, 0xFFFFAB00, 0xFFFF6D00, 0xFFDD2C00, 0xFFB71C1C], acc: Accessory.wings, accA: 0xFFFF6D00, accB: 0xFFFFD600, accC: 0xFFFFFFFF,
      fx: Fx.flame, fxColors: <int>[0xFFFF6D00, 0xFFFFD600, 0xFFFFFF8D], aura: 0xFFFF6D00, hue: false, hueSpeed: 0, ghost: false),
  SkinDef(id: 'prism', nameEn: 'Prism Cat', nameBg: 'Призма Нян', rarity: Rarity.chromatic, price: 3200,
      outline: 0xFF20204A, crust: 0xFFFFE082, frost: 0xFFFF80AB, sprinkle: 0xFFFFFFFF, accentZ: 0xFF80D8FF, accentY: 0xFFFFFFFF, fur: 0xFFB0BEC5, cheek: 0xFFFFFFFF, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFFF0000, 0xFFFF9900, 0xFFFFFF00, 0xFF33FF00, 0xFF0099FF, 0xFF6633FF], acc: Accessory.crystal, accA: 0xFFFF80AB, accB: 0xFF80D8FF, accC: 0xFFFFFFFF,
      fx: Fx.sparkle, fxColors: <int>[0xFFFFFFFF, 0xFFFF80AB, 0xFF80D8FF], aura: 0xFFFF80AB, hue: true, hueSpeed: 45, ghost: false),
  SkinDef(id: 'rainbow', nameEn: 'Rainbow Nyan Cat', nameBg: 'Дъгов Нян', rarity: Rarity.chromatic, price: 3400,
      outline: 0xFF000000, crust: 0xFFFFCC99, frost: 0xFFFF99FF, sprinkle: 0xFFFF3399, accentZ: 0xFFFF99FF, accentY: 0xFFFF99FF, fur: 0xFF999999, cheek: 0xFFFF9999, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFFF0000, 0xFFFF9900, 0xFFFFFF00, 0xFF33FF00, 0xFF0099FF, 0xFF6633FF], acc: Accessory.none, accA: 0xFFFFD700, accB: 0xFFFF1744, accC: 0xFFFFFFFF,
      fx: Fx.rainbow, fxColors: <int>[0xFFFF0000, 0xFFFFFF00, 0xFF00FF00, 0xFF00BFFF], aura: 0xFFFF99FF, hue: true, hueSpeed: 60, ghost: false),
  SkinDef(id: 'rainbowgalaxy', nameEn: 'Rainbow Galaxy Cat', nameBg: 'Дъгова Галактика Нян', rarity: Rarity.chromatic, price: 3700,
      outline: 0xFF0D0033, crust: 0xFF7E57C2, frost: 0xFF311B92, sprinkle: 0xFFFFFFFF, accentZ: 0xFF80D8FF, accentY: 0xFFEA80FC, fur: 0xFF455A64, cheek: 0xFFB388FF, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFF50057, 0xFFD500F9, 0xFF651FFF, 0xFF3D5AFE, 0xFF00B0FF, 0xFF00E5FF], acc: Accessory.none, accA: 0xFFFFD700, accB: 0xFFFF1744, accC: 0xFFFFFFFF,
      fx: Fx.orbit, fxColors: <int>[0xFFFFFFFF, 0xFFFFD740, 0xFF80D8FF], aura: 0xFF7C4DFF, hue: true, hueSpeed: 50, ghost: false),
  SkinDef(id: 'aurora', nameEn: 'Aurora Cat', nameBg: 'Аврора Нян', rarity: Rarity.chromatic, price: 4000,
      outline: 0xFF06251F, crust: 0xFFB9F6CA, frost: 0xFF1DE9B6, sprinkle: 0xFFFFFFFF, accentZ: 0xFFB388FF, accentY: 0xFF84FFFF, fur: 0xFFCFD8DC, cheek: 0xFFEA80FC, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFB9F6CA, 0xFF69F0AE, 0xFF1DE9B6, 0xFF18FFFF, 0xFF40C4FF, 0xFFB388FF], acc: Accessory.halo, accA: 0xFF84FFFF, accB: 0xFFB388FF, accC: 0xFFFFFFFF,
      fx: Fx.sparkle, fxColors: <int>[0xFF84FFFF, 0xFFB388FF, 0xFFFFFFFF], aura: 0xFF1DE9B6, hue: true, hueSpeed: 28, ghost: false),
  SkinDef(id: 'ultra', nameEn: 'Ultra Nyan Cat', nameBg: 'Ултра Нян', rarity: Rarity.ultra, price: 4500,
      outline: 0xFF1A0033, crust: 0xFFFFD700, frost: 0xFFFF00C8, sprinkle: 0xFFFFFFFF, accentZ: 0xFF00E5FF, accentY: 0xFFFFEA00, fur: 0xFFE0E0E0, cheek: 0xFFFF4081, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFFF0000, 0xFFFF9900, 0xFFFFFF00, 0xFF33FF00, 0xFF0099FF, 0xFF6633FF], acc: Accessory.crown, accA: 0xFFFFD700, accB: 0xFFFF1744, accC: 0xFFFFFFFF,
      fx: Fx.rainbow, fxColors: <int>[0xFFFF0000, 0xFFFFFF00, 0xFF00FF00, 0xFF00BFFF, 0xFFFF00FF], aura: 0xFFFF00C8, hue: true, hueSpeed: 90, ghost: false),
  SkinDef(id: 'omega', nameEn: 'Omega Cat', nameBg: 'Омега Нян', rarity: Rarity.ultra, price: 4600,
      outline: 0xFFFFFFFF, crust: 0xFF9E9E9E, frost: 0xFF0A0A0A, sprinkle: 0xFFFFFFFF, accentZ: 0xFFFFFFFF, accentY: 0xFF616161, fur: 0xFF212121, cheek: 0xFFE0E0E0, eye: 0xFFFFFFFF, eyeHi: 0xFFFF1744,
      trail: <int>[0xFFFFFFFF, 0xFFE0E0E0, 0xFF9E9E9E, 0xFF616161, 0xFF424242, 0xFF212121], acc: Accessory.halo, accA: 0xFFFFFFFF, accB: 0xFFE0E0E0, accC: 0xFFFFFFFF,
      fx: Fx.orbit, fxColors: <int>[0xFFFFFFFF, 0xFFB0BEC5], aura: 0xFFFF1744, hue: true, hueSpeed: 70, ghost: false),
  SkinDef(id: 'quantum', nameEn: 'Quantum Cat', nameBg: 'Квантов Нян', rarity: Rarity.ultra, price: 4800,
      outline: 0xFF001F2B, crust: 0xFF00B8D4, frost: 0xFF1A0033, sprinkle: 0xFF00E5FF, accentZ: 0xFFFF00E6, accentY: 0xFF00E5FF, fur: 0xFF37474F, cheek: 0xFFFF00E6, eye: 0xFF00E5FF, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFF00E5FF, 0xFF18FFFF, 0xFFFF00E6, 0xFFD500F9, 0xFF651FFF, 0xFF2979FF], acc: Accessory.visor, accA: 0xFF00E5FF, accB: 0xFF1A0033, accC: 0xFFFFFFFF,
      fx: Fx.glitch, fxColors: <int>[0xFF00E5FF, 0xFFFF00E6, 0xFFFFFFFF], aura: 0xFF00E5FF, hue: true, hueSpeed: 80, ghost: false),
  SkinDef(id: 'infinity', nameEn: 'Infinity Cat', nameBg: 'Безкраен Нян', rarity: Rarity.ultra, price: 5000,
      outline: 0xFF12003A, crust: 0xFFFFFFFF, frost: 0xFF7C4DFF, sprinkle: 0xFFFFFFFF, accentZ: 0xFFFF80AB, accentY: 0xFF80D8FF, fur: 0xFFECEFF1, cheek: 0xFFFF80AB, eye: 0xFF000000, eyeHi: 0xFFFFFFFF,
      trail: <int>[0xFFFF0000, 0xFFFF9900, 0xFFFFFF00, 0xFF33FF00, 0xFF0099FF, 0xFF6633FF], acc: Accessory.wings, accA: 0xFFFFFFFF, accB: 0xFFB388FF, accC: 0xFFFFD740,
      fx: Fx.stars, fxColors: <int>[0xFFFFFFFF, 0xFFFFD740, 0xFFFF80AB, 0xFF80D8FF], aura: 0xFFB388FF, hue: true, hueSpeed: 100, ghost: false),
  ];

  static SkinDef byId(String id) {
    for (final SkinDef s in all) {
      if (s.id == id) return s;
    }
    return all.first;
  }

  static List<SkinDef> ofRarity(Rarity r) => all.where((SkinDef s) => s.rarity == r).toList();
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/l10n.dart';
import '../data/levels.dart';
import '../data/skins.dart';
import 'audio_service.dart';

enum BuyResult { ok, notEnough, alreadyOwned }

/// All persistent player data + the coin economy. Saved as one JSON string (atomic write).
class AppState extends ChangeNotifier {
  AppState._();

  static final AppState instance = AppState._();

  /// Every level pays exactly this many coins, once.
  static const int levelReward = 300;
  static const String _saveKey = 'nyancat6767_save_v1';

  int coins = 0;
  final Set<int> completed = <int>{};
  final Set<int> rewarded = <int>{};
  final Map<int, int> stars = <int, int>{};
  final Map<int, int> bestScore = <int, int>{};
  final Set<String> owned = <String>{SkinCatalog.starterId};
  String equipped = SkinCatalog.starterId;

  bool musicOn = true;
  bool sfxOn = true;
  double musicVol = 0.6;
  double sfxVol = 0.9;
  String lang = 'bg';

  SharedPreferences? _prefs;

  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final String? raw = _prefs!.getString(_saveKey);
      if (raw != null) {
        _apply(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {
      // Corrupt or missing save: start fresh.
    }
    L10n.lang = lang;
  }

  List<int> _intList(dynamic v) {
    final List<int> out = <int>[];
    if (v is List<dynamic>) {
      for (final dynamic e in v) {
        if (e is num) out.add(e.toInt());
      }
    }
    return out;
  }

  Map<int, int> _intMap(dynamic v) {
    final Map<int, int> out = <int, int>{};
    if (v is Map<String, dynamic>) {
      v.forEach((String k, dynamic val) {
        final int? key = int.tryParse(k);
        if (key != null && val is num) out[key] = val.toInt();
      });
    }
    return out;
  }

  void _apply(Map<String, dynamic> m) {
    coins = (m['coins'] as num?)?.toInt() ?? 0;
    completed
      ..clear()
      ..addAll(_intList(m['completed']));
    rewarded
      ..clear()
      ..addAll(_intList(m['rewarded']));
    stars
      ..clear()
      ..addAll(_intMap(m['stars']));
    bestScore
      ..clear()
      ..addAll(_intMap(m['best']));
    owned.clear();
    final dynamic o = m['owned'];
    if (o is List<dynamic>) {
      for (final dynamic e in o) {
        if (e is String) owned.add(e);
      }
    }
    owned.add(SkinCatalog.starterId);
    final String? eq = m['equipped'] as String?;
    equipped = (eq != null && owned.contains(eq)) ? eq : SkinCatalog.starterId;
    musicOn = (m['musicOn'] as bool?) ?? true;
    sfxOn = (m['sfxOn'] as bool?) ?? true;
    musicVol = ((m['musicVol'] as num?) ?? 0.6).toDouble();
    sfxVol = ((m['sfxVol'] as num?) ?? 0.9).toDouble();
    lang = (m['lang'] as String?) == 'en' ? 'en' : 'bg';
  }

  Future<void> save() async {
    final Map<String, dynamic> m = <String, dynamic>{
      'coins': coins,
      'completed': completed.toList(),
      'rewarded': rewarded.toList(),
      'stars': stars.map((int k, int v) => MapEntry<String, int>(k.toString(), v)),
      'best': bestScore.map((int k, int v) => MapEntry<String, int>(k.toString(), v)),
      'owned': owned.toList(),
      'equipped': equipped,
      'musicOn': musicOn,
      'sfxOn': sfxOn,
      'musicVol': musicVol,
      'sfxVol': sfxVol,
      'lang': lang,
    };
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setString(_saveKey, jsonEncode(m));
    } catch (_) {}
  }

  // ---------------------------------------------------------------- levels

  bool isCompleted(int level) => completed.contains(level);

  bool isUnlocked(int level) => level <= 1 || completed.contains(level - 1);

  /// First level that is not completed yet (the one the Play button starts).
  int get currentLevel {
    final int n = LevelCatalog.count;
    for (int i = 1; i <= n; i++) {
      if (!completed.contains(i)) return i;
    }
    return n < 1 ? 1 : n;
  }

  int get unlockedCount {
    final int n = LevelCatalog.count;
    int c = 0;
    for (int i = 1; i <= n; i++) {
      if (isUnlocked(i)) c = i;
    }
    return c;
  }

  /// Marks the level as completed. Returns the coins granted: exactly [levelReward] the first
  /// time, 0 for repeated completions (duplicate rewards are impossible).
  int completeLevel(int level, int score, int starCount) {
    int granted = 0;
    if (!rewarded.contains(level)) {
      rewarded.add(level);
      coins += levelReward;
      granted = levelReward;
    }
    completed.add(level);
    final int oldStars = stars[level] ?? 0;
    if (starCount > oldStars) stars[level] = starCount;
    final int oldBest = bestScore[level] ?? 0;
    if (score > oldBest) bestScore[level] = score;
    save();
    notifyListeners();
    return granted;
  }

  // ---------------------------------------------------------------- skins

  SkinDef get equippedSkin => SkinCatalog.byId(equipped);

  bool owns(String id) => owned.contains(id);

  BuyResult buySkin(SkinDef s) {
    if (owned.contains(s.id)) return BuyResult.alreadyOwned;
    if (coins < s.price) return BuyResult.notEnough;
    coins -= s.price;
    owned.add(s.id);
    save();
    notifyListeners();
    return BuyResult.ok;
  }

  void equip(String id) {
    if (!owned.contains(id)) return;
    equipped = id;
    save();
    notifyListeners();
  }

  // ---------------------------------------------------------------- settings

  void applyAudio() {
    AudioService.instance.configure(musicOn: musicOn, sfxOn: sfxOn, musicVol: musicVol, sfxVol: sfxVol);
  }

  void setMusicOn(bool v) {
    musicOn = v;
    applyAudio();
    save();
    notifyListeners();
  }

  void setSfxOn(bool v) {
    sfxOn = v;
    applyAudio();
    save();
    notifyListeners();
  }

  void setMusicVol(double v) {
    musicVol = v;
    applyAudio();
    notifyListeners();
  }

  void setSfxVol(double v) {
    sfxVol = v;
    applyAudio();
    notifyListeners();
  }

  /// Persist slider values once the user lets go.
  void commitSettings() {
    save();
  }

  void setLang(String l) {
    lang = l == 'en' ? 'en' : 'bg';
    L10n.lang = lang;
    save();
    notifyListeners();
  }

  Future<void> resetProgress() async {
    coins = 0;
    completed.clear();
    rewarded.clear();
    stars.clear();
    bestScore.clear();
    owned
      ..clear()
      ..add(SkinCatalog.starterId);
    equipped = SkinCatalog.starterId;
    await save();
    notifyListeners();
  }
}

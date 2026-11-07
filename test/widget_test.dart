import 'package:flutter_test/flutter_test.dart';
import 'package:nyancat6767/data/skins.dart';

void main() {
  test('skin catalogue: 30+ skins, 7 rarities, prices up to 5000', () {
    expect(SkinCatalog.all.length >= 30, true);
    expect(Rarity.values.length, 7);
    final Set<String> ids = <String>{};
    for (final SkinDef s in SkinCatalog.all) {
      expect(ids.add(s.id), true);
      expect(s.price <= 5000, true);
      expect(s.trail.length, 6);
    }
    for (final Rarity r in Rarity.values) {
      expect(SkinCatalog.ofRarity(r).isNotEmpty, true);
    }
  });
}

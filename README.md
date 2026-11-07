# NyanCat6767

A colorful 2D space arcade game (Flutter + Flame, Android 12+, portrait). UI language: Bulgarian (English selectable).

* 120 levels in 12 worlds (obstacles: rocks, floaters, gates, swinging gates, lasers, spinners, ion storms)
* 32 cat skins in 7 rarities (Обикновен, Рядък, Епически, Митически, Легендарен, Хроматичен, Ултра), max price 5000
* Every level pays exactly 300 coins, once (replays pay nothing)
* Skin shop, collection, settings (music/sfx volume + on/off, language, reset), progress saved locally
* Drag your finger up/down to fly; you have 3 hearts per attempt

Build locally: `flutter pub get && flutter build apk --release`.
GitHub: upload `NyanCat6767_Project.zip` to the repository root and add `.github/workflows/build.yml`.

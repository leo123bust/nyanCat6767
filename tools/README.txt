Development tools used to generate the game content (not needed to build the app):
  sprite.py        - original pixel-art cat sprite + accessories
  gen_levels.py    - generates assets/levels/levels.json (120 levels) and verifies every level is completable
                     with a reachability simulation that uses the same collision maths as the game
  gen_audio.py     - synthesizes the sound effects and music loops in assets/audio
  gen_icons.py     - launcher icons
  gen_dart_data.py - writes lib/data/sprite_data.dart and the skin list
(Paths inside the scripts point to the original build machine.)

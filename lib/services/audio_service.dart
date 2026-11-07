import 'package:audioplayers/audioplayers.dart';

/// Music + sound effects. Every call is wrapped in try/catch so audio problems never crash the game.
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  static const List<String> _sfxNames = <String>['coin', 'hit', 'click', 'buy', 'win', 'lose', 'heart', 'error'];

  final AudioPlayer _music = AudioPlayer();
  final Map<String, List<AudioPlayer>> _pools = <String, List<AudioPlayer>>{};
  final Map<String, int> _cursor = <String, int>{};

  bool musicOn = true;
  bool sfxOn = true;
  double musicVol = 0.6;
  double sfxVol = 0.9;
  String? _track;
  bool _ready = false;

  Future<void> init() async {
    try {
      await _music.setReleaseMode(ReleaseMode.loop);
      for (final String n in _sfxNames) {
        final List<AudioPlayer> pool = <AudioPlayer>[];
        for (int i = 0; i < 2; i++) {
          final AudioPlayer p = AudioPlayer();
          await p.setPlayerMode(PlayerMode.lowLatency);
          await p.setReleaseMode(ReleaseMode.stop);
          pool.add(p);
        }
        _pools[n] = pool;
        _cursor[n] = 0;
      }
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  void configure({required bool musicOn, required bool sfxOn, required double musicVol, required double sfxVol}) {
    this.musicOn = musicOn;
    this.sfxOn = sfxOn;
    this.musicVol = musicVol;
    this.sfxVol = sfxVol;
    _applyMusic();
  }

  Future<void> _applyMusic() async {
    try {
      await _music.setVolume(musicOn ? musicVol : 0.0);
      if (!musicOn) {
        await _music.pause();
      } else if (_track != null) {
        await _music.resume();
      }
    } catch (_) {}
  }

  /// [track] is 'menu' or 'game'. Restarting the same track is a no-op.
  Future<void> playMusic(String track) async {
    if (!_ready) return;
    if (_track == track) {
      await _applyMusic();
      return;
    }
    _track = track;
    try {
      await _music.stop();
      await _music.setVolume(musicOn ? musicVol : 0.0);
      if (musicOn) {
        await _music.play(AssetSource('audio/music_$track.ogg'));
      }
    } catch (_) {}
  }

  Future<void> pauseMusic() async {
    try {
      await _music.pause();
    } catch (_) {}
  }

  Future<void> resumeMusic() async {
    if (!musicOn) return;
    try {
      if (_track != null) {
        await _music.setVolume(musicVol);
        await _music.resume();
      }
    } catch (_) {}
  }

  void sfx(String name) {
    if (!sfxOn || !_ready) return;
    _play(name);
  }

  Future<void> _play(String name) async {
    try {
      final List<AudioPlayer>? pool = _pools[name];
      if (pool == null) return;
      final int i = (_cursor[name] ?? 0) % pool.length;
      _cursor[name] = i + 1;
      final AudioPlayer p = pool[i];
      await p.stop();
      await p.setVolume(sfxVol);
      await p.play(AssetSource('audio/$name.wav'));
    } catch (_) {}
  }
}

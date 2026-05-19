import 'package:flutter/rendering.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rum_tap/features/drum_pad/models/pad_kits.dart';

class AudioService {
  final AudioPlayer musicPlayer = AudioPlayer();

  final Map<String, AudioPlayer> _musicPads = {};
  final Map<String, List<AudioPlayer>> _padPlayers = {};

  static const int _poolSize = 8;
  final List<AudioPlayer> _sfxPool = [];

  double musicVolume = 0.5;
  double sfxVolume = 0.5;

  bool _padsPreloaded = false;
  static const int _playersPerSound = 4;

  List<String> get allAssets => PadKits.kits.values.expand((e) => e).toList();
  List<String> get allMusicAssets =>
      PadKits.kits.values.expand((e) => e).toList();

  void Function(String asset)? _onPadFinished;
  void Function(String asset)? _onMusicPadFinished;

  void setOnPadFinished(void Function(String asset) callback) {
    _onPadFinished = callback;
  }

  void setOnMusicPadFinished(void Function(String asset) callback) {
    _onMusicPadFinished = callback;
  }

  Future<void> init() async {
    for (int i = 0; i < _poolSize; i++) {
      final p = AudioPlayer();
      await p.setVolume(sfxVolume);
      _sfxPool.add(p);
    }
  }

  // ---------- MUSIC PAD ----------
  Future<void> preloadMusic(String asset) async {
    if (_musicPads.containsKey(asset)) return;

    final p = AudioPlayer();
    await p.setAsset(asset);
    p.setLoopMode(LoopMode.one);
    p.setVolume(musicVolume);

    _musicPads[asset] = p;
  }

  Future<void> preloadMusicPads(List<String> assets) async {
    for (final asset in assets) {
      if (_musicPads.containsKey(asset)) continue;
      final player = AudioPlayer();
      await player.setAsset(asset);
      player.setLoopMode(LoopMode.one); // ⭐ เพลงวน
      player.setVolume(musicVolume);

      _musicPads[asset] = player;
    }
  }

  Future<void> stopMusic(String asset) async {
    await _musicPads[asset]?.stop();
  }

  Future<void> stopPad(String asset) async {
    if (!_padPlayers.containsKey(asset)) return;

    final players = _padPlayers[asset]!;

    for (final p in players) {
      if (p.playing) {
        await p.stop();
      }
    }
  }

  // ---------- PAD SOUND ----------

  Future<void> preloadPads(List<String> assets) async {
    if (_padsPreloaded) return;
    _padsPreloaded = true;

    for (final asset in assets) {
      if (_padPlayers.containsKey(asset)) continue;

      final players = <AudioPlayer>[];

      for (int i = 0; i < _playersPerSound; i++) {
        final p = AudioPlayer();

        await p.setAsset(asset);
        await p.setVolume(sfxVolume);

        players.add(p);
      }

      _padPlayers[asset] = players;
    }
  }

  AudioPlayer _getFree(List<AudioPlayer> list) {
    for (final p in list) {
      if (!p.playing) return p;
    }
    return list.first;
  }

  Future<void> playPad(String asset) async {
    final list = _padPlayers[asset];

    print("▶️ playPad: $asset");
    print("players: ${list?.length}");

    if (list == null) {
      print("❌ pad not preloaded");
      return;
    }

    final p = _getFree(list);

    print("🎧 using player: $p");

    await p.seek(Duration.zero);
    // ⭐ listen ตอนจบ (สำคัญ)
    p.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // 🔥 ถ้าใช้ Riverpod ต้อง notify ด้วย
        _onPadFinished?.call(asset);
      }
    });

    await p.play();

    print("▶️ play called");
  }

  Future<void> playMusic(String asset) async {
    if (!_musicPads.containsKey(asset)) {
      debugPrint("Music not preloaded: $asset");
      return;
    }

    /// ⭐ หยุดเพลงอื่นก่อน (สำคัญมาก)
    for (final p in _musicPads.values) {
      if (p.playing) await p.stop();
    }

    final player = _musicPads[asset]!;
    await player.seek(Duration.zero);

    // ⭐ listen ตอนจบ (สำคัญ)
    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // 🔥 ถ้าใช้ Riverpod ต้อง notify ด้วย
        _onMusicPadFinished?.call(asset);
      }
    });

    player.play();
  }

  // ---------- VOLUME ----------
  void setMusicVolume(double v) {
    musicVolume = v;

    musicPlayer.setVolume(v);

    for (final p in _musicPads.values) {
      p.setVolume(v);
    }
  }

  void setSfxVolume(double v) {
    sfxVolume = v;

    for (final p in _sfxPool) {
      p.setVolume(v);
    }

    for (final list in _padPlayers.values) {
      for (final p in list) {
        p.setVolume(v);
      }
    }
  }

  void dispose() {
    musicPlayer.dispose();

    for (final p in _sfxPool) {
      p.dispose();
    }

    for (final list in _musicPads.values) {
      list.dispose();
    }

    for (final list in _padPlayers.values) {
      for (final p in list) {
        p.dispose();
      }
    }
  }
}

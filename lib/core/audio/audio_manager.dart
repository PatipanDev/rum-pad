import 'package:flutter/rendering.dart';
import 'package:just_audio/just_audio.dart';

class AudioManager {
  /// ⭐ Singleton
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  /// 🎵 BGM Player (ตัวเดียวพอ)
  final AudioPlayer musicPlayer = AudioPlayer();

  /// 🔊 SFX Player Pool (สำหรับ Sound Pad)
  final List<AudioPlayer> _sfxPool = [];
  static const int _poolSize = 8;

  final Map<String, List<AudioPlayer>> _padPlayers = {};
  static const int _playersPerSound = 4;

  double musicVolume = 0.5;
  double sfxVolume = 0.5;

  bool _initialized = false;

  bool _padsPreloaded = false;
  String? _lastPadAsset;

  //บอกสถานะ ui
  final Map<String, bool> _padPlayingState = {};

  bool isPadPlaying(String asset) {
    return _padPlayingState[asset] ?? false;
  }

  /// โหลดครั้งเดียวตอนเปิดแอป
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    /// 🎵 BGM
    // await musicPlayer.setAsset('assets/audio/bgm.mp3');
    // musicPlayer.setLoopMode(LoopMode.one);
    // musicPlayer.setVolume(musicVolume);
    // musicPlayer.play();

    /// 🔊 สร้าง Player Pool
    for (int i = 0; i < _poolSize; i++) {
      final player = AudioPlayer();
      player.setVolume(sfxVolume);
      _sfxPool.add(player);
    }
  }

  Future<void> preloadPads(List<String> assets) async {
    if (_padsPreloaded) return;
    _padsPreloaded = true;

    for (final asset in assets) {
      _padPlayers[asset] = [];
      _padPlayingState[asset] = false;

      for (int i = 0; i < _playersPerSound; i++) {
        final player = AudioPlayer();
        await player.setAsset(asset);
        player.setVolume(sfxVolume);

        /// ⭐ ฟัง event ตอนเสียงจบ
        player.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            _padPlayingState[asset] = false;
          }
        });

        _padPlayers[asset]!.add(player);
      }
    }
  }

  /// หา player ที่ว่าง
  AudioPlayer _getFreePadPlayer(String asset) {
    final players = _padPlayers[asset]!;

    for (final p in players) {
      if (!p.playing) return p;
    }

    return players.first; // ถ้าเต็ม เอาตัวแรก
  }

  /// 🎛 เล่นเสียง Pad (กดพร้อมกันได้)
  Future<void> playPad(String asset) async {
    if (!_padPlayers.containsKey(asset)) {
      debugPrint("Sound not preloaded: $asset");
      return;
    }

    _padPlayingState[asset] = true;

    final player = _getFreePadPlayer(asset);
    await player.seek(Duration.zero);
    player.play();
  }

  Future<void> stopPad(String asset) async {
    if (!_padPlayers.containsKey(asset)) return;

    final players = _padPlayers[asset]!;

    for (final p in players) {
      if (p.playing) {
        await p.stop();
      }
    }

    _padPlayingState[asset] = false;
  }

  Future<void> stopAllPads() async {
    for (final players in _padPlayers.values) {
      for (final p in players) {
        if (p.playing) {
          await p.stop();
        }
      }
    }
  }

  Future<void> pauseAllPads() async {
    for (final players in _padPlayers.values) {
      for (final p in players) {
        if (p.playing) {
          await p.pause();
        }
      }
    }
  }

  /// 🎚 ปรับ volume เพลง
  void setMusicVolume(double v) {
    musicVolume = v;
    musicPlayer.setVolume(v);
  }

  /// 🎚 ปรับ volume SFX (ต้องปรับทั้ง pool)
  void setSfxVolume(double v) {
    sfxVolume = v;

    // pool เดิม
    for (final p in _sfxPool) {
      p.setVolume(v);
    }

    // ⭐ สำคัญมาก: pad players
    for (final players in _padPlayers.values) {
      for (final p in players) {
        p.setVolume(v);
      }
    }
  }

  void dispose() {
    musicPlayer.dispose();

    for (final p in _sfxPool) {
      p.dispose();
    }

    // ⭐ dispose pad players
    for (final players in _padPlayers.values) {
      for (final p in players) {
        p.dispose();
      }
    }
  }
}

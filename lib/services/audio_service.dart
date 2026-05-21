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

  List<String> get allAssets => PadKitsMusic.kits
      .expand(
        (kit) => kit.audioSamples,
      ) // ยุบรวมให้เหลือ List ของ AudioSample ทุกตัว
      .map((sample) => sample.path) // ดึงเอาเฉพาะ Path ของไฟล์เสียงออกมา
      .toList();

  List<String> get allMusicAssets => PadKitsMusic.kits
      .expand(
        (kit) => kit.audioSamples,
      ) // ยุบรวมให้เหลือ List ของ AudioSample ทุกตัว
      .map((sample) => sample.path) // ดึงเอาเฉพาะ Path ของไฟล์เสียงออกมา
      .toList();

  void Function(String asset)? _onPadFinished;
  void Function(String asset)? _onMusicPadFinished;

  AudioPlayer? _currentMusicPlayer;
  String? _currentAsset;

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

  final Set<AudioPlayer> _listenedPlayers = {};

  void _attachListener(AudioPlayer player, String asset) {
    if (_listenedPlayers.contains(player)) return;

    _listenedPlayers.add(player);

    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_currentAsset == asset) {
          _onMusicPadFinished?.call(asset);
        }
      }
    });
  }

  Future<void> playMusic(String asset) async {
    final player = _musicPads[asset];

    if (player == null) {
      debugPrint("Music not preloaded: $asset");
      return;
    }

    /// ⭐ 1. หยุดเพลงปัจจุบัน (ถ้ามี)
    await _currentMusicPlayer?.stop();

    /// ⭐ 2. ตั้งตัวใหม่เป็น active
    _currentMusicPlayer = player;
    _currentAsset = asset;

    /// ⭐ 3. reset แล้วเล่นใหม่
    await player.seek(Duration.zero);

    /// ⭐ 4. เล่น
    await player.play();

    /// ⭐ 5. subscribe แค่ครั้งเดียว (กัน leak)
    _attachListener(player, asset);
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

  // 1. ฟังก์ชันเปิดเพลงพร้อม Fade In
  // ---------- FADE IN สำหรับเพลงทั้งหมดที่เก็บไว้ ----------
  Future<void> fadeInAllMusicVolume({
    Duration duration = const Duration(milliseconds: 1500),
  }) async {
    if (_musicPads.isEmpty) return;

    final int steps = 30;
    final Duration interval = duration ~/ steps;

    // 🔥 อ่าน volume เป้าหมายจาก global musicVolume
    final double targetVolume = musicVolume;

    // เริ่มจาก volume ปัจจุบัน (สำคัญมาก)
    double currentVolume = 0.0;

    // อ่าน volume ปัจจุบันจาก player ตัวแรก (สมมุติว่าทุกตัวเท่ากัน)
    final firstPlayer = _musicPads.values.first;
    currentVolume = firstPlayer.volume;

    final double volumeStep = (targetVolume - currentVolume) / steps;

    for (int i = 0; i < steps; i++) {
      await Future.delayed(interval);

      currentVolume += volumeStep;
      currentVolume = currentVolume.clamp(0.0, targetVolume);

      for (final player in _musicPads.values) {
        await player.setVolume(currentVolume);
      }
    }

    // จบแบบเป๊ะ
    for (final player in _musicPads.values) {
      await player.setVolume(targetVolume);
    }
  }

  Future<void> fadeOutAllMusicVolume({
    Duration duration = const Duration(milliseconds: 1500),
  }) async {
    if (_musicPads.isEmpty) return;

    final int steps = 30;
    final Duration interval = duration ~/ steps;

    final firstPlayer = _musicPads.values.first;
    double currentVolume = firstPlayer.volume;

    final double volumeStep = currentVolume / steps;

    for (int i = 0; i < steps; i++) {
      await Future.delayed(interval);

      currentVolume -= volumeStep;
      currentVolume = currentVolume.clamp(0.0, 1.0);

      for (final player in _musicPads.values) {
        await player.setVolume(currentVolume);
      }
    }

    for (final player in _musicPads.values) {
      await player.setVolume(0);
    }
  }

  // ---------- FADE OUT สำหรับเพลงทั้งหมดที่กำลังเล่น ----------
  Future<void> stopAllMusicWithFadeOut({
    Duration duration = const Duration(milliseconds: 1500),
  }) async {
    if (_musicPads.isEmpty) return;

    final int steps = 30;
    final Duration interval = duration ~/ steps;

    // คิดสเต็ปการลดเสียงอิงจากระดับเสียงปัจจุบัน
    final double volumeStep = musicVolume / steps;

    double currentVolume = musicVolume;

    for (int i = 0; i < steps; i++) {
      await Future.delayed(interval);
      currentVolume -= volumeStep;
      currentVolume = currentVolume.clamp(0.0, 1.0);

      // วนลูปหรี่เสียงลงพร้อมกันทุกตัว
      for (final player in _musicPads.values) {
        if (player.playing) {
          await player.setVolume(currentVolume);
        }
      }
    }

    // พอเสียงเงียบสนิทแล้ว สั่ง stop และคืนค่า Volume เริ่มต้นไว้รอเปิดครั้งต่อไป
    for (final player in _musicPads.values) {
      if (player.playing) {
        await player.stop();
        await player.setVolume(musicVolume);
      }
    }
  }

  AudioPlayer? get activeMusicPlayer {
    for (final player in _musicPads.values) {
      if (player.playing) return player;
    }
    return null;
  }
}

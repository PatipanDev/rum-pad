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

  List<String> get allAssets => PadKitsSfx.kits
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

  // Future<void> preloadMusicPads(List<String> assets) async {
  //   for (final asset in assets) {
  //     if (_musicPads.containsKey(asset)) continue;
  //     final player = AudioPlayer();
  //     await player.setAsset(asset);
  //     player.setLoopMode(LoopMode.one); // ⭐ เพลงวน
  //     player.setVolume(musicVolume);

  //     _musicPads[asset] = player;
  //   }
  // }

  Future<void> stopMusic() async {
    // 1. เช็กก่อนว่าตอนนี้มีเพลงกำลังเล่นอยู่จริงไหม
    if (_currentMusicPlayer != null) {
      // 2. สั่งหยุดเครื่องเล่นปัจจุบันให้สนิท
      await _currentMusicPlayer!.stop();

      // 3. รีเซ็ตเวลากลับไปที่เริ่มต้น (วินาทีที่ 0) เพื่อเตรียมพร้อมสำหรับครั้งต่อไป
      await _currentMusicPlayer!.seek(Duration.zero);

      // 4. ล้างค่าตัวแปรอ้างอิงให้เป็น null เพื่อเคลียร์สถานะ (State)
      _currentMusicPlayer = null;
      _currentAsset = null;

      print('หยุดเล่นเพลงเรียบร้อยแล้ว');
    }
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
    // ⭐ 1. หยุดเพลงเก่าที่กำลังเล่นอยู่ให้สนิทก่อน (ถ้ามี)
    if (musicPlayer.playing) {
      await musicPlayer.stop();
    }

    // ⭐ 2. ดึงหรือสร้างเครื่องเล่นตัวใหม่สำหรับ Asset นี้
    // (สมมติว่าดึงมาจาก _musicPads ที่เราเคยทำ Preload ไว้ หรือใช้ตัวแปร musicPlayer ของคุณ)
    final player = musicPlayer;

    // ⭐ 3. โหลดไฟล์เสียง (ใช้ setAsset ให้ถูกประเภทไฟล์)
    // หมายเหตุ: ถ้าใช้ระบบ Preload มาก่อนแล้ว ขั้นตอนนี้สามารถข้ามไปได้เลยครับ
    await player.setAsset(asset);

    // ⭐ 4. รีเซ็ตเวลาเริ่มต้นใหม่กลับไปที่วินาทีที่ 0
    await player.seek(Duration.zero);

    // ⭐ 5. อัปเดตสถานะว่าตอนนี้เครื่องเล่นตัวนี้กำลังทำงานอยู่
    _currentMusicPlayer = player;
    _currentAsset = asset;

    // ⭐ 6. ลงทะเบียน Listener (ดักฟังสถานะ) ก่อนที่จะกดเล่นเสียง
    _attachListener(player, asset);

    // ⭐ 7. สั่งเล่นเพลง
    // แนะนำ: ไม่ต้องใส่ await หน้า play() ก็ได้ครับ หากต้องการให้แอปทำงานต่อไปได้เลยโดยไม่ต้องรอให้เพลงเล่นจนจบ
    player.play();
  }

  Stream<Duration> get currentPositionStream {
    return musicPlayer.positionStream;
  }

  // 🟢 แก้ไข: ดึงความยาวเพลงรวมจาก musicPlayer ตัวหลักเช่นกัน
  Stream<Duration?> get currentDurationStream {
    return musicPlayer.durationStream;
  }

  // ฟังก์ชันเลื่อนเวลาเพลง (ตอนที่คนลาก Slider บนหน้าจอ)
  Future<void> seekCurrentMusic(Duration position) async {
    await _currentMusicPlayer?.seek(position);
  }

  Future<void> pauseMusic() async {
    // เช็กก่อนว่าเครื่องเล่นกำลังเล่นเพลงอยู่จริง ๆ ไหม
    if (musicPlayer.playing) {
      await musicPlayer.pause();
      print('พักเล่นเพลงชั่วคราวแล้ว');
    }
  }

  //เล่นเพลงต่อ
  Future<void> resumeMusic() async {
    // เช็กก่อนว่าเพลงหยุดอยู่ และเครื่องเล่นถูกโหลดเพลงไว้แล้วจริง ๆ (ไม่มีค่าเป็น null)
    if (!musicPlayer.playing && _currentMusicPlayer != null) {
      await musicPlayer.play();
      print('เล่นเพลงต่อจากจุดเดิมแล้ว');
    }
  }

  Stream<bool> get isPlayingStream => musicPlayer.playingStream;
  Stream<bool> get isLoopingStream =>
      musicPlayer.loopModeStream.map((mode) => mode == LoopMode.one);

  Future<void> enableLoopOne() async {
    await musicPlayer.setLoopMode(LoopMode.one);
  }

  Future<void> disableLoop() async {
    await musicPlayer.setLoopMode(LoopMode.off);
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
  Future<void> fadeInMusicVolume({
    Duration duration = const Duration(milliseconds: 1500),
  }) async {
    // ไม่มี player ปัจจุบัน
    final player = _currentMusicPlayer;
    if (player == null) return;

    // ไม่มีเพลงเล่นอยู่
    if (!player.playing) return;

    const int steps = 30;
    final Duration interval = duration ~/ steps;

    // volume เป้าหมายจาก global
    final double targetVolume = musicVolume;

    // เริ่มจาก volume ปัจจุบัน
    double currentVolume = player.volume;

    // ถ้า volume ถึงอยู่แล้ว ไม่ต้อง fade
    if (currentVolume >= targetVolume) return;

    final double volumeStep = (targetVolume - currentVolume) / steps;

    for (int i = 0; i < steps; i++) {
      await Future.delayed(interval);

      currentVolume += volumeStep;

      // กันเกิน
      currentVolume = currentVolume.clamp(0.0, targetVolume);

      await player.setVolume(currentVolume);
    }

    // จบแบบตรงเป๊ะ
    await player.setVolume(targetVolume);
  }

  Future<void> fadeOutMusicVolume({
    Duration duration = const Duration(milliseconds: 1500),
  }) async {
    final player = _currentMusicPlayer;

    // ไม่มี player
    if (player == null) return;

    // ไม่มีเพลงเล่น
    if (!player.playing) return;

    const int steps = 30;
    final Duration interval = duration ~/ steps;

    // volume ปัจจุบัน
    double currentVolume = player.volume;

    // ถ้า mute อยู่แล้ว
    if (currentVolume <= 0) return;

    final double volumeStep = currentVolume / steps;

    for (int i = 0; i < steps; i++) {
      await Future.delayed(interval);

      currentVolume -= volumeStep;

      // กันค่าติดลบ
      currentVolume = currentVolume.clamp(0.0, 1.0);

      await player.setVolume(currentVolume);
    }

    // จบแบบเป๊ะ
    await player.setVolume(0);
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

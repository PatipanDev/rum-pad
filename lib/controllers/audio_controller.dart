import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:rum_tap/provider/audio_provider.dart';
import 'package:rum_tap/services/audio_service.dart';
import 'package:rum_tap/services/pref_service.dart';
import 'package:rum_tap/state/audio_state.dart';

class AudioController extends Notifier<AudioState> {
  late final AudioService _audio;
  late final PrefService _pref;

  @override
  AudioState build() {
    _audio = ref.read(audioServiceProvider);
    _pref = ref.read(prefServiceProvider);

    return const AudioState(
      musicVolume: 0.5,
      sfxVolume: 0.5,
      musicMuted: false,
      sfxMuted: false,

      /// ⭐ ต้องมีค่าเริ่มต้น
      padPlaying: {},
      fadeInDurationMs: 1500,
      fadeOutDurationMs: 1500,

      /// ⭐ default
      currentMusicAsset: null,
    );
  }

  Future<void> init() async {
    await _audio.init();

    _audio.setOnPadFinished((asset) {
      state = state.copyWith(padPlaying: {...state.padPlaying, asset: false});
    });
  }

  Future<void> loadPrefs() async {
    final pref = ref.read(prefServiceProvider);

    final musicVolume = await pref.getMusicVolume();
    final sfxVolume = await pref.getSfxVolume();
    final musicMuted = await pref.getMusicMuted();
    final sfxMuted = await pref.getSfxMuted();
    final fadeIn = await pref.getFadeIn();
    final fadeOut = await pref.getFadeOut();

    // apply volume ให้ audio engine ด้วย
    _audio.setMusicVolume(musicMuted ? 0 : musicVolume);
    _audio.setSfxVolume(sfxMuted ? 0 : sfxVolume);

    state = state.copyWith(
      musicVolume: musicVolume,
      sfxVolume: sfxVolume,
      musicMuted: musicMuted,
      sfxMuted: sfxMuted,
      fadeInDurationMs: fadeIn,
      fadeOutDurationMs: fadeOut,
    );
  }

  Future<void> preloadPads() async {
    await _audio.preloadPads(_audio.allAssets);
  }

  Future<void> preloadMusics() async {
    await _audio.preloadMusicPads(_audio.allMusicAssets);
  }

  // ---------- MUSIC ----------
  Future<void> playMusic(String asset) async {
    final previous = state.currentMusicAsset;

    /// ⭐ 1. ปิด UI เพลงเก่าก่อน
    if (previous != null) {
      state = state.copyWith(
        padPlaying: {...state.padPlaying, previous: false},
      );

      await _audio.stopMusic(previous);
    }

    /// ⭐ 2. set เพลงใหม่ + UI true
    state = state.copyWith(
      currentMusicAsset: asset,
      padPlaying: {...state.padPlaying, asset: true},
    );

    /// ⭐ 3. เล่นเพลงใหม่
    await _audio.playMusic(asset);
  }

  // Future<void> playMusic(String asset) async {
  //   final previous = state.currentMusicAsset;

  //   /// ⭐ 1. ปิด UI เพลงเก่าก่อน
  //   if (previous != null) {
  //     state = state.copyWith(
  //       padPlaying: {...state.padPlaying, previous: false},
  //     );

  //     await _audio.stopMusic(previous);
  //   }

  //   /// ⭐ 2. set เพลงใหม่ + UI true (เพื่อให้ปุ่มแสดงสถานะกำลังโหลด/กำลังเล่นทันที)
  //   state = state.copyWith(
  //     currentMusicAsset: asset,
  //     padPlaying: {...state.padPlaying, asset: true},
  //   );

  //   /// ⭐ 3. โหลดและเล่นเพลงใหม่แบบทันท่วงที (Lazy Loading)
  //   try {
  //     // 💡 สั่ง preload เฉพาะไฟล์ที่จะเล่น ณ วินาทีก่อนเล่นจริง
  //     // (ส่วนใหญ่แพลตฟอร์มเสียงจะใช้เวลาตรงนี้เพียงเสี้ยววินาที ไม่ทำให้แอปค้าง)
  //     await _audio.preloadMusicPads([asset]);

  //     // เล่นเพลงทันทีหลังจากโหลดเสร็จ
  //     await _audio.playMusic(asset);
  //   } catch (e) {
  //     // ระบบป้องกัน: เผื่อเกิดข้อผิดพลาดในการโหลดไฟล์ จะได้คืนค่า UI ไม่ให้ปุ่มค้าง
  //     state = state.copyWith(padPlaying: {...state.padPlaying, asset: false});
  //     print("Error loading audio: $e");
  //   }
  // }

  Future<void> stopMusic(String asset) {
    state = state.copyWith(padPlaying: {...state.padPlaying, asset: false});
    return _audio.stopMusic(asset);
  }

  void setMusicVolume(double v) async {
    _audio.setMusicVolume(v);

    state = state.copyWith(musicVolume: v, musicMuted: v == 0);
    await _pref.saveMusicVolume(v);
  }

  void toggleMusicMute() async {
    final muted = !state.musicMuted;
    final v = muted ? 0.0 : state.musicVolume;

    _audio.setMusicVolume(v);

    state = state.copyWith(musicMuted: muted);
    await _pref.saveMusicVolume(v);
  }

  // ---------- SFX ----------
  Future<void> playPad(String asset) async {
    state = state.copyWith(padPlaying: {...state.padPlaying, asset: true});

    await _audio.playPad(asset);
  }

  Future<void> stopPad(String asset) async {
    state = state.copyWith(padPlaying: {...state.padPlaying, asset: false});

    await _audio.stopPad(asset);
  }

  void setSfxVolume(double v) async {
    _audio.setSfxVolume(v);

    state = state.copyWith(sfxVolume: v, sfxMuted: v == 0);
    await _pref.saveSfxVolume(v);
  }

  void toggleSfxMute() async {
    final muted = !state.sfxMuted;
    final v = muted ? 0.0 : state.sfxVolume;

    _audio.setSfxVolume(v);

    state = state.copyWith(sfxMuted: muted);
    await _pref.saveSfxVolume(v);
  }

  Future<void> fadeInAllMusicVolume() async {
    Duration duration = Duration(milliseconds: state.fadeInDurationMs);
    await _audio.fadeInAllMusicVolume(duration: duration);
    state = state.copyWith(musicMuted: false);
  }

  Future<void> fadeOutAllMusicVolume() async {
    Duration duration = Duration(milliseconds: state.fadeOutDurationMs);
    await _audio.fadeOutAllMusicVolume(duration: duration);
    state = state.copyWith(musicMuted: true);
  }

  void setFadeInDuration(int ms) async {
    // สั่งอัปเดตค่า fadeInDurationMs ใน State เพื่อให้ UI รับรู้และหมุนตาม
    await _pref.saveFadeIn(ms);
    state = state.copyWith(fadeInDurationMs: ms);
  }

  void setFadeOutDuration(int ms) async {
    await _pref.saveFadeOut(ms);
    // สั่งอัปเดตค่า fadeOutDurationMs ใน State
    state = state.copyWith(fadeOutDurationMs: ms);
  }

  void dispose() {
    _audio.dispose();
  }
}

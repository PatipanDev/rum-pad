import 'package:riverpod/riverpod.dart';
import 'package:rum_tap/provider/audio_provider.dart';
import 'package:rum_tap/services/audio_service.dart';
import 'package:rum_tap/state/audio_state.dart';

class AudioController extends Notifier<AudioState> {
  late final AudioService _audio;

  @override
  AudioState build() {
    _audio = ref.read(audioServiceProvider);

    return const AudioState(
      musicVolume: 0.5,
      sfxVolume: 0.5,
      musicMuted: false,
      sfxMuted: false,

      /// ⭐ ต้องมีค่าเริ่มต้น
      padPlaying: {},
    );
  }

  Future<void> init() async {
    await _audio.init();

    _audio.setOnPadFinished((asset) {
      state = state.copyWith(padPlaying: {...state.padPlaying, asset: false});
    });
  }

  Future<void> preloadPads() async {
    await _audio.preloadPads(_audio.allAssets);
  }

  Future<void> preloadMusics() async {
    await _audio.preloadMusicPads(_audio.allMusicAssets);
  }

  // ---------- MUSIC ----------
  Future<void> playMusic(String asset) {
     state = state.copyWith(padPlaying: {...state.padPlaying, asset: true});
    return _audio.playMusic(asset);
  }

  Future<void> stopMusic(String asset) {
     state = state.copyWith(padPlaying: {...state.padPlaying, asset: false});
    return _audio.stopMusic(asset);
  }

  void setMusicVolume(double v) {
    _audio.setMusicVolume(v);

    state = state.copyWith(musicVolume: v, musicMuted: v == 0);
  }

  void toggleMusicMute() {
    final muted = !state.musicMuted;
    final v = muted ? 0.0 : state.musicVolume;

    _audio.setMusicVolume(v);

    state = state.copyWith(musicMuted: muted);
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

  void setSfxVolume(double v) {
    _audio.setSfxVolume(v);

    state = state.copyWith(sfxVolume: v, sfxMuted: v == 0);
  }

  void toggleSfxMute() {
    final muted = !state.sfxMuted;
    final v = muted ? 0.0 : state.sfxVolume;

    _audio.setSfxVolume(v);

    state = state.copyWith(sfxMuted: muted);
  }
}

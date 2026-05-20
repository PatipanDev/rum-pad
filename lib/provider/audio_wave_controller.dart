import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rum_tap/controllers/audio_controller.dart';
import 'package:rum_tap/provider/audio_provider.dart';

final audioWaveProvider = Provider<AudioController>((ref) {
  final controller = AudioController();

  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
});


/// ⭐ stream ตำแหน่งเพลง (หัวอ่านเพลง)
final musicPositionProvider = StreamProvider<Duration>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.musicPlayer.positionStream;
});
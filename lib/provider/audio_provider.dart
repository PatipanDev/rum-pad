import 'package:riverpod/riverpod.dart';
import 'package:rum_tap/controllers/audio_controller.dart';
import 'package:rum_tap/services/audio_service.dart';
import 'package:rum_tap/state/audio_state.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});

final audioControllerProvider =
    NotifierProvider<AudioController, AudioState>(AudioController.new);
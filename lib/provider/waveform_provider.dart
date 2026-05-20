import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:rum_tap/services/waveform_service.dart';

final waveformServiceProvider = Provider<WaveformService>((ref) {
  return WaveformService();
});

/// ⭐ ตัวที่ถาม = ตัวนี้
final waveformDataProvider = FutureProvider.family<Waveform, String>((
  ref,
  assetPath,
) async {
  final service = ref.read(waveformServiceProvider);
  return service.extractWaveform(assetPath);
});

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:just_waveform/just_waveform.dart';

class WaveformService {

  /// ⭐ extract waveform จาก asset
  Future<Waveform> extractWaveform(String assetPath) async {
    final dir = await getTemporaryDirectory();

    // แปลงชื่อไฟล์ให้ใช้เป็น cache
    final fileName = assetPath.split('/').last;
    final audioFile = File(p.join(dir.path, fileName));
    final waveFile = File(p.join(dir.path, "$fileName.wave"));

    /// ถ้าเคย extract แล้ว → ใช้ cache ทันที 🚀
    if (await waveFile.exists()) {
      return JustWaveform.parse(waveFile);
    }

    /// copy asset → temp
    final data = await rootBundle.load(assetPath);
    await audioFile.writeAsBytes(data.buffer.asUint8List());

    /// extract waveform
    final stream = JustWaveform.extract(
      audioInFile: audioFile,
      waveOutFile: waveFile,
    );

    Waveform? result;

    await for (final progress in stream) {
      if (progress.waveform != null) {
        result = progress.waveform;
      }
    }

    return result!;
  }
}
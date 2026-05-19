import 'package:flutter/material.dart';
import 'package:rum_tap/core/audio/audio_manager.dart';

double musicVolume = AudioManager().musicVolume;
double sfxVolume = AudioManager().sfxVolume;

Widget buildMixerSlider( BuildContext context, {
  required String title,
  required double value,
  required Function(double) onChanged,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      /// ชื่อ
      Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

      SizedBox(height: 20),

      /// 🔊 แท่ง Mixer
      SizedBox(
        height: 150,
        child: RotatedBox(
          quarterTurns: -1, // หมุน slider ให้ตั้ง
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 1,
              onChanged: onChanged,
            ),
          ),
        ),
      ),

      SizedBox(height: 10),

      Text("${(value * 100).round()}%"),
    ],
  );
}
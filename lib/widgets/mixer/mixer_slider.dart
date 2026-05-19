import 'package:flutter/material.dart';

class MixerSlider extends StatelessWidget {
  final String title;
  final double value;
  final ValueChanged<double> onChanged;
  final bool
  isMuted; // เพิ่มสถานะเปิด/ปิดเสียง (true = ปิดเสียง, false = เปิดเสียง)
  final VoidCallback onMuteToggled; // เพิ่ม Callback เมื่อกดปุ่มเปิด/ปิดเสียง

  const MixerSlider({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.isMuted,
    required this.onMuteToggled,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            RotatedBox(
              quarterTurns: -1,
              child: SizedBox(
                width: 150,
                child: Slider(
                  value: isMuted ? 0 : value,
                  min: 0,
                  max: 1,
                  onChanged: onChanged,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // แสดงเปอร์เซ็นต์ (ถ้าปิดเสียงอยู่ให้โชว์ 0%)
            Text(isMuted ? "0%" : "${(value * 100).toInt()}%"),
            const SizedBox(height: 10),

            IconButton(
              onPressed: onMuteToggled,
              icon: Icon(
                isMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
              ),
              // สลับสีพื้นหลัง: เปิดเสียง (isMuted เป็น false) = สีเขียว, ปิดเสียง (isMuted เป็น true) = สีแดง
              style: IconButton.styleFrom(
                backgroundColor: isMuted ? Colors.red : Colors.green,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        );
      },
    );
  }
}

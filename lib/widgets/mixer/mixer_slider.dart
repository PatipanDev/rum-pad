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
    final percent = (isMuted ? 0 : value) * 100;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// TITLE
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 1.5,
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        /// FADER TRACK + SLIDER
        SizedBox(
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// รางเหล็กของ Fader
              ///
              const Positioned(left: 0, child: _FaderScale()),

              /// 🔹 SCALE RIGHT
              const Positioned(right: 0, child: _FaderScale()),
              Container(
                width: 28,
                height: 170,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey.shade800,
                      Colors.black,
                      Colors.grey.shade900,
                    ],
                  ),
                  border: Border.all(color: Colors.black, width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black87,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),

              /// แถบ Volume เรืองแสง
              Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: isMuted ? 0 : value,
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.greenAccent,
                          Colors.green,
                          Colors.green.shade900,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.greenAccent.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Slider จริง (ซ่อน track เดิมออก)
              RotatedBox(
                quarterTurns: -1,
                child: SizedBox(
                  width: 170,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 0, // ❌ ซ่อน track เดิม
                      thumbShape: const RectSliderThumbShape(),
                      thumbColor: Colors.grey.shade200,
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(
                      value: isMuted ? 0 : value,
                      min: 0,
                      max: 1,
                      onChanged: onChanged,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // แสดงเปอร์เซ็นต์ (ถ้าปิดเสียงอยู่ให้โชว์ 0%)
        Text(
          "${percent.toInt()}%",
          style: const TextStyle(
            fontSize: 12,
            fontFamily: "monospace",
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 10),

        /// MUTE BUTTON (LED STYLE)
        GestureDetector(
          onTap: onMuteToggled,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 42,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isMuted ? Colors.red.shade800 : Colors.green.shade700,
              boxShadow: [
                BoxShadow(
                  color: (isMuted ? Colors.red : Colors.green).withOpacity(0.7),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
                const BoxShadow(
                  color: Colors.black87,
                  offset: Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Icon(
              isMuted ? Icons.volume_off : Icons.volume_up,
              size: 14,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _FaderScale extends StatelessWidget {
  const _FaderScale();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      width: 16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(11, (i) {
          // ทุก 5 step = ขีดใหญ่ (0%,25%,50%,75%,100%)
          final bool isMajor = i % 5 == 0;

          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: isMajor ? 12 : 6,
              height: 2,
              decoration: BoxDecoration(
                color: isMajor ? Colors.white70 : Colors.white24,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class RectSliderThumbShape extends SliderComponentShape {
  final double width;
  final double height;

  const RectSliderThumbShape({this.width = 18, this.height = 28});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(width, height);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final Rect rect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );

    final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

    /// เงาด้านล่าง (ปุ่มลอย)
    canvas.drawRRect(
      rrect.shift(const Offset(0, 3)),
      Paint()..color = Colors.black87,
    );

    /// ตัวปุ่ม (ไล่สีพลาสติก)
    final Paint paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xffeeeeee), Color(0xffcfcfcf), Color(0xff9e9e9e)],
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);

    /// ขีดกลางปุ่ม (จับเลื่อน)
    final grip = Rect.fromCenter(center: center, width: width * 0.4, height: 3);

    canvas.drawRRect(
      RRect.fromRectAndRadius(grip, const Radius.circular(2)),
      Paint()..color = Colors.black54,
    );
  }
}

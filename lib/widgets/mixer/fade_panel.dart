import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rum_tap/l10n/app_localizations.dart';
import 'package:rum_tap/provider/audio_provider.dart';
import 'dart:math' as math;

class FadePanel extends ConsumerWidget {
  const FadePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioControllerProvider);
    final audio = ref.read(audioControllerProvider.notifier);

    // สมมติว่าใน state ของคุณมีค่าเหล่านี้อยู่ (ถ้ายังไม่มี สามารถดูวิธีเพิ่มในหัวข้อถัดไปได้ครับ)
    // หรือหากยังไม่มี สามารถใช้ค่าจำลองภายในไปก่อนได้ เช่น 1500 มิลลิวินาที
    final double fadeInSec = (state.fadeInDurationMs ) / 1000;
    final double fadeOutSec = (state.fadeOutDurationMs) / 1000;
    final bool isFading = state.isFading;

    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900], // เปลี่ยนจากสีแดงเป็นสีมิกเซอร์เข้มๆ เท่ๆ
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ================= ฝั่ง FADE IN =================
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.fadeIn,
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                _VolumeKnob(
                  value: fadeInSec,
                  min: 0.1,
                  max: 5.0, // ปรับได้สูงสุด 5 วินาที
                  label: '${fadeInSec.toStringAsFixed(1)}s',
                  onChanged: (newValue) {
                    // ส่งค่ามิลลิวินาทีกลับไปเซ็ตที่ controller
                    audio.setFadeInDuration((newValue * 1000).toInt());
                  },
                ),
                const SizedBox(height: 12),
                MixerTriggerButton(
                  disabled: isFading,
                  onPressed: () => audio.fadeInAllMusicVolume(),
                  icon: Icons.trending_up,
                ),
              ],
            ),
          ),

          // เส้นแบ่งตรงกลางบอร์ด
          Container(width: 2, height: 100, color: Colors.grey[800]),

          // ================= ฝั่ง FADE OUT =================
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.fadeOut,
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                _VolumeKnob(
                  value: fadeOutSec,
                  min: 0.1,
                  max: 5.0,
                  label: '${fadeOutSec.toStringAsFixed(1)}s',
                  onChanged: (newValue) {
                    audio.setFadeOutDuration((newValue * 1000).toInt());
                  },
                ),
                const SizedBox(height: 12),

                MixerTriggerButton(
                  disabled: isFading,
                  onPressed: () => audio.fadeOutAllMusicVolume(),
                  icon: Icons.trending_down,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= คอมโพเนนต์ปุ่มหมุน (Knob Widget) =================
class _VolumeKnob extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final String label;
  final ValueChanged<double> onChanged;

  const _VolumeKnob({
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // คำนวณเปอร์เซ็นต์ของค่าปัจจุบันเพื่อเอาไปหมุนองศาปุ่ม (0.0 ถึง 1.0)
    final double percent = (value - min) / (max - min);
    // ตั้งค่าให้ปุ่มหมุนกวาดจาก -135 องศา ถึง 135 องศา สไตล์ปุ่มมิกเซอร์จริง
    final double angle = (percent * 270 - 135) * math.pi / 180;

    return GestureDetector(
      // ใช้ลากนิ้วขึ้น-ลง เพื่อปรับค่า (ใช้งานบนมือถือสะดวกกว่าการหมุนเป็นวงกลมจริง)
      onVerticalDragUpdate: (details) {
        final double sensitivity = 0.02; // ความไวในการหมุนลาก
        double newValue = value - (details.primaryDelta ?? 0) * sensitivity;
        newValue = newValue.clamp(min, max);
        onChanged(newValue);
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // วงแหวนพื้นหลังคอยบอกสเกล
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black38,
                  border: Border.all(color: Colors.grey[700]!, width: 2),
                ),
              ),
              // ตัวปุ่มที่หมุนได้จริงตามองศาแองเกิล
              Transform.rotate(
                angle: angle,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.grey[700]!, Colors.grey[850]!],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  // ขีดสีขาวบนปุ่มหมุนเพื่อแสดงตำแหน่งปัจจุบัน
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 3,
                      height: 10,
                      margin: const EdgeInsets.only(top: 2),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // ตัวเลขแสดงวิ เช่น "1.5s"
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class MixerTriggerButton extends StatefulWidget {
  final bool disabled;
  final VoidCallback onPressed;
  final IconData icon;

  const MixerTriggerButton({
    super.key,
    required this.disabled,
    required this.onPressed,
    required this.icon,
  });

  @override
  State<MixerTriggerButton> createState() => _MixerTriggerButtonState();
}

class _MixerTriggerButtonState extends State<MixerTriggerButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  bool _flash = false;

  void _handleTapDown(_) {
    if (widget.disabled) return;
    setState(() => _pressed = true);
  }

  void _handleTapUp(_) async {
    if (widget.disabled) return;

    setState(() {
      _pressed = false;
      _flash = true; // ยิงแสง
    });

    widget.onPressed();

    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) setState(() => _flash = false);
  }

  void _handleCancel() {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final double yOffset = _pressed ? 4 : 0;
    final double shadowOffset = _pressed ? 1 : 4;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleCancel,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: widget.disabled ? 0.5 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          transform: Matrix4.translationValues(0, yOffset, 0),
          width: 50,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),

            // 🎨 สีโลหะเข้มแบบ mixer
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.green.shade600, Colors.green.shade900],
            ),

            border: Border.all(color: Colors.green.shade300, width: 1.2),

            boxShadow: [
              // เงาหลัก (ยุบลงตอนกด)
              BoxShadow(
                color: Colors.black87,
                offset: Offset(0, shadowOffset),
                blurRadius: 0,
              ),

              // glow ตอนยิง
              if (_flash)
                const BoxShadow(
                  color: Colors.greenAccent,
                  blurRadius: 16,
                  spreadRadius: 1,
                ),

              // inner shadow
              BoxShadow(
                color: Colors.green.shade900.withValues(alpha: 0.6),
                offset: const Offset(0, -2),
                blurRadius: 0,
                spreadRadius: -2,
              ),
            ],
          ),

          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(widget.icon, size: 16, color: Colors.white)],
            ),
          ),
        ),
      ),
    );
  }
}

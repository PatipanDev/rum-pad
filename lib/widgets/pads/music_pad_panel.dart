import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rum_tap/core/audio/audio_manager.dart';
import 'package:rum_tap/features/drum_pad/models/pad_kits.dart';
import 'package:rum_tap/provider/audio_provider.dart';
import 'package:rum_tap/provider/panel_provider.dart';

class MusicPadPanel extends ConsumerStatefulWidget {
  const MusicPadPanel({super.key});

  @override
  ConsumerState<MusicPadPanel> createState() => _MusicPadPanelState();
}

class _MusicPadPanelState extends ConsumerState<MusicPadPanel> {
  @override
  Widget build(BuildContext context) {
    final audio = ref.read(audioControllerProvider.notifier);
    final panel = ref.watch(panelControllerProvider);
    return DefaultTabController(
      length: PadKits.kits.keys.length,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900], // เปลี่ยนจากสีแดงเป็นสีมิกเซอร์เข้มๆ เท่ๆ
          borderRadius: BorderRadius.circular(0),
          border: Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: Column(
          children: [
            /// 🎚 TAB BAR (เลือกหมวดเพลง)
            Container(
              decoration: BoxDecoration(
                color: Colors.black, // เปลี่ยนจากสีแดงเป็นสีมิกเซอร์เข้มๆ เท่ๆ
                borderRadius: BorderRadius.circular(0),
                border: Border.all(color: Colors.grey[900]!, width: 1),
              ),
              child: TabBar(
                tabs: PadKits.kits.keys.map((e) => Tab(text: e)).toList(),
                indicatorColor: Colors.white,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                labelColor: Colors
                    .white, // สีของตัวอักษรบน Tab ที่ถูกเลือก (ให้ขาวชัดเจน 100%)
                unselectedLabelColor: Colors.white38,
              ),
            ),

            /// 🎵 MUSIC PAD GRID
            Flexible(
              child: IgnorePointer(
                ignoring: panel.isLocked,
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: PadKits.kits.keys.map((kitName) {
                    final pads = PadKits.kits[kitName]!;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(4),

                      child: Wrap(
                        spacing: 4, // ระยะห่างระหว่างปุ่ม (แนวนอน)
                        runSpacing:
                            4, // ระยะห่างระหว่างปุ่ม (แนวตั้งเมื่อตกบรรทัด)
                        alignment:
                            WrapAlignment.start, // จัดให้ปุ่มเรียงจากซ้ายไปขวา
                        children: List.generate(pads.length, (index) {
                          final asset = pads[index];

                          // ดึงสถานะการเล่น (ฝั่งใครฝั่งมัน)
                          final isPlaying = ref.watch(
                            audioControllerProvider.select(
                              (s) => s.padPlaying[asset] ?? false,
                            ),
                          ); // ถ้าฝั่งเอฟเฟคให้เปลี่ยนเป็น audio.isPadPlaying(asset)

                          // 2. ใช้ SizedBox ล็อกขนาดปุ่มตรงนี้ให้เท่ากันทั้ง 2 ไฟล์! 👇
                          return SizedBox(
                            width:
                                75, // 👈 ตั้งขนาดที่อยากได้เลยครับ เช่น 75 พิกเซลเท่ากันทั้ง 2 แผง
                            height: 75, // 👈 ความสูง 75 พิกเซลเท่ากัน
                            child: GestureDetector(
                              onTap: () {
                                audio.playMusic(asset);
                              },
                              child: Stack(
                                children: [
                                  AnimatedContainer(
                                    width: 75,
                                    height: 75,
                                    transform: Matrix4.translationValues(
                                      0,
                                      isPlaying ? 2 : 0, // ปุ่มยุบลง
                                      0,
                                    ),
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),

                                      // 🔥 สีปุ่ม Rubber
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isPlaying
                                            ? [
                                                Colors.greenAccent.shade400,
                                                Colors.green.shade700,
                                                Colors.green.shade900,
                                              ]
                                            : [
                                                Colors.grey.shade700,
                                                Colors.grey.shade900,
                                              ],
                                      ),

                                      border: Border.all(
                                        color: isPlaying
                                            ? Colors.greenAccent
                                            : Colors.black,
                                        width: 1.4,
                                      ),

                                      boxShadow: isPlaying
                                          ? [
                                              // 🌟 ไฟเรืองรอบ pad
                                              BoxShadow(
                                                color: Colors.greenAccent
                                                    .withValues(alpha: 0.9),
                                                blurRadius: 18,
                                                spreadRadius: 3,
                                              ),

                                              // 🔽 เงากดลง
                                              const BoxShadow(
                                                color: Colors.black,
                                                offset: Offset(0, 2),
                                                blurRadius: 3,
                                              ),
                                            ]
                                          : [
                                              // 🔼 เงาปุ่มลอย
                                              const BoxShadow(
                                                color: Colors.black87,
                                                offset: Offset(0, 5),
                                                blurRadius: 6,
                                              ),
                                            ],
                                    ),

                                    // 3. ใช้ LayoutBuilder และ Column ข้างในปุ่มตามสูตรเดิม เพื่อความปลอดภัย
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        return Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.music_note,
                                                color: isPlaying
                                                    ? Colors.black
                                                    : Colors.white70,
                                                size: 20,
                                              ),
                                              const SizedBox(height: 4),
                                              if (!isPlaying) ...[
                                                Text(
                                                  "${index + 1}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: isPlaying
                                                        ? Colors.black
                                                        : Colors.white,
                                                  ),
                                                ),
                                              ] else ...[
                                                const SizedBox(height: 2),
                                                GestureDetector(
                                                  onTap: () =>
                                                      audio.stopMusic(asset),
                                                  child: const Icon(
                                                    Icons.stop,
                                                    color: Colors.black,
                                                    size: 36,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  /// 🔒 LOCK OVERLAY (มุมขวาบน)
                                  if (panel.isLocked)
                                    const Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Icon(
                                        Icons.lock,
                                        size: 14,
                                        color: Colors.red,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

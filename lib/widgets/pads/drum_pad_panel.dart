import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rum_tap/features/drum_pad/models/pad_kits.dart';
import 'package:rum_tap/provider/audio_provider.dart';
import 'package:rum_tap/provider/panel_provider.dart';

class DrumPadPanel extends ConsumerStatefulWidget {
  const DrumPadPanel({super.key});

  @override
  ConsumerState<DrumPadPanel> createState() => _DrumPadPanelState();
}

class _DrumPadPanelState extends ConsumerState<DrumPadPanel> {
  @override
  Widget build(BuildContext context) {
    final audio = ref.read(audioControllerProvider.notifier);
    final panel = ref.watch(panelControllerProvider);

    print("LOCK STATE: ${panel.isLocked}");

    return DefaultTabController(
      length: PadKitsSfx.kits.length,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900], // เปลี่ยนจากสีแดงเป็นสีมิกเซอร์เข้มๆ เท่ๆ
          borderRadius: BorderRadius.circular(0),
          border: Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: Column(
          children: [
            /// 🎚 TAB BAR
            Container(
              decoration: BoxDecoration(
                color: Colors.black, // เปลี่ยนจากสีแดงเป็นสีมิกเซอร์เข้มๆ เท่ๆ
                borderRadius: BorderRadius.circular(0),
                border: Border.all(color: Colors.grey[900]!, width: 1),
              ),
              child: TabBar(
                tabs: PadKitsSfx.kits.map((e) => Tab(text: e.id)).toList(),
                indicatorColor: Colors.white,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                labelColor: Colors
                    .white, // สีของตัวอักษรบน Tab ที่ถูกเลือก (ให้ขาวชัดเจน 100%)
                unselectedLabelColor: Colors.white38,
              ),
            ),

            /// 🟧 PAD GRID
            Expanded(
              child: IgnorePointer(
                ignoring: panel.isLocked,
                child: TabBarView(
                  children: PadKitsSfx.kits.map((kit) {
                    // 1. ดึงชื่อแนวเพลง
                    final String kitName = kit.name;

                    // 2. ดึง List ของ Object เสียงออกมา
                    final List<AudioSample> pads = kit.audioSamples;

                    return Column(
                      children: [
                        SizedBox(height: 2),
                        Text(
                          kitName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(4),
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            alignment: WrapAlignment.center,
                            children: List.generate(pads.length, (index) {
                              final asset = pads[index];

                              /// ⭐ ใช้ watch แทน setState (สำคัญ)
                              final isPlaying = ref.watch(
                                audioControllerProvider.select(
                                  (s) => s.padPlaying[asset.path] ?? false,
                                ),
                              );

                              return SizedBox(
                                width: 75,
                                height: 75,
                                child: GestureDetector(
                                  onTap: () {
                                    audio.playPad(asset.path);
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
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),

                                          // 🔥 สีปุ่ม Rubber
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: isPlaying
                                                ? [
                                                    Colors
                                                        .orangeAccent
                                                        .shade400,
                                                    Colors.orange.shade700,
                                                    Colors.orange.shade900,
                                                  ]
                                                : [
                                                    Colors.grey.shade700,
                                                    Colors.grey.shade900,
                                                  ],
                                          ),

                                          border: Border.all(
                                            color: isPlaying
                                                ? Colors.orangeAccent
                                                : Colors.black,
                                            width: 1.4,
                                          ),

                                          boxShadow: isPlaying
                                              ? [
                                                  // 🌟 ไฟเรืองรอบ pad
                                                  BoxShadow(
                                                    color: Colors.orangeAccent
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

                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            return Padding(
                                              padding: const EdgeInsets.all(
                                                4.0,
                                              ),
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

                                                  Text(
                                                    textAlign: TextAlign.center,
                                                    asset.title.toString(),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 8,
                                                      color: isPlaying
                                                          ? Colors.black
                                                          : Colors.white,
                                                    ),
                                                  ),
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
                        ),
                      ],
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

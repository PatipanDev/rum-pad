import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rum_tap/core/audio/audio_manager.dart';
import 'package:rum_tap/features/drum_pad/models/pad_kits.dart';
import 'package:rum_tap/provider/audio_provider.dart';

class MusicPadPanel extends ConsumerStatefulWidget {
  const MusicPadPanel({super.key});

  @override
  ConsumerState<MusicPadPanel> createState() => _MusicPadPanelState();
}

class _MusicPadPanelState extends ConsumerState<MusicPadPanel> {
  @override
  Widget build(BuildContext context) {
    final audio = ref.read(audioControllerProvider.notifier);
    return DefaultTabController(
      length: PadKits.kits.keys.length,
      child: Column(
        children: [
          /// 🎚 TAB BAR (เลือกหมวดเพลง)
          Container(
            color: Colors.black12,
            child: TabBar(
              tabs: PadKits.kits.keys.map((e) => Tab(text: e)).toList(),
              indicatorColor: Colors.orange,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ),

          /// 🎵 MUSIC PAD GRID
          Flexible(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: PadKits.kits.keys.map((kitName) {
                final pads = PadKits.kits[kitName]!;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 4, // ระยะห่างระหว่างปุ่ม (แนวนอน)
                    runSpacing: 4, // ระยะห่างระหว่างปุ่ม (แนวตั้งเมื่อตกบรรทัด)
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
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isPlaying ? Colors.green : Colors.blueGrey,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: isPlaying
                                  ? [
                                      const BoxShadow(
                                        color: Colors.greenAccent,
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [],
                            ),

                            // 3. ใช้ LayoutBuilder และ Column ข้างในปุ่มตามสูตรเดิม เพื่อความปลอดภัย
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            "TRACK ${index + 1}", // ถ้าฝั่งเอฟเฟคอาจจะเปลี่ยนชื่อเป็น "SFX ${index + 1}"
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (isPlaying) ...[
                                        const SizedBox(height: 4),
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: IconButton(
                                              iconSize:
                                                  constraints.maxHeight * 0.4,
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              color: Colors.redAccent,
                                              icon: const Icon(
                                                Icons.stop_circle,
                                              ),
                                              onPressed: () async {
                                                audio.stopMusic(asset);
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

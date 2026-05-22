import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rum_tap/controllers/audio_controller.dart';
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
    final _audioWatch = ref.watch(audioControllerProvider);
    final panel = ref.watch(panelControllerProvider);
    return DefaultTabController(
      length: PadKitsMusic.kits.length,
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
                tabs: PadKitsMusic.kits.map((e) => Tab(text: e.id)).toList(),
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
                  children: PadKitsMusic.kits.map((kit) {
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 2,
                          ), // เว้นขอบหน้าจอซ้ายขวา
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              buildPlayPauseButton(audio),

                              const SizedBox(width: 12),

                              Expanded(child: buildMusicSlider(audio)),

                              const SizedBox(width: 12),

                              buildLoopButton(audio),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(4),

                          child: Wrap(
                            spacing: 4, // ระยะห่างระหว่างปุ่ม (แนวนอน)
                            runSpacing:
                                4, // ระยะห่างระหว่างปุ่ม (แนวตั้งเมื่อตกบรรทัด)
                            alignment: WrapAlignment
                                .center, // จัดให้ปุ่มเรียงจากซ้ายไปขวา
                            children: List.generate(pads.length, (index) {
                              final asset = pads[index];

                              // ดึงสถานะการเล่น (ฝั่งใครฝั่งมัน)
                              final isPlaying = ref.watch(
                                audioControllerProvider.select(
                                  (s) => s.padPlaying[asset.path] ?? false,
                                ),
                              ); // ถ้าฝั่งเอฟเฟคให้เปลี่ยนเป็น audio.isPadPlaying(asset)

                              // 2. ใช้ SizedBox ล็อกขนาดปุ่มตรงนี้ให้เท่ากันทั้ง 2 ไฟล์! 👇
                              return SizedBox(
                                width:
                                    75, // 👈 ตั้งขนาดที่อยากได้เลยครับ เช่น 75 พิกเซลเท่ากันทั้ง 2 แผง
                                height: 75, // 👈 ความสูง 75 พิกเซลเท่ากัน
                                child: GestureDetector(
                                  onTap: () {
                                    audio.playMusic(asset.path);
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
                                                  if (!isPlaying) ...[
                                                    Text(
                                                      textAlign:
                                                          TextAlign.center,
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
                                                  ] else ...[
                                                    const SizedBox(height: 2),
                                                    GestureDetector(
                                                      onTap: () =>
                                                          audio.stopMusic(
                                                            asset.path,
                                                          ),
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

Widget buildMusicSlider(AudioController audioController) {
  // 1. ประกาศตัวแปรเก็บสถานะไว้ในฟังก์ชันนี้ได้เลย
  bool isDragging = false;
  double dragValue = 0.0;

  return StreamBuilder<Duration?>(
    stream: audioController.durationStream,
    builder: (context, durationSnapshot) {
      final duration = durationSnapshot.data ?? Duration.zero;

      return StreamBuilder<Duration>(
        stream: audioController.positionStream,
        builder: (context, positionSnapshot) {
          var position = positionSnapshot.data ?? Duration.zero;
          if (position > duration) position = duration;

          // 2. ใช้ StatefulBuilder ครอบส่วนที่ต้องขยับตามนิ้วตอนลาก
          return StatefulBuilder(
            builder: (context, setLocalState) {
              // เช็กค่าตำแหน่งตุ่มเลื่อน
              double sliderValue = isDragging
                  ? dragValue
                  : position.inMilliseconds.toDouble();

              if (sliderValue > duration.inMilliseconds.toDouble()) {
                sliderValue = duration.inMilliseconds.toDouble();
              }

              return Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        activeTrackColor: Colors.amberAccent,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: Colors.amber,
                        overlayColor: Colors.amber.withAlpha(40),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6.0,
                          // activatedThumbRadius: 9.0, // แก้ตัวแปรตามรอบที่แล้วเรียบร้อย
                        ),
                        // materialTapTargetSize: MaterialTapTargetSize
                        //     .shrinkWrap, // บีบพื้นที่กดให้พอดีตัว
                        overlayShape: SliderComponentShape.noOverlay,
                      ),

                      child: Slider(
                        min: 0.0,
                        max: duration.inMilliseconds.toDouble(),
                        value: sliderValue,

                        // ⚡ เปลี่ยนจาก setState ทั่วไป เป็น setLocalState ของ StatefulBuilder
                        onChangeStart: (value) {
                          setLocalState(() {
                            isDragging = true;
                            dragValue = value;
                          });
                        },

                        onChanged: (value) {
                          setLocalState(() {
                            dragValue = value;
                          });
                        },

                        onChangeEnd: (value) async {
                          final seekTo = Duration(milliseconds: value.toInt());
                          await audioController.seekCurrentMusic(seekTo);

                          Future.delayed(const Duration(milliseconds: 200), () {
                            setLocalState(() {
                              isDragging = false;
                            });
                          });
                        },
                      ),
                    ),

                    // ตัวเลขเวลา ซ้าย-ขวา
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isDragging
                                ? _formatDuration(
                                    Duration(milliseconds: dragValue.toInt()),
                                  )
                                : _formatDuration(position),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          Text(
                            _formatDuration(duration),
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

// ฟังก์ชันเสริมสำหรับแปลงเวลาเป็นข้อความสวยๆ
String _formatDuration(Duration duration) {
  String minutes = duration.inMinutes.toString().padLeft(2, '0');
  String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

Widget buildPlayPauseButton(AudioController audio) {
  return StreamBuilder<bool>(
    stream: audio.isPlayingStream, // 🚰 ดักฟังว่าเพลงกำลังเล่นอยู่ไหม
    builder: (context, snapshot) {
      final isPlaying = snapshot.data ?? false;

      return GestureDetector(
        onTap: () {
          if (isPlaying) {
            audio.pauseMusic(); // ⏸️ พักเพลง
          } else {
            audio.resumeMusic(); // ▶️ เล่นต่อ
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32, // ขนาดปุ่มกำลังพอดีนิ้วสัมผัส
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // 🎨 ใส่เงาเรืองแสงรอบปุ่ม (Glow Effect) ถ้ากำลังเล่นอยู่ไฟจะสว่างขึ้น
            boxShadow: [
              BoxShadow(
                color: isPlaying
                    ? Colors.amber.withAlpha(80)
                    : Colors.black.withAlpha(60),
                blurRadius: isPlaying ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
            // 🌈 ไล่เฉดสีปุ่มให้ดูมีมิติเหมือนปุ่มกดจริงๆ
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isPlaying
                  ? [
                      Colors.amber.shade400,
                      Colors.amber.shade600,
                    ] // ตอนเล่น: สีเหลืองทองเด่นชัด
                  : [
                      Colors.grey.shade800,
                      Colors.grey.shade900,
                    ], // ตอนหยุด: โทนเข้มกลืนกับแผง
            ),
          ),
          // 🎬 ใส่แอนิเมชันตอนสลับรูปไอคอนไม่ให้มันตัดฉับเกินไป
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            // สลับไอคอนตามสถานะเพลง
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              key: ValueKey<bool>(
                isPlaying,
              ), // ใส่ Key เพื่อให้มีแอนิเมชันสลับไอคอน
              size: 24,
              color: isPlaying ? Colors.black : Colors.white,
            ),
          ),
        ),
      );
    },
  );
}

Widget buildLoopButton(AudioController audio) {
  return StreamBuilder<bool>(
    stream: audio.isLoopingStream, // 🚰 ฟังสถานะ Loop
    builder: (context, snapshot) {
      final isLooping = snapshot.data ?? false;

      return GestureDetector(
        onTap: () async {
          await audio.toggleLoop();
        },

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,

          decoration: BoxDecoration(
            shape: BoxShape.circle,

            boxShadow: [
              BoxShadow(
                color: isLooping
                    ? Colors.lightBlueAccent.withAlpha(80)
                    : Colors.black.withAlpha(60),
                blurRadius: isLooping ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],

            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,

              colors: isLooping
                  ? [Colors.lightBlue.shade300, Colors.blue.shade700]
                  : [Colors.grey.shade800, Colors.grey.shade900],
            ),
          ),

          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),

            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },

            child: Icon(
              Icons.repeat_rounded,
              key: ValueKey<bool>(isLooping),
              size: 24,
              color: isLooping ? Colors.white : Colors.white70,
            ),
          ),
        ),
      );
    },
  );
}

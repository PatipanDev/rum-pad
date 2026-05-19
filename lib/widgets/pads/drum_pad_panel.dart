import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rum_tap/features/drum_pad/models/pad_kits.dart';
import 'package:rum_tap/provider/audio_provider.dart';

class DrumPadPanel extends ConsumerStatefulWidget {
  const DrumPadPanel({super.key});

  @override
  ConsumerState<DrumPadPanel> createState() => _DrumPadPanelState();
}

class _DrumPadPanelState extends ConsumerState<DrumPadPanel> {
  @override
  Widget build(BuildContext context) {
    final audio = ref.read(audioControllerProvider.notifier);

    return DefaultTabController(
      length: PadKits.kits.keys.length,
      child: Column(
        children: [
          /// 🎚 TAB BAR
          Container(
            color: Colors.black12,
            child: TabBar(
              tabs: PadKits.kits.keys.map((e) => Tab(text: e)).toList(),
            ),
          ),

          /// 🟧 PAD GRID
          Expanded(
            child: TabBarView(
              children: PadKits.kits.keys.map((kitName) {
                final pads = PadKits.kits[kitName]!;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(pads.length, (index) {
                      final asset = pads[index];

                      /// ⭐ ใช้ watch แทน setState (สำคัญ)
                      final isPlaying = ref.watch(
                        audioControllerProvider.select(
                          (s) => s.padPlaying[asset] ?? false,
                        ),
                      );

                      return SizedBox(
                        width: 75,
                        height: 75,
                        child: GestureDetector(
                          onTap: () {
                            audio.playPad(asset);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                /// STOP BUTTON
                                if (isPlaying)
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    iconSize: 28,
                                    color: Colors.red,
                                    icon: const Icon(Icons.stop),
                                    onPressed: () {
                                      audio.stopPad(asset);
                                    },
                                  ),
                              ],
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

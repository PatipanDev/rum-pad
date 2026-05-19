import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rum_tap/core/audio/audio_manager.dart';
import 'package:rum_tap/features/drum_pad/models/pad_kits.dart';

class DrumPadPage extends StatefulWidget {
  const DrumPadPage({super.key});

  @override
  State<DrumPadPage> createState() => _DrumPadPageState();
}

class _DrumPadPageState extends State<DrumPadPage> {
  final audio = AudioManager();
  late final Timer _uiTimer;

  @override
  void initState() {
    super.initState();

    /// รีเฟรช UI ทุก 200ms
    _uiTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _uiTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: PadKits.kits.keys.length,
      child: Column(
        children: [
          /// 🎚 TAB BAR (เลือก kit)
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

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: pads.length,
                  itemBuilder: (context, index) {
                    final asset = pads[index];

                    return GestureDetector(
                      onTap: () async {
                        await audio.playPad(asset);
                        setState(() {}); // ⭐ refresh UI
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
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(width: 60),

                            /// ⏹ STOP ALL
                            if (audio.isPadPlaying(asset))
                              IconButton(
                                iconSize: 40,
                                color: Colors.red,
                                icon: const Icon(Icons.stop),
                                onPressed: () async {
                                  await audio.stopPad(asset);
                                  setState(() {});
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rum_tap/controllers/audio_controller.dart';
import 'package:rum_tap/core/audio/audio_manager.dart';
import 'package:rum_tap/provider/audio_provider.dart';
import 'package:rum_tap/provider/panel_provider.dart';
import 'package:rum_tap/state/panel_state.dart';
import 'package:rum_tap/widgets/mixer/fade_panel.dart';
import 'package:rum_tap/widgets/mixer/mixer_panel.dart';
import 'package:rum_tap/widgets/mixer/mixer_slider.dart';

class MixerAndFadePanel extends ConsumerWidget {
  const MixerAndFadePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panel = ref.watch(panelControllerProvider);
    final controller = ref.read(panelControllerProvider.notifier);

    return Scaffold(
      body: Column(
        children: [
          /// 🔝 TOP BAR (กินพื้นที่จริง)
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.black, // เปลี่ยนจากสีแดงเป็นสีมิกเซอร์เข้มๆ เท่ๆ
              borderRadius: BorderRadius.circular(0),
              border: Border.all(color: Colors.grey[900]!, width: 1),
            ),
            child: Row(
              children: [
                /// 🔘 switch button
                IconButton(
                  onPressed: controller.togglePanel,
                  icon: const Icon(Icons.swap_horiz),
                  style: IconButton.styleFrom(
                    // backgroundColor: Colors.white, // สีพื้นปุ่ม
                    foregroundColor: Colors.white, // สี icon
                  ),
                ),

                const SizedBox(width: 4),

                Text(
                  panel.currentPanel.name.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          /// 📦 MAIN CONTENT
          Expanded(
            child: panel.currentPanel == AppPanel.mixer
                ? const MixerPanel()
                : const FadePanel(),
          ),
        ],
      ),
    );
  }
}

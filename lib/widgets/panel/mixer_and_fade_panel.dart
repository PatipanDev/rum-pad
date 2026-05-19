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
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.black12,
            child: Row(
              children: [
                /// 🔘 switch button
                IconButton(
                  onPressed: controller.togglePanel,
                  icon: const Icon(Icons.swap_horiz),
                ),

                const SizedBox(width: 8),

                Text(
                  panel.currentPanel.name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
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

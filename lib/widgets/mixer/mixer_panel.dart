import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rum_tap/controllers/audio_controller.dart';
import 'package:rum_tap/core/audio/audio_manager.dart';
import 'package:rum_tap/l10n/app_localizations.dart';
import 'package:rum_tap/provider/audio_provider.dart';
import 'package:rum_tap/widgets/mixer/mixer_slider.dart';

class MixerPanel extends ConsumerWidget {
  const MixerPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioControllerProvider);
    final audio = ref.read(audioControllerProvider.notifier);
    final t = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900], // เปลี่ยนจากสีแดงเป็นสีมิกเซอร์เข้มๆ เท่ๆ
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          /// 🎵 MUSIC SLIDER
          MixerSlider(
            title: t.music,
            value: state.musicVolume,
            isMuted: state.musicMuted,
            onChanged: audio.setMusicVolume,
            onMuteToggled: audio.toggleMusicMute,
          ),

          MixerSlider(
            title: t.sfx,
            value: state.sfxVolume,
            isMuted: state.sfxMuted,
            onChanged: audio.setSfxVolume,
            onMuteToggled: audio.toggleSfxMute,
          ),

          /// 🔘 SWITCH BUTTON (TOP LEFT)
        ],
      ),
    );
  }
}

class AudioSample {
  final String title;
  final String path;
  // สามารถเพิ่มตัวแปรอื่นในอนาคตได้ เช่น final Color padColor;
  const AudioSample({required this.title, required this.path});
}

class KitModel {
  final String id;
  final String name;
  final List<AudioSample> audioSamples;

  const KitModel({
    required this.id,
    required this.name,
    required this.audioSamples,
  });
}

class PadKitsMusic {
  static const List<KitModel> kits = [
    KitModel(
      id: "1",
      name: "ALL",
      audioSamples: [
        // AudioSample(
        //   title: "Kick Drum",
        //   path: "assets/pad/sound_effect/drum.mp3",
        // ),
        // AudioSample(
        //   title: "Heavenly Pad",
        //   path: "assets/pad/sound_effect/heavenly.mp3",
        // ),
        // AudioSample(
        //   title: "Snare Drum",
        //   path: "assets/pad/sound_effect/drum.mp3",
        // ),
        AudioSample(
          title: "Beard",
          path: "assets/pad/sound/beard.mp3",
        ),
        AudioSample(
          title: "Jason Farnham Get Outside",
          path: "assets/pad/sound/jason_farnham_get_outside.mp3",
        ),
        AudioSample(
          title: "Lambada",
          path: "assets/pad/sound/lambada.mp3",
        ),
        AudioSample(
          title: "Melon",
          path: "assets/pad/sound/melon.mp3",
        ),
      ],
    ),

    KitModel(
      id: "2",
      name: "HIPHOP",
      audioSamples: [
        AudioSample(
          title: "Kick Drum",
          path: "assets/pad/sound_effect/drum.mp3",
        ),
        AudioSample(
          title: "Heavenly Pad",
          path: "assets/pad/sound_effect/heavenly.mp3",
        ),
        AudioSample(
          title: "Snare Drum",
          path: "assets/pad/sound_effect/drum.mp3",
        ),
      ],
    ),
  ];
}


class PadKitsSfx {
  static const List<KitModel> kits = [
    KitModel(
      id: "1",
      name: "ALL",
      audioSamples: [
        AudioSample(
          title: "Kick Drum",
          path: "assets/pad/sound_effect/drum.mp3",
        ),
        AudioSample(
          title: "Heavenly Pad",
          path: "assets/pad/sound_effect/heavenly.mp3",
        ),
        AudioSample(
          title: "Snare Drum",
          path: "assets/pad/sound_effect/drum.mp3",
        ),
        // AudioSample(
        //   title: "Beard",
        //   path: "assets/pad/sound/beard.mp3",
        // ),
        // AudioSample(
        //   title: "Jason Farnham Get Outside",
        //   path: "assets/pad/sound/jason_farnham_get_outside.mp3",
        // ),
        // AudioSample(
        //   title: "Lambada",
        //   path: "assets/pad/sound/lambada.mp3",
        // ),
        // AudioSample(
        //   title: "Melon",
        //   path: "assets/pad/sound/melon.mp3",
        // ),
      ],
    ),

    KitModel(
      id: "2",
      name: "HIPHOP",
      audioSamples: [
        AudioSample(
          title: "Kick Drum",
          path: "assets/pad/sound_effect/drum.mp3",
        ),
        AudioSample(
          title: "Heavenly Pad",
          path: "assets/pad/sound_effect/heavenly.mp3",
        ),
        AudioSample(
          title: "Snare Drum",
          path: "assets/pad/sound_effect/drum.mp3",
        ),
      ],
    ),
  ];
}

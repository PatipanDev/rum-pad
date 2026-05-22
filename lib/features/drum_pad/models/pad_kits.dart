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
        AudioSample(title: "Beard", path: "assets/pad/sound/beard.mp3"),
        AudioSample(
          title: "Jason Farnham Get Outside",
          path: "assets/pad/sound/jason_farnham_get_outside.mp3",
        ),
        AudioSample(title: "Lambada", path: "assets/pad/sound/lambada.mp3"),
        AudioSample(title: "Melon", path: "assets/pad/sound/melon.mp3"),
        AudioSample(
          title: "On The Dance Floor",
          path: "assets/pad/sound/on_the_dance_floor.mp3",
        ),
        AudioSample(
          title: "Two Steps From Hell Victory",
          path: "assets/pad/sound/two_steps_from_hell_victory.mp3",
        ),
        AudioSample(
          title: "CEO Reveal Sound",
          path: "assets/pad/sound/ceo_reveal_sound.mp3",
        ),
        AudioSample(title: "Scare", path: "assets/pad/sound/scare.mp3"),
        AudioSample(
          title: "Opening Ceremony 1",
          path: "assets/pad/sound/opening_ceremony_1.mp3",
        ),
        AudioSample(
          title: "Award giving 1",
          path: "assets/pad/sound/award_giving_1.mp3",
        ),
        AudioSample(
          title: "Award giving 2",
          path: "assets/pad/sound/award_giving_2.mp3",
        ),
      ],
    ),

    KitModel(
      id: "2",
      name: "Opening ceremony",
      audioSamples: [
        AudioSample(
          title: "Opening Ceremony 1",
          path: "assets/pad/sound/opening_ceremony_1.mp3",
        ),
      ],
    ),
    KitModel(
      id: "3",
      name: "Award giving",
      audioSamples: [
        AudioSample(
          title: "Award giving 1",
          path: "assets/pad/sound/award_giving_1.mp3",
        ),
        AudioSample(
          title: "Award giving 2",
          path: "assets/pad/sound/award_giving_2.mp3",
        ),
      ],
    ),
    KitModel(
      id: "4",
      name: "Fast",
      audioSamples: [
        AudioSample(title: "Melon", path: "assets/pad/sound/melon.mp3"),
        AudioSample(
          title: "On The Dance Floor",
          path: "assets/pad/sound/on_the_dance_floor.mp3",
        ),
        AudioSample(
          title: "Step Nara",
          path: "assets/pad/sound/step_nara.mp3",
        ),
        AudioSample(
          title: "Rock Gun Tud",
          path: "assets/pad/sound/rock_gun_tud.mp3",
        ),
        AudioSample(
          title: "Don T One",
          path: "assets/pad/sound/don_t_one.mp3",
        ),
      ],
    ),
    KitModel(
      id: "5",
      name: "Another",
      audioSamples: [
        AudioSample(title: "Scare", path: "assets/pad/sound/scare.mp3"),
        AudioSample(title: "Beard", path: "assets/pad/sound/beard.mp3"),
        AudioSample(
          title: "Jason Farnham Get Outside",
          path: "assets/pad/sound/jason_farnham_get_outside.mp3",
        ),
        AudioSample(title: "Lambada", path: "assets/pad/sound/lambada.mp3"),
        AudioSample(title: "Melon", path: "assets/pad/sound/melon.mp3"),
        AudioSample(
          title: "On The Dance Floor",
          path: "assets/pad/sound/on_the_dance_floor.mp3",
        ),
        AudioSample(
          title: "Two Steps From Hell Victory",
          path: "assets/pad/sound/two_steps_from_hell_victory.mp3",
        ),
        AudioSample(
          title: "CEO Reveal Sound",
          path: "assets/pad/sound/ceo_reveal_sound.mp3",
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
          title: "Hitwang",
          path: "assets/pad/sound_effect/hitwang.mp3",
        ),
        AudioSample(
          title: "Ba dum tss",
          path: "assets/pad/sound_effect/ba_dum_tss.mp3",
        ),
        AudioSample(
          title: "Badam bam",
          path: "assets/pad/sound_effect/badam_bam.mp3",
        ),
        AudioSample(
          title: "Tumg Cham",
          path: "assets/pad/sound_effect/tumg_cham.mp3",
        ),
        AudioSample(
          title: "Tung da",
          path: "assets/pad/sound_effect/tung_da.mp3",
        ),
        AudioSample(title: "Right", path: "assets/pad/sound_effect/right.mp3"),
        AudioSample(title: "Gun", path: "assets/pad/sound_effect/gun.mp3"),
        AudioSample(
          title: "Gun Big",
          path: "assets/pad/sound_effect/gun_big.mp3",
        ),
        AudioSample(
          title: "Gun gun gun",
          path: "assets/pad/sound_effect/gungungun.mp3",
        ),
        AudioSample(
          title: "Laugh",
          path:
              "assets/pad/sound_effect/artificiallyinspired_90s_sitcom_laugh.mp3",
        ),
        AudioSample(
          title: "Dog Howl",
          path: "assets/pad/sound_effect/dog_howl.mp3",
        ),
      ],
    ),

    KitModel(
      id: "2",
      name: "Rimshot",
      audioSamples: [
        AudioSample(
          title: "Kick Drum",
          path: "assets/pad/sound_effect/drum.mp3",
        ),
        AudioSample(
          title: "Hitwang",
          path: "assets/pad/sound_effect/hitwang.mp3",
        ),
        AudioSample(
          title: "Ba dum tss",
          path: "assets/pad/sound_effect/ba_dum_tss.mp3",
        ),
        AudioSample(
          title: "Badam bam",
          path: "assets/pad/sound_effect/badam_bam.mp3",
        ),
        AudioSample(
          title: "Tumg Cham",
          path: "assets/pad/sound_effect/tumg_cham.mp3",
        ),
        AudioSample(
          title: "Tung da",
          path: "assets/pad/sound_effect/tung_da.mp3",
        ),
        AudioSample(title: "Right", path: "assets/pad/sound_effect/right.mp3"),
      ],
    ),

    KitModel(
      id: "3",
      name: "fight",
      audioSamples: [
        AudioSample(title: "Gun", path: "assets/pad/sound_effect/gun.mp3"),
        AudioSample(
          title: "Gun Big",
          path: "assets/pad/sound_effect/gun_big.mp3",
        ),
        AudioSample(
          title: "Gun gun gun",
          path: "assets/pad/sound_effect/gungungun.mp3",
        ),
      ],
    ),

    KitModel(
      id: "4",
      name: "Another",
      audioSamples: [
        AudioSample(
          title: "Laugh",
          path:
              "assets/pad/sound_effect/artificiallyinspired_90s_sitcom_laugh.mp3",
        ),
        AudioSample(
          title: "Dog Howl",
          path: "assets/pad/sound_effect/dog_howl.mp3",
        ),
      ],
    ),
  ];
}
